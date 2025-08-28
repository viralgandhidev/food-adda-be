import {Container} from 'inversify';
import {TYPES} from './application/di/types';
import {App} from './app';
import {AppRouter} from './application/routers/appRouter';
import {UserController} from './application/controllers/userController';
import {UserService} from './application/services/userService';
import {UserRepository} from './domain/repositories/userRepository';
import {UserRepositoryImpl} from './infrastructure/repositories/userRepositoryImpl';
import {JWTUtils} from './application/utils/jwtUtils';
import {SupplierController} from './application/controllers/supplierController';
import {ProductRepository} from './domain/repositories/productRepository';
import {ProductRepositoryImpl} from './infrastructure/repositories/productRepositoryImpl';
import {Logger} from './application/utils/logger';
import {AuthMiddleware} from './application/middleware/authenticate';
import {CategoryController} from './application/controllers/categoryController';
import {SearchController} from './application/controllers/searchController';
import {ProductController} from './application/controllers/productController';
import {DatabaseController} from './application/utils/databaseController';

const container = new Container({defaultScope: 'Singleton'});

// App
container.bind<App>(TYPES.App).to(App).inSingletonScope();
container.bind<AppRouter>(TYPES.AppRouter).to(AppRouter).inSingletonScope();

// Controllers
container
  .bind<UserController>(TYPES.UserController)
  .to(UserController)
  .inSingletonScope();
container
  .bind<SupplierController>(TYPES.SupplierController)
  .to(SupplierController)
  .inSingletonScope();
container
  .bind<CategoryController>(TYPES.CategoryController)
  .to(CategoryController)
  .inSingletonScope();
container
  .bind<SearchController>(TYPES.SearchController)
  .to(SearchController)
  .inSingletonScope();
container
  .bind<ProductController>(TYPES.ProductController)
  .to(ProductController)
  .inSingletonScope();

// Services
container
  .bind<UserService>(TYPES.UserService)
  .to(UserService)
  .inSingletonScope();

// Repositories
container
  .bind<UserRepository>(TYPES.UserRepository)
  .to(UserRepositoryImpl)
  .inSingletonScope();
container
  .bind<ProductRepository>(TYPES.ProductRepository)
  .to(ProductRepositoryImpl)
  .inSingletonScope();

// Utils
container.bind<JWTUtils>(TYPES.JWTUtils).to(JWTUtils).inSingletonScope();
container.bind<Logger>(TYPES.Logger).to(Logger).inSingletonScope();
container
  .bind<DatabaseController>(TYPES.DatabaseController)
  .to(DatabaseController)
  .inSingletonScope();

// Middleware
container
  .bind<AuthMiddleware>(TYPES.AuthMiddleware)
  .to(AuthMiddleware)
  .inSingletonScope();

export {container};
