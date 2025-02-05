import { SignUpRequest } from "../../../domain/entity/request/signUp/signUp.entity";
import { UserDetails } from "../../../domain/entity/response/userDetails/userDetails.entity";

export default interface UserService {
    getAll(): Promise<UserDetails[]>;
    signUp(data: SignUpRequest): Promise<UserDetails>;
}