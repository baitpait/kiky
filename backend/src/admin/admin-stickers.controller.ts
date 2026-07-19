import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  ParseIntPipe,
} from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { UserRole } from '@prisma/client';
import { Roles } from '../common/decorators/roles.decorator';
import { StickersAdminService } from './stickers-admin.service';
import {
  CreateStickerLevelDto,
  UpdateStickerLevelDto,
  CreateStickerDto,
  UpdateStickerDto,
} from '../stickers/dto/stickers.dto';

@ApiTags('Admin — Stickers')
@ApiBearerAuth()
@Roles(UserRole.admin)
@Controller('admin')
export class AdminStickersController {
  constructor(private stickersAdmin: StickersAdminService) {}

  @Get('sticker-levels')
  @ApiOperation({ summary: 'List sticker levels' })
  listLevels() {
    return this.stickersAdmin.findAllLevels();
  }

  @Post('sticker-levels')
  createLevel(@Body() dto: CreateStickerLevelDto) {
    return this.stickersAdmin.createLevel(dto);
  }

  @Put('sticker-levels/:id')
  updateLevel(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateStickerLevelDto,
  ) {
    return this.stickersAdmin.updateLevel(id, dto);
  }

  @Delete('sticker-levels/:id')
  removeLevel(@Param('id', ParseIntPipe) id: number) {
    return this.stickersAdmin.deactivateLevel(id);
  }

  @Get('stickers')
  listStickers() {
    return this.stickersAdmin.findAllStickers();
  }

  @Post('stickers')
  createSticker(@Body() dto: CreateStickerDto) {
    return this.stickersAdmin.createSticker(dto);
  }

  @Put('stickers/:id')
  updateSticker(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateStickerDto,
  ) {
    return this.stickersAdmin.updateSticker(id, dto);
  }

  @Delete('stickers/:id')
  removeSticker(@Param('id', ParseIntPipe) id: number) {
    return this.stickersAdmin.deactivateSticker(id);
  }
}
