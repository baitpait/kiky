import {
  Controller,
  Get,
  Post,
  Put,
  Body,
  Param,
  ParseIntPipe,
  UseInterceptors,
  UploadedFile,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import {
  ApiTags,
  ApiBearerAuth,
  ApiOperation,
  ApiConsumes,
  ApiBody,
} from '@nestjs/swagger';
import { UserRole } from '@prisma/client';
import { Roles } from '../common/decorators/roles.decorator';
import {
  CurrentUser,
  JwtPayload,
} from '../common/decorators/current-user.decorator';
import { ChatService } from './chat.service';
import { ChatGateway } from './chat.gateway';
import { CreateConversationDto, SendMessageDto } from './dto/chat.dto';

@ApiTags('Chat')
@ApiBearerAuth()
@Roles(UserRole.teacher, UserRole.parent)
@Controller('conversations')
export class ChatController {
  constructor(
    private chatService: ChatService,
    private chatGateway: ChatGateway,
  ) {}

  @Get()
  @ApiOperation({ summary: 'List conversations for current user' })
  list(@CurrentUser() user: JwtPayload) {
    return this.chatService.listConversations(
      user.sub,
      user.role as UserRole,
    );
  }

  @Post()
  @Roles(UserRole.parent)
  @ApiOperation({ summary: 'Parent opens chat with child teacher' })
  create(
    @CurrentUser() user: JwtPayload,
    @Body() dto: CreateConversationDto,
  ) {
    return this.chatService.getOrCreateConversation(user.sub, dto.studentId);
  }

  @Get(':id/messages')
  @ApiOperation({ summary: 'Get messages in conversation' })
  messages(
    @CurrentUser() user: JwtPayload,
    @Param('id', ParseIntPipe) id: number,
  ) {
    return this.chatService.getMessages(id, user.sub, user.role as UserRole);
  }

  @Post(':id/messages')
  @ApiOperation({ summary: 'Send text message' })
  async sendMessage(
    @CurrentUser() user: JwtPayload,
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: SendMessageDto,
  ) {
    const message = await this.chatService.sendMessage(
      id,
      user.sub,
      user.role as UserRole,
      dto.body,
    );
    this.chatGateway.broadcastMessage(id, message);
    return message;
  }

  @Post(':id/attachments')
  @UseInterceptors(FileInterceptor('file'))
  @ApiConsumes('multipart/form-data')
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        file: { type: 'string', format: 'binary' },
        body: { type: 'string' },
      },
      required: ['file'],
    },
  })
  @ApiOperation({ summary: 'Send message with image attachment' })
  async sendAttachment(
    @CurrentUser() user: JwtPayload,
    @Param('id', ParseIntPipe) id: number,
    @UploadedFile() file: Express.Multer.File,
    @Body('body') body?: string,
  ) {
    const message = await this.chatService.sendAttachment(
      id,
      user.sub,
      user.role as UserRole,
      file,
      body,
    );
    if (message) this.chatGateway.broadcastMessage(id, message);
    return message;
  }

  @Put(':id/read')
  @ApiOperation({ summary: 'Mark conversation messages as read' })
  markRead(
    @CurrentUser() user: JwtPayload,
    @Param('id', ParseIntPipe) id: number,
  ) {
    return this.chatService.markConversationRead(
      id,
      user.sub,
      user.role as UserRole,
    );
  }
}
