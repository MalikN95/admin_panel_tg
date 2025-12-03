import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { Template } from './Template.entity';

@Entity('template_files')
export class TemplateFile {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'template_id', type: 'uuid' })
  templateId: string;

  @ManyToOne(() => Template, (template) => template.files, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'template_id' })
  template: Template;

  @Column({ name: 'file_name', type: 'varchar', length: 255 })
  fileName: string;

  @Column({ name: 'file_path', type: 'varchar', length: 500 })
  filePath: string;

  @Column({ name: 'file_type', type: 'varchar', length: 100 })
  fileType: string;

  @Column({ name: 'file_size', type: 'bigint' })
  fileSize: number;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}

