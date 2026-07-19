import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  ParseIntPipe,
} from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { UserRole } from '@prisma/client';
import { Roles } from '../common/decorators/roles.decorator';
import { BannersService, CalendarService } from './content.service';
import {
  CreateBannerDto,
  UpdateBannerDto,
  CreateCalendarEventDto,
  UpdateCalendarEventDto,
} from './dto/content.dto';

@ApiTags('Admin — Banners')
@ApiBearerAuth()
@Roles(UserRole.admin)
@Controller('admin/banners')
export class AdminBannersController {
  constructor(private bannersService: BannersService) {}

  @Get()
  list() {
    return this.bannersService.findAllAdmin();
  }

  @Post()
  create(@Body() dto: CreateBannerDto) {
    return this.bannersService.create(dto);
  }

  @Put(':id')
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateBannerDto,
  ) {
    return this.bannersService.update(id, dto);
  }

  @Delete(':id')
  remove(@Param('id', ParseIntPipe) id: number) {
    return this.bannersService.deactivate(id);
  }
}

@ApiTags('Admin — Calendar')
@ApiBearerAuth()
@Roles(UserRole.admin)
@Controller('admin/calendar-events')
export class AdminCalendarController {
  constructor(private calendarService: CalendarService) {}

  @Get()
  list() {
    return this.calendarService.findAllAdmin();
  }

  @Post()
  create(@Body() dto: CreateCalendarEventDto) {
    return this.calendarService.create(dto);
  }

  @Put(':id')
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateCalendarEventDto,
  ) {
    return this.calendarService.update(id, dto);
  }

  @Delete(':id')
  remove(@Param('id', ParseIntPipe) id: number) {
    return this.calendarService.deactivate(id);
  }
}
