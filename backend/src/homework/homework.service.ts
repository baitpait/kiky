import {
  Injectable,
  NotFoundException,
  BadRequestException,
  ForbiddenException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { UsersService } from '../users/users.service';
import { AiService } from '../ai/ai.service';
import { PushService } from '../notifications/push.service';
import { CreateHomeworkDto, GradeHomeworkDto } from './dto/homework.dto';
import { HomeworkStatus, StickerAssignedBy } from '@prisma/client';
import { UpdateStudentStickerDto } from '../stickers/dto/stickers.dto';

@Injectable()
export class HomeworkService {
  constructor(
    private prisma: PrismaService,
    private users: UsersService,
    private ai: AiService,
    private push: PushService,
  ) {}

  async create(userId: number, dto: CreateHomeworkDto) {
    const teacher = await this.users.getTeacherByUserId(userId);
    await this.users.verifyTeacherStudent(teacher.id, dto.studentId);

    const homework = await this.prisma.$transaction(async (tx) => {
      const hw = await tx.homework.create({
        data: {
          teacherId: teacher.id,
          studentId: dto.studentId,
          title: dto.title,
          description: dto.description,
          dueDate: dto.dueDate ? new Date(dto.dueDate) : undefined,
          status: HomeworkStatus.assigned,
        },
        include: {
          student: { select: { id: true, name: true } },
        },
      });
      await tx.homeworkSubmission.create({ data: { homeworkId: hw.id } });
      return hw;
    });

    const parentIds = await this.users.getParentUserIdsForStudent(dto.studentId);
    await this.push.notifyUsers(
      parentIds,
      'واجب جديد',
      `واجب جديد لـ ${homework.student.name}: ${dto.title}`,
    );

    return homework;
  }

  async listForStudent(userId: number, studentId: number) {
    const parent = await this.users.getParentByUserId(userId);
    await this.users.verifyParentStudent(parent.id, studentId);

    return this.prisma.homework.findMany({
      where: { studentId },
      include: {
        submissions: true,
        teacher: { include: { user: { select: { name: true } } } },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async listForTeacher(userId: number) {
    const teacher = await this.users.getTeacherByUserId(userId);
    return this.prisma.homework.findMany({
      where: { teacherId: teacher.id },
      include: {
        student: { select: { id: true, name: true, className: true } },
        submissions: true,
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async confirm(userId: number, homeworkId: number) {
    const parent = await this.users.getParentByUserId(userId);
    const homework = await this.prisma.homework.findUnique({
      where: { id: homeworkId },
      include: { submissions: true, student: true },
    });

    if (!homework) throw new NotFoundException('Homework not found');
    await this.users.verifyParentStudent(parent.id, homework.studentId);

    if (homework.status !== HomeworkStatus.assigned) {
      throw new BadRequestException('Homework already confirmed or graded');
    }

    const submission = homework.submissions[0];
    if (!submission) throw new NotFoundException('Submission not found');

    const [updated] = await this.prisma.$transaction([
      this.prisma.homeworkSubmission.update({
        where: { id: submission.id },
        data: {
          parentConfirmed: true,
          parentConfirmedAt: new Date(),
        },
      }),
      this.prisma.homework.update({
        where: { id: homeworkId },
        data: { status: HomeworkStatus.submitted },
      }),
    ]);

    const teacherIds = await this.users.getTeacherUserIdsForStudent(
      homework.studentId,
    );
    await this.push.notifyUsers(
      teacherIds,
      'تأكيد حل واجب',
      `ولي أمر ${homework.student.name} أكّد حل الواجب: ${homework.title}`,
    );

    return updated;
  }

  async grade(userId: number, homeworkId: number, dto: GradeHomeworkDto) {
    const teacher = await this.users.getTeacherByUserId(userId);
    const homework = await this.prisma.homework.findUnique({
      where: { id: homeworkId },
      include: { submissions: true, student: true },
    });

    if (!homework) throw new NotFoundException('Homework not found');
    if (homework.teacherId !== teacher.id) {
      throw new ForbiddenException('Not your homework assignment');
    }
    if (homework.status !== HomeworkStatus.submitted) {
      throw new BadRequestException('Parent must confirm homework first');
    }

    const submission = homework.submissions[0];
    if (!submission?.parentConfirmed) {
      throw new BadRequestException('Parent has not confirmed yet');
    }

    await this.prisma.homeworkSubmission.update({
      where: { id: submission.id },
      data: {
        teacherGrade: dto.teacherGrade,
        teacherNote: dto.teacherNote,
      },
    });

    const aiResult = await this.ai.analyzeHomework(homeworkId, submission.id);

    await this.prisma.$transaction([
      this.prisma.homeworkSubmission.update({
        where: { id: submission.id },
        data: { gradedAt: new Date() },
      }),
      this.prisma.homework.update({
        where: { id: homeworkId },
        data: { status: HomeworkStatus.graded },
      }),
    ]);

    const parentIds = await this.users.getParentUserIdsForStudent(
      homework.studentId,
    );
    await this.push.notifyUsers(
      parentIds,
      'ملصق جديد',
      `حصل ${homework.student.name} على ملصق جديد بعد إنجاز الواجب!`,
    );

    return {
      homeworkId,
      grade: dto.teacherGrade,
      ai: aiResult,
    };
  }

  async getStickerForHomework(
    userId: number,
    role: string,
    homeworkId: number,
  ) {
    const homework = await this.prisma.homework.findUnique({
      where: { id: homeworkId },
    });
    if (!homework) throw new NotFoundException('Homework not found');

    if (role === 'parent') {
      const parent = await this.users.getParentByUserId(userId);
      await this.users.verifyParentStudent(parent.id, homework.studentId);
    } else if (role === 'teacher') {
      const teacher = await this.users.getTeacherByUserId(userId);
      if (homework.teacherId !== teacher.id) {
        throw new ForbiddenException('Not your homework assignment');
      }
    } else if (role !== 'admin') {
      throw new ForbiddenException('Access denied');
    }

    const sticker = await this.prisma.studentSticker.findFirst({
      where: { homeworkId },
      include: {
        sticker: { include: { level: true } },
      },
    });
    if (!sticker) throw new NotFoundException('No sticker for this homework');
    return sticker;
  }

  findActiveStickers() {
    return this.prisma.sticker.findMany({
      where: { isActive: true, level: { isActive: true } },
      include: { level: true },
      orderBy: [{ level: { sortOrder: 'asc' } }, { name: 'asc' }],
    });
  }

  async getStudentStickers(userId: number, studentId: number, role: string) {
    if (role === 'parent') {
      const parent = await this.users.getParentByUserId(userId);
      await this.users.verifyParentStudent(parent.id, studentId);
    } else if (role === 'teacher') {
      const teacher = await this.users.getTeacherByUserId(userId);
      await this.users.verifyTeacherStudent(teacher.id, studentId);
    }

    return this.prisma.studentSticker.findMany({
      where: { studentId },
      include: {
        sticker: { include: { level: true } },
        homework: { select: { id: true, title: true } },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async updateStudentSticker(
    userId: number,
    stickerRecordId: number,
    dto: UpdateStudentStickerDto,
  ) {
    const teacher = await this.users.getTeacherByUserId(userId);
    const record = await this.prisma.studentSticker.findUnique({
      where: { id: stickerRecordId },
      include: { student: true },
    });

    if (!record) throw new NotFoundException('Sticker record not found');
    await this.users.verifyTeacherStudent(teacher.id, record.studentId);

    if (dto.stickerId != null) {
      const sticker = await this.prisma.sticker.findFirst({
        where: {
          id: dto.stickerId,
          isActive: true,
          level: { isActive: true },
        },
      });
      if (!sticker) {
        throw new BadRequestException('Invalid or inactive sticker');
      }
    }

    return this.prisma.studentSticker.update({
      where: { id: stickerRecordId },
      data: {
        stickerId: dto.stickerId,
        note: dto.note,
        assignedBy: StickerAssignedBy.teacher,
      },
      include: { sticker: { include: { level: true } } },
    });
  }

  async removeStudentSticker(userId: number, stickerRecordId: number) {
    const teacher = await this.users.getTeacherByUserId(userId);
    const record = await this.prisma.studentSticker.findUnique({
      where: { id: stickerRecordId },
    });
    if (!record) throw new NotFoundException('Sticker record not found');
    await this.users.verifyTeacherStudent(teacher.id, record.studentId);

    await this.prisma.studentSticker.delete({ where: { id: stickerRecordId } });
    return { message: 'Sticker removed' };
  }
}
