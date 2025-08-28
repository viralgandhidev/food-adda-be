import {Request, Response, NextFunction, Router} from 'express';
import {inject, injectable} from 'inversify';
import {UserService} from '../services/userService';
import {validateRequest} from '../middleware/validateRequest';
import {TYPES} from '../di/types';
import {
  UserSignUpDTO,
  UserLoginDTO,
  UserType,
} from '../../domain/entities/user';
import {body} from 'express-validator';
import {asyncHandler} from '../utils/asyncHandler';
import {Logger} from '../utils/logger';
import multer from 'multer';
import path from 'path';
import {AuthMiddleware} from '../middleware/authenticate';
import {container} from '../di/container';

@injectable()
export class UserController {
  private router: Router;
  private authMiddleware = container.get(AuthMiddleware);

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
        body('phone_number').notEmpty().isMobilePhone('any'),
        body('user_type').isIn(['CONSUMER', 'SELLER']),
        body('address').optional(),
        body('company_name')
          .optional()
          .custom((value, {req}) => {
            if (req.body.user_type === UserType.SELLER && !value) {
              throw new Error('Company name is required for sellers');
            }
            return true;
          }),
        body('company_description')
          .optional()
          .custom((value, {req}) => {
            if (req.body.user_type === UserType.SELLER && !value) {
              throw new Error('Company description is required for sellers');
            }
            return true;
          }),
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

    // Multer setup for profile image upload
    const storage = multer.diskStorage({
      destination: function (req, file, cb) {
        cb(null, path.join(__dirname, '../../../uploads'));
      },
      filename: function (req, file, cb) {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
        cb(null, uniqueSuffix + '-' + file.originalname);
      },
    });
    const upload = multer({storage});

    this.router.put(
      '/profile',
      this.authMiddleware.authenticate,
      upload.single('profile_image'),
      asyncHandler(async (req: Request, res: Response) => {
        const anyReq = req as any;
        const userId = anyReq.user?.id;
        if (!userId) {
          return res
            .status(401)
            .json({success: false, message: 'Unauthorized'});
        }
        const {
          first_name,
          last_name,
          phone_number,
          address,
          company_name,
          company_description,
        } = req.body;
        let profile_image_url;
        if (anyReq.file) {
          profile_image_url = `/uploads/${anyReq.file.filename}`;
        }
        const updateData: any = {
          first_name,
          last_name,
          phone_number,
          address,
          company_name,
          company_description,
        };
        if (profile_image_url) updateData.profile_image_url = profile_image_url;
        // Remove undefined fields
        Object.keys(updateData).forEach(
          key => updateData[key] === undefined && delete updateData[key],
        );
        const updatedUser = await this.userService.updateProfile(
          userId,
          updateData,
        );
        res.json({success: true, data: updatedUser});
      }),
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
    res.json({
      success: true,
      data: result,
    });
  }

  public getRouter(): Router {
    return this.router;
  }
}
