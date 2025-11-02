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
import {SupplierController} from '../controllers/supplierController';
import {FormController} from '../controllers/formController';
import {KeywordController} from '../controllers/keywordController';
import {KeywordRepository} from '../../domain/repositories/keywordRepository';
import {KeywordRepositoryImpl} from '../../infrastructure/repositories/keywordRepositoryImpl';
import {SubscriptionController} from '../controllers/subscriptionController';

const container = new Container({defaultScope: 'Singleton'});

// Make sure Logger is bound first
container.bind<Logger>(TYPES.Logger).to(Logger).inSingletonScope();

// Core
container.bind<App>(TYPES.App).to(App).inSingletonScope();
container.bind<AppRouter>(TYPES.AppRouter).to(AppRouter).inSingletonScope();
container
  .bind<DatabaseController>(TYPES.DatabaseController)
  .to(DatabaseController)
  .inSingletonScope();
container
  .bind<ErrorHandler>(TYPES.ErrorHandler)
  .to(ErrorHandler)
  .inSingletonScope();

// Utils
container.bind<JWTUtils>(TYPES.JWTUtils).to(JWTUtils).inSingletonScope();

// Middleware
container.bind<Middleware>(TYPES.Middleware).to(Middleware).inSingletonScope();
container
  .bind<AuthMiddleware>(TYPES.AuthMiddleware)
  .to(AuthMiddleware)
  .inSingletonScope();
container.bind(AuthMiddleware).toSelf().inSingletonScope();

// User Module
container
  .bind<UserController>(TYPES.UserController)
  .to(UserController)
  .inSingletonScope();
container
  .bind<UserService>(TYPES.UserService)
  .to(UserService)
  .inSingletonScope();
container
  .bind<UserRepository>(TYPES.UserRepository)
  .to(UserRepositoryImpl)
  .inSingletonScope();

// Category Module
container
  .bind<CategoryController>(TYPES.CategoryController)
  .to(CategoryController)
  .inSingletonScope();
container
  .bind<CategoryRepository>(TYPES.CategoryRepository)
  .to(CategoryRepositoryImpl)
  .inSingletonScope();

// Product Module
container
  .bind<ProductController>(TYPES.ProductController)
  .to(ProductController)
  .inSingletonScope();
container
  .bind<ProductRepository>(TYPES.ProductRepository)
  .to(ProductRepositoryImpl)
  .inSingletonScope();

// Search Module
container
  .bind<SearchController>(TYPES.SearchController)
  .to(SearchController)
  .inSingletonScope();

// Keywords Module
container
  .bind<KeywordController>(TYPES.KeywordController)
  .to(KeywordController)
  .inSingletonScope();
container
  .bind<KeywordRepository>(TYPES.KeywordRepository)
  .to(KeywordRepositoryImpl)
  .inSingletonScope();

// Supplier Module
container
  .bind<SupplierController>(TYPES.SupplierController)
  .to(SupplierController)
  .inSingletonScope();

// Form Module
container
  .bind<FormController>(TYPES.FormController)
  .to(FormController)
  .inSingletonScope();

// Subscription Module
container
  .bind<SubscriptionController>(TYPES.SubscriptionController)
  .to(SubscriptionController)
  .inSingletonScope();

export {container};
