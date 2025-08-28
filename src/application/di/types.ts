export const TYPES = {
  // Core
  App: Symbol.for('App'),
  AppRouter: Symbol.for('AppRouter'),
  Logger: Symbol.for('Logger'),
  DatabaseController: Symbol.for('DatabaseController'),
  ErrorHandler: Symbol.for('ErrorHandler'),

  // User Module
  USER_SERVICE_IMPL: Symbol.for('UserServiceImpl'),
  USER_REPOSITORY_IMPL: Symbol.for('UserRepositoryImpl'),

  // Controllers
  UserController: Symbol.for('UserController'),

  // Services
  UserService: Symbol.for('UserService'),

  // Repositories
  UserRepository: Symbol.for('UserRepository'),

  // Category Module
  CategoryController: Symbol.for('CategoryController'),
  CategoryRepository: Symbol.for('CategoryRepository'),

  // Utils
  JWTUtils: Symbol.for('JWTUtils'),

  // Middleware
  Middleware: Symbol.for('Middleware'),

  ProductRepository: Symbol.for('ProductRepository'),
  ProductController: Symbol.for('ProductController'),

  AuthMiddleware: Symbol.for('AuthMiddleware'),

  SearchController: Symbol.for('SearchController'),

  SupplierController: Symbol.for('SupplierController'),
  FormController: Symbol.for('FormController'),
};
