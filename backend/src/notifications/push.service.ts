import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../prisma/prisma.service';
import { NotificationTarget } from '@prisma/client';
import * as admin from 'firebase-admin';

@Injectable()
export class PushService implements OnModuleInit {
  private readonly logger = new Logger(PushService.name);
  private fcmEnabled = false;

  constructor(
    private config: ConfigService,
    private prisma: PrismaService,
  ) {}

  onModuleInit() {
    const projectId = this.config.get<string>('FCM_PROJECT_ID');
    const clientEmail = this.config.get<string>('FCM_CLIENT_EMAIL');
    const privateKey = this.config.get<string>('FCM_PRIVATE_KEY')?.replace(
      /\\n/g,
      '\n',
    );

    if (projectId && clientEmail && privateKey) {
      try {
        admin.initializeApp({
          credential: admin.credential.cert({
            projectId,
            clientEmail,
            privateKey,
          }),
        });
        this.fcmEnabled = true;
        this.logger.log('FCM initialized');
      } catch (e) {
        this.logger.warn('FCM init failed — push will be logged only');
      }
    } else {
      this.logger.warn('FCM credentials missing — push notifications disabled');
    }
  }

  async notifyUser(userId: number, title: string, body: string) {
    await this.prisma.notification.create({
      data: { title, body, userId, target: NotificationTarget.all },
    });

    if (!this.fcmEnabled) {
      this.logger.debug(`[Push stub] user=${userId}: ${title}`);
      return;
    }

    const tokens = await this.prisma.deviceToken.findMany({
      where: { userId, isActive: true },
    });

    if (tokens.length === 0) return;

    const messaging = admin.messaging();
    await messaging.sendEachForMulticast({
      tokens: tokens.map((t) => t.token),
      notification: { title, body },
    });
  }

  async notifyUsers(userIds: number[], title: string, body: string) {
    for (const userId of userIds) {
      await this.notifyUser(userId, title, body);
    }
  }

  async notifyByTarget(
    target: NotificationTarget,
    title: string,
    body: string,
    senderId?: number,
  ) {
    const userIds = await this.getUsersByTarget(target);
    if (userIds.length === 0) {
      this.logger.debug(`[Push] no users for target=${target}`);
      return { sent: 0 };
    }

    await this.prisma.notification.createMany({
      data: userIds.map((userId) => ({
        title,
        body,
        userId,
        target,
        senderId,
      })),
    });

    if (!this.fcmEnabled) {
      this.logger.debug(
        `[Push stub] target=${target} users=${userIds.length}: ${title}`,
      );
      return { sent: userIds.length };
    }

    const tokens = await this.prisma.deviceToken.findMany({
      where: { userId: { in: userIds }, isActive: true },
    });

    if (tokens.length === 0) return { sent: userIds.length };

    const messaging = admin.messaging();
    await messaging.sendEachForMulticast({
      tokens: tokens.map((t) => t.token),
      notification: { title, body },
    });

    return { sent: userIds.length };
  }

  private async getUsersByTarget(target: NotificationTarget): Promise<number[]> {
    const where =
      target === NotificationTarget.teachers
        ? { role: 'teacher' as const, isActive: true }
        : target === NotificationTarget.parents
          ? { role: 'parent' as const, isActive: true }
          : { isActive: true };

    const users = await this.prisma.user.findMany({
      where,
      select: { id: true },
    });
    return users.map((u) => u.id);
  }
}
