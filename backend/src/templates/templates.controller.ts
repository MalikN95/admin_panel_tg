import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  UseInterceptors,
  UploadedFiles,
  Res,
  HttpStatus,
} from '@nestjs/common';
import { FilesInterceptor } from '@nestjs/platform-express';
import { Response } from 'express';
import { TemplatesService } from './templates.service';
import { CreateTemplateDto } from './dto/create-template.dto';
import { UpdateTemplateDto } from './dto/update-template.dto';
import * as fs from 'fs/promises';

@Controller('templates')
export class TemplatesController {
  constructor(private readonly templatesService: TemplatesService) {}

  @Get()
  async findAll() {
    // TODO: В реальном приложении adminId должен браться из JWT токена
    const adminId = 'default-admin';
    return this.templatesService.findAllByAdmin(adminId);
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    return this.templatesService.findOne(id);
  }

  @Post()
  @UseInterceptors(FilesInterceptor('files'))
  async create(
    @Body() body: any,
    @UploadedFiles() files?: Express.Multer.File[],
  ) {
    // TODO: В реальном приложении adminId должен браться из JWT токена
    const adminId = 'default-admin';
    const createTemplateDto: CreateTemplateDto = {
      name: body.name,
      text: body.text || undefined,
    };
    return this.templatesService.create(adminId, createTemplateDto, files);
  }

  @Patch(':id')
  @UseInterceptors(FilesInterceptor('files'))
  async update(
    @Param('id') id: string,
    @Body() body: any,
    @UploadedFiles() files?: Express.Multer.File[],
  ) {
    const updateTemplateDto: UpdateTemplateDto = {
      name: body.name || undefined,
      text: body.text || undefined,
    };
    return this.templatesService.update(id, updateTemplateDto, files);
  }

  @Delete(':id')
  async delete(@Param('id') id: string) {
    await this.templatesService.delete(id);
    return { message: 'Шаблон успешно удален' };
  }

  @Delete(':id/files/:fileId')
  async deleteFile(
    @Param('id') id: string,
    @Param('fileId') fileId: string,
  ) {
    await this.templatesService.deleteFile(fileId);
    return { message: 'Файл успешно удален' };
  }

  @Get(':id/files/:fileId')
  async downloadFile(
    @Param('id') id: string,
    @Param('fileId') fileId: string,
    @Res() res: Response,
  ) {
    try {
      const filePath = await this.templatesService.getFilePath(fileId);
      const fileBuffer = await fs.readFile(filePath);
      
      res.setHeader('Content-Type', 'application/octet-stream');
      res.setHeader('Access-Control-Allow-Origin', '*');
      res.send(fileBuffer);
    } catch (error) {
      res.status(HttpStatus.NOT_FOUND).json({ message: 'Файл не найден' });
    }
  }
}

