import { IsString, IsNotEmpty, IsInt } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { Type } from 'class-transformer';

export class StartLiveDto {
  @ApiProperty({ example: 'حصة الصباح' })
  @IsString()
  @IsNotEmpty()
  title!: string;
}

export class EndLiveDto {
  @ApiProperty()
  @Type(() => Number)
  @IsInt()
  streamId!: number;
}
