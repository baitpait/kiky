import { Controller, Get, Post, Body, Param, ParseIntPipe } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { UserRole } from '@prisma/client';
import { Roles } from '../common/decorators/roles.decorator';
import {
  CurrentUser,
  JwtPayload,
} from '../common/decorators/current-user.decorator';
import { MealsService } from './meals.service';
import { MealConfirmDto } from './dto/meals.dto';

@ApiTags('Meals')
@ApiBearerAuth()
@Controller('meals')
export class MealsController {
  constructor(private mealsService: MealsService) {}

  @Post('teacher-confirm')
  @Roles(UserRole.teacher)
  @ApiOperation({ summary: 'Teacher confirms meal at kindergarten' })
  teacherConfirm(
    @CurrentUser() user: JwtPayload,
    @Body() dto: MealConfirmDto,
  ) {
    return this.mealsService.teacherConfirm(user.sub, dto);
  }

  @Post('parent-confirm')
  @Roles(UserRole.parent)
  @ApiOperation({ summary: 'Parent confirms meal at home' })
  parentConfirm(
    @CurrentUser() user: JwtPayload,
    @Body() dto: MealConfirmDto,
  ) {
    return this.mealsService.parentConfirm(user.sub, dto);
  }

  @Get('student/:id')
  @Roles(UserRole.parent)
  @ApiOperation({ summary: 'Parent — meal history for child' })
  byStudent(
    @CurrentUser() user: JwtPayload,
    @Param('id', ParseIntPipe) studentId: number,
  ) {
    return this.mealsService.historyForStudent(user.sub, studentId);
  }

  @Get('today')
  @Roles(UserRole.teacher)
  @ApiOperation({ summary: 'Teacher — today meal confirmations' })
  today(@CurrentUser() user: JwtPayload) {
    return this.mealsService.todayForTeacher(user.sub);
  }
}
