import express, {NextFunction, Request, Response, Router} from 'express';
import UserService from '../../services/user/userService';
import {inject, injectable} from 'inversify';
import {UserDetails} from '../../../domain/entity/response/userDetails/userDetails.entity';
import {TYPES} from '../../../application/di/types';
import {Middleware} from '../../../application/middlewares/middlewares';

@injectable()
class UserController {
  private router: Router;
  private userService: UserService;
  private middlewares: Middleware;

  constructor(
    @inject(TYPES.USER_SERVICE_IMPL) userService: UserService,
    @inject(TYPES.Middleware) middlewares: Middleware,
  ) {
    this.userService = userService;
    this.middlewares = middlewares;
    this.router = express.Router();
    this.configureRoutes();
  }

  public getRouter(): Router {
    return this.router;
  }

  private configureRoutes() {
    this.router.get(
      '/all',
      [
        (req, res, next) => this.middlewares.authenticateToken(req, res, next),
        this.middlewares.permissionMiddleWare(['ADMIN']),
      ],
      this.getAllUsers.bind(this),
    );
    this.router.post('/signUp', this.signUp.bind(this));
  }

  private async getAllUsers(
    request: Request,
    response: Response,
    next: NextFunction,
  ): Promise<void> {
    try {
      const users: UserDetails[] = await this.userService.getAll();
      response.send(users);
    } catch (error) {
      next(error);
    }
  }

  private async signUp(
    request: Request,
    response: Response,
    next: NextFunction,
  ): Promise<void> {
    try {
      const user: UserDetails = await this.userService.signUp(request.body);
      response.send(user);
    } catch (error) {
      next(error);
    }
  }
}

export default UserController;
