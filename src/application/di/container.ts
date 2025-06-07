import 'reflect-metadata';
import {Container} from 'inversify';
import {buildProviderModule} from 'inversify-binding-decorators';
import {TYPES} from './types';
import {App} from '../../app';
import {AppRouter} from '../routers/appRouter';
import {UserController} from '../controllers/userController';
import {UserService} from '../services/userService';
import {UserRepository} from '../../domain/repositories/userRepository';
import {UserRepositoryImpl} from '../../infrastructure/repositories/userRepositoryImpl';
import {JWTUtils} from '../utils/jwtUtils';
import {Middleware} from '../middlewares/middlewares';
import {Logger} from '../utils/logger';
import {DatabaseController} from '../utils/databaseController';
import {ErrorHandler} from '../utils/errorHandler';
import {CategoryController} from '../controllers/categoryController';
import {CategoryRepository} from '../../domain/repositories/categoryRepository';
import {CategoryRepositoryImpl} from '../../infrastructure/repositories/categoryRepositoryImpl';
import {ProductController} from '../controllers/productController';
import {ProductRepository} from '../../domain/repositories/productRepository';
import {ProductRepositoryImpl} from '../../infrastructure/repositories/productRepositoryImpl';
import {AuthMiddleware} from '../middleware/authenticate';
import {SearchController} from '../controllers/searchController';

const container = new Container({defaultScope: 'Singleton'});

// Make sure Logger is bound first
container.bind<Logger>(TYPES.Logger).to(Logger).inSingletonScope();

// Core
container.bind<App>(TYPES.App).to(App);
container.bind<AppRouter>(TYPES.AppRouter).to(AppRouter);
container
  .bind<DatabaseController>(TYPES.DatabaseController)
  .to(DatabaseController);
container.bind<ErrorHandler>(TYPES.ErrorHandler).to(ErrorHandler);

// Utils
container.bind<JWTUtils>(TYPES.JWTUtils).to(JWTUtils);

// Middleware
container.bind<Middleware>(TYPES.Middleware).to(Middleware);

// User Module
container.bind<UserController>(TYPES.UserController).to(UserController);
container.bind<UserService>(TYPES.UserService).to(UserService);
container.bind<UserRepository>(TYPES.UserRepository).to(UserRepositoryImpl);

// Category Module
container
  .bind<CategoryController>(TYPES.CategoryController)
  .to(CategoryController);
container
  .bind<CategoryRepository>(TYPES.CategoryRepository)
  .to(CategoryRepositoryImpl);

// Product Module
container
  .bind<ProductController>(TYPES.ProductController)
  .to(ProductController);
container
  .bind<ProductRepository>(TYPES.ProductRepository)
  .to(ProductRepositoryImpl);

container.bind<AuthMiddleware>(TYPES.AuthMiddleware).to(AuthMiddleware);

container.bind<SearchController>(TYPES.SearchController).to(SearchController);

export {container};
