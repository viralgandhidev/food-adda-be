import {Request, Response, Router} from 'express';
import {inject, injectable} from 'inversify';
import {TYPES} from '../di/types';
import {Logger} from '../utils/logger';
import {DatabaseController} from '../utils/databaseController';
import {asyncHandler} from '../utils/asyncHandler';
import multer from 'multer';
import path from 'path';
import fs from 'fs';
import {AuthMiddleware} from '../middleware/authenticate';
import nodemailer from 'nodemailer';
import config from '../config';

@injectable()
export class FormController {
  private router: Router;

  constructor(
    @inject(TYPES.Logger) private logger: Logger,
    @inject(TYPES.DatabaseController) private db: DatabaseController,
    @inject(TYPES.AuthMiddleware) private auth: AuthMiddleware,
  ) {
    this.router = Router();
    this.initializeRoutes();
  }

  private initializeRoutes() {
    const storage = multer.diskStorage({
      destination: (req, file, cb) => {
        const dest = path.join(process.cwd(), 'uploads', 'forms');
        fs.mkdirSync(dest, {recursive: true});
        cb(null, dest);
      },
      filename: (req, file, cb) => {
        const unique = `${Date.now()}-${Math.round(Math.random() * 1e9)}`;
        cb(null, `${unique}-${file.originalname}`);
      },
    });
    const upload = multer({storage});
    // Accept many files from various fields
    this.router.post(
      '/submit',
      this.auth.optionalAuthenticate,
      upload.any(),
      asyncHandler(this.submit.bind(this)),
    );

    // List submissions
    this.router.get('/list', asyncHandler(this.list.bind(this)));

    // Latest submission status for current user
    this.router.get(
      '/my-status',
      this.auth.authenticate,
      asyncHandler(this.myStatus.bind(this)),
    );

    // Contact form (phone number submission)
    this.router.post(
      '/contact',
      asyncHandler(this.contact.bind(this)),
    );
  }

  private async submit(req: Request, res: Response) {
    const {form_type, contact_name, contact_email, contact_phone} =
      req.body || {};
    // payload for multipart will be everything except known fields
    const raw = {...(req.body || {})};
    delete raw.form_type;
    delete raw.contact_name;
    delete raw.contact_email;
    delete raw.contact_phone;
    const payload = raw;
    if (!form_type || !payload) {
      return res
        .status(400)
        .json({success: false, message: 'form_type and payload are required'});
    }
    const connection = await this.db.getConnection();
    try {
      const userId = (req as any).user?.id || null;
      const [result]: any = await connection.execute(
        'INSERT INTO form_submissions (form_type, contact_name, contact_email, contact_phone, user_id, payload, status) VALUES (?,?,?,?,?,?,?)',
        [
          form_type,
          contact_name || null,
          contact_email || null,
          contact_phone || null,
          userId,
          JSON.stringify(payload),
          'APPROVED',
        ],
      );
      const submissionId = result.insertId as number;
      const files = (req as any).files as any[] | undefined;
      if (files && files.length) {
        const values = files.map(f => [
          submissionId,
          f.fieldname,
          path.relative(process.cwd(), f.path).replace(/\\/g, '/'),
          f.originalname,
          f.mimetype,
          f.size,
        ]);
        await connection.query(
          'INSERT INTO form_submission_files (submission_id, field_name, file_path, original_name, mime_type, size) VALUES ?',
          [values],
        );
      }
      res.status(201).json({success: true});
    } catch (e) {
      this.logger.error('Error saving form submission', e);
      res.status(500).json({success: false, message: 'Failed to submit form'});
    } finally {
      connection.release();
    }
  }

  public getRouter(): Router {
    return this.router;
  }

  private async list(req: Request, res: Response) {
    const formType = (req.query.form_type as string) || '';
    const page = parseInt((req.query.page as string) || '1', 10);
    const limit = Math.min(
      50,
      parseInt((req.query.limit as string) || '12', 10),
    );
    const offset = (page - 1) * limit;

    if (!formType) {
      return res
        .status(400)
        .json({success: false, message: 'form_type is required'});
    }

    const connection = await this.db.getConnection();
    try {
      // Some MySQL setups complain about binding LIMIT/OFFSET, so inline them safely
      const [rows] = await connection.query(
        `SELECT * FROM form_submissions WHERE form_type = ? ORDER BY created_at DESC LIMIT ${limit} OFFSET ${offset}`,
        [formType],
      );
      const [countRows] = await connection.execute(
        'SELECT COUNT(*) as total FROM form_submissions WHERE form_type = ?',
        [formType],
      );
      const total = (countRows as any[])[0].total as number;
      const submissions = rows as any[];

      if (submissions.length) {
        const ids = submissions.map(s => s.id);
        const placeholders = ids.map(() => '?').join(',');
        const [fileRows] = await connection.query(
          `SELECT * FROM form_submission_files WHERE submission_id IN (${placeholders})`,
          ids,
        );
        const bySubmission: Record<number, any[]> = {};
        (fileRows as any[]).forEach(f => {
          if (!bySubmission[f.submission_id])
            bySubmission[f.submission_id] = [];
          bySubmission[f.submission_id].push({
            id: f.id,
            field_name: f.field_name,
            file_path: f.file_path,
            original_name: f.original_name,
            mime_type: f.mime_type,
            size: f.size,
          });
        });
        submissions.forEach(s => (s.files = bySubmission[s.id] || []));
      }

      res.json({
        success: true,
        data: submissions,
        meta: {total, page, limit, totalPages: Math.ceil(total / limit)},
      });
    } finally {
      connection.release();
    }
  }

  private async myStatus(req: Request, res: Response) {
    const userId = (req as any).user?.id as string | number | undefined;
    if (!userId) {
      return res.status(401).json({success: false});
    }
    const connection = await this.db.getConnection();
    try {
      const [rows] = await connection.execute(
        `SELECT id, form_type, status, created_at
         FROM form_submissions
         WHERE user_id = ? AND form_type IN ('B2B','B2C','HORECA')
         ORDER BY created_at DESC
         LIMIT 1`,
        [userId],
      );
      const latest = (rows as any[])[0] || null;
      res.json({success: true, data: latest});
    } finally {
      connection.release();
    }
  }

  private async contact(req: Request, res: Response) {
    const {phone} = req.body || {};
    if (!phone || !phone.trim()) {
      return res
        .status(400)
        .json({success: false, message: 'Phone number is required'});
    }

    try {
      // Create email transporter
      const transporter = nodemailer.createTransport({
        host: config.email.host,
        port: config.email.port,
        secure: config.email.secure,
        auth: {
          user: config.email.user,
          pass: config.email.password,
        },
      });

      // Send email
      await transporter.sendMail({
        from: config.email.user,
        to: config.email.to,
        subject: 'New Contact Request - FoodAdda',
        html: `
          <h2>New Contact Request</h2>
          <p><strong>Phone Number:</strong> ${phone}</p>
          <p><strong>Submitted At:</strong> ${new Date().toLocaleString()}</p>
        `,
        text: `New Contact Request\n\nPhone Number: ${phone}\nSubmitted At: ${new Date().toLocaleString()}`,
      });

      this.logger.info(`Contact form submitted: ${phone}`);
      res.status(200).json({success: true, message: 'Contact request submitted successfully'});
    } catch (error) {
      this.logger.error('Error sending contact email', error);
      res.status(500).json({success: false, message: 'Failed to submit contact request'});
    }
  }
}
