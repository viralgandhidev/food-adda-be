import {Request, Response, NextFunction} from 'express';
import {validationResult} from 'express-validator';
import {AppError} from '../utils/appErrors';

export const validateRequest = (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    throw new AppError('Validation Error', 400, errors.array());
  }
  next();
};
