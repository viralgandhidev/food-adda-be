import {Container} from 'inversify';
import {TYPES} from './types';
import {App} from './app';
import {AppRouter} from './application/routers/appRouter';
import {UserController} from './application/controllers/userController';
import {UserService} from './application/services/userService';
import {UserRepository} from './domain/repositories/userRepository';
import {UserRepositoryImpl} from './infrastructure/repositories/userRepositoryImpl';
import {JWTUtils} from './application/utils/jwtUtils';

const container = new Container();

// App
container.bind<App>(TYPES.App).to(App);
container.bind<AppRouter>(TYPES.AppRouter).to(AppRouter);

// Controllers
container.bind<UserController>(TYPES.UserController).to(UserController);

// Services
container.bind<UserService>(TYPES.UserService).to(UserService);

// Repositories
container.bind<UserRepository>(TYPES.UserRepository).to(UserRepositoryImpl);

// Utils
container.bind<JWTUtils>(TYPES.JWTUtils).to(JWTUtils);

export {container};
