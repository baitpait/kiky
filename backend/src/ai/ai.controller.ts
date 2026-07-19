import { Controller, Post, Body } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { IsInt } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty } from '@nestjs/swagger';
import { UserRole } from '@prisma/client';
import { Roles } from '../common/decorators/roles.decorator';
import { AiService } from './ai.service';

class AnalyzeHomeworkDto {
  @ApiProperty()
  @Type(() => Number)
  @IsInt()
  homework_id!: number;

  @ApiProperty()
  @Type(() => Number)
  @IsInt()
  submission_id!: number;
}

@ApiTags('AI (Internal)')
@ApiBearerAuth()
@Roles(UserRole.admin)
@Controller('internal/ai')
export class AiController {
  constructor(private ai: AiService) {}

  @Post('analyze-homework')
  @ApiOperation({ summary: 'Manually trigger AI homework analysis (admin)' })
  analyze(@Body() dto: AnalyzeHomeworkDto) {
    return this.ai.analyzeHomework(dto.homework_id, dto.submission_id);
  }
}
