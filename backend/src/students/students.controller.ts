import { Controller, Get } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { UserRole } from '@prisma/client';
import { Roles } from '../common/decorators/roles.decorator';
import {
  CurrentUser,
  JwtPayload,
} from '../common/decorators/current-user.decorator';
import { StudentsService } from './students.service';

@ApiTags('Students')
@ApiBearerAuth()
@Controller('students')
export class StudentsController {
  constructor(private studentsService: StudentsService) {}

  @Get('my-class')
  @Roles(UserRole.teacher)
  @ApiOperation({ summary: 'Teacher — assigned students' })
  myClass(@CurrentUser() user: JwtPayload) {
    return this.studentsService.myClass(user.sub);
  }

  @Get('my-children')
  @Roles(UserRole.parent)
  @ApiOperation({ summary: 'Parent — linked children' })
  myChildren(@CurrentUser() user: JwtPayload) {
    return this.studentsService.myChildren(user.sub);
  }
}
