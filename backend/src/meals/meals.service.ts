import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { UsersService } from '../users/users.service';
import { PushService } from '../notifications/push.service';
import { MealConfirmDto } from './dto/meals.dto';

@Injectable()
export class MealsService {
  constructor(
    private prisma: PrismaService,
    private users: UsersService,
    private push: PushService,
  ) {}

  async teacherConfirm(userId: number, dto: MealConfirmDto) {
    const teacher = await this.users.getTeacherByUserId(userId);
    const student = await this.users.verifyTeacherStudent(
      teacher.id,
      dto.studentId,
    );

    const date = new Date(dto.date);
    const record = await this.prisma.mealRecord.upsert({
      where: {
        studentId_date_mealType: {
          studentId: dto.studentId,
          date,
          mealType: dto.mealType,
        },
      },
      create: {
        studentId: dto.studentId,
        date,
        mealType: dto.mealType,
        teacherConfirmed: true,
        teacherConfirmedAt: new Date(),
      },
      update: {
        teacherConfirmed: true,
        teacherConfirmedAt: new Date(),
      },
      include: { student: { select: { id: true, name: true } } },
    });

    const parentIds = await this.users.getParentUserIdsForStudent(dto.studentId);
    const mealLabels: Record<string, string> = {
      breakfast: 'الفطور',
      lunch: 'الغداء',
      snack: 'الوجبة الخفيفة',
    };
    await this.push.notifyUsers(
      parentIds,
      'تأكيد وجبة',
      `المعلمة أكّدت أن ${student.name} تناول ${mealLabels[dto.mealType]}`,
    );

    return record;
  }

  async parentConfirm(userId: number, dto: MealConfirmDto) {
    const parent = await this.users.getParentByUserId(userId);
    const student = await this.users.verifyParentStudent(
      parent.id,
      dto.studentId,
    );

    const date = new Date(dto.date);
    const record = await this.prisma.mealRecord.upsert({
      where: {
        studentId_date_mealType: {
          studentId: dto.studentId,
          date,
          mealType: dto.mealType,
        },
      },
      create: {
        studentId: dto.studentId,
        date,
        mealType: dto.mealType,
        parentConfirmed: true,
        parentConfirmedAt: new Date(),
      },
      update: {
        parentConfirmed: true,
        parentConfirmedAt: new Date(),
      },
      include: { student: { select: { id: true, name: true } } },
    });

    const teacherIds = await this.users.getTeacherUserIdsForStudent(dto.studentId);
    const mealLabels: Record<string, string> = {
      breakfast: 'الفطور',
      lunch: 'الغداء',
      snack: 'الوجبة الخفيفة',
    };
    await this.push.notifyUsers(
      teacherIds,
      'تأكيد وجبة من ولي الأمر',
      `ولي أمر ${student.name} أكّد تناول ${mealLabels[dto.mealType]} في المنزل`,
    );

    return record;
  }

  async historyForStudent(userId: number, studentId: number) {
    const parent = await this.users.getParentByUserId(userId);
    await this.users.verifyParentStudent(parent.id, studentId);

    return this.prisma.mealRecord.findMany({
      where: { studentId },
      orderBy: [{ date: 'desc' }, { mealType: 'asc' }],
      take: 60,
    });
  }

  async todayForTeacher(userId: number) {
    const teacher = await this.users.getTeacherByUserId(userId);
    const studentIds = (
      await this.prisma.teacherStudent.findMany({
        where: { teacherId: teacher.id },
        select: { studentId: true },
      })
    ).map((s) => s.studentId);

    const today = new Date();
    today.setHours(0, 0, 0, 0);

    return this.prisma.mealRecord.findMany({
      where: { studentId: { in: studentIds }, date: today },
      include: { student: { select: { id: true, name: true } } },
    });
  }
}
