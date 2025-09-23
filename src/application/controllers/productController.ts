import {Request, Response, Router} from 'express';
import {inject, injectable} from 'inversify';
import {TYPES} from '../di/types';
import {ProductRepository} from '../../domain/repositories/productRepository';
import {asyncHandler} from '../utils/asyncHandler';
import {Logger} from '../utils/logger';
import {body} from 'express-validator';
import {validateRequest} from '../middleware/validateRequest';
import {UserType} from '../../domain/entities/user';
import {AuthMiddleware} from '../middleware/authenticate';
import {authorize} from '../middleware/authorize';
import multer from 'multer';
import path from 'path';
import type {Request as ExpressRequest} from 'express';
import {DatabaseController} from '../utils/databaseController';

@injectable()
export class ProductController {
  private router: Router;

  constructor(
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
    // Public routes (no authentication required)
    // Attach optional auth so we can tailor responses
    this.router.get(
      '/',
      this.authMiddleware.optionalAuthenticate,
      asyncHandler(this.getAllProducts.bind(this)),
    );
    // Register static route BEFORE param route to avoid shadowing
    this.router.get(
      '/top-viewed',
      this.authMiddleware.optionalAuthenticate,
      asyncHandler(this.getTopViewedProducts.bind(this)),
    );
    this.router.get(
      '/:id',
      this.authMiddleware.optionalAuthenticate,
      asyncHandler(this.getProductById.bind(this)),
    );
    this.router.post('/:id/save', asyncHandler(this.saveProduct.bind(this)));
    this.router.delete(
      '/:id/save',
      asyncHandler(this.unsaveProduct.bind(this)),
    );
    this.router.get('/:id/saved', asyncHandler(this.isProductSaved.bind(this)));
    this.router.get(
      '/saved/list/all',
      asyncHandler(this.getSavedProducts.bind(this)),
    );

    // Seller routes (need both authentication and authorization)
    const storage = multer.diskStorage({
      destination: function (req, file, cb) {
        cb(null, path.join(__dirname, '../../../uploads'));
      },
      filename: function (req, file, cb) {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
        cb(null, uniqueSuffix + '-' + file.originalname);
      },
    });
    const upload = multer({storage});

    this.router.post(
      '/',
      this.authMiddleware.authenticate,
      upload.fields([
        {name: 'image', maxCount: 1},
        {name: 'images', maxCount: 10},
      ]),
      asyncHandler(async (req: Request, res: Response) => {
        const sellerId = (req as any).user.id;
        // Parse order array for images
        let orderArr: number[] = [];
        if (req.body.order) {
          try {
            orderArr = JSON.parse(req.body.order);
          } catch {
            return res
              .status(400)
              .json({success: false, message: 'Invalid order array'});
          }
        }
        // Handle main image
        let image_url = req.body.image_url;
        if (
          (req as any).files &&
          (req as any).files['image'] &&
          (req as any).files['image'][0]
        ) {
          image_url = `/uploads/${(req as any).files['image'][0].filename}`;
        }
        // Handle additional images
        let images = [];
        if ((req as any).files && (req as any).files['images']) {
          const files = (req as any).files['images'];
          if (orderArr.length && orderArr.length !== files.length) {
            return res.status(400).json({
              success: false,
              message: 'Order array length must match number of images',
            });
          }
          images = files.map((file: any, idx: number) => ({
            image_url: `/uploads/${file.filename}`,
            order: orderArr[idx] ?? idx,
          }));
        } else if (req.body.images) {
          // Fallback for JSON body
          try {
            images = JSON.parse(req.body.images);
          } catch {
            images = req.body.images;
          }
        }
        // Handle metrics
        let metrics = [];
        if (req.body.metrics) {
          try {
            metrics =
              typeof req.body.metrics === 'string'
                ? JSON.parse(req.body.metrics)
                : req.body.metrics;
          } catch {
            metrics = req.body.metrics;
          }
        }
        const productData = {
          ...req.body,
          image_url,
          images,
          metrics,
        };
        const product = await this.productRepository.create(
          productData,
          sellerId,
        );
        res.status(201).json({success: true, data: product});
      }),
    );

    this.router.put(
      '/:id',
      this.authMiddleware.authenticate,
      upload.fields([
        {name: 'image', maxCount: 1},
        {name: 'new_images', maxCount: 10},
      ]),
      asyncHandler(async (req: Request, res: Response) => {
        const sellerId = (req as any).user.id;
        // Parse order array for images
        let orderArr: any[] = [];
        if (req.body.order) {
          try {
            orderArr = JSON.parse(req.body.order);
          } catch {
            return res
              .status(400)
              .json({success: false, message: 'Invalid order array'});
          }
        }
        // Handle main image
        let image_url = req.body.image_url;
        if (
          (req as any).files &&
          (req as any).files['image'] &&
          (req as any).files['image'][0]
        ) {
          image_url = `/uploads/${(req as any).files['image'][0].filename}`;
        }
        // Handle images: reorder, add, delete
        let images = [];
        const newFiles =
          ((req as any).files && (req as any).files['new_images']) || [];
        for (const entry of orderArr) {
          if (entry.id) {
            // Existing image, keep and update order
            images.push({id: entry.id, order: entry.order});
          } else if (
            entry.fileIndex !== undefined &&
            newFiles[entry.fileIndex]
          ) {
            // New image upload
            images.push({
              image_url: `/uploads/${newFiles[entry.fileIndex].filename}`,
              order: entry.order,
            });
          }
        }
        // Handle metrics
        let metrics = [];
        if (req.body.metrics) {
          try {
            metrics =
              typeof req.body.metrics === 'string'
                ? JSON.parse(req.body.metrics)
                : req.body.metrics;
          } catch {
            metrics = req.body.metrics;
          }
        }
        const productData = {
          ...req.body,
          image_url,
          images,
          metrics,
        };
        const product = await this.productRepository.update(
          req.params.id,
          sellerId,
          productData,
        );
        res.status(200).json({success: true, data: product});
      }),
    );

    this.router.delete(
      '/:id',
      this.authMiddleware.authenticate,
      asyncHandler(this.deleteProduct.bind(this)),
    );

    // Allow all authenticated users to fetch their own products (returns empty if none)
    this.router.get(
      '/seller/products',
      this.authMiddleware.authenticate,
      asyncHandler(this.getSellerProducts.bind(this)),
    );

    // Add this new route
    this.router.get(
      '/category/:categoryId',
      // public
      asyncHandler(this.getProductsByCategory.bind(this)),
    );

    this.router.delete(
      '/images/:imageId',
      this.authMiddleware.authenticate,
      asyncHandler(this.deleteProductImage.bind(this)),
    );
  }

