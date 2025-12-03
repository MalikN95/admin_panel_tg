import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  CreateDateColumn,
  Index,
  Unique,
} from 'typeorm';
import { Message } from './Message.entity';
import { User } from './User.entity';

@Entity('message_reads')
@Unique(['messageId', 'userId'])
export class MessageRead {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ManyToOne(() => Message, (message) => message.reads)
  @JoinColumn({ name: 'message_id' })
  @Index()
  message: Message;

  @Column({ name: 'message_id' })
  messageId: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'user_id' })
  @Index()
  user: User;

  @Column({ name: 'user_id' })
  userId: string;

  @CreateDateColumn({ name: 'read_at' })
  readAt: Date;
}

