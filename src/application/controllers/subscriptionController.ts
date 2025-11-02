import {Request, Response, Router} from 'express';
import {inject, injectable} from 'inversify';
import {TYPES} from '../di/types';
import {Logger} from '../utils/logger';
import {DatabaseController} from '../utils/databaseController';
import {AuthMiddleware} from '../middleware/authenticate';
import {asyncHandler} from '../utils/asyncHandler';
import config from '../config';
import crypto from 'crypto';

type Plan = {
  code: 'SILVER' | 'GOLD';
  label: string;
  amountPaise: number;
};

const PLANS: Record<string, Plan> = {
  SILVER: {code: 'SILVER', label: 'Silver', amountPaise: 5900 * 100},
  GOLD: {code: 'GOLD', label: 'Gold', amountPaise: 10620 * 100},
};

@injectable()
export class SubscriptionController {
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
    this.router.post(
      '/checkout',
      this.auth.authenticate,
      asyncHandler(this.checkout.bind(this)),
    );
    this.router.post(
      '/verify',
      this.auth.authenticate,
      asyncHandler(this.verify.bind(this)),
    );
    this.router.get(
      '/me',
      this.auth.authenticate,
      asyncHandler(this.me.bind(this)),
    );
  }

  private async ensureApproved(
    userId: string | number,
  ): Promise<'NEED_FORM' | 'NEED_APPROVAL' | 'OK'> {
    const conn = await this.db.getConnection();
    try {
      const [rows] = await conn.execute(
        `SELECT status FROM form_submissions
         WHERE user_id = ? AND form_type IN ('B2B','B2C')
         ORDER BY created_at DESC LIMIT 1`,
        [userId],
      );
      const rec = (rows as any[])[0];
      if (!rec) return 'NEED_FORM';
      if (rec.status !== 'APPROVED') return 'NEED_APPROVAL';
      return 'OK';
    } finally {
      conn.release();
    }
  }

  private async checkout(req: Request, res: Response) {
    const userId = (req as any).user?.id as string | number;
    const planCode = String((req.body?.plan || '').toUpperCase());
    const plan = PLANS[planCode];
    if (!plan) {
      return res.status(400).json({success: false, message: 'Invalid plan'});
    }

    if (!config.razorpay.keyId || !config.razorpay.keySecret) {
      this.logger.error('Razorpay keys missing in environment');
      return res
        .status(500)
        .json({success: false, message: 'Payment is not configured'});
    }

    const approval = await this.ensureApproved(userId);
    if (approval === 'NEED_FORM') {
      return res.status(409).json({success: false, code: 'FORM_REQUIRED'});
    }
    if (approval === 'NEED_APPROVAL') {
      return res.status(403).json({success: false, code: 'APPROVAL_REQUIRED'});
    }

    // Razorpay receipt must be <= 40 chars. Use compact format.
    const shortUser = String(userId)
      .replace(/[^a-zA-Z0-9]/g, '')
      .slice(-10);
    const ts = Date.now().toString(36);
    const receipt = `sub_${shortUser}_${ts}`.slice(0, 40);
    const orderPayload = {
      amount: plan.amountPaise,
      currency: 'INR',
      receipt,
      notes: {user_id: String(userId), plan_code: plan.code},
    } as const;

    const authHeader =
      'Basic ' +
      Buffer.from(
        `${config.razorpay.keyId}:${config.razorpay.keySecret}`,
      ).toString('base64');

    const resp = await fetch('https://api.razorpay.com/v1/orders', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: authHeader,
      },
      body: JSON.stringify(orderPayload),
    });
    if (!resp.ok) {
      const text = await resp.text();
      this.logger.error('Razorpay order creation failed', {
        status: resp.status,
        body: text,
      });
      return res.status(502).json({
        success: false,
        message: 'Payment gateway error',
        data: {status: resp.status},
      });
    }
    const order = await resp.json();

    const conn = await this.db.getConnection();
    try {
      await conn.execute(
        `INSERT INTO subscriptions (user_id, plan_code, plan_label, amount_paise, currency, status, razorpay_order_id, receipt)
         VALUES (?,?,?,?,?,'PENDING_PAYMENT',?,?)`,
        [
          userId,
          plan.code,
          plan.label,
          plan.amountPaise,
          'INR',
          order.id,
          receipt,
        ],
      );
    } finally {
      conn.release();
    }

    res.json({success: true, data: {order, keyId: config.razorpay.keyId}});
  }

  private async verify(req: Request, res: Response) {
    const userId = (req as any).user?.id as string | number;
    const {razorpay_order_id, razorpay_payment_id, razorpay_signature} =
      req.body || {};
    if (!razorpay_order_id || !razorpay_payment_id || !razorpay_signature) {
      return res.status(400).json({success: false, message: 'Missing fields'});
    }

    const payload = `${razorpay_order_id}|${razorpay_payment_id}`;
    const expected = crypto
      .createHmac('sha256', config.razorpay.keySecret)
      .update(payload)
      .digest('hex');
    const valid = expected === razorpay_signature;
    const status = valid ? 'ACTIVE' : 'FAILED';

    const conn = await this.db.getConnection();
    try {
      await conn.execute(
        `UPDATE subscriptions
         SET status = ?, razorpay_payment_id = ?, razorpay_signature = ?, updated_at = NOW()
         WHERE razorpay_order_id = ? AND user_id = ?`,
        [
          status,
          razorpay_payment_id,
          razorpay_signature,
          razorpay_order_id,
          userId,
        ],
      );
    } finally {
      conn.release();
    }

    if (!valid) {
      return res
        .status(400)
        .json({success: false, message: 'Signature mismatch'});
    }

    return res.json({success: true});
  }

  private async me(req: Request, res: Response) {
    const userId = (req as any).user?.id as string | number;
    const conn = await this.db.getConnection();
    try {
      const [rows] = await conn.execute(
        `SELECT * FROM subscriptions WHERE user_id = ? ORDER BY created_at DESC LIMIT 1`,
        [userId],
      );
      res.json({success: true, data: (rows as any[])[0] || null});
    } finally {
      conn.release();
    }
  }

  public getRouter(): Router {
    return this.router;
  }
}
