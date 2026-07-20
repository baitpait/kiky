import {
  Injectable,
  BadRequestException,
  NotFoundException,
  ForbiddenException,
  Logger,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { RtcTokenBuilder, RtcRole } from 'agora-token';
import { randomUUID } from 'crypto';
import { PrismaService } from '../prisma/prisma.service';
import { UsersService } from '../users/users.service';
import { PushService } from '../notifications/push.service';
import { LiveStreamStatus, NotificationCategory } from '@prisma/client';

@Injectable()
export class LiveService {
  private readonly logger = new Logger(LiveService.name);

  constructor(
    private prisma: PrismaService,
    private users: UsersService,
    private push: PushService,
    private config: ConfigService,
  ) {}

  async start(userId: number, title: string) {
    const teacher = await this.users.getTeacherByUserId(userId);

    const existing = await this.prisma.liveStream.findFirst({
      where: { teacherId: teacher.id, status: LiveStreamStatus.active },
    });
    if (existing) {
      throw new BadRequestException('You already have an active live stream');
    }

    const channelName = `kiddy-${teacher.id}-${randomUUID().slice(0, 8)}`;
    const stream = await this.prisma.liveStream.create({
      data: {
        teacherId: teacher.id,
        title,
        channelName,
        status: LiveStreamStatus.active,
      },
      include: {
        teacher: { include: { user: { select: { name: true } } } },
      },
    });

    const token = this.buildToken(channelName, userId, RtcRole.PUBLISHER);
    const appId = this.config.get<string>('AGORA_APP_ID', '');

    const parentUserIds = await this.getParentIdsForTeacher(teacher.id);
    await this.push.notifyUsers(
      parentUserIds,
      'بث مباشر',
      `بدأ بث مباشر: ${title} — ${stream.teacher.user.name}`,
      NotificationCategory.live,
    );

    return {
      stream,
      agora: {
        appId,
        channelName,
        token,
        uid: userId,
        role: 'publisher',
        demo: !appId || !this.config.get('AGORA_APP_CERTIFICATE'),
      },
    };
  }

  async end(userId: number, streamId: number) {
    const teacher = await this.users.getTeacherByUserId(userId);
    const stream = await this.prisma.liveStream.findUnique({
      where: { id: streamId },
    });

    if (!stream) throw new NotFoundException('Stream not found');
    if (stream.teacherId !== teacher.id) {
      throw new ForbiddenException('Not your stream');
    }
    if (stream.status !== LiveStreamStatus.active) {
      throw new BadRequestException('Stream already ended');
    }

    return this.prisma.liveStream.update({
      where: { id: streamId },
      data: { status: LiveStreamStatus.ended, endedAt: new Date() },
    });
  }

  async getActiveForParent(userId: number) {
    const parent = await this.users.getParentByUserId(userId);
    const studentIds = parent.students.map((l) => l.studentId);

    const teacherLinks = await this.prisma.teacherStudent.findMany({
      where: { studentId: { in: studentIds } },
      select: { teacherId: true },
    });
    const teacherIds = [...new Set(teacherLinks.map((l) => l.teacherId))];

    return this.prisma.liveStream.findMany({
      where: {
        teacherId: { in: teacherIds },
        status: LiveStreamStatus.active,
      },
      include: {
        teacher: { include: { user: { select: { name: true } } } },
      },
      orderBy: { startedAt: 'desc' },
    });
  }

  async joinAsAudience(userId: number, streamId: number) {
    const parent = await this.users.getParentByUserId(userId);
    const stream = await this.prisma.liveStream.findFirst({
      where: { id: streamId, status: LiveStreamStatus.active },
      include: { teacher: true },
    });

    if (!stream) throw new NotFoundException('Active stream not found');

    const studentIds = parent.students.map((l) => l.studentId);
    const link = await this.prisma.teacherStudent.findFirst({
      where: {
        teacherId: stream.teacherId,
        studentId: { in: studentIds },
      },
    });
    if (!link) {
      throw new ForbiddenException('This stream is not for your children');
    }

    const token = this.buildToken(stream.channelName, userId, RtcRole.SUBSCRIBER);
    const appId = this.config.get<string>('AGORA_APP_ID', '');

    return {
      stream,
      agora: {
        appId,
        channelName: stream.channelName,
        token,
        uid: userId,
        role: 'audience',
        demo: !appId || !this.config.get('AGORA_APP_CERTIFICATE'),
      },
    };
  }

  async getMyActive(userId: number) {
    const teacher = await this.users.getTeacherByUserId(userId);
    return this.prisma.liveStream.findFirst({
      where: { teacherId: teacher.id, status: LiveStreamStatus.active },
    });
  }

  private buildToken(
    channelName: string,
    uid: number,
    role: number,
  ): string {
    const appId = this.config.get<string>('AGORA_APP_ID', '');
    const certificate = this.config.get<string>('AGORA_APP_CERTIFICATE', '');

    if (!appId || !certificate) {
      this.logger.warn('Agora credentials missing — returning demo token');
      return 'demo-token';
    }

    const expireSeconds = parseInt(
      this.config.get<string>('AGORA_TOKEN_EXPIRE', '3600'),
      10,
    );
    const expireTime =
      Math.floor(Date.now() / 1000) + expireSeconds;

    return RtcTokenBuilder.buildTokenWithUid(
      appId,
      certificate,
      channelName,
      uid,
      role,
      expireTime,
      expireTime,
    );
  }

  private async getParentIdsForTeacher(teacherId: number): Promise<number[]> {
    const links = await this.prisma.teacherStudent.findMany({
      where: { teacherId },
      select: { studentId: true },
    });
    const studentIds = links.map((l) => l.studentId);
    const parentLinks = await this.prisma.parentStudent.findMany({
      where: { studentId: { in: studentIds } },
      include: { parent: true },
    });
    return [
      ...new Set(
        parentLinks.filter((l) => l.parent.isActive).map((l) => l.parent.userId),
      ),
    ];
  }
}
