import {
  Controller,
  Get,
  Put,
  Post,
  Body,
  Param,
  ParseIntPipe,
} from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { NotificationsService } from './notifications.service';
import { RegisterDeviceDto } from './dto/notifications.dto';
import {
  CurrentUser,
  JwtPayload,
} from '../common/decorators/current-user.decorator';

@ApiTags('Notifications')
@ApiBearerAuth()
@Controller()
export class NotificationsController {
  constructor(private notificationsService: NotificationsService) {}

  @Post('devices/register')
  @ApiOperation({ summary: 'Register FCM device token' })
  registerDevice(
    @CurrentUser() user: JwtPayload,
    @Body() dto: RegisterDeviceDto,
  ) {
    return this.notificationsService.registerDevice(user.sub, dto);
  }

  @Get('notifications')
  @ApiOperation({ summary: 'List notifications for current user' })
  list(@CurrentUser() user: JwtPayload) {
    return this.notificationsService.listForUser(user.sub, user.role);
  }

  @Get('notifications/unread-count')
  @ApiOperation({ summary: 'Unread notifications count' })
  async unreadCount(@CurrentUser() user: JwtPayload) {
    const count = await this.notificationsService.unreadCount(
      user.sub,
      user.role,
    );
    return { count };
  }

  @Put('notifications/:id/read')
  @ApiOperation({ summary: 'Mark notification as read' })
  markRead(
    @CurrentUser() user: JwtPayload,
    @Param('id', ParseIntPipe) id: number,
  ) {
    return this.notificationsService.markRead(id, user.sub, user.role);
  }
}
