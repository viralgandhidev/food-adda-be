import {Request, Response, NextFunction} from 'express';
import {inject, injectable} from 'inversify';
import {TYPES} from '../di/types';
import {Logger} from '../utils/logger';
import {UnauthorizedError} from '../utils/appErrors';
import jwt from 'jsonwebtoken';
import config from '../config';

@injectable()
export class AuthMiddleware {
  constructor(@inject(TYPES.Logger) private logger: Logger) {}

  public authenticate = async (
    req: Request,
    res: Response,
    next: NextFunction,
  ): Promise<void> => {
    try {
      const authHeader = req.headers.authorization;
      if (!authHeader) {
        throw new UnauthorizedError('No authorization token provided');
      }

      const token = authHeader.split(' ')[1];
      if (!token) {
        throw new UnauthorizedError('Invalid authorization format');
      }

      try {
        const decoded = jwt.verify(token, config.jwtSecret) as any;
        (req as any).user = decoded;
        next();
      } catch (error) {
        throw new UnauthorizedError('Invalid or expired token');
      }
    } catch (error) {
      next(error);
    }
  };

  // Optional auth: set req.user if a valid token is present; do not error if missing/invalid
  public optionalAuthenticate = async (
    req: Request,
    res: Response,
    next: NextFunction,
  ): Promise<void> => {
    try {
      const authHeader = req.headers.authorization;
      if (!authHeader) {
        return next();
      }

      const token = authHeader.split(' ')[1];
      if (!token) {
        return next();
      }

      try {
        const decoded = jwt.verify(token, config.jwtSecret) as any;
        (req as any).user = decoded;
      } catch (error) {
        // ignore invalid tokens for optional auth
      }
      next();
    } catch (error) {
      // never block for optional auth
      next();
    }
  };
}
