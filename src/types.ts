export const TYPES = {
  // Core
  App: Symbol.for('App'),
  AppRouter: Symbol.for('AppRouter'),
  DatabaseController: Symbol.for('DatabaseController'),

  // Utils
  Logger: Symbol.for('Logger'),
  ErrorHandler: Symbol.for('ErrorHandler'),
  JWTUtils: Symbol.for('JWTUtils'),

  // Middleware
  Middleware: Symbol.for('Middleware'),

  // User Module
  UserController: Symbol.for('UserController'),
  UserService: Symbol.for('UserService'),
  UserRepository: Symbol.for('UserRepository'),
};
