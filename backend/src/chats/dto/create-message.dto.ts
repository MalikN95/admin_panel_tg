import { IsString, IsOptional, IsEnum } from 'class-validator';
import { MessageType } from '../../entities/Message.entity';

export class CreateMessageDto {
  @IsString()
  @IsOptional()
  text?: string;

  @IsString()
  @IsOptional()
  caption?: string;

  @IsString()
  @IsOptional()
  fileId?: string;

  @IsEnum(MessageType)
  @IsOptional()
  messageType?: MessageType;

  @IsString()
  @IsOptional()
  replyToMessageId?: string;
}

