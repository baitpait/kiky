import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { UsersService } from '../users/users.service';

@Injectable()
export class StudentsService {
  constructor(
    private prisma: PrismaService,
    private users: UsersService,
  ) {}

  async myClass(userId: number) {
    const teacher = await this.users.getTeacherByUserId(userId);
    const links = await this.prisma.teacherStudent.findMany({
      where: { teacherId: teacher.id },
      include: {
        student: {
          select: {
            id: true,
            name: true,
            className: true,
            avatarUrl: true,
            isActive: true,
          },
        },
      },
    });
    return links
      .filter((l) => l.student.isActive)
      .map((l) => l.student);
  }

  async myChildren(userId: number) {
    const parent = await this.users.getParentByUserId(userId);
    const links = await this.prisma.parentStudent.findMany({
      where: { parentId: parent.id },
      include: {
        student: {
          select: {
            id: true,
            name: true,
            className: true,
            avatarUrl: true,
            isActive: true,
          },
        },
      },
    });
    return links
      .filter((l) => l.student.isActive)
      .map((l) => l.student);
  }
}
