import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  BadRequestException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { UsersService } from '../users/users.service';
import { StorageService } from '../storage/storage.service';
import { PushService } from '../notifications/push.service';
import { UserRole } from '@prisma/client';
import { resolveImageMime } from '../common/utils/image-mime.util';

const MAX_SIZE = 10 * 1024 * 1024;

@Injectable()
export class ChatService {
  constructor(
    private prisma: PrismaService,
    private users: UsersService,
    private storage: StorageService,
    private push: PushService,
  ) {}

  async listConversations(userId: number, role: UserRole) {
    let convs;
    if (role === UserRole.teacher) {
      const teacher = await this.users.getTeacherByUserId(userId);
      convs = await this.prisma.conversation.findMany({
        where: { teacherId: teacher.id },
        include: this.conversationIncludes(),
        orderBy: { updatedAt: 'desc' },
      });
    } else if (role === UserRole.parent) {
      const parent = await this.users.getParentByUserId(userId);
      convs = await this.prisma.conversation.findMany({
        where: { parentId: parent.id },
        include: this.conversationIncludes(),
        orderBy: { updatedAt: 'desc' },
      });
    } else {
      throw new ForbiddenException('Only teachers and parents can use chat');
    }

    return this.attachStudents(convs);
  }

  async getOrCreateConversation(userId: number, studentId: number) {
    const parent = await this.users.getParentByUserId(userId);
    await this.users.verifyParentStudent(parent.id, studentId);

    const teacherLink = await this.prisma.teacherStudent.findFirst({
      where: { studentId },
      include: { teacher: true },
    });
    if (!teacherLink) {
      throw new BadRequestException('Student has no assigned teacher');
    }

    const existing = await this.prisma.conversation.findUnique({
      where: {
        teacherId_parentId_studentId: {
          teacherId: teacherLink.teacherId,
          parentId: parent.id,
          studentId,
        },
      },
      include: this.conversationIncludes(),
    });

    if (existing) return (await this.attachStudents([existing]))[0];

    const created = await this.prisma.conversation.create({
      data: {
        teacherId: teacherLink.teacherId,
        parentId: parent.id,
        studentId,
      },
      include: this.conversationIncludes(),
    });

    return (await this.attachStudents([created]))[0];
  }

  async getMessages(conversationId: number, userId: number, role: UserRole) {
    await this.verifyParticipant(conversationId, userId, role);

    return this.prisma.message.findMany({
      where: { conversationId },
      include: { attachments: true },
      orderBy: { createdAt: 'asc' },
      take: 200,
    });
  }

  async sendMessage(
    conversationId: number,
    userId: number,
    role: UserRole,
    body: string,
  ) {
    const conversation = await this.verifyParticipant(
      conversationId,
      userId,
      role,
    );

    const message = await this.prisma.$transaction(async (tx) => {
      const msg = await tx.message.create({
        data: {
          conversationId,
          senderRole: role,
          senderId: userId,
          body,
        },
        include: { attachments: true },
      });
      await tx.conversation.update({
        where: { id: conversationId },
        data: { updatedAt: new Date() },
      });
      return msg;
    });

    await this.notifyRecipient(conversation, userId, role, body);

    return message;
  }

  async sendAttachment(
    conversationId: number,
    userId: number,
    role: UserRole,
    file: Express.Multer.File,
    body?: string,
  ) {
    if (!file) throw new BadRequestException('File required');
    const mime = resolveImageMime(file);
    if (!mime) {
      throw new BadRequestException('Only JPEG, PNG, WebP allowed');
    }
    file.mimetype = mime;
    if (file.size > MAX_SIZE) {
      throw new BadRequestException('Max file size 10MB');
    }

    const conversation = await this.verifyParticipant(
      conversationId,
      userId,
      role,
    );

    const fileUrl = await this.storage.upload(file, 'chat');

    const message = await this.prisma.$transaction(async (tx) => {
      const msg = await tx.message.create({
        data: {
          conversationId,
          senderRole: role,
          senderId: userId,
          body: body || null,
        },
      });
      await tx.messageAttachment.create({
        data: {
          messageId: msg.id,
          fileUrl,
          fileType: file.mimetype,
        },
      });
      await tx.conversation.update({
        where: { id: conversationId },
        data: { updatedAt: new Date() },
      });
      return tx.message.findUnique({
        where: { id: msg.id },
        include: { attachments: true },
      });
    });

    await this.notifyRecipient(
      conversation,
      userId,
      role,
      body || 'صورة مرفقة',
    );

    return message;
  }

  async markConversationRead(
    conversationId: number,
    userId: number,
    role: UserRole,
  ) {
    await this.verifyParticipant(conversationId, userId, role);
    await this.prisma.message.updateMany({
      where: {
        conversationId,
        senderId: { not: userId },
        isRead: false,
      },
      data: { isRead: true },
    });
    return { message: 'Marked as read' };
  }

  private async verifyParticipant(
    conversationId: number,
    userId: number,
    role: UserRole,
  ) {
    const conversation = await this.prisma.conversation.findUnique({
      where: { id: conversationId },
      include: {
        teacher: true,
        parent: true,
      },
    });

    if (!conversation) throw new NotFoundException('Conversation not found');

    const student = await this.prisma.student.findUnique({
      where: { id: conversation.studentId },
      select: { id: true, name: true },
    });

    if (role === UserRole.teacher) {
      const teacher = await this.users.getTeacherByUserId(userId);
      if (conversation.teacherId !== teacher.id) {
        throw new ForbiddenException('Not your conversation');
      }
    } else if (role === UserRole.parent) {
      const parent = await this.users.getParentByUserId(userId);
      if (conversation.parentId !== parent.id) {
        throw new ForbiddenException('Not your conversation');
      }
    } else {
      throw new ForbiddenException('Only teachers and parents can use chat');
    }

    return { ...conversation, student: student! };
  }

  private async notifyRecipient(
    conversation: {
      teacher: { userId: number };
      parent: { userId: number };
      student: { name: string };
    },
    senderUserId: number,
    senderRole: UserRole,
    preview: string,
  ) {
    const recipientId =
      senderRole === UserRole.teacher
        ? conversation.parent.userId
        : conversation.teacher.userId;

    if (recipientId === senderUserId) return;

    const senderLabel =
      senderRole === UserRole.teacher ? 'المعلمة' : 'ولي الأمر';
    await this.push.notifyUser(
      recipientId,
      'رسالة جديدة',
      `${senderLabel} (${conversation.student.name}): ${preview.slice(0, 80)}`,
    );
  }

  private conversationIncludes() {
    return {
      teacher: {
        include: { user: { select: { id: true, name: true } } },
      },
      parent: {
        include: { user: { select: { id: true, name: true } } },
      },
      messages: {
        orderBy: { createdAt: 'desc' as const },
        take: 1,
      },
    };
  }

  private async attachStudents<T extends { studentId: number }>(convs: T[]) {
    const ids = [...new Set(convs.map((c) => c.studentId))];
    const students = await this.prisma.student.findMany({
      where: { id: { in: ids } },
      select: { id: true, name: true, className: true },
    });
    const map = new Map(students.map((s) => [s.id, s]));
    return convs.map((c) => ({ ...c, student: map.get(c.studentId) }));
  }
}
