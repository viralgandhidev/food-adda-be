import { SignUpRequest } from "../../../domain/entity/request/signUp/signUp.entity";
import { UserDetails } from "../../../domain/entity/response/userDetails/userDetails.entity";


export default interface UserRepository {
    getAll(): Promise<UserDetails[]>;
    signup(data: SignUpRequest): Promise<UserDetails>;
}