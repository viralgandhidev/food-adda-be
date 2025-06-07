import {Request, Response, NextFunction, Router} from 'express';
import {inject, injectable} from 'inversify';
import {UserService} from '../services/userService';
import {validateRequest} from '../middleware/validateRequest';
import {TYPES} from '../di/types';
import {UserSignUpDTO, UserLoginDTO} from '../../domain/entities/user';
import {body} from 'express-validator';
import {asyncHandler} from '../utils/asyncHandler';
import {Logger} from '../utils/logger';

@injectable()
export class UserController {
  private router: Router;

  constructor(
    @inject(TYPES.UserService) private userService: UserService,
    @inject(TYPES.Logger) private logger: Logger,
  ) {
    this.router = Router();
    this.initializeRoutes();
  }

  private initializeRoutes() {
    this.router.post(
      '/signup',
      [
        body('email').isEmail().normalizeEmail(),
        body('password').isLength({min: 6}),
        body('first_name').notEmpty(),
        body('last_name').notEmpty(),
        body('user_type').isIn(['CONSUMER', 'SELLER']),
        validateRequest,
      ],
      asyncHandler(this.signUp.bind(this)),
    );

    this.router.post(
      '/login',
      [
        body('email').isEmail().normalizeEmail(),
        body('password').notEmpty(),
        validateRequest,
      ],
      asyncHandler(this.login.bind(this)),
    );
  }

  private async signUp(
    req: Request,
    res: Response,
    next: NextFunction,
  ): Promise<void> {
    const userData: UserSignUpDTO = req.body;
    const result = await this.userService.signUp(userData);
    res.status(201).json({
      success: true,
      data: result,
    });
  }

  private async login(
    req: Request,
    res: Response,
    next: NextFunction,
  ): Promise<void> {
    const credentials: UserLoginDTO = req.body;
    const result = await this.userService.login(credentials);
    res.status(200).json({
      success: true,
      data: result,
    });
  }

  getRouter(): Router {
    return this.router;
  }
}
