import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
  Unique,
} from 'typeorm';
import { Chat } from './Chat.entity';
import { User } from './User.entity';
import { Message } from './Message.entity';

@Entity('chat_unread_counts')
@Unique(['chatId', 'userId'])
export class ChatUnreadCount {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ManyToOne(() => Chat, (chat) => chat.unreadCounts)
  @JoinColumn({ name: 'chat_id' })
  @Index()
  chat: Chat;

  @Column({ name: 'chat_id' })
  chatId: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'user_id' })
  @Index()
  user: User;

  @Column({ name: 'user_id' })
  userId: string;

  @Column({ type: 'int', default: 0 })
  unreadCount: number;

  @ManyToOne(() => Message, { nullable: true })
  @JoinColumn({ name: 'last_read_message_id' })
  lastReadMessage: Message | null;

  @Column({ name: 'last_read_message_id', nullable: true })
  lastReadMessageId: string | null;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}

