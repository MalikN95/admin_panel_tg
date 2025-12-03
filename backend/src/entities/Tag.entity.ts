import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToMany,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';
import { Chat } from './Chat.entity';

export enum TagType {
  HOT = 'hot',
  WARM = 'warm',
  COLD = 'cold',
}

@Entity('tags')
export class Tag {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'varchar', length: 50, unique: true })
  name: string;

  @Column({
    type: 'enum',
    enum: TagType,
    name: 'tag_type',
  })
  tagType: TagType;

  @Column({ type: 'varchar', length: 7, nullable: true })
  color: string | null; // HEX цвет для отображения

  @ManyToMany(() => Chat, (chat) => chat.tags)
  chats: Chat[];

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}

