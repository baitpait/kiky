import { PrismaClient, UserRole } from '@prisma/client';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
  const adminUsername = process.env.ADMIN_USERNAME || 'admin';
  const adminPassword = process.env.ADMIN_PASSWORD || 'Admin@123';
  const adminName = process.env.ADMIN_NAME || 'مديرة الروضة';

  const existingAdmin = await prisma.user.findUnique({
    where: { username: adminUsername },
  });

  if (!existingAdmin) {
    const passwordHash = await bcrypt.hash(adminPassword, 12);
    await prisma.user.create({
      data: {
        username: adminUsername,
        passwordHash,
        role: UserRole.admin,
        name: adminName,
        isActive: true,
      },
    });
    console.log(`Admin user created: ${adminUsername}`);
  } else {
    const passwordHash = await bcrypt.hash(adminPassword, 12);
    await prisma.user.update({
      where: { username: adminUsername },
      data: { passwordHash, isActive: true, name: adminName },
    });
    console.log(`Admin password synced: ${adminUsername}`);
  }

  const levels = [
    { name: 'مبتدئ', color: '#6BC04B', sortOrder: 1 },
    { name: 'متوسط', color: '#F5A623', sortOrder: 2 },
    { name: 'متقدم', color: '#4A90D9', sortOrder: 3 },
  ];

  for (const level of levels) {
    const existing = await prisma.stickerLevel.findFirst({
      where: { name: level.name },
    });
    if (!existing) {
      await prisma.stickerLevel.create({ data: { ...level, isActive: true } });
    }
  }

  const stickerLevels = await prisma.stickerLevel.findMany({
    orderBy: { sortOrder: 'asc' },
  });

  const stickers = [
    {
      name: 'شاطر',
      iconUrl: '/stickers/shatir.png',
      description: 'التزام وأداء جيد',
      levelName: 'مبتدئ',
    },
    {
      name: 'متعاون',
      iconUrl: '/stickers/mutaawan.png',
      description: 'تعاون مع الآخرين',
      levelName: 'متوسط',
    },
    {
      name: 'مبدع',
      iconUrl: '/stickers/mubdi.png',
      description: 'إبداع في الحل',
      levelName: 'متقدم',
    },
  ];

  for (const sticker of stickers) {
    const level = stickerLevels.find((l) => l.name === sticker.levelName);
    if (!level) continue;

    const existing = await prisma.sticker.findFirst({
      where: { name: sticker.name },
    });
    if (!existing) {
      await prisma.sticker.create({
        data: {
          name: sticker.name,
          iconUrl: sticker.iconUrl,
          description: sticker.description,
          levelId: level.id,
          isActive: true,
        },
      });
    }
  }

  console.log('Seed completed.');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
