import { UserType } from "../../../enums/userType";

export class SignUpRequest {
    name: string;
    email: string;
    userType: UserType;

    constructor(model: SignUpRequest) {
        this.name = model.name;
        this.email = model.email;
        this.userType = model.userType;
    }
}