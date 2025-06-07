import {injectable} from 'inversify';
import jwt from 'jsonwebtoken';
import {UserType} from '../../domain/entities';

@injectable()
export class JWTUtils {
  private readonly secret: string;

  constructor() {
    this.secret = process.env.JWT_SECRET || 'your-secret-key';
  }

  generateToken(payload: {
    id: string;
    email: string;
    user_type: UserType;
  }): string {
    return jwt.sign(payload, this.secret, {expiresIn: '24h'});
  }

  verifyToken(token: string): any {
    return jwt.verify(token, this.secret);
  }
}
