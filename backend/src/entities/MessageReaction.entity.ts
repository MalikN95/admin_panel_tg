import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { Message } from './Message.entity';

@Entity('message_reactions')
export class MessageReaction {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'message_id' })
  messageId: string;

  @ManyToOne(() => Message, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'message_id' })
  message: Message;

  @Column()
  emoji: string;

  @Column({ name: 'admin_id', nullable: true })
  adminId: string; // ID админа, который поставил реакцию

  @Column({ default: false })
  isFromTelegram: boolean; // Реакция пришла из Telegram

  @CreateDateColumn()
  createdAt: Date;
}

