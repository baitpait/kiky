import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { UsersService } from '../users/users.service';
import { NotificationCategory } from '@prisma/client';
import { PushService } from '../notifications/push.service';
import { RecordAttendanceDto } from './dto/attendance.dto';
import { AttendanceType } from '@prisma/client';

@Injectable()
export class AttendanceService {
  constructor(
    private prisma: PrismaService,
    private users: UsersService,
    private push: PushService,
  ) {}

  async record(userId: number, dto: RecordAttendanceDto) {
    const teacher = await this.users.getTeacherByUserId(userId);
    const student = await this.users.verifyTeacherStudent(
      teacher.id,
      dto.studentId,
    );

    const timeStr = dto.time || new Date().toTimeString().slice(0, 8);
    const date = new Date(dto.date);
    const time = new Date(`1970-01-01T${timeStr}`);

    const record = await this.prisma.attendanceRecord.create({
      data: {
        studentId: dto.studentId,
        teacherId: teacher.id,
        type: dto.type,
        date,
        time,
        note: dto.note,
      },
      include: { student: { select: { id: true, name: true } } },
    });

    const parentIds = await this.users.getParentUserIdsForStudent(dto.studentId);
    const messages: Record<AttendanceType, { title: string; body: string }> = {
      check_in: {
        title: 'تسجيل حضور',
        body: `تم تسجيل حضور ${student.name} في الروضة`,
      },
      check_out: {
        title: 'تسجيل انصراف',
        body: `تم تسجيل انصراف ${student.name} من الروضة`,
      },
      absent: {
        title: 'غياب',
        body: `تم تسجيل غياب ${student.name}`,
      },
    };

    const msg = messages[dto.type];
    await this.push.notifyUsers(
      parentIds,
      msg.title,
      msg.body,
      dto.type === 'absent'
        ? NotificationCategory.absence
        : NotificationCategory.attendance,
    );

    return record;
  }

  async todayForTeacher(userId: number) {
    const teacher = await this.users.getTeacherByUserId(userId);
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    return this.prisma.attendanceRecord.findMany({
      where: { teacherId: teacher.id, date: today },
      include: { student: { select: { id: true, name: true, className: true } } },
      orderBy: { time: 'desc' },
    });
  }

  async historyForStudent(userId: number, studentId: number) {
    const parent = await this.users.getParentByUserId(userId);
    await this.users.verifyParentStudent(parent.id, studentId);

    return this.prisma.attendanceRecord.findMany({
      where: { studentId },
      include: {
        teacher: { include: { user: { select: { name: true } } } },
      },
      orderBy: [{ date: 'desc' }, { time: 'desc' }],
      take: 60,
    });
  }
}
