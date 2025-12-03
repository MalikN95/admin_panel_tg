import { IsString, IsOptional, MaxLength } from 'class-validator';

export class UpdateTemplateDto {
  @IsString()
  @IsOptional()
  @MaxLength(255)
  name?: string;

  @IsString()
  @IsOptional()
  text?: string;
}

