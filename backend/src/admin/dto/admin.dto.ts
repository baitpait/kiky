import {
  IsString,
  IsNotEmpty,
  IsOptional,
  MinLength,
  IsDateString,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional, PartialType } from '@nestjs/swagger';

export class CreateTeacherDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  username!: string;

  @ApiProperty()
  @IsString()
  @MinLength(6)
  password!: string;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  name!: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  phone?: string;
}

export class UpdateTeacherDto extends PartialType(CreateTeacherDto) {}

export class CreateParentDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  username!: string;

  @ApiProperty()
  @IsString()
  @MinLength(6)
  password!: string;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  name!: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  phone?: string;
}

export class UpdateParentDto extends PartialType(CreateParentDto) {}

export class CreateStudentDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  name!: string;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  className!: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsDateString()
  birthDate?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  avatarUrl?: string;
}

export class UpdateStudentDto extends PartialType(CreateStudentDto) {}

import { IsInt } from 'class-validator';
import { Type } from 'class-transformer';

export class LinkParentDto {
  @ApiProperty()
  @Type(() => Number)
  @IsInt()
  parentId!: number;
}

export class LinkTeacherDto {
  @ApiProperty()
  @Type(() => Number)
  @IsInt()
  teacherId!: number;
}
