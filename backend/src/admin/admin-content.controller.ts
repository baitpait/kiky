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
import { UserRole } from '@prisma/client';
import { Roles } from '../common/decorators/roles.decorator';
import {
  CurrentUser,
  JwtPayload,
} from '../common/decorators/current-user.decorator';
import { PhotosService } from '../photos/photos.service';
import { PushService } from '../notifications/push.service';
import { UsersService } from '../users/users.service';
import { RejectPhotoDto } from '../photos/dto/photos.dto';
import { SendNotificationDto } from '../notifications/dto/notifications.dto';
import { NotificationTarget } from '@prisma/client';

@ApiTags('Admin — Content')
@ApiBearerAuth()
@Roles(UserRole.admin)
@Controller('admin')
export class AdminContentController {
  constructor(
    private photosService: PhotosService,
    private pushService: PushService,
    private usersService: UsersService,
  ) {}

  @Get('photos/pending')
  @ApiOperation({ summary: 'List photos pending approval' })
  pendingPhotos() {
    return this.photosService.findPending();
  }

  @Put('photos/:id/approve')
  @ApiOperation({ summary: 'Approve photo — notifies parents' })
  async approvePhoto(
    @CurrentUser() user: JwtPayload,
    @Param('id', ParseIntPipe) id: number,
  ) {
    const photo = await this.photosService.approve(id, user.sub);
    const parentIds = await this.usersService.getParentUserIdsForStudent(
      photo.studentId,
    );
    await this.pushService.notifyUsers(
      parentIds,
      'صورة جديدة',
      `صورة جديدة لـ ${photo.student.name} في ألبوم الروضة`,
    );
    return photo;
  }

  @Put('photos/:id/reject')
  @ApiOperation({ summary: 'Reject photo' })
  rejectPhoto(
    @CurrentUser() user: JwtPayload,
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: RejectPhotoDto,
  ) {
    return this.photosService.reject(id, user.sub, dto.note);
  }

  @Post('notifications/send')
  @ApiOperation({ summary: 'Send push notification to target group' })
  sendNotification(
    @CurrentUser() user: JwtPayload,
    @Body() dto: SendNotificationDto,
  ) {
    return this.pushService.notifyByTarget(
      dto.target as NotificationTarget,
      dto.title,
      dto.body,
      user.sub,
    );
  }
}