  private async getAllProducts(req: Request, res: Response): Promise<void> {
    // Parse filters from query params
    const filters = {
      query: req.query.q as string,
      categoryId: req.query.categoryId as string,
      minPrice: req.query.minPrice
        ? parseFloat(req.query.minPrice as string)
        : undefined,
      maxPrice: req.query.maxPrice
        ? parseFloat(req.query.maxPrice as string)
        : undefined,
      isVeg:
        req.query.isVeg !== undefined ? req.query.isVeg === 'true' : undefined,
      sortBy: req.query.sortBy as 'price' | 'name' | 'preparation_time',
      sortOrder: req.query.sortOrder as 'asc' | 'desc',
      page: req.query.page ? parseInt(req.query.page as string, 10) : 1,
      limit: req.query.limit ? parseInt(req.query.limit as string, 10) : 20,
    };

    // Use new repository method for search+filter+pagination
    const result = await this.productRepository.findWithFilters(filters);
    const isAuthed = Boolean((req as any).user?.id);

    const sanitized = result.items.map(p => {
      if (isAuthed) return p;
      // mask price for unauthenticated users
      const {price, ...rest} = p as any;
      return {...rest, price: null};
    });

    res.status(200).json({
      success: true,
      data: sanitized,
      meta: {
        total: result.total,
        page: filters.page,
        limit: filters.limit,
        totalPages: Math.ceil(result.total / (filters.limit || 20)),
      },
    });
  }

  private async getProductById(req: Request, res: Response): Promise<void> {
    const product = await this.productRepository.findById(req.params.id);
    if (!product) {
      res.status(404).json({
        success: false,
        message: 'Product not found',
      });
      return;
    }
    // mask sensitive fields for unauthenticated users
    const isAuthed = Boolean((req as any).user?.id);
    const masked = !isAuthed ? ({...product, price: null} as any) : product;
    // Record a product view (fire-and-forget)
    try {
      const viewerId = (req as any).user?.id as string | undefined;
      if (viewerId && product.seller_id !== viewerId) {
        const connection = await this.db.getConnection();
        try {
          await connection.execute(
            'INSERT IGNORE INTO product_views (product_id, viewer_id, view_date) VALUES (?, ?, CURRENT_DATE)',
            [req.params.id, viewerId],
          );
        } finally {
          connection.release();
        }
      }
    } catch (err) {
      this.logger.error('Error recording product view', err);
      // Do not block response
    }
    res.status(200).json({
      success: true,
      data: masked,
    });
  }

