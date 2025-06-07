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

@injectable()
export class ProductController {
  private router: Router;

  constructor(
    @inject(TYPES.ProductRepository)
    private productRepository: ProductRepository,
    @inject(TYPES.Logger) private logger: Logger,
    @inject(TYPES.AuthMiddleware) private authMiddleware: AuthMiddleware,
  ) {
    this.router = Router();
    this.initializeRoutes();
  }

  private initializeRoutes(): void {
    // All routes require authentication
    this.router.use(this.authMiddleware.authenticate);

    // Public routes (still need authentication)
    this.router.get('/', asyncHandler(this.getAllProducts.bind(this)));
    this.router.get('/:id', asyncHandler(this.getProductById.bind(this)));

    // Seller routes (need both authentication and authorization)
    this.router.post(
      '/',
      authorize([UserType.SELLER]),
      [
        body('name').notEmpty(),
        body('description').notEmpty(),
        body('price').isFloat({min: 0}),
        body('category_id').notEmpty(),
        body('is_veg').isBoolean(),
        body('preparation_time').isInt({min: 0}),
        validateRequest,
      ],
      asyncHandler(this.createProduct.bind(this)),
    );

    this.router.put(
      '/:id',
      authorize([UserType.SELLER]),
      asyncHandler(this.updateProduct.bind(this)),
    );

    this.router.delete(
      '/:id',
      authorize([UserType.SELLER]),
      asyncHandler(this.deleteProduct.bind(this)),
    );

    this.router.get(
      '/seller/products',
      authorize([UserType.SELLER]),
      asyncHandler(this.getSellerProducts.bind(this)),
    );

    // Add this new route
    this.router.get(
      '/category/:categoryId',
      asyncHandler(this.getProductsByCategory.bind(this)),
    );

    // Product image routes
    this.router.post(
      '/:id/images',
      authorize([UserType.SELLER]),
      [
        body('images').isArray(),
        body('images.*.image_url').isString().notEmpty(),
        validateRequest,
      ],
      asyncHandler(this.addProductImages.bind(this)),
    );

    this.router.delete(
      '/images/:imageId',
      authorize([UserType.SELLER]),
      asyncHandler(this.deleteProductImage.bind(this)),
    );
  }

  private async getAllProducts(req: Request, res: Response): Promise<void> {
    const products = await this.productRepository.findAll();
    res.status(200).json({
      success: true,
      data: products,
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
    res.status(200).json({
      success: true,
      data: product,
    });
  }

  private async createProduct(req: Request, res: Response): Promise<void> {
    const sellerId = (req as any).user.id;
    const product = await this.productRepository.create(req.body, sellerId);
    res.status(201).json({
      success: true,
      data: product,
    });
  }

  private async updateProduct(req: Request, res: Response): Promise<void> {
    const sellerId = (req as any).user.id;
    const product = await this.productRepository.update(
      req.params.id,
      sellerId,
      req.body,
    );
    res.status(200).json({
      success: true,
      data: product,
    });
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

  private async addProductImages(req: Request, res: Response): Promise<void> {
    const sellerId = (req as any).user.id;
    const productId = req.params.id;
    const images = await this.productRepository.addProductImages(
      productId,
      req.body.images,
    );

    res.status(201).json({
      success: true,
      data: images,
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
