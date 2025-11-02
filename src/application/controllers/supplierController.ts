import {Request, Response, Router} from 'express';
import {inject, injectable} from 'inversify';
import {TYPES} from '../di/types';
import {UserRepository} from '../../domain/repositories/userRepository';
import {ProductRepository} from '../../domain/repositories/productRepository';
import {Logger} from '../utils/logger';
import {AuthMiddleware} from '../middleware/authenticate';
import {UserType} from '../../domain/entities/user';
import {asyncHandler} from '../utils/asyncHandler';
import {DatabaseController} from '../utils/databaseController';

@injectable()
export class SupplierController {
  private router: Router;

  constructor(
    @inject(TYPES.UserRepository) private userRepository: UserRepository,
    @inject(TYPES.ProductRepository)
    private productRepository: ProductRepository,
    @inject(TYPES.Logger) private logger: Logger,
    @inject(TYPES.AuthMiddleware) private authMiddleware: AuthMiddleware,
    @inject(TYPES.DatabaseController) private db: DatabaseController,
  ) {
    this.router = Router();
    this.initializeRoutes();
  }

  private initializeRoutes(): void {
    // Public supplier endpoints
    this.router.get(
      '/:supplierId',
      this.authMiddleware.optionalAuthenticate,
      asyncHandler(this.getSupplierDetails.bind(this)),
    );
    // Authenticated actions
    this.router.post(
      '/:supplierId/save',
      this.authMiddleware.authenticate,
      asyncHandler(this.saveSupplier.bind(this)),
    );
    this.router.delete(
      '/:supplierId/save',
      this.authMiddleware.authenticate,
      asyncHandler(this.unsaveSupplier.bind(this)),
    );
    this.router.get(
      '/saved/list/all',
      this.authMiddleware.authenticate,
      asyncHandler(async (req, res) => {
        const userId = (req as any).user?.id as string;
        const connection = await this.db.getConnection();
        try {
          const [rows] = await connection.execute(
            `SELECT u.id, u.first_name, u.last_name, u.company_name, u.company_description, u.profile_image_url
             FROM saved_suppliers ss
             JOIN users u ON ss.supplier_id = u.id
             WHERE ss.user_id = ?
             ORDER BY ss.saved_at DESC`,
            [userId],
          );
          res.json({success: true, data: rows});
        } finally {
          connection.release();
        }
      }),
    );
    this.router.get(
      '/:supplierId/saved',
      this.authMiddleware.authenticate,
      asyncHandler(async (req, res) => {
        const userId = (req as any).user?.id as string;
        const supplierId = req.params.supplierId;
        const connection = await this.db.getConnection();
        try {
          const [rows] = await connection.execute(
            'SELECT 1 FROM saved_suppliers WHERE user_id = ? AND supplier_id = ? LIMIT 1',
            [userId, supplierId],
          );
          const saved = (rows as any[]).length > 0;
          res.json({success: true, data: {saved}});
        } finally {
          connection.release();
        }
      }),
    );
    this.router.get(
      '/:supplierId/metrics',
      // Keep public, metrics don't require auth
      asyncHandler(this.getSupplierMetrics.bind(this)),
    );
    this.router.get(
      '/:supplierId/products',
      this.authMiddleware.optionalAuthenticate,
      // Public products for supplier
      asyncHandler(this.getSupplierProducts.bind(this)),
    );
  }

  private async getActivePlanCode(
    userId?: string,
  ): Promise<'SILVER' | 'GOLD' | null> {
    if (!userId) return null;
    const connection = await this.db.getConnection();
    try {
      const [rows] = await connection.execute(
        `SELECT plan_code FROM subscriptions
         WHERE user_id = ? AND status = 'ACTIVE'
         ORDER BY created_at DESC LIMIT 1`,
        [userId],
      );
      const rec = (rows as any[])[0];
      return (rec?.plan_code as 'SILVER' | 'GOLD' | undefined) || null;
    } finally {
      connection.release();
    }
  }

