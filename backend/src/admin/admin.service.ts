import {
  Injectable,
  NotFoundException,
  ConflictException,
} from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../prisma/prisma.service';
import { UserRole } from '@prisma/client';
import {
  CreateTeacherDto,
  UpdateTeacherDto,
  CreateParentDto,
  UpdateParentDto,
  CreateStudentDto,
  UpdateStudentDto,
} from './dto/admin.dto';

@Injectable()
export class AdminService {
  constructor(private prisma: PrismaService) {}

  // ─── Teachers ───

  async findAllTeachers() {
    return this.prisma.teacher.findMany({
      where: { isActive: true },
      include: {
        user: {
          select: {
            id: true,
            username: true,
            name: true,
            phone: true,
            isActive: true,
          },
        },
        students: {
          include: { student: { select: { id: true, name: true, className: true } } },
        },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async listTeacherOptions() {
    return this.prisma.teacher.findMany({
      where: { isActive: true },
      select: {
        id: true,
        user: { select: { id: true, name: true } },
      },
      orderBy: { user: { name: 'asc' } },
    });
  }

  async findTeacher(id: number) {
    const teacher = await this.prisma.teacher.findFirst({
      where: { id, isActive: true },
      include: {
        user: {
          select: {
            id: true,
            username: true,
            name: true,
            phone: true,
            isActive: true,
          },
        },
        students: {
          include: { student: true },
        },
      },
    });
    if (!teacher) throw new NotFoundException('Teacher not found');
    return teacher;
  }

  async createTeacher(dto: CreateTeacherDto) {
    await this.ensureUniqueUsername(dto.username);
    const passwordHash = await bcrypt.hash(dto.password, 12);

    return this.prisma.$transaction(async (tx) => {
      const user = await tx.user.create({
        data: {
          username: dto.username,
          passwordHash,
          role: UserRole.teacher,
          name: dto.name,
          phone: dto.phone,
        },
      });
      return tx.teacher.create({
        data: { userId: user.id },
        include: {
          user: {
            select: { id: true, username: true, name: true, phone: true },
          },
        },
      });
    });
  }

  async updateTeacher(id: number, dto: UpdateTeacherDto) {
    const teacher = await this.findTeacher(id);

    if (dto.username && dto.username !== teacher.user.username) {
      await this.ensureUniqueUsername(dto.username);
    }

    const userData: Record<string, unknown> = {};
    if (dto.username) userData.username = dto.username;
    if (dto.name) userData.name = dto.name;
    if (dto.phone !== undefined) userData.phone = dto.phone;
    if (dto.password) userData.passwordHash = await bcrypt.hash(dto.password, 12);

    if (Object.keys(userData).length > 0) {
      await this.prisma.user.update({
        where: { id: teacher.userId },
        data: userData,
      });
    }

    return this.findTeacher(id);
  }

  async deleteTeacher(id: number) {
    const teacher = await this.findTeacher(id);
    await this.prisma.$transaction([
      this.prisma.teacher.update({
        where: { id },
        data: { isActive: false },
      }),
      this.prisma.user.update({
        where: { id: teacher.userId },
        data: { isActive: false },
      }),
    ]);
    return { message: 'Teacher deactivated' };
  }

  // ─── Parents ───

  async findAllParents() {
    return this.prisma.parent.findMany({
      where: { isActive: true },
      include: {
        user: {
          select: {
            id: true,
            username: true,
            name: true,
            phone: true,
            isActive: true,
          },
        },
        students: {
          include: { student: { select: { id: true, name: true, className: true } } },
        },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async listParentOptions() {
    return this.prisma.parent.findMany({
      where: { isActive: true },
      select: {
        id: true,
        user: { select: { id: true, name: true } },
      },
      orderBy: { user: { name: 'asc' } },
    });
  }

  async findParent(id: number) {
    const parent = await this.prisma.parent.findFirst({
      where: { id, isActive: true },
      include: {
        user: {
          select: {
            id: true,
            username: true,
            name: true,
            phone: true,
            isActive: true,
          },
        },
        students: { include: { student: true } },
      },
    });
    if (!parent) throw new NotFoundException('Parent not found');
    return parent;
  }

  async createParent(dto: CreateParentDto) {
    await this.ensureUniqueUsername(dto.username);
    const passwordHash = await bcrypt.hash(dto.password, 12);

    return this.prisma.$transaction(async (tx) => {
      const user = await tx.user.create({
        data: {
          username: dto.username,
          passwordHash,
          role: UserRole.parent,
          name: dto.name,
          phone: dto.phone,
        },
      });
      return tx.parent.create({
        data: { userId: user.id },
        include: {
          user: {
            select: { id: true, username: true, name: true, phone: true },
          },
        },
      });
    });
  }

  async updateParent(id: number, dto: UpdateParentDto) {
    const parent = await this.findParent(id);

    if (dto.username && dto.username !== parent.user.username) {
      await this.ensureUniqueUsername(dto.username);
    }

    const userData: Record<string, unknown> = {};
    if (dto.username) userData.username = dto.username;
    if (dto.name) userData.name = dto.name;
    if (dto.phone !== undefined) userData.phone = dto.phone;
    if (dto.password) userData.passwordHash = await bcrypt.hash(dto.password, 12);

    if (Object.keys(userData).length > 0) {
      await this.prisma.user.update({
        where: { id: parent.userId },
        data: userData,
      });
    }

    return this.findParent(id);
  }

  async deleteParent(id: number) {
    const parent = await this.findParent(id);
    await this.prisma.$transaction([
      this.prisma.parent.update({
        where: { id },
        data: { isActive: false },
      }),
      this.prisma.user.update({
        where: { id: parent.userId },
        data: { isActive: false },
      }),
    ]);
    return { message: 'Parent deactivated' };
  }

  // ─── Students ───

  async findAllStudents() {
    return this.prisma.student.findMany({
      where: { isActive: true },
      include: {
        parentLinks: {
          include: {
            parent: {
              include: {
                user: { select: { id: true, name: true, username: true } },
              },
            },
          },
        },
        teacherLinks: {
          include: {
            teacher: {
              include: {
                user: { select: { id: true, name: true, username: true } },
              },
            },
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async findStudent(id: number) {
    const student = await this.prisma.student.findFirst({
      where: { id, isActive: true },
      include: {
        parentLinks: {
          include: {
            parent: {
              include: {
                user: { select: { id: true, name: true, username: true } },
              },
            },
          },
        },
        teacherLinks: {
          include: {
            teacher: {
              include: {
                user: { select: { id: true, name: true, username: true } },
              },
            },
          },
        },
      },
    });
    if (!student) throw new NotFoundException('Student not found');
    return student;
  }

  async createStudent(dto: CreateStudentDto) {
    return this.prisma.student.create({
      data: {
        name: dto.name,
        className: dto.className,
        birthDate: dto.birthDate ? new Date(dto.birthDate) : undefined,
        avatarUrl: dto.avatarUrl,
      },
    });
  }

  async updateStudent(id: number, dto: UpdateStudentDto) {
    await this.ensureStudentExists(id);
    return this.prisma.student.update({
      where: { id },
      data: {
        name: dto.name,
        className: dto.className,
        birthDate: dto.birthDate ? new Date(dto.birthDate) : undefined,
        avatarUrl: dto.avatarUrl,
      },
    });
  }

  async deleteStudent(id: number) {
    await this.ensureStudentExists(id);
    await this.prisma.student.update({
      where: { id },
      data: { isActive: false },
    });
    return { message: 'Student deactivated' };
  }

  async linkParent(studentId: number, parentId: number) {
    await this.ensureStudentExists(studentId);
    await this.ensureParentExists(parentId);

    const existing = await this.prisma.parentStudent.findUnique({
      where: { parentId_studentId: { parentId, studentId } },
    });
    if (existing) {
      throw new ConflictException('Parent already linked to this student');
    }

    return this.prisma.parentStudent.create({
      data: { parentId, studentId },
      include: {
        parent: {
          include: { user: { select: { id: true, name: true } } },
        },
        student: { select: { id: true, name: true } },
      },
    });
  }

  async linkTeacher(studentId: number, teacherId: number) {
    await this.ensureStudentExists(studentId);
    await this.ensureTeacherExists(teacherId);

    const existing = await this.prisma.teacherStudent.findUnique({
      where: { teacherId_studentId: { teacherId, studentId } },
    });
    if (existing) {
      throw new ConflictException('Teacher already linked to this student');
    }

    return this.prisma.teacherStudent.create({
      data: { teacherId, studentId },
      include: {
        teacher: {
          include: { user: { select: { id: true, name: true } } },
        },
        student: { select: { id: true, name: true } },
      },
    });
  }

  async getDashboardStats() {
    const [
      teachers,
      parents,
      students,
      pendingPhotos,
      activeBanners,
      calendarEvents,
      stickerLevels,
      stickers,
    ] = await Promise.all([
      this.prisma.teacher.count({ where: { isActive: true } }),
      this.prisma.parent.count({ where: { isActive: true } }),
      this.prisma.student.count({ where: { isActive: true } }),
      this.prisma.photo.count({ where: { status: 'pending' } }),
      this.prisma.banner.count({ where: { isActive: true } }),
      this.prisma.calendarEvent.count({ where: { isActive: true } }),
      this.prisma.stickerLevel.count({ where: { isActive: true } }),
      this.prisma.sticker.count({ where: { isActive: true } }),
    ]);

    return {
      teachers,
      parents,
      students,
      pendingPhotos,
      activeBanners,
      calendarEvents,
      stickerLevels,
      stickers,
    };
  }

  private async ensureStudentExists(id: number) {
    const student = await this.prisma.student.findFirst({
      where: { id, isActive: true },
      select: { id: true },
    });
    if (!student) throw new NotFoundException('Student not found');
  }

  private async ensureParentExists(id: number) {
    const parent = await this.prisma.parent.findFirst({
      where: { id, isActive: true },
      select: { id: true },
    });
    if (!parent) throw new NotFoundException('Parent not found');
  }

  private async ensureTeacherExists(id: number) {
    const teacher = await this.prisma.teacher.findFirst({
      where: { id, isActive: true },
      select: { id: true },
    });
    if (!teacher) throw new NotFoundException('Teacher not found');
  }

  private async ensureUniqueUsername(username: string) {
    const existing = await this.prisma.user.findUnique({
      where: { username },
    });
    if (existing) {
      throw new ConflictException('Username already exists');
    }
  }
}
