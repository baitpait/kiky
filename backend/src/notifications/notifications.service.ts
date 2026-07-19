import { Injectable, NotFoundException } from '@nestjs/common';
import { NotificationTarget, UserRole } from '@prisma/client';
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

  private targetsForRole(role: string): NotificationTarget[] {
    if (role === UserRole.teacher) {
      return [NotificationTarget.all, NotificationTarget.teachers];
    }
    if (role === UserRole.parent) {
      return [NotificationTarget.all, NotificationTarget.parents];
    }
    return [
      NotificationTarget.all,
      NotificationTarget.teachers,
      NotificationTarget.parents,
    ];
  }

  async listForUser(userId: number, role: string) {
    const targets = this.targetsForRole(role);

    return this.prisma.notification.findMany({
      where: {
        OR: [
          { userId },
          { userId: null, target: { in: targets } },
        ],
      },
      orderBy: { createdAt: 'desc' },
      take: 50,
    });
  }

  async unreadCount(userId: number, role: string) {
    const targets = this.targetsForRole(role);

    return this.prisma.notification.count({
      where: {
        isRead: false,
        OR: [
          { userId },
          { userId: null, target: { in: targets } },
        ],
      },
    });
  }

  async markRead(id: number, userId: number, role: string) {
    const targets = this.targetsForRole(role);
    const notification = await this.prisma.notification.findFirst({
      where: {
        id,
        OR: [
          { userId },
          { userId: null, target: { in: targets } },
        ],
      },
    });
    if (!notification) throw new NotFoundException('Notification not found');

    return this.prisma.notification.update({
      where: { id },
      data: { isRead: true },
    });
  }
}
