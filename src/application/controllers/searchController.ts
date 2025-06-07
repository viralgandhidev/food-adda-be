import {Request, Response, Router} from 'express';
import {inject, injectable} from 'inversify';
import {TYPES} from '../di/types';
import {ProductRepository} from '../../domain/repositories/productRepository';
import {asyncHandler} from '../utils/asyncHandler';
import {Logger} from '../utils/logger';
import {query} from 'express-validator';
import {validateRequest} from '../middleware/validateRequest';

@injectable()
export class SearchController {
  private router: Router;

  constructor(
    @inject(TYPES.ProductRepository)
    private productRepository: ProductRepository,
    @inject(TYPES.Logger) private logger: Logger,
  ) {
    this.router = Router();
    this.initializeRoutes();
  }

  private initializeRoutes(): void {
    this.router.get(
      '/',
      [
        query('q').optional().isString(),
        query('categoryId').optional().isString(),
        query('minPrice').optional().isFloat({min: 0}),
        query('maxPrice').optional().isFloat({min: 0}),
        query('isVeg').optional().isBoolean(),
        query('sortBy').optional().isIn(['price', 'name', 'preparation_time']),
        query('sortOrder').optional().isIn(['asc', 'desc']),
        validateRequest,
      ],
      asyncHandler(this.search.bind(this)),
    );
  }

  private async search(req: Request, res: Response): Promise<void> {
    const filters = {
      query: req.query.q as string,
      categoryId: req.query.categoryId as string,
      minPrice: req.query.minPrice
        ? parseFloat(req.query.minPrice as string)
        : undefined,
      maxPrice: req.query.maxPrice
        ? parseFloat(req.query.maxPrice as string)
        : undefined,
      isVeg: req.query.isVeg ? req.query.isVeg === 'true' : undefined,
      sortBy: req.query.sortBy as 'price' | 'name' | 'preparation_time',
      sortOrder: req.query.sortOrder as 'asc' | 'desc',
    };

    const results = await this.productRepository.search(filters);

    res.status(200).json({
      success: true,
      data: results,
    });
  }

  public getRouter(): Router {
    return this.router;
  }
}
