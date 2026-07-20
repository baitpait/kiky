import {
  Injectable,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { RegisterDeviceDto } from './dto/notifications.dto';

@Injectable()
export class NotificationsService {
  constructor(private prisma: PrismaService) {}

  async registerDevice(userId: number, dto: RegisterDeviceDto) {
    return this.prisma.deviceToken.upsert({
      where: { userId_token: { userId, token: dto.token } },
      create: {
        userId,
        token: dto.token,
        platform: dto.platform,
      },
      update: { platform: dto.platform, isActive: true },
    });
  }

  /** Each user sees only their own notification rows (DEVELOPER_SPEC §5.4 + PHOTOS_NOTIFICATIONS_FIX). */
  async listForUser(userId: number, _role?: string) {
    return this.prisma.notification.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
      take: 50,
    });
  }

  async unreadCount(userId: number, _role?: string) {
    return this.prisma.notification.count({
      where: { userId, isRead: false },
    });
  }

  async markRead(id: number, userId: number, _role?: string) {
    const notification = await this.prisma.notification.findUnique({
      where: { id },
    });
    if (!notification) throw new NotFoundException('Notification not found');
    if (notification.userId !== userId) {
      throw new ForbiddenException('Not your notification');
    }
    if (notification.isRead) return notification;

    return this.prisma.notification.update({
      where: { id },
      data: { isRead: true },
    });
  }

  async markAllRead(userId: number) {
    const result = await this.prisma.notification.updateMany({
      where: { userId, isRead: false },
      data: { isRead: true },
    });
    return { updated: result.count };
  }
}
