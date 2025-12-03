import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Template } from '../entities/Template.entity';
import { TemplateFile } from '../entities/TemplateFile.entity';
import { CreateTemplateDto } from './dto/create-template.dto';
import { UpdateTemplateDto } from './dto/update-template.dto';
import * as fs from 'fs/promises';
import * as path from 'path';

@Injectable()
export class TemplatesService {
  private readonly uploadDir = path.join(process.cwd(), 'uploads', 'templates');

  constructor(
    @InjectRepository(Template)
    private templateRepository: Repository<Template>,
    @InjectRepository(TemplateFile)
    private templateFileRepository: Repository<TemplateFile>,
  ) {
    this.ensureUploadDir();
  }

  private async ensureUploadDir() {
    try {
      await fs.mkdir(this.uploadDir, { recursive: true });
    } catch (error) {
      console.error('Error creating upload directory:', error);
    }
  }

  async findAllByAdmin(adminId: string): Promise<Template[]> {
    return this.templateRepository.find({
      where: { adminId },
      relations: ['files'],
      order: { createdAt: 'DESC' },
    });
  }

  async findOne(id: string): Promise<Template> {
    const template = await this.templateRepository.findOne({
      where: { id },
      relations: ['files'],
    });

    if (!template) {
      throw new NotFoundException('Шаблон не найден');
    }

    return template;
  }

  async create(
    adminId: string,
    createTemplateDto: CreateTemplateDto,
    files?: Express.Multer.File[],
  ): Promise<Template> {
    const template = this.templateRepository.create({
      ...createTemplateDto,
      adminId,
    });

    const savedTemplate = await this.templateRepository.save(template);

    if (files && files.length > 0) {
      const templateFiles = await Promise.all(
        files.map(async (file) => {
          const fileName = `${Date.now()}-${file.originalname}`;
          const filePath = path.join(this.uploadDir, fileName);

          await fs.writeFile(filePath, file.buffer);

          return this.templateFileRepository.create({
            templateId: savedTemplate.id,
            fileName: file.originalname,
            filePath: fileName,
            fileType: file.mimetype,
            fileSize: file.size,
          });
        }),
      );

      await this.templateFileRepository.save(templateFiles);
      savedTemplate.files = templateFiles;
    }

    return savedTemplate;
  }

  async update(
    id: string,
    updateTemplateDto: UpdateTemplateDto,
    files?: Express.Multer.File[],
  ): Promise<Template> {
    const template = await this.findOne(id);

    if (updateTemplateDto.name) {
      template.name = updateTemplateDto.name;
    }

    if (updateTemplateDto.text !== undefined) {
      template.text = updateTemplateDto.text;
    }

    await this.templateRepository.save(template);

    if (files && files.length > 0) {
      const templateFiles = await Promise.all(
        files.map(async (file) => {
          const fileName = `${Date.now()}-${file.originalname}`;
          const filePath = path.join(this.uploadDir, fileName);

          await fs.writeFile(filePath, file.buffer);

          return this.templateFileRepository.create({
            templateId: template.id,
            fileName: file.originalname,
            filePath: fileName,
            fileType: file.mimetype,
            fileSize: file.size,
          });
        }),
      );

      await this.templateFileRepository.save(templateFiles);
    }

    return this.findOne(id);
  }

  async deleteFile(fileId: string): Promise<void> {
    const file = await this.templateFileRepository.findOne({
      where: { id: fileId },
    });

    if (!file) {
      throw new NotFoundException('Файл не найден');
    }

    const filePath = path.join(this.uploadDir, file.filePath);
    try {
      await fs.unlink(filePath);
    } catch (error) {
      console.error('Error deleting file:', error);
    }

    await this.templateFileRepository.remove(file);
  }

  async delete(id: string): Promise<void> {
    const template = await this.findOne(id);

    // Удаляем все файлы шаблона
    if (template.files && template.files.length > 0) {
      await Promise.all(
        template.files.map(async (file) => {
          const filePath = path.join(this.uploadDir, file.filePath);
          try {
            await fs.unlink(filePath);
          } catch (error) {
            console.error('Error deleting file:', error);
          }
        }),
      );
    }

    await this.templateRepository.remove(template);
  }

  async getFilePath(fileId: string): Promise<string> {
    const file = await this.templateFileRepository.findOne({
      where: { id: fileId },
    });

    if (!file) {
      throw new NotFoundException('Файл не найден');
    }

    return path.join(this.uploadDir, file.filePath);
  }
}

