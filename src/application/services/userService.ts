import {inject, injectable} from 'inversify';
import {
  User,
  UserSignUpDTO,
  UserLoginDTO,
  UserStatus,
} from '../../domain/entities/user';
import {UserRepository} from '../../domain/repositories/userRepository';
import {AppError, BadRequestError, UnauthorizedError} from '../utils/appErrors';
import {JWTUtils} from '../utils/jwtUtils';
import bcrypt from 'bcrypt';
import {TYPES} from '../di/types';
import {Logger} from '../utils/logger';

@injectable()
export class UserService {
  constructor(
    @inject(TYPES.UserRepository) private userRepository: UserRepository,
    @inject(TYPES.JWTUtils) private jwtUtils: JWTUtils,
    @inject(TYPES.Logger) private logger: Logger,
  ) {}

  public async signUp(userSignUpDTO: UserSignUpDTO): Promise<{
    user: Omit<User, 'password_hash'>;
    token: string;
  }> {
    try {
      const existingUser = await this.userRepository.findByEmail(
        userSignUpDTO.email,
      );
      if (existingUser) {
        throw new BadRequestError('User already exists');
      }

      const createdUser = await this.userRepository.create(userSignUpDTO);
      if (!createdUser) {
        throw new BadRequestError('Failed to create user');
      }

      this.logger.info(`User created successfully: ${createdUser.id}`);

      // Create JWT token
      const token = this.jwtUtils.generateToken({
        id: createdUser.id,
        email: createdUser.email,
        user_type: createdUser.user_type,
      });

      // Remove password_hash from response
      const {password_hash, ...userWithoutPassword} = createdUser;

      return {
        user: userWithoutPassword,
        token,
      };
    } catch (error) {
      this.logger.error('Error in signUp:', error);
      throw error;
    }
  }

  async login(credentials: UserLoginDTO): Promise<{user: User; token: string}> {
    // Find user
    const user = await this.userRepository.findByEmail(credentials.email);
    if (!user) {
      this.logger.error('User not found');
      throw new AppError('Invalid email or password', 401);
    }

    // Check password
    const isValidPassword = await bcrypt.compare(
      credentials.password,
      user.password_hash,
    );
    if (!isValidPassword) {
      throw new AppError('Invalid email or password', 401);
    }

    // Check user status
    if (user.status !== UserStatus.ACTIVE) {
      throw new AppError('Account is not active', 403);
    }

    // Update last login
    await this.userRepository.updateLastLogin(user.id!);

    // Generate token
    const token = this.jwtUtils.generateToken({
      id: user.id!,
      email: user.email,
      user_type: user.user_type,
    });

    return {user, token};
  }

  public async updateProfile(
    userId: string,
    updateData: Partial<User>,
  ): Promise<User> {
    try {
      const updatedUser = await this.userRepository.updateProfile(
        userId,
        updateData,
      );
      this.logger.info(`User profile updated: ${userId}`);
      return updatedUser;
    } catch (error) {
      this.logger.error('Error in updateProfile:', error);
      throw error;
    }
  }
}
