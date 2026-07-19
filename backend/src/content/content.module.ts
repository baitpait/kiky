import { Module } from '@nestjs/common';
import { UsersModule } from '../users/users.module';
import { ContentController } from './content.controller';
import { BannersService, CalendarService } from '../admin/content.service';

@Module({
  imports: [UsersModule],
  controllers: [ContentController],
  providers: [BannersService, CalendarService],
  exports: [BannersService, CalendarService],
})
export class ContentModule {}
