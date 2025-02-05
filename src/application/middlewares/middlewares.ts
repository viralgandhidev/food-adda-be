import { NextFunction, Request, Response } from "express";
import { UnauthorizedError } from "../utils/appErrors";
import JwtUtil from "../utils/jwtUtils";
import { inject, injectable } from "inversify";
import { JwtPayload } from "jsonwebtoken";

@injectable()
class Middlewares {
    private jwtUtils: JwtUtil;

    constructor(@inject(JwtUtil) jwtUtils: JwtUtil) {
        this.jwtUtils = jwtUtils;
    }
    public authMiddleWare() {
        return (request: Request, response: Response, next: NextFunction) => {
            if (!request.headers.authorization) {
                throw new UnauthorizedError();
            }

            if (!request.headers.authorization.includes('Bearer ')) {
                throw new UnauthorizedError();
            }

            const accessToken: string = (request.headers.authorization as string).split('Bearer ')[1];
            const decodedToken: string | JwtPayload = this.jwtUtils.verifyToken(accessToken);
            if (!decodedToken) {
                throw new UnauthorizedError();
            }

            next();
        }
    }

    public permissionMiddleWare(roles: string[]) {
        return (request: Request, response: Response, next: NextFunction) => {
            const accessToken: string = (request.headers.authorization as string).split('Bearer ')[1];
            const decodedToken: string | JwtPayload = this.jwtUtils.verifyToken(accessToken);
            const userRoles = decodedToken['roles'];
            if (!roles.includes(userRoles)) {
                throw new UnauthorizedError();
            }

            next();
        }
    }
}

export default Middlewares;