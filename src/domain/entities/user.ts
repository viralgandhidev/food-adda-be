export enum UserType {
  CONSUMER = 'CONSUMER',
  SELLER = 'SELLER',
  ADMIN = 'ADMIN',
}

export enum UserStatus {
  ACTIVE = 'ACTIVE',
  INACTIVE = 'INACTIVE',
  SUSPENDED = 'SUSPENDED',
}

export interface User {
  id?: string;
  email: string;
  password_hash: string;
  first_name: string;
  last_name: string;
  phone_number?: string;
  user_type: UserType;
  status: UserStatus;
  profile_image_url?: string;
  address?: string;
  preferred_language?: string;
  notification_preferences?: object;
  created_at?: Date;
  updated_at?: Date;
}

export interface UserSignUpDTO {
  email: string;
  password: string;
  first_name: string;
  last_name: string;
  phone_number?: string;
  user_type: UserType;
  address?: string;
}

export interface UserLoginDTO {
  email: string;
  password: string;
}
