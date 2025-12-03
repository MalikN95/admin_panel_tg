import { Module, forwardRef } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ChatsController } from './chats.controller';
import { ChatsService } from './chats.service';
import { Chat } from '../entities/Chat.entity';
import { Message } from '../entities/Message.entity';
import { MessageRead } from '../entities/MessageRead.entity';
import { MessageReaction } from '../entities/MessageReaction.entity';
import { ChatUnreadCount } from '../entities/ChatUnreadCount.entity';
import { Tag } from '../entities/Tag.entity';
import { TelegramModule } from '../telegram/telegram.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([Chat, Message, MessageRead, MessageReaction, ChatUnreadCount, Tag]),
    forwardRef(() => TelegramModule),
  ],
  controllers: [ChatsController],
  providers: [ChatsService],
})
export class ChatsModule {}

