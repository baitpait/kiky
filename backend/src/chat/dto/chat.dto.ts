import { IsString, IsNotEmpty, IsOptional, IsInt } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';

export class CreateConversationDto {
  @ApiProperty({ description: 'Student ID to open chat about' })
  @Type(() => Number)
  @IsInt()
  studentId!: number;
}

export class SendMessageDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  body!: string;
}

export class WsSendMessageDto {
  conversationId!: number;
  body!: string;
}

export class WsJoinDto {
  conversationId!: number;
}
