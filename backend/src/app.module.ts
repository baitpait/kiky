import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { PrismaModule } from './prisma/prisma.module';
import { StorageModule } from './storage/storage.module';
import { AuthModule } from './auth/auth.module';
import { AdminModule } from './admin/admin.module';
import { UsersModule } from './users/users.module';
import { StudentsModule } from './students/students.module';
import { PhotosModule } from './photos/photos.module';
import { AttendanceModule } from './attendance/attendance.module';
import { MealsModule } from './meals/meals.module';
import { NotificationsModule } from './notifications/notifications.module';
import { ContentModule } from './content/content.module';
import { HomeworkModule } from './homework/homework.module';
import { AiModule } from './ai/ai.module';
import { ChatModule } from './chat/chat.module';
import { LiveModule } from './live/live.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    PrismaModule,
    StorageModule,
    AuthModule,
    AdminModule,
    UsersModule,
    StudentsModule,
    PhotosModule,
    AttendanceModule,
    MealsModule,
    NotificationsModule,
    ContentModule,
    HomeworkModule,
    AiModule,
    ChatModule,
    LiveModule,
  ],
})
export class AppModule {}
