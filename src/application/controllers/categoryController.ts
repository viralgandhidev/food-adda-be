import {Request, Response, Router} from 'express';
import {inject, injectable} from 'inversify';
import {TYPES} from '../di/types';
import {CategoryRepository} from '../../domain/repositories/categoryRepository';
import {asyncHandler} from '../utils/asyncHandler';
import {Logger} from '../utils/logger';
import {AuthMiddleware} from '../middleware/authenticate';

@injectable()
export class CategoryController {
  private router: Router;

  constructor(
    @inject(TYPES.CategoryRepository)
    private categoryRepository: CategoryRepository,
    @inject(TYPES.Logger) private logger: Logger,
    @inject(TYPES.AuthMiddleware) private authMiddleware: AuthMiddleware,
  ) {
    this.router = Router();
    this.initializeRoutes();
  }

  private initializeRoutes(): void {
    this.router.get(
      '/',
      this.authMiddleware.authenticate,
      asyncHandler(this.getCategories.bind(this)),
    );
  }

  private async getCategories(req: Request, res: Response): Promise<void> {
    const categories = await this.categoryRepository.findAll();

    const formattedCategories = categories.map(category => ({
      ...category,
      product_count: parseInt(category.product_count?.toString() || '0'),
      is_featured: Boolean(category.is_featured),
      is_active: Boolean(category.is_active),
    }));

    res.status(200).json({
      success: true,
      data: formattedCategories,
      meta: {
        total: formattedCategories.length,
        total_products: formattedCategories.reduce(
          (sum, cat) => sum + (cat.product_count || 0),
          0,
        ),
      },
    });
  }

  public getRouter(): Router {
    return this.router;
  }
}
