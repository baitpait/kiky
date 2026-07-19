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
import {
  CurrentUser,
  JwtPayload,
} from '../common/decorators/current-user.decorator';
import { HomeworkService } from './homework.service';
import { CreateHomeworkDto, GradeHomeworkDto } from './dto/homework.dto';
import { UpdateStudentStickerDto } from '../stickers/dto/stickers.dto';

@ApiTags('Homework')
@ApiBearerAuth()
@Controller()
export class HomeworkController {
  constructor(private homeworkService: HomeworkService) {}

  @Post('homeworks')
  @Roles(UserRole.teacher)
  @ApiOperation({ summary: 'Teacher creates homework' })
  create(
    @CurrentUser() user: JwtPayload,
    @Body() dto: CreateHomeworkDto,
  ) {
    return this.homeworkService.create(user.sub, dto);
  }

  @Get('homeworks/my-students')
  @Roles(UserRole.teacher)
  @ApiOperation({ summary: 'Teacher — all homework assignments' })
  teacherList(@CurrentUser() user: JwtPayload) {
    return this.homeworkService.listForTeacher(user.sub);
  }

  @Get('homeworks/student/:id')
  @Roles(UserRole.parent)
  @ApiOperation({ summary: 'Parent — homework for child' })
  byStudent(
    @CurrentUser() user: JwtPayload,
    @Param('id', ParseIntPipe) studentId: number,
  ) {
    return this.homeworkService.listForStudent(user.sub, studentId);
  }

  @Put('homeworks/:id/confirm')
  @Roles(UserRole.parent)
  @ApiOperation({ summary: 'Parent confirms homework done' })
  confirm(
    @CurrentUser() user: JwtPayload,
    @Param('id', ParseIntPipe) id: number,
  ) {
    return this.homeworkService.confirm(user.sub, id);
  }

  @Put('homeworks/:id/grade')
  @Roles(UserRole.teacher)
  @ApiOperation({ summary: 'Teacher grades homework → triggers AI sticker' })
  grade(
    @CurrentUser() user: JwtPayload,
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: GradeHomeworkDto,
  ) {
    return this.homeworkService.grade(user.sub, id, dto);
  }

  @Get('homeworks/:id/sticker')
  @ApiOperation({ summary: 'Get AI-assigned sticker for homework' })
  sticker(
    @CurrentUser() user: JwtPayload,
    @Param('id', ParseIntPipe) id: number,
  ) {
    return this.homeworkService.getStickerForHomework(user.sub, user.role, id);
  }

  @Get('stickers/active')
  @Roles(UserRole.teacher)
  @ApiOperation({ summary: 'Teacher — active stickers for manual assignment' })
  activeStickers() {
    return this.homeworkService.findActiveStickers();
  }

  @Get('students/:id/stickers')
  @ApiOperation({ summary: 'Student earned stickers' })
  studentStickers(
    @CurrentUser() user: JwtPayload,
    @Param('id', ParseIntPipe) studentId: number,
  ) {
    return this.homeworkService.getStudentStickers(
      user.sub,
      studentId,
      user.role,
    );
  }

  @Put('student-stickers/:id')
  @Roles(UserRole.teacher)
  @ApiOperation({ summary: 'Teacher modifies sticker assignment' })
  updateSticker(
    @CurrentUser() user: JwtPayload,
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateStudentStickerDto,
  ) {
    return this.homeworkService.updateStudentSticker(user.sub, id, dto);
  }

  @Delete('student-stickers/:id')
  @Roles(UserRole.teacher)
  @ApiOperation({ summary: 'Teacher removes sticker assignment' })
  removeSticker(
    @CurrentUser() user: JwtPayload,
    @Param('id', ParseIntPipe) id: number,
  ) {
    return this.homeworkService.removeStudentSticker(user.sub, id);
  }
}
