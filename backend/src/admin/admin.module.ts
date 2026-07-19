import { Module } from '@nestjs/common';
import { AdminController } from './admin.controller';
import { AdminService } from './admin.service';
import { AdminContentController } from './admin-content.controller';
import {
  AdminBannersController,
  AdminCalendarController,
} from './admin-banners.controller';
import { AdminStickersController } from './admin-stickers.controller';
import { BannersService, CalendarService } from './content.service';
import { StickersAdminService } from './stickers-admin.service';
import { PhotosModule } from '../photos/photos.module';
import { NotificationsModule } from '../notifications/notifications.module';
import { UsersModule } from '../users/users.module';

@Module({
  imports: [PhotosModule, NotificationsModule, UsersModule],
  controllers: [
    AdminController,
    AdminContentController,
    AdminBannersController,
    AdminCalendarController,
    AdminStickersController,
  ],
  providers: [AdminService, BannersService, CalendarService, StickersAdminService],
  exports: [BannersService, CalendarService],
})
export class AdminModule {}
