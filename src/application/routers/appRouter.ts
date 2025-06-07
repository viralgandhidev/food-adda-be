import {Application} from 'express';
import {inject, injectable} from 'inversify';
import {TYPES} from '../di/types';
import {UserController} from '../controllers/userController';
import {CategoryController} from '../controllers/categoryController';
import {ProductController} from '../controllers/productController';
import {SearchController} from '../controllers/searchController';

@injectable()
export class AppRouter {
  constructor(
    @inject(TYPES.UserController) private userController: UserController,
    @inject(TYPES.CategoryController)
    private categoryController: CategoryController,
    @inject(TYPES.ProductController)
    private productController: ProductController,
    @inject(TYPES.SearchController) private searchController: SearchController,
  ) {}

  public registerRoutes(app: Application): void {
    // Define base API path
    const apiRouter = '/api/v1';

    // Auth routes
    app.use(`${apiRouter}/auth`, this.userController.getRouter());

    // Category routes
    app.use(`${apiRouter}/categories`, this.categoryController.getRouter());

    // Product routes
    app.use(`${apiRouter}/products`, this.productController.getRouter());

    // Search routes
    app.use(`${apiRouter}/search`, this.searchController.getRouter());
  }
}
