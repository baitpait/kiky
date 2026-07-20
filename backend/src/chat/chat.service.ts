import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  BadRequestException,
} from '@nestjs/common';
import { ConversationKind, UserRole, NotificationCategory } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { UsersService } from '../users/users.service';
import { StorageService } from '../storage/storage.service';
import { PushService } from '../notifications/push.service';
import { resolveImageMime } from '../common/utils/image-mime.util';
import { CreateConversationDto } from './dto/chat.dto';

const MAX_SIZE = 10 * 1024 * 1024;

type ConversationRow = {
  id: number;
  kind: ConversationKind;
  teacherId: number | null;
  parentId: number | null;
  adminUserId: number | null;
  studentId: number | null;
  teacher?: { userId: number; user: { id: number; name: string } } | null;
  parent?: { userId: number; user: { id: number; name: string } } | null;
  adminUser?: { id: number; name: string } | null;
  student?: { id: number; name: string; className?: string };
};

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

    if (role === UserRole.admin) {
      convs = await this.prisma.conversation.findMany({
        where: { adminUserId: userId },
        include: this.conversationIncludes(),
        orderBy: { updatedAt: 'desc' },
      });
    } else if (role === UserRole.teacher) {
      const teacher = await this.users.getTeacherByUserId(userId);
      convs = await this.prisma.conversation.findMany({
        where: {
          OR: [
            { kind: ConversationKind.teacher_parent, teacherId: teacher.id },
            { kind: ConversationKind.admin_teacher, teacherId: teacher.id },
          ],
        },
        include: this.conversationIncludes(),
        orderBy: { updatedAt: 'desc' },
      });
    } else if (role === UserRole.parent) {
      const parent = await this.users.getParentByUserId(userId);
      convs = await this.prisma.conversation.findMany({
        where: {
          OR: [
            { kind: ConversationKind.teacher_parent, parentId: parent.id },
            { kind: ConversationKind.admin_parent, parentId: parent.id },
          ],
        },
        include: this.conversationIncludes(),
        orderBy: { updatedAt: 'desc' },
      });
    } else {
      throw new ForbiddenException('Invalid role for chat');
    }

    return this.attachStudents(convs);
  }

  async createConversation(
    userId: number,
    role: UserRole,
    dto: CreateConversationDto,
  ) {
    const target = (dto.targetRole ?? 'teacher').toLowerCase();

    if (role === UserRole.parent) {
      if (target === 'admin') {
        if (!dto.studentId) {
          throw new BadRequestException('studentId required');
        }
        const parent = await this.users.getParentByUserId(userId);
        await this.users.verifyParentStudent(parent.id, dto.studentId);
        const adminUserId = await this.primaryAdminUserId();
        return this.findOrCreateAdminParent(
          adminUserId,
          parent.id,
          dto.studentId,
        );
      }
      if (!dto.studentId) {
        throw new BadRequestException('studentId required');
      }
      return this.getOrCreateTeacherParent(userId, dto.studentId);
    }

    if (role === UserRole.teacher) {
      const teacher = await this.users.getTeacherByUserId(userId);
      if (target === 'admin') {
        const adminUserId = await this.primaryAdminUserId();
        return this.findOrCreateAdminTeacher(
          adminUserId,
          teacher.id,
          dto.studentId ?? null,
        );
      }
      if (target === 'parent') {
        if (!dto.studentId) {
          throw new BadRequestException('studentId required');
        }
        await this.users.verifyTeacherStudent(teacher.id, dto.studentId);
        let parentId = dto.parentId;
        if (!parentId) {
          const link = await this.prisma.parentStudent.findFirst({
            where: { studentId: dto.studentId },
          });
          if (!link) {
            throw new BadRequestException('No parent linked to this student');
          }
          parentId = link.parentId;
        } else {
          await this.users.verifyParentStudent(parentId, dto.studentId);
        }
        return this.findOrCreateTeacherParent(
          teacher.id,
          parentId,
          dto.studentId,
        );
      }
      throw new BadRequestException('targetRole must be admin or parent');
    }

    if (role === UserRole.admin) {
      if (target === 'teacher') {
        if (!dto.teacherId) {
          throw new BadRequestException('teacherId required');
        }
        return this.findOrCreateAdminTeacher(
          userId,
          dto.teacherId,
          dto.studentId ?? null,
        );
      }
      if (target === 'parent') {
        if (!dto.parentId || !dto.studentId) {
          throw new BadRequestException('parentId and studentId required');
        }
        await this.users.verifyParentStudent(dto.parentId, dto.studentId);
        return this.findOrCreateAdminParent(
          userId,
          dto.parentId,
          dto.studentId,
        );
      }
      throw new BadRequestException('targetRole must be teacher or parent');
    }

    throw new ForbiddenException('Invalid role for chat');
  }

  /** Parent opens chat with child's teacher (legacy). */
  async getOrCreateTeacherParent(userId: number, studentId: number) {
    const parent = await this.users.getParentByUserId(userId);
    await this.users.verifyParentStudent(parent.id, studentId);

    const teacherLink = await this.prisma.teacherStudent.findFirst({
      where: { studentId },
      include: { teacher: true },
    });
    if (!teacherLink) {
      throw new BadRequestException('Student has no assigned teacher');
    }

    return this.findOrCreateTeacherParent(
      teacherLink.teacherId,
      parent.id,
      studentId,
    );
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

  private async primaryAdminUserId(): Promise<number> {
    const admin = await this.prisma.user.findFirst({
      where: { role: UserRole.admin, isActive: true },
      orderBy: { id: 'asc' },
    });
    if (!admin) {
      throw new BadRequestException('No active admin account');
    }
    return admin.id;
  }

  private async findOrCreateTeacherParent(
    teacherId: number,
    parentId: number,
    studentId: number,
  ) {
    const existing = await this.prisma.conversation.findFirst({
      where: {
        kind: ConversationKind.teacher_parent,
        teacherId,
        parentId,
        studentId,
      },
      include: this.conversationIncludes(),
    });
    if (existing) return (await this.attachStudents([existing]))[0];

    const created = await this.prisma.conversation.create({
      data: {
        kind: ConversationKind.teacher_parent,
        teacherId,
        parentId,
        studentId,
      },
      include: this.conversationIncludes(),
    });
    return (await this.attachStudents([created]))[0];
  }

  private async findOrCreateAdminTeacher(
    adminUserId: number,
    teacherId: number,
    studentId: number | null,
  ) {
    const existing = await this.prisma.conversation.findFirst({
      where: {
        kind: ConversationKind.admin_teacher,
        adminUserId,
        teacherId,
        studentId,
      },
      include: this.conversationIncludes(),
    });
    if (existing) return (await this.attachStudents([existing]))[0];

    const created = await this.prisma.conversation.create({
      data: {
        kind: ConversationKind.admin_teacher,
        adminUserId,
        teacherId,
        studentId,
      },
      include: this.conversationIncludes(),
    });
    return (await this.attachStudents([created]))[0];
  }

  private async findOrCreateAdminParent(
    adminUserId: number,
    parentId: number,
    studentId: number,
  ) {
    const existing = await this.prisma.conversation.findFirst({
      where: {
        kind: ConversationKind.admin_parent,
        adminUserId,
        parentId,
        studentId,
      },
      include: this.conversationIncludes(),
    });
    if (existing) return (await this.attachStudents([existing]))[0];

    const created = await this.prisma.conversation.create({
      data: {
        kind: ConversationKind.admin_parent,
        adminUserId,
        parentId,
        studentId,
      },
      include: this.conversationIncludes(),
    });
    return (await this.attachStudents([created]))[0];
  }

  private async verifyParticipant(
    conversationId: number,
    userId: number,
    role: UserRole,
  ): Promise<ConversationRow> {
    const conversation = await this.prisma.conversation.findUnique({
      where: { id: conversationId },
      include: {
        teacher: { include: { user: { select: { id: true, name: true } } } },
        parent: { include: { user: { select: { id: true, name: true } } } },
        adminUser: { select: { id: true, name: true } },
      },
    });

    if (!conversation) throw new NotFoundException('Conversation not found');

    if (role === UserRole.admin) {
      if (conversation.adminUserId !== userId) {
        throw new ForbiddenException('Not your conversation');
      }
    } else if (role === UserRole.teacher) {
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
      throw new ForbiddenException('Invalid role for chat');
    }

    const student = conversation.studentId
      ? await this.prisma.student.findUnique({
          where: { id: conversation.studentId },
          select: { id: true, name: true, className: true },
        })
      : null;

    return { ...conversation, student: student ?? undefined };
  }

  private async notifyRecipient(
    conversation: ConversationRow,
    senderUserId: number,
    senderRole: UserRole,
    preview: string,
  ) {
    let recipientId: number | null = null;
    let senderLabel = 'رسالة';

    if (conversation.kind === ConversationKind.teacher_parent) {
      if (senderRole === UserRole.teacher) {
        recipientId = conversation.parent!.userId;
        senderLabel = 'المعلمة';
      } else if (senderRole === UserRole.parent) {
        recipientId = conversation.teacher!.userId;
        senderLabel = 'ولي الأمر';
      }
    } else if (conversation.kind === ConversationKind.admin_teacher) {
      if (senderRole === UserRole.admin) {
        recipientId = conversation.teacher!.userId;
        senderLabel = 'المديرة';
      } else if (senderRole === UserRole.teacher) {
        recipientId = conversation.adminUserId!;
        senderLabel = 'المعلمة';
      }
    } else if (conversation.kind === ConversationKind.admin_parent) {
      if (senderRole === UserRole.admin) {
        recipientId = conversation.parent!.userId;
        senderLabel = 'المديرة';
      } else if (senderRole === UserRole.parent) {
        recipientId = conversation.adminUserId!;
        senderLabel = 'ولي الأمر';
      }
    }

    if (!recipientId || recipientId === senderUserId) return;

    const studentName = conversation.student?.name ?? 'الروضة';
    await this.push.notifyUser(
      recipientId,
      'رسالة جديدة',
      `${senderLabel} (${studentName}): ${preview.slice(0, 120)}`,
      NotificationCategory.chat,
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
      adminUser: { select: { id: true, name: true } },
      messages: {
        orderBy: { createdAt: 'desc' as const },
        take: 1,
      },
    };
  }

  private async attachStudents<T extends { studentId: number | null }>(
    convs: T[],
  ) {
    const ids = [
      ...new Set(convs.map((c) => c.studentId).filter((id): id is number => id != null)),
    ];
    if (ids.length === 0) {
      return convs.map((c) => ({ ...c, student: null }));
    }
    const students = await this.prisma.student.findMany({
      where: { id: { in: ids } },
      select: { id: true, name: true, className: true },
    });
    const map = new Map(students.map((s) => [s.id, s]));
    return convs.map((c) => ({
      ...c,
      student: c.studentId != null ? map.get(c.studentId) ?? null : null,
    }));
  }
}
