import { Controller, Get, Post, Body, Param, ParseIntPipe } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { UserRole } from '@prisma/client';
import { Roles } from '../common/decorators/roles.decorator';
import {
  CurrentUser,
  JwtPayload,
} from '../common/decorators/current-user.decorator';
import { AttendanceService } from './attendance.service';
import { RecordAttendanceDto } from './dto/attendance.dto';

@ApiTags('Attendance')
@ApiBearerAuth()
@Controller('attendance')
export class AttendanceController {
  constructor(private attendanceService: AttendanceService) {}

  @Post()
  @Roles(UserRole.teacher)
  @ApiOperation({ summary: 'Teacher records attendance' })
  record(
    @CurrentUser() user: JwtPayload,
    @Body() dto: RecordAttendanceDto,
  ) {
    return this.attendanceService.record(user.sub, dto);
  }

  @Get('today')
  @Roles(UserRole.teacher)
  @ApiOperation({ summary: 'Teacher — today attendance' })
  today(@CurrentUser() user: JwtPayload) {
    return this.attendanceService.todayForTeacher(user.sub);
  }

  @Get('student/:id')
  @Roles(UserRole.parent)
  @ApiOperation({ summary: 'Parent — child attendance history' })
  byStudent(
    @CurrentUser() user: JwtPayload,
    @Param('id', ParseIntPipe) studentId: number,
  ) {
    return this.attendanceService.historyForStudent(user.sub, studentId);
  }
}
