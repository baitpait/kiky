import {
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import {
  CreateBannerDto,
  UpdateBannerDto,
  CreateCalendarEventDto,
  UpdateCalendarEventDto,
} from './dto/content.dto';

@Injectable()
export class BannersService {
  constructor(private prisma: PrismaService) {}

  async findAllActive() {
    const now = new Date();
    return this.prisma.banner.findMany({
      where: {
        isActive: true,
        OR: [
          { startsAt: null },
          { startsAt: { lte: now } },
        ],
        AND: [
          { OR: [{ endsAt: null }, { endsAt: { gte: now } }] },
        ],
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async findAllAdmin() {
    return this.prisma.banner.findMany({
      orderBy: { createdAt: 'desc' },
    });
  }

  async findOne(id: number) {
    const banner = await this.prisma.banner.findUnique({ where: { id } });
    if (!banner) throw new NotFoundException('Banner not found');
    return banner;
  }

  async create(dto: CreateBannerDto) {
    return this.prisma.banner.create({
      data: {
        title: dto.title,
        body: dto.body,
        imageUrl: dto.imageUrl,
        target: dto.target,
        startsAt: dto.startsAt ? new Date(dto.startsAt) : undefined,
        endsAt: dto.endsAt ? new Date(dto.endsAt) : undefined,
      },
    });
  }

  async update(id: number, dto: UpdateBannerDto) {
    await this.findOne(id);
    return this.prisma.banner.update({
      where: { id },
      data: {
        title: dto.title,
        body: dto.body,
        imageUrl: dto.imageUrl,
        target: dto.target,
        startsAt: dto.startsAt ? new Date(dto.startsAt) : undefined,
        endsAt: dto.endsAt ? new Date(dto.endsAt) : undefined,
      },
    });
  }

  async deactivate(id: number) {
    await this.findOne(id);
    return this.prisma.banner.update({
      where: { id },
      data: { isActive: false },
    });
  }
}

@Injectable()
export class CalendarService {
  constructor(private prisma: PrismaService) {}

  async findAllActive() {
    return this.prisma.calendarEvent.findMany({
      where: { isActive: true },
      orderBy: { startDate: 'asc' },
    });
  }

  async findAllAdmin() {
    return this.prisma.calendarEvent.findMany({
      orderBy: { startDate: 'desc' },
    });
  }

  async findOne(id: number) {
    const event = await this.prisma.calendarEvent.findUnique({ where: { id } });
    if (!event) throw new NotFoundException('Calendar event not found');
    return event;
  }

  async create(dto: CreateCalendarEventDto) {
    return this.prisma.calendarEvent.create({
      data: {
        title: dto.title,
        description: dto.description,
        eventType: dto.eventType,
        startDate: new Date(dto.startDate),
        endDate: dto.endDate ? new Date(dto.endDate) : undefined,
      },
    });
  }

  async update(id: number, dto: UpdateCalendarEventDto) {
    await this.findOne(id);
    return this.prisma.calendarEvent.update({
      where: { id },
      data: {
        title: dto.title,
        description: dto.description,
        eventType: dto.eventType,
        startDate: dto.startDate ? new Date(dto.startDate) : undefined,
        endDate: dto.endDate ? new Date(dto.endDate) : undefined,
      },
    });
  }

  async deactivate(id: number) {
    await this.findOne(id);
    return this.prisma.calendarEvent.update({
      where: { id },
      data: { isActive: false },
    });
  }
}
