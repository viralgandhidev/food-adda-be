import {NextFunction, Request, Response} from 'express';
import {UnauthorizedError} from '../utils/appErrors';
import {JWTUtils} from '../utils/jwtUtils';
import {inject, injectable} from 'inversify';
import {JwtPayload} from 'jsonwebtoken';
import {TYPES} from '../../types';
import {Constants} from '../utils/constants';

@injectable()
export class Middleware {
  constructor(@inject(TYPES.JWTUtils) private jwtUtils: JWTUtils) {}

  public async authenticateToken(
    req: Request,
    res: Response,
    next: NextFunction,
  ) {
    try {
      const authHeader = req.headers['authorization'];
      const token = authHeader && authHeader.split(' ')[1];

      if (!token) {
        return res.status(401).send({message: Constants.UNAUTHORIZED});
      }

      try {
        const user = this.jwtUtils.verifyToken(token);
        req['user'] = user;
        next();
      } catch (error) {
        return res.status(403).send({message: Constants.FORBIDDEN});
      }
    } catch (error) {
      return res.status(403).send({message: Constants.FORBIDDEN});
    }
  }

  public permissionMiddleWare(roles: string[]) {
    return (request: Request, response: Response, next: NextFunction) => {
      const accessToken: string = (
        request.headers.authorization as string
      ).split('Bearer ')[1];
      const decodedToken: string | JwtPayload =
        this.jwtUtils.verifyToken(accessToken);
      const userRoles = decodedToken['roles'];
      if (!roles.includes(userRoles)) {
        throw new UnauthorizedError();
      }

      next();
    };
  }
}
