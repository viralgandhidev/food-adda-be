export class Constants {
  // Auth related
  public static readonly UNAUTHORIZED = 'Unauthorized access';
  public static readonly UNAUTHORIZED_REQUEST = 'Unauthorized request';
  public static readonly FORBIDDEN = 'Forbidden access';

  // Resource related
  public static readonly RESOURCE_NOT_FOUND = 'Resource not found';
  public static readonly RESOURCE_ALREADY_EXISTS = 'Resource already exists';

  // General errors
  public static readonly SOMETHING_WENT_WRONG = 'Something went wrong';
  public static readonly INVALID_TOKEN = 'Invalid token';
  public static readonly BAD_REQUEST = 'Bad request';
  public static readonly VALIDATION_ERROR = 'Validation error';
}

export const ErrorCodes = {
  NOT_FOUND: 404,
  BAD_REQUEST: 400,
  INTERNAL_SERVER_ERROR: 500,
  UNAUTHORIZED_ERROR: 401,
};

export default Constants;
