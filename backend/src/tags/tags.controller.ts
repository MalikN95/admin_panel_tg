import { Controller, Get, UseGuards } from '@nestjs/common';
import { TagsService } from './tags.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('tags')
export class TagsController {
  constructor(private readonly tagsService: TagsService) {}

  @Get()
  @UseGuards(JwtAuthGuard)
  async getAllTags() {
    return this.tagsService.getAllTags();
  }
}

