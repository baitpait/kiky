import {
  IsString,
  IsNotEmpty,
  IsOptional,
  IsInt,
  IsBoolean,
  Matches,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional, PartialType } from '@nestjs/swagger';
import { Type } from 'class-transformer';

export class CreateStickerLevelDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  name!: string;

  @ApiProperty({ example: '#6BC04B' })
  @IsString()
  @Matches(/^#[0-9A-Fa-f]{6}$/)
  color!: string;

  @ApiProperty()
  @Type(() => Number)
  @IsInt()
  sortOrder!: number;
}

export class UpdateStickerLevelDto extends PartialType(CreateStickerLevelDto) {
  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}

export class CreateStickerDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  name!: string;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  iconUrl!: string;

  @ApiProperty()
  @Type(() => Number)
  @IsInt()
  levelId!: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  description?: string;
}

export class UpdateStickerDto extends PartialType(CreateStickerDto) {
  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}

export class UpdateStudentStickerDto {
  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  stickerId?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  note?: string;
}
