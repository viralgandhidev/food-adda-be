import {Request, Response, NextFunction} from 'express';
import {AppError} from './appErrors';

type AsyncRequestHandler = (
  req: Request,
  res: Response,
  next: NextFunction,
) => Promise<any>;

export const asyncHandler = (fn: AsyncRequestHandler) => {
  return (req: Request, res: Response, next: NextFunction) => {
    Promise.resolve(fn(req, res, next)).catch(error => {
      if (error instanceof AppError) {
        next(error);
      } else {
        next(new AppError(error.message || 'Internal server error', 500));
      }
    });
  };
};
