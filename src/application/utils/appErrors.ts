import Constants, { ErrorCodes } from "./constants";

export class AppError extends Error {
    public code: number = null;
    public message: string = null;

    constructor(code: number, message: string) {
        super();
        this.code = code;

        if (message) {
        this.message = message;
        } else {
            Constants.SOMETHING_WENT_WRONG;
        }
        Object.setPrototypeOf(this, new.target.prototype);
    }
}

export class BadRequestError extends AppError {
    constructor(message: string) {
        super(ErrorCodes.BAD_REQUEST, message);
    }
}

export class UnauthorizedError extends AppError {
    constructor(message?: string) {
        super(ErrorCodes.UNAUTHORIZED_ERROR, message || Constants.UNAUTHORIZED_REQUEST);
    }
}

export class NotFoundError extends AppError {
    constructor(message?: string) {
        super(ErrorCodes.NOT_FOUND, message || Constants.RESOURCE_NOT_FOUND);
    }
}