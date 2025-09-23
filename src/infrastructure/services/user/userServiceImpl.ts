import {inject, injectable} from 'inversify';
import {UserDetails} from '../../../domain/entity/response/userDetails/userDetails.entity';
import UserService from './userService';
import UserRepository from '../../respository/user/userRepository';
import {TYPES} from '../../../application/di/types';
import {SignUpRequest} from '../../../domain/entity/request/signUp/signUp.entity';
import {BadRequestError} from '../../../application/utils/appErrors';
import {isEmpty, isEmail} from 'validator';
import Constants from '../../../application/utils/constants';
import {JWTUtils} from '../../../application/utils/jwtUtils';

@injectable()
class UserServiceImpl implements UserService {
  private userRepository: UserRepository;
  private jwtUtils: JWTUtils;

  constructor(
    @inject(TYPES.USER_REPOSITORY_IMPL) userRepository: UserRepository,
    @inject(TYPES.JWTUtils) jwtUtils: JWTUtils,
  ) {
    this.userRepository = userRepository;
    this.jwtUtils = jwtUtils;
  }

  // end point handlers
  public async signUp(data: SignUpRequest): Promise<UserDetails> {
    if (this.validateSignUpRequest(data)) {
      const user: UserDetails = await this.userRepository.signup(data);
      const payloadToken = {
        id: String(user.userId),
        email: user.email,
        user_type: user.userType as any,
      };
      const accessToken = this.jwtUtils.generateToken(payloadToken);
      user.accessToken = accessToken;
      return Promise.resolve(user);
    }
  }

  public async getAll(): Promise<UserDetails[]> {
    const users: UserDetails[] = await this.userRepository.getAll();
    return Promise.resolve(users);
  }

  // validators
  private validateSignUpRequest(data: SignUpRequest): Boolean {
    if (!data.email || isEmpty(data.email.trim())) {
      throw new BadRequestError(Constants.BAD_REQUEST);
    }

    if (!data.name || isEmpty(data.name.trim())) {
      throw new BadRequestError(Constants.BAD_REQUEST);
    }

    if (!data.userType || isEmpty(data.userType.trim())) {
      throw new BadRequestError(Constants.BAD_REQUEST);
    }

    if (!isEmail(data.email)) {
      throw new BadRequestError(Constants.VALIDATION_ERROR);
    }
    return true;
  }
}

export default UserServiceImpl;
