import {User, UserSignUpDTO} from '../entities';

export interface UserRepository {
  create(user: UserSignUpDTO): Promise<User>;
  findByEmail(email: string): Promise<User | null>;
  findById(id: string): Promise<User | null>;
  updateLastLogin(userId: string): Promise<void>;
}
