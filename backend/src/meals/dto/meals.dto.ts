import { IsInt, IsEnum, IsDateString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { MealType } from '@prisma/client';

export class MealConfirmDto {
  @ApiProperty()
  @Type(() => Number)
  @IsInt()
  studentId!: number;

  @ApiProperty({ example: '2026-07-13' })
  @IsDateString()
  date!: string;

  @ApiProperty({ enum: MealType })
  @IsEnum(MealType)
  mealType!: MealType;
}
