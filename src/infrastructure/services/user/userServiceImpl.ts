import { inject, injectable } from "inversify";
import { UserDetails } from "../../../domain/entity/response/userDetails/userDetails.entity";
import UserService from "./userService";
import UserRepository from "../../respository/user/userRepository";
import { TYPES } from "../../../application/di/types";
import { SignUpRequest } from "../../../domain/entity/request/signUp/signUp.entity";
import { BadRequestError } from "../../../application/utils/appErrors";
import { isEmpty, isEmail } from "validator";
import Constants from "../../../application/utils/constants";
import JwtUtil from "../../../application/utils/jwtUtils";

@injectable()
class UserServiceImpl implements UserService {
    private userRepository: UserRepository;
    private jwtUtils: JwtUtil;

    constructor(@inject(TYPES.USER_REPOSITORY_IMPL) userRepository: UserRepository, @inject(JwtUtil) jwtUtils: JwtUtil) {
        this.userRepository = userRepository;
        this.jwtUtils = jwtUtils;
    }

    // end point handlers
    public async signUp(data: SignUpRequest): Promise<UserDetails> {
        if (this.validateSignUpRequest(data)) {
            const user : UserDetails = await this.userRepository.signup(data);
            const payloadToken = {userId: user.userId, roles: user.userType}
            const accessToken = this.jwtUtils.signToken(payloadToken);
            user.accessToken = accessToken;
            return Promise.resolve(user);
        }
    }

    public async getAll(): Promise<UserDetails[]> {
        const users: UserDetails[] = await this.userRepository.getAll();;
        return Promise.resolve(users);
    }

    // validators
    private validateSignUpRequest(data: SignUpRequest): Boolean {
        if (!data.email || isEmpty(data.email.trim())) {
            throw new BadRequestError(Constants.ENTER_EMAIL);
        }

        if (!data.name || isEmpty(data.name.trim())) {
            throw new BadRequestError(Constants.ENTER_NAME);
        }

        if (!data.userType || isEmpty(data.userType.trim())) {
            throw new BadRequestError(Constants.ENTER_ROLE);
        }

        if (!isEmail(data.email)) {
            throw new BadRequestError(Constants.ENTER_VALID_EMAIL)
        }
        return true;
    }
}

export default UserServiceImpl;