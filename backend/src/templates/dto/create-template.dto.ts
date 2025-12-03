import { IsString, IsOptional, MaxLength } from 'class-validator';

export class CreateTemplateDto {
  @IsString()
  @MaxLength(255)
  name: string;

  @IsString()
  @IsOptional()
  text?: string;
}

