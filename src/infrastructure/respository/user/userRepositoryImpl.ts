import { SignUpRequest } from "../../../domain/entity/request/signUp/signUp.entity";
import { UserDetails } from "../../../domain/entity/response/userDetails/userDetails.entity";
import { UserType } from "../../../domain/enums/userType";
import UserRepository from "./userRepository";

class UserRepositoryImpl implements UserRepository {
    public signup(data: SignUpRequest): Promise<UserDetails> {
        const user: UserDetails = new UserDetails({ userId: 1, name: data.name, email: data.email, userType: data.userType });
        return Promise.resolve(user)
    }

    public getAll(): Promise<UserDetails[]> {
        const users: UserDetails[] = [
            new UserDetails({ userId: 1, name: "Test", email: "test@test.com", userType: UserType.ADMIN }),
            new UserDetails({ userId: 2, name: "Test 1", email: "test1@test.com", userType: UserType.USER })
        ];
        return Promise.resolve(users);
    }

}

export default UserRepositoryImpl;