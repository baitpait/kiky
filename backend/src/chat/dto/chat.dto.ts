import { IsString, IsNotEmpty, IsOptional, IsInt, IsIn } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';

export class CreateConversationDto {
  @ApiPropertyOptional({ description: 'Student context when needed' })
  @Type(() => Number)
  @IsOptional()
  @IsInt()
  studentId?: number;

  @ApiPropertyOptional({
    enum: ['teacher', 'parent', 'admin'],
    description: 'Who to chat with (depends on caller role)',
  })
  @IsOptional()
  @IsString()
  @IsIn(['teacher', 'parent', 'admin'])
  targetRole?: string;

  @ApiPropertyOptional({ description: 'Teacher profile id (admin → teacher)' })
  @Type(() => Number)
  @IsOptional()
  @IsInt()
  teacherId?: number;

  @ApiPropertyOptional({ description: 'Parent profile id (admin/teacher → parent)' })
  @Type(() => Number)
  @IsOptional()
  @IsInt()
  parentId?: number;
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
