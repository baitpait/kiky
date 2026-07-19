import { IsInt, IsOptional, IsString } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Transform } from 'class-transformer';

export class UploadPhotoDto {
  @ApiProperty()
  @Transform(({ value }) => parseInt(String(value), 10))
  @IsInt()
  studentId!: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  caption?: string;
}

export class RejectPhotoDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  note?: string;
}
