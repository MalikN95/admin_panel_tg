import { IsString, IsNotEmpty } from 'class-validator';

export class CreateBotDto {
  @IsString()
  @IsNotEmpty()
  token: string;
}