  private async getTopViewedProducts(
    req: Request,
    res: Response,
  ): Promise<void> {
    const limit = req.query.limit
      ? parseInt(req.query.limit as string, 10)
      : 20;
    const safeLimit = Number.isFinite(limit)
      ? Math.max(1, Math.min(limit, 100))
      : 20;
    const isAuthed = Boolean((req as any).user?.id);
    const connection = await this.db.getConnection();
    try {
      const [rows] = await connection.execute(
        `SELECT p.*, c.name as category_name,
                u.first_name as seller_first_name, u.last_name as seller_last_name,
                COALESCE(cnt.views, 0) as views
         FROM products p
         LEFT JOIN (
           SELECT product_id, COUNT(*) as views
           FROM product_views
           GROUP BY product_id
         ) cnt ON cnt.product_id = p.id
         LEFT JOIN categories c ON p.category_id = c.id
         LEFT JOIN users u ON p.seller_id = u.id
         ORDER BY views DESC, p.updated_at DESC
         LIMIT ${safeLimit}`,
      );
      const products = rows as any[];
      // attach images
      for (const product of products) {
        product.images = await this.productRepository.getProductImages(
          product.id,
        );
        product.brand = (
          (product.seller_first_name || '') +
          ' ' +
          (product.seller_last_name || '')
        ).trim();
        if (!isAuthed) {
          product.price = null;
        }
      }
      res.json({success: true, data: products});
    } finally {
      connection.release();
    }
  }

  private async saveProduct(req: Request, res: Response): Promise<void> {
    const userId = (req as any).user?.id as string;
    const productId = req.params.id;
    const connection = await this.db.getConnection();
    try {
      await connection.execute(
        'INSERT IGNORE INTO saved_products (user_id, product_id) VALUES (?, ?)',
        [userId, productId],
      );
      res.status(204).send();
    } finally {
      connection.release();
    }
  }

  private async unsaveProduct(req: Request, res: Response): Promise<void> {
    const userId = (req as any).user?.id as string;
    const productId = req.params.id;
    const connection = await this.db.getConnection();
    try {
      await connection.execute(
        'DELETE FROM saved_products WHERE user_id = ? AND product_id = ?',
        [userId, productId],
      );
      res.status(204).send();
    } finally {
      connection.release();
    }
  }

  private async isProductSaved(req: Request, res: Response): Promise<void> {
    const userId = (req as any).user?.id as string;
    const productId = req.params.id;
    const connection = await this.db.getConnection();
    try {
      const [rows] = await connection.execute(
        'SELECT 1 FROM saved_products WHERE user_id = ? AND product_id = ? LIMIT 1',
        [userId, productId],
      );
      const saved = (rows as any[]).length > 0;
      res.json({success: true, data: {saved}});
    } finally {
      connection.release();
    }
  }

  private async getSavedProducts(req: Request, res: Response): Promise<void> {
    const userId = (req as any).user?.id as string;
    const connection = await this.db.getConnection();
    try {
      const [rows] = await connection.execute(
        `SELECT p.*, c.name as category_name,
                u.first_name as seller_first_name, u.last_name as seller_last_name
         FROM saved_products sp
         JOIN products p ON sp.product_id = p.id
         LEFT JOIN categories c ON p.category_id = c.id
         LEFT JOIN users u ON p.seller_id = u.id
         WHERE sp.user_id = ?
         ORDER BY sp.saved_at DESC`,
        [userId],
      );
      const products = rows as any[];
      for (const product of products) {
        product.images = await this.productRepository.getProductImages(
          product.id,
        );
        product.brand = (
          (product.seller_first_name || '') +
          ' ' +
          (product.seller_last_name || '')
        ).trim();
      }
      res.json({success: true, data: products});
    } finally {
      connection.release();
    }
  }

  private async deleteProduct(req: Request, res: Response): Promise<void> {
    const sellerId = (req as any).user.id;
    await this.productRepository.delete(req.params.id, sellerId);
    res.status(204).send();
  }

  private async getSellerProducts(req: Request, res: Response): Promise<void> {
    const sellerId = (req as any).user.id;
    const products = await this.productRepository.findBySeller(sellerId);
    res.status(200).json({
      success: true,
      data: products,
    });
  }

  private async getProductsByCategory(
    req: Request,
    res: Response,
  ): Promise<void> {
    const categoryId = req.params.categoryId;
    const products = await this.productRepository.findByCategory(categoryId);

    res.status(200).json({
      success: true,
      data: products,
      meta: {
        total: products.length,
      },
    });
  }

  private async deleteProductImage(req: Request, res: Response): Promise<void> {
    const sellerId = (req as any).user.id;
    await this.productRepository.deleteProductImage(
      req.params.imageId,
      sellerId,
    );
    res.status(204).send();
  }

  public getRouter(): Router {
    return this.router;
  }
}