  private async getSupplierDetails(req: Request, res: Response): Promise<void> {
    const {supplierId} = req.params;
    const user = await this.userRepository.findById(supplierId);
    if (!user) {
      res.status(404).json({success: false, message: 'Supplier not found'});
      return;
    }

    // Record a profile view (fire-and-forget)
    try {
      const viewerId = (req as any).user?.id as string | undefined;
      if (viewerId && viewerId !== supplierId) {
        const connection = await this.db.getConnection();
        try {
          await connection.execute(
            'INSERT IGNORE INTO profile_views (supplier_id, viewer_id, view_date) VALUES (?, ?, CURRENT_DATE)',
            [supplierId, viewerId],
          );
        } finally {
          connection.release();
        }
      }
    } catch (err) {
      this.logger.error('Error recording profile view', err);
      // Do not block response on analytics failure
    }
    // Exclude password_hash from response
    const {password_hash, ...supplierData} = user as any;
    const viewerId = (req as any).user?.id as string | undefined;
    const plan = await this.getActivePlanCode(viewerId);
    if (!plan) {
      (supplierData as any).email = null;
      (supplierData as any).phone_number = null;
    } else if (plan === 'SILVER') {
      // Silver: email only
      (supplierData as any).phone_number = null;
    } // Gold: show both
    res.json({success: true, data: supplierData});
  }

  private async getSupplierProducts(
    req: Request,
    res: Response,
  ): Promise<void> {
    const {supplierId} = req.params;
    const user = await this.userRepository.findById(supplierId);
    if (!user) {
      res.status(404).json({success: false, message: 'Supplier not found'});
      return;
    }
    const products = await this.productRepository.findBySeller(supplierId);
    const isAuthed = Boolean((req as any).user?.id);
    const sanitized = isAuthed
      ? products
      : (products as any[]).map(p => ({...p, price: null}));
    res.json({success: true, data: sanitized});
  }

  private async saveSupplier(req: Request, res: Response): Promise<void> {
    const userId = (req as any).user?.id as string;
    const supplierId = req.params.supplierId;
    const connection = await this.db.getConnection();
    try {
      await connection.execute(
        'INSERT IGNORE INTO saved_suppliers (user_id, supplier_id) VALUES (?, ?)',
        [userId, supplierId],
      );
      res.status(204).send();
    } finally {
      connection.release();
    }
  }

  private async unsaveSupplier(req: Request, res: Response): Promise<void> {
    const userId = (req as any).user?.id as string;
    const supplierId = req.params.supplierId;
    const connection = await this.db.getConnection();
    try {
      await connection.execute(
        'DELETE FROM saved_suppliers WHERE user_id = ? AND supplier_id = ?',
        [userId, supplierId],
      );
      res.status(204).send();
    } finally {
      connection.release();
    }
  }

  private async getSupplierMetrics(req: Request, res: Response): Promise<void> {
    const {supplierId} = req.params;
    const user = await this.userRepository.findById(supplierId);
    if (!user) {
      res.status(404).json({success: false, message: 'Supplier not found'});
      return;
    }
    const connection = await this.db.getConnection();
    try {
      // Profile views count
      const [profileRows] = await connection.execute(
        'SELECT COUNT(*) as cnt FROM profile_views WHERE supplier_id = ?',
        [supplierId],
      );
      const profileViews = (profileRows as any[])[0]?.cnt || 0;

      // Products viewed count for this supplier's products
      const [productRows] = await connection.execute(
        `SELECT COUNT(*) as cnt
         FROM product_views pv
         JOIN products p ON pv.product_id = p.id
         WHERE p.seller_id = ?`,
        [supplierId],
      );
      const productsViewed = (productRows as any[])[0]?.cnt || 0;

      // Engagement: unique viewers across profile and product views
      const [engagementRows] = await connection.execute(
        `SELECT COUNT(DISTINCT viewer_id) as cnt FROM (
            SELECT viewer_id FROM profile_views WHERE supplier_id = ?
            UNION
            SELECT pv.viewer_id FROM product_views pv
            JOIN products p ON pv.product_id = p.id
            WHERE p.seller_id = ?
         ) as viewers`,
        [supplierId, supplierId],
      );
      const engagement = (engagementRows as any[])[0]?.cnt || 0;

      // Enquiries - not implemented yet
      const enquiries = 0;

      res.json({
        success: true,
        data: {profileViews, productsViewed, engagement, enquiries},
      });
    } catch (error) {
      this.logger.error('Error fetching supplier metrics', error);
      res
        .status(500)
        .json({success: false, message: 'Failed to fetch metrics'});
    } finally {
      connection.release();
    }
  }

  public getRouter(): Router {
    return this.router;
  }
}
