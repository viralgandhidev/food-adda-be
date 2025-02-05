import { UserType } from "../../../enums/userType";


export class UserDetails {
    userId: number;
    name: string;
    email: string;
    userType: UserType;
    accessToken?: string;

    constructor(model: UserDetails) {
        this.userId = model.userId;
        this.name = model.name;
        this.email = model.email;
        this.userType = model.userType;
        this.accessToken = model.accessToken;
    }
}