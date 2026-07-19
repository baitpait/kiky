import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  ParseIntPipe,
} from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { UserRole } from '@prisma/client';
import { Roles } from '../common/decorators/roles.decorator';
import {
  CurrentUser,
  JwtPayload,
} from '../common/decorators/current-user.decorator';
import { LiveService } from './live.service';
import { StartLiveDto, EndLiveDto } from './dto/live.dto';

@ApiTags('Live')
@ApiBearerAuth()
@Controller('live')
export class LiveController {
  constructor(private liveService: LiveService) {}

  @Post('start')
  @Roles(UserRole.teacher)
  @ApiOperation({ summary: 'Teacher starts live stream — returns Agora token' })
  start(@CurrentUser() user: JwtPayload, @Body() dto: StartLiveDto) {
    return this.liveService.start(user.sub, dto.title);
  }

  @Post('end')
  @Roles(UserRole.teacher)
  @ApiOperation({ summary: 'Teacher ends live stream' })
  end(@CurrentUser() user: JwtPayload, @Body() dto: EndLiveDto) {
    return this.liveService.end(user.sub, dto.streamId);
  }

  @Get('active')
  @Roles(UserRole.parent)
  @ApiOperation({ summary: 'Parent — list active live streams' })
  active(@CurrentUser() user: JwtPayload) {
    return this.liveService.getActiveForParent(user.sub);
  }

  @Get('my-active')
  @Roles(UserRole.teacher)
  @ApiOperation({ summary: 'Teacher — current active stream if any' })
  myActive(@CurrentUser() user: JwtPayload) {
    return this.liveService.getMyActive(user.sub);
  }

  @Post(':id/join')
  @Roles(UserRole.parent)
  @ApiOperation({ summary: 'Parent joins stream as audience — Agora token' })
  join(
    @CurrentUser() user: JwtPayload,
    @Param('id', ParseIntPipe) id: number,
  ) {
    return this.liveService.joinAsAudience(user.sub, id);
  }
}
