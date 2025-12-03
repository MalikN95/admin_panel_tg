import { IsEmail, IsString } from 'class-validator';

export class LoginDto {
  @IsEmail({}, { message: 'Email должен быть валидным' })
  email: string;

  @IsString()
  password: string;
}

