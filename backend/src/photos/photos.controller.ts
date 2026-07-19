import {
  Controller,
  Get,
  Post,
  Param,
  ParseIntPipe,
  UseInterceptors,
  UploadedFile,
  Body,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import {
  ApiTags,
  ApiBearerAuth,
  ApiOperation,
  ApiConsumes,
  ApiBody,
} from '@nestjs/swagger';
import { UserRole } from '@prisma/client';
import { Roles } from '../common/decorators/roles.decorator';
import {
  CurrentUser,
  JwtPayload,
} from '../common/decorators/current-user.decorator';
import { PhotosService } from './photos.service';
import { UploadPhotoDto } from './dto/photos.dto';

@ApiTags('Photos')
@ApiBearerAuth()
@Controller('photos')
export class PhotosController {
  constructor(private photosService: PhotosService) {}

  @Post()
  @Roles(UserRole.teacher)
  @UseInterceptors(FileInterceptor('image'))
  @ApiConsumes('multipart/form-data')
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        image: { type: 'string', format: 'binary' },
        studentId: { type: 'integer' },
        caption: { type: 'string' },
      },
      required: ['image', 'studentId'],
    },
  })
  @ApiOperation({ summary: 'Teacher uploads photo (pending approval)' })
  upload(
    @CurrentUser() user: JwtPayload,
    @UploadedFile() file: Express.Multer.File,
    @Body() dto: UploadPhotoDto,
  ) {
    return this.photosService.upload(
      user.sub,
      dto.studentId,
      file,
      dto.caption,
    );
  }

  @Get('my-students')
  @Roles(UserRole.teacher)
  @ApiOperation({ summary: 'Teacher — photos of assigned students' })
  myStudents(@CurrentUser() user: JwtPayload) {
    return this.photosService.findByTeacher(user.sub);
  }

  @Get('student/:id')
  @Roles(UserRole.parent)
  @ApiOperation({ summary: 'Parent — approved photos of child' })
  byStudent(
    @CurrentUser() user: JwtPayload,
    @Param('id', ParseIntPipe) studentId: number,
  ) {
    return this.photosService.findApprovedByStudent(user.sub, studentId);
  }
}
