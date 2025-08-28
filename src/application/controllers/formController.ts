import {Request, Response, Router} from 'express';
import {inject, injectable} from 'inversify';
import {TYPES} from '../di/types';
import {Logger} from '../utils/logger';
import {DatabaseController} from '../utils/databaseController';
import {asyncHandler} from '../utils/asyncHandler';
import multer from 'multer';
import path from 'path';
import fs from 'fs';

@injectable()
export class FormController {
  private router: Router;

  constructor(
    @inject(TYPES.Logger) private logger: Logger,
    @inject(TYPES.DatabaseController) private db: DatabaseController,
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
      upload.any(),
      asyncHandler(this.submit.bind(this)),
    );

    // List submissions
    this.router.get('/list', asyncHandler(this.list.bind(this)));
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
      const [result]: any = await connection.execute(
        'INSERT INTO form_submissions (form_type, contact_name, contact_email, contact_phone, payload) VALUES (?,?,?,?,?)',
        [
          form_type,
          contact_name || null,
          contact_email || null,
          contact_phone || null,
          JSON.stringify(payload),
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
}
