import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import {
  CreateStickerLevelDto,
  UpdateStickerLevelDto,
  CreateStickerDto,
  UpdateStickerDto,
} from '../stickers/dto/stickers.dto';

@Injectable()
export class StickersAdminService {
  constructor(private prisma: PrismaService) {}

  // ─── Levels ───

  findAllLevels() {
    return this.prisma.stickerLevel.findMany({
      orderBy: { sortOrder: 'asc' },
      include: { stickers: { where: { isActive: true } } },
    });
  }

  async findLevel(id: number) {
    const level = await this.prisma.stickerLevel.findUnique({
      where: { id },
      include: { stickers: true },
    });
    if (!level) throw new NotFoundException('Sticker level not found');
    return level;
  }

  createLevel(dto: CreateStickerLevelDto) {
    return this.prisma.stickerLevel.create({ data: dto });
  }

  async updateLevel(id: number, dto: UpdateStickerLevelDto) {
    await this.findLevel(id);
    return this.prisma.stickerLevel.update({ where: { id }, data: dto });
  }

  async deactivateLevel(id: number) {
    await this.findLevel(id);
    return this.prisma.stickerLevel.update({
      where: { id },
      data: { isActive: false },
    });
  }

  // ─── Stickers ───

  findAllStickers() {
    return this.prisma.sticker.findMany({
      include: { level: true },
      orderBy: { createdAt: 'desc' },
    });
  }

  async findSticker(id: number) {
    const sticker = await this.prisma.sticker.findUnique({
      where: { id },
      include: { level: true },
    });
    if (!sticker) throw new NotFoundException('Sticker not found');
    return sticker;
  }

  createSticker(dto: CreateStickerDto) {
    return this.prisma.sticker.create({
      data: dto,
      include: { level: true },
    });
  }

  async updateSticker(id: number, dto: UpdateStickerDto) {
    await this.findSticker(id);
    return this.prisma.sticker.update({
      where: { id },
      data: dto,
      include: { level: true },
    });
  }

  async deactivateSticker(id: number) {
    await this.findSticker(id);
    return this.prisma.sticker.update({
      where: { id },
      data: { isActive: false },
    });
  }
}
