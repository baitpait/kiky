import { IsInt, IsEnum, IsOptional, IsString, IsDateString } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { AttendanceType } from '@prisma/client';

export class RecordAttendanceDto {
  @ApiProperty()
  @Type(() => Number)
  @IsInt()
  studentId!: number;

  @ApiProperty({ enum: AttendanceType })
  @IsEnum(AttendanceType)
  type!: AttendanceType;

  @ApiProperty({ example: '2026-07-13' })
  @IsDateString()
  date!: string;

  @ApiPropertyOptional({ example: '08:30:00' })
  @IsOptional()
  @IsString()
  time?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  note?: string;
}
