import {Request, Response, NextFunction} from 'express';
import {injectable, inject} from 'inversify';
import {TYPES} from '../di/types';
import {Logger} from '../utils/logger';
import {AppError} from '../utils/appErrors';

@injectable()
export class ErrorHandler {
  constructor(@inject(TYPES.Logger) private logger: Logger) {
    // Bind the method to preserve 'this' context
    this.handleError = this.handleError.bind(this);
  }

  public handleError = (
    error: Error,
    req: Request,
    res: Response,
    next: NextFunction,
  ): void => {
    this.logger.error(`Error occurred: ${error.message}`);
    this.logger.error(error.stack || 'No stack trace available');

    // If headers have already been sent, let the default Express error handler deal with it
    if (res.headersSent) {
      return next(error);
    }

    // If it's our custom AppError
    if (error instanceof AppError) {
      res.status(error.statusCode).json({
        success: false,
        message: error.message,
        status: error.status,
      });
      return;
    }

    // Handle validation errors (if you're using express-validator)
    if (error.name === 'ValidationError') {
      res.status(400).json({
        success: false,
        message: 'Validation Error',
        errors: error.message,
      });
      return;
    }

    // Handle other errors
    res.status(500).json({
      success: false,
      message: 'Internal server error',
    });
  };
}
