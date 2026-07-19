import {
  Injectable,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { UserRole } from '@prisma/client';

@Injectable()
export class UsersService {
  constructor(private prisma: PrismaService) {}

  async getTeacherByUserId(userId: number) {
    const teacher = await this.prisma.teacher.findFirst({
      where: { userId, isActive: true },
      include: { user: { select: { id: true, name: true } } },
    });
    if (!teacher) throw new NotFoundException('Teacher profile not found');
    return teacher;
  }

  async getParentByUserId(userId: number) {
    const parent = await this.prisma.parent.findFirst({
      where: { userId, isActive: true },
      include: {
        user: { select: { id: true, name: true } },
        students: { include: { student: true } },
      },
    });
    if (!parent) throw new NotFoundException('Parent profile not found');
    return parent;
  }

  async verifyTeacherStudent(teacherId: number, studentId: number) {
    const link = await this.prisma.teacherStudent.findUnique({
      where: { teacherId_studentId: { teacherId, studentId } },
      include: { student: true },
    });
    if (!link || !link.student.isActive) {
      throw new ForbiddenException('Student not assigned to this teacher');
    }
    return link.student;
  }

  async verifyParentStudent(parentId: number, studentId: number) {
    const link = await this.prisma.parentStudent.findUnique({
      where: { parentId_studentId: { parentId, studentId } },
      include: { student: true },
    });
    if (!link || !link.student.isActive) {
      throw new ForbiddenException('Student not linked to this parent');
    }
    return link.student;
  }

  async getParentUserIdsForStudent(studentId: number): Promise<number[]> {
    const links = await this.prisma.parentStudent.findMany({
      where: { studentId },
      include: { parent: true },
    });
    return links
      .filter((l) => l.parent.isActive)
      .map((l) => l.parent.userId);
  }

  async getTeacherUserIdsForStudent(studentId: number): Promise<number[]> {
    const links = await this.prisma.teacherStudent.findMany({
      where: { studentId },
      include: { teacher: true },
    });
    return links
      .filter((l) => l.teacher.isActive)
      .map((l) => l.teacher.userId);
  }

  filterBannersByRole<T extends { target: string }>(
    banners: T[],
    role: UserRole,
  ): T[] {
    return banners.filter((b) => {
      if (b.target === 'all') return true;
      if (role === UserRole.teacher && b.target === 'teachers') return true;
      if (role === UserRole.parent && b.target === 'parents') return true;
      if (role === UserRole.admin) return true;
      return false;
    });
  }
}
