import { Controller, Get } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { BannersService, CalendarService } from '../admin/content.service';
import { UsersService } from '../users/users.service';
import {
  CurrentUser,
  JwtPayload,
} from '../common/decorators/current-user.decorator';
import { UserRole } from '@prisma/client';

@ApiTags('Content')
@ApiBearerAuth()
@Controller()
export class ContentController {
  constructor(
    private bannersService: BannersService,
    private calendarService: CalendarService,
    private usersService: UsersService,
  ) {}

  @Get('banners')
  @ApiOperation({ summary: 'Active banners filtered by user role' })
  async banners(@CurrentUser() user: JwtPayload) {
    const all = await this.bannersService.findAllActive();
    return this.usersService.filterBannersByRole(
      all,
      user.role as UserRole,
    );
  }

  @Get('calendar-events')
  @ApiOperation({ summary: 'Active calendar events' })
  calendarEvents() {
    return this.calendarService.findAllActive();
  }
}
