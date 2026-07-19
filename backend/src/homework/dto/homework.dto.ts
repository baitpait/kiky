import {
  IsString,
  IsNotEmpty,
  IsOptional,
  IsInt,
  IsDateString,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';

export class CreateHomeworkDto {
  @ApiProperty()
  @Type(() => Number)
  @IsInt()
  studentId!: number;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  title!: string;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  description!: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsDateString()
  dueDate?: string;
}

export class GradeHomeworkDto {
  @ApiProperty({ example: 'ممتاز' })
  @IsString()
  @IsNotEmpty()
  teacherGrade!: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  teacherNote?: string;
}
