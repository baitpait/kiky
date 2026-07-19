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
import { AdminService } from './admin.service';
import {
  CreateTeacherDto,
  UpdateTeacherDto,
  CreateParentDto,
  UpdateParentDto,
  CreateStudentDto,
  UpdateStudentDto,
  LinkParentDto,
  LinkTeacherDto,
} from './dto/admin.dto';

@ApiTags('Admin')
@ApiBearerAuth()
@Roles(UserRole.admin)
@Controller('admin')
export class AdminController {
  constructor(private adminService: AdminService) {}

  @Get('stats')
  @ApiOperation({ summary: 'Dashboard counts for admin home' })
  getStats() {
    return this.adminService.getDashboardStats();
  }

  // Teachers
  @Get('teachers')
  @ApiOperation({ summary: 'List all teachers' })
  findAllTeachers() {
    return this.adminService.findAllTeachers();
  }

  @Get('teachers/options')
  @ApiOperation({ summary: 'Lightweight teacher list for dropdowns' })
  listTeacherOptions() {
    return this.adminService.listTeacherOptions();
  }

  @Get('teachers/:id')
  @ApiOperation({ summary: 'Get teacher by ID' })
  findTeacher(@Param('id', ParseIntPipe) id: number) {
    return this.adminService.findTeacher(id);
  }

  @Post('teachers')
  @ApiOperation({ summary: 'Create teacher account' })
  createTeacher(@Body() dto: CreateTeacherDto) {
    return this.adminService.createTeacher(dto);
  }

  @Put('teachers/:id')
  @ApiOperation({ summary: 'Update teacher' })
  updateTeacher(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateTeacherDto,
  ) {
    return this.adminService.updateTeacher(id, dto);
  }

  @Delete('teachers/:id')
  @ApiOperation({ summary: 'Deactivate teacher (soft delete)' })
  deleteTeacher(@Param('id', ParseIntPipe) id: number) {
    return this.adminService.deleteTeacher(id);
  }

  // Parents
  @Get('parents')
  @ApiOperation({ summary: 'List all parents' })
  findAllParents() {
    return this.adminService.findAllParents();
  }

  @Get('parents/options')
  @ApiOperation({ summary: 'Lightweight parent list for dropdowns' })
  listParentOptions() {
    return this.adminService.listParentOptions();
  }

  @Get('parents/:id')
  @ApiOperation({ summary: 'Get parent by ID' })
  findParent(@Param('id', ParseIntPipe) id: number) {
    return this.adminService.findParent(id);
  }

  @Post('parents')
  @ApiOperation({ summary: 'Create parent account' })
  createParent(@Body() dto: CreateParentDto) {
    return this.adminService.createParent(dto);
  }

  @Put('parents/:id')
  @ApiOperation({ summary: 'Update parent' })
  updateParent(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateParentDto,
  ) {
    return this.adminService.updateParent(id, dto);
  }

  @Delete('parents/:id')
  @ApiOperation({ summary: 'Deactivate parent (soft delete)' })
  deleteParent(@Param('id', ParseIntPipe) id: number) {
    return this.adminService.deleteParent(id);
  }

  // Students
  @Get('students')
  @ApiOperation({ summary: 'List all students' })
  findAllStudents() {
    return this.adminService.findAllStudents();
  }

  @Get('students/:id')
  @ApiOperation({ summary: 'Get student by ID' })
  findStudent(@Param('id', ParseIntPipe) id: number) {
    return this.adminService.findStudent(id);
  }

  @Post('students')
  @ApiOperation({ summary: 'Create student' })
  createStudent(@Body() dto: CreateStudentDto) {
    return this.adminService.createStudent(dto);
  }

  @Put('students/:id')
  @ApiOperation({ summary: 'Update student' })
  updateStudent(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateStudentDto,
  ) {
    return this.adminService.updateStudent(id, dto);
  }

  @Delete('students/:id')
  @ApiOperation({ summary: 'Deactivate student (soft delete)' })
  deleteStudent(@Param('id', ParseIntPipe) id: number) {
    return this.adminService.deleteStudent(id);
  }

  @Post('students/:id/link-parent')
  @ApiOperation({ summary: 'Link parent to student' })
  linkParent(
    @Param('id', ParseIntPipe) studentId: number,
    @Body() dto: LinkParentDto,
  ) {
    return this.adminService.linkParent(studentId, dto.parentId);
  }

  @Post('students/:id/link-teacher')
  @ApiOperation({ summary: 'Link teacher to student' })
  linkTeacher(
    @Param('id', ParseIntPipe) studentId: number,
    @Body() dto: LinkTeacherDto,
  ) {
    return this.adminService.linkTeacher(studentId, dto.teacherId);
  }
}
