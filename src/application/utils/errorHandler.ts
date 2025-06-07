import {inject, injectable} from 'inversify';
import {Logger} from './logger';
import {Application, NextFunction, Request, Response} from 'express';
import {AppError} from './appErrors';
import Constants, {ErrorCodes} from './constants';
import {TYPES} from '../di/types';

@injectable()
export class ErrorHandler {
  private logger: Logger;

  constructor(@inject(TYPES.Logger) logger: Logger) {
    this.logger = logger;
  }

  public registerErrorHandler(app: Application) {
    // Request error handler
    app.use((error: Error, req: Request, res: Response, next: NextFunction) => {
      if (error instanceof AppError) {
        this.logger.error(`${error.statusCode} ${error?.message}`, error.stack);
        if (error.message) {
          res.status(error.statusCode).send({message: error.message});
        } else {
          res
            .status(error.statusCode)
            .send({message: Constants.SOMETHING_WENT_WRONG});
        }
      } else if (error instanceof Error) {
        if (error.message) {
          this.logger.error(
            `${req.method} ${req.path}: Unhandled request error. ${error.message}`,
          );
          res
            .status(ErrorCodes.INTERNAL_SERVER_ERROR)
            .send({message: error.message});
        } else {
          this.logger.error(
            `${req.method} ${req.path}: Unhandled request error. ${error}`,
          );
          res
            .status(ErrorCodes.INTERNAL_SERVER_ERROR)
            .send({message: Constants.SOMETHING_WENT_WRONG});
        }
      } else if (typeof error === 'string') {
        this.logger.error(
          `${req.method} ${req.path}: Unhandled request error. ${error}`,
        );
        res.status(ErrorCodes.INTERNAL_SERVER_ERROR).send({message: error});
      } else {
        this.logger.error(
          `${req.method} ${req.path}: Unhandled request error. ${error}`,
        );
        res
          .status(ErrorCodes.INTERNAL_SERVER_ERROR)
          .send({message: Constants.SOMETHING_WENT_WRONG});
      }

      next(error);
    });
  }

  public handleError(
    error: Error,
    req: Request,
    res: Response,
    next: NextFunction,
  ): void {
    this.logger.error(`Error: ${error.message}`);
    res.status(500).json({
      success: false,
      message: error.message || 'Internal server error',
    });
  }
}

export default ErrorHandler;
