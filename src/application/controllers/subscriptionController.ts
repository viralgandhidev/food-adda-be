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
      '/start',
      this.auth.authenticate,
      asyncHandler(this.startRecurring.bind(this)),
    );
    this.router.post(
      '/verify',
      this.auth.authenticate,
      asyncHandler(this.verify.bind(this)),
    );
    this.router.post(
      '/authorize/verify',
      this.auth.authenticate,
      asyncHandler(this.verifyAuthorization.bind(this)),
    );
    this.router.get(
      '/me',
      this.auth.authenticate,
      asyncHandler(this.me.bind(this)),
    );
    // Razorpay webhook (no auth), verify via signature
    this.router.post('/webhook', asyncHandler(this.webhook.bind(this)));
  }

  private async ensureApproved(
    userId: string | number,
  ): Promise<'NEED_FORM' | 'NEED_APPROVAL' | 'OK'> {
    const conn = await this.db.getConnection();
    try {
      const [rows] = await conn.execute(
        `SELECT status FROM form_submissions
         WHERE user_id = ? AND form_type IN ('B2B','B2C','HORECA')
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

    // Enforce single active/pending subscription per user
    {
      const conn = await this.db.getConnection();
      try {
        const [rows] = await conn.execute(
          `SELECT id, plan_code, status, created_at
           FROM subscriptions
           WHERE user_id = ? AND status IN ('ACTIVE','PENDING_PAYMENT')
           ORDER BY created_at DESC
           LIMIT 1`,
          [userId],
        );
        const existing = (rows as any[])[0];
        if (existing) {
          return res.status(409).json({
            success: false,
            code: 'ALREADY_SUBSCRIBED',
            data: existing,
          });
        }
      } finally {
        conn.release();
      }
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

  // Create a Razorpay recurring subscription (monthly)
  private async startRecurring(req: Request, res: Response) {
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
    // Single active/pending check
    {
      const conn = await this.db.getConnection();
      try {
        const [rows] = await conn.execute(
          `SELECT id, plan_code, status FROM subscriptions
           WHERE user_id = ? AND status IN ('ACTIVE','PENDING_PAYMENT')
           ORDER BY created_at DESC LIMIT 1`,
          [userId],
        );
        if ((rows as any[])[0]) {
          return res
            .status(409)
            .json({success: false, code: 'ALREADY_SUBSCRIBED'});
        }
      } finally {
        conn.release();
      }
    }
    const approval = await this.ensureApproved(userId);
    if (approval !== 'OK') {
      return res.status(approval === 'NEED_FORM' ? 409 : 403).json({
        success: false,
        code: approval === 'NEED_FORM' ? 'FORM_REQUIRED' : 'APPROVAL_REQUIRED',
      });
    }

    // Map plan code to Razorpay plan ID
    const planId =
      plan.code === 'SILVER'
        ? config.razorpay.silverPlanId
        : config.razorpay.goldPlanId;
    if (!planId) {
      return res
        .status(500)
        .json({success: false, message: 'Plan not configured'});
    }

    const authHeader =
      'Basic ' +
      Buffer.from(
        `${config.razorpay.keyId}:${config.razorpay.keySecret}`,
      ).toString('base64');

    // Create subscription for monthly billing; set total_count to 12 by default
    const createPayload = {
      plan_id: planId,
      customer_notify: 1,
      total_count: 12,
      notes: {user_id: String(userId), plan_code: plan.code},
    };
    const resp = await fetch('https://api.razorpay.com/v1/subscriptions', {
      method: 'POST',
      headers: {'Content-Type': 'application/json', Authorization: authHeader},
      body: JSON.stringify(createPayload),
    });
    if (!resp.ok) {
      const text = await resp.text();
      this.logger.error('Razorpay subscription create failed', {
        status: resp.status,
        body: text,
      });
      return res
        .status(502)
        .json({success: false, message: 'Payment gateway error'});
    }
    const sub = await resp.json();

    // Persist local record with PENDING_PAYMENT until authorization
    const conn = await this.db.getConnection();
    try {
      await conn.execute(
        `INSERT INTO subscriptions (user_id, plan_code, plan_label, amount_paise, currency, status,
          razorpay_subscription_id, total_count, paid_count)
         VALUES (?,?,?,?,?,'PENDING_PAYMENT',?,?,0)`,
        [
          userId,
          plan.code,
          plan.label,
          plan.amountPaise,
          'INR',
          sub.id,
          sub.total_count ?? 12,
        ],
      );
    } finally {
      conn.release();
    }

    return res.json({
      success: true,
      data: {subscription: sub, keyId: config.razorpay.keyId},
    });
  }

  // Verify first authorization payment signature for subscription
  private async verifyAuthorization(req: Request, res: Response) {
    const userId = (req as any).user?.id as string | number;
    const {razorpay_payment_id, razorpay_subscription_id, razorpay_signature} =
      req.body || {};
    if (
      !razorpay_payment_id ||
      !razorpay_subscription_id ||
      !razorpay_signature
    ) {
      return res.status(400).json({success: false, message: 'Missing fields'});
    }
    const payload = `${razorpay_payment_id}|${razorpay_subscription_id}`;
    const expected = crypto
      .createHmac('sha256', config.razorpay.keySecret)
      .update(payload)
      .digest('hex');
    if (expected !== razorpay_signature) {
      return res
        .status(400)
        .json({success: false, message: 'Signature mismatch'});
    }

    const conn = await this.db.getConnection();
    try {
      await conn.execute(
        `UPDATE subscriptions
         SET status = 'ACTIVE', auth_payment_id = ?, updated_at = NOW()
         WHERE user_id = ? AND razorpay_subscription_id = ?`,
        [razorpay_payment_id, userId, razorpay_subscription_id],
      );
    } finally {
      conn.release();
    }
    return res.json({success: true});
  }

  // Razorpay webhook handler
  private async webhook(req: Request, res: Response) {
    const signature = req.header('x-razorpay-signature') || '';
    const body = JSON.stringify(req.body || {});
    const expected = crypto
      .createHmac('sha256', config.razorpay.webhookSecret)
      .update(body)
      .digest('hex');
    if (!config.razorpay.webhookSecret || signature !== expected) {
      return res.status(401).json({success: false});
    }

    const event = req.body?.event;
    const payload = req.body?.payload || {};

    const conn = await this.db.getConnection();
    try {
      if (event === 'subscription.activated') {
        const subId = payload?.subscription?.entity?.id;
        await conn.execute(
          `UPDATE subscriptions SET status='ACTIVE', updated_at=NOW() WHERE razorpay_subscription_id = ?`,
          [subId],
        );
      } else if (event === 'subscription.charged' || event === 'invoice.paid') {
        const subId =
          payload?.subscription?.entity?.id ||
          payload?.invoice?.entity?.subscription_id;
        const periodStart = payload?.subscription?.entity?.current_start
          ? new Date(payload.subscription.entity.current_start * 1000)
          : null;
        const periodEnd = payload?.subscription?.entity?.current_end
          ? new Date(payload.subscription.entity.current_end * 1000)
          : null;
        await conn.execute(
          `UPDATE subscriptions
           SET paid_count = paid_count + 1,
               current_period_start = COALESCE(?, current_period_start),
               current_period_end = COALESCE(?, current_period_end),
               updated_at = NOW()
           WHERE razorpay_subscription_id = ?`,
          [periodStart, periodEnd, subId],
        );
      } else if (event === 'subscription.cancelled') {
        const subId = payload?.subscription?.entity?.id;
        await conn.execute(
          `UPDATE subscriptions SET status='CANCELLED', updated_at=NOW() WHERE razorpay_subscription_id = ?`,
          [subId],
        );
      } else if (event === 'payment.failed') {
        // Optional: mark as past due/failed
      }
    } finally {
      conn.release();
    }

    return res.json({success: true});
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
      const rec = (rows as any[])[0] || null;
      res.json({success: true, data: rec});
    } finally {
      conn.release();
    }
  }

  public getRouter(): Router {
    return this.router;
  }
}
