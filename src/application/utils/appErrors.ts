import {Constants} from './constants';

export enum ErrorCodes {
  BAD_REQUEST = 400,
  UNAUTHORIZED = 401,
  FORBIDDEN = 403,
  NOT_FOUND = 404,
  INTERNAL_SERVER = 500,
}

export class AppError extends Error {
  public readonly statusCode: number;
  public readonly status: string;
  public readonly isOperational: boolean;

  constructor(message: string, statusCode: number, details?: any) {
    super(message);
    this.statusCode = statusCode;
    this.status = `${statusCode}`.startsWith('4') ? 'fail' : 'error';
    this.isOperational = true;
    this.name = 'AppError';

    Error.captureStackTrace(this, this.constructor);
  }
}

export class UnauthorizedError extends AppError {
  constructor(message?: string) {
    super(message || Constants.UNAUTHORIZED_REQUEST, ErrorCodes.UNAUTHORIZED);
  }
}

export class NotFoundError extends AppError {
  constructor(message?: string) {
    super(message || Constants.RESOURCE_NOT_FOUND, ErrorCodes.NOT_FOUND);
  }
}

export class BadRequestError extends AppError {
  constructor(message?: string) {
    super(message || Constants.BAD_REQUEST, ErrorCodes.BAD_REQUEST);
  }
}

export class ForbiddenError extends AppError {
  constructor(message?: string) {
    super(message || Constants.FORBIDDEN, ErrorCodes.FORBIDDEN);
  }
}
