import { IsString, IsNotEmpty, IsIn } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class RegisterDeviceDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  token!: string;

  @ApiProperty({ example: 'android' })
  @IsString()
  @IsIn(['android', 'ios'])
  platform!: string;
}

export class SendNotificationDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  title!: string;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  body!: string;

  @ApiProperty({ enum: ['all', 'teachers', 'parents'] })
  @IsString()
  @IsIn(['all', 'teachers', 'parents'])
  target!: 'all' | 'teachers' | 'parents';
}
