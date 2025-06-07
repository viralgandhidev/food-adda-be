import {Request, Response, NextFunction} from 'express';
import {UserType} from '../../domain/entities/user';
import {UnauthorizedError} from '../utils/appErrors';

export const authorize = (allowedRoles: UserType[]) => {
  return (req: Request, res: Response, next: NextFunction) => {
    try {
      const user = (req as any).user;

      if (!user) {
        throw new UnauthorizedError('Authentication required');
      }

      if (!allowedRoles.includes(user.user_type)) {
        throw new UnauthorizedError(
          'You are not authorized to perform this action',
        );
      }

      next();
    } catch (error) {
      next(error);
    }
  };
};
