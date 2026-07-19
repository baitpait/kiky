import {
  Injectable,
  BadRequestException,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { StorageService } from '../storage/storage.service';
import { UsersService } from '../users/users.service';
import { PhotoStatus } from '@prisma/client';
import { resolveImageMime } from '../common/utils/image-mime.util';

const MAX_SIZE = 10 * 1024 * 1024;

function normalizeImageUrl(url: string): string {
  if (url.startsWith('/uploads/')) return url;
  try {
    const parsed = new URL(url);
    if (parsed.pathname.startsWith('/uploads/')) return parsed.pathname;
  } catch {
    /* keep as-is */
  }
  return url;
}

function withNormalizedUrl<T extends { imageUrl: string }>(photo: T): T {
  return { ...photo, imageUrl: normalizeImageUrl(photo.imageUrl) };
}

@Injectable()
export class PhotosService {
  constructor(
    private prisma: PrismaService,
    private storage: StorageService,
    private users: UsersService,
  ) {}

  async upload(
    userId: number,
    studentId: number,
    file: Express.Multer.File,
    caption?: string,
  ) {
    if (!file) throw new BadRequestException('Image file required');
    const mime = resolveImageMime(file);
    if (!mime) {
      throw new BadRequestException('Only JPEG, PNG, WebP allowed');
    }
    file.mimetype = mime;
    if (file.size > MAX_SIZE) {
      throw new BadRequestException('Max file size 10MB');
    }

    const teacher = await this.users.getTeacherByUserId(userId);
    await this.users.verifyTeacherStudent(teacher.id, studentId);

    const imageUrl = await this.storage.upload(file, 'photos');

    return withNormalizedUrl(
      await this.prisma.photo.create({
        data: {
          teacherId: teacher.id,
          studentId,
          imageUrl,
          caption,
          status: PhotoStatus.pending,
        },
        include: {
          student: { select: { id: true, name: true } },
          teacher: { include: { user: { select: { name: true } } } },
        },
      }),
    );
  }

  async findByTeacher(userId: number) {
    const teacher = await this.users.getTeacherByUserId(userId);
    const rows = await this.prisma.photo.findMany({
      where: { teacherId: teacher.id },
      include: { student: { select: { id: true, name: true, className: true } } },
      orderBy: { createdAt: 'desc' },
    });
    return rows.map(withNormalizedUrl);
  }

  async findApprovedByStudent(userId: number, studentId: number) {
    const parent = await this.users.getParentByUserId(userId);
    await this.users.verifyParentStudent(parent.id, studentId);

    const rows = await this.prisma.photo.findMany({
      where: {
        studentId,
        status: PhotoStatus.approved,
      },
      include: {
        teacher: { include: { user: { select: { name: true } } } },
      },
      orderBy: { publishedAt: 'desc' },
    });
    return rows.map(withNormalizedUrl);
  }

  async findPending() {
    const rows = await this.prisma.photo.findMany({
      where: { status: PhotoStatus.pending },
      include: {
        student: { select: { id: true, name: true, className: true } },
        teacher: { include: { user: { select: { name: true } } } },
      },
      orderBy: { createdAt: 'asc' },
    });
    return rows.map(withNormalizedUrl);
  }

  async approve(photoId: number, adminId: number) {
    const photo = await this.prisma.photo.findUnique({ where: { id: photoId } });
    if (!photo) throw new NotFoundException('Photo not found');
    if (photo.status !== PhotoStatus.pending) {
      throw new BadRequestException('Photo is not pending');
    }

    const updated = await this.prisma.$transaction(async (tx) => {
      const p = await tx.photo.update({
        where: { id: photoId },
        data: {
          status: PhotoStatus.approved,
          publishedAt: new Date(),
        },
        include: { student: true },
      });
      await tx.photoApproval.create({
        data: { photoId, adminId, action: 'approved' },
      });
      return p;
    });

    return withNormalizedUrl(updated);
  }

  async reject(photoId: number, adminId: number, note?: string) {
    const photo = await this.prisma.photo.findUnique({ where: { id: photoId } });
    if (!photo) throw new NotFoundException('Photo not found');
    if (photo.status !== PhotoStatus.pending) {
      throw new BadRequestException('Photo is not pending');
    }

    return this.prisma.$transaction(async (tx) => {
      const p = await tx.photo.update({
        where: { id: photoId },
        data: { status: PhotoStatus.rejected },
      });
      await tx.photoApproval.create({
        data: { photoId, adminId, action: 'rejected', note },
      });
      return p;
    });
  }
}
