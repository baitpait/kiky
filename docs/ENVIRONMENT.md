# متغيرات البيئة — `.env`

انسخ من `.env.example`:

```powershell
copy .env.example .env
```

---

## MySQL

| المتغير | الافتراضي | الوصف |
|---------|----------|-------|
| `MYSQL_ROOT_PASSWORD` | rootpassword | كلمة root |
| `MYSQL_DATABASE` | kiddy_link | اسم القاعدة |
| `MYSQL_USER` | kiddy | مستخدم التطبيق |
| `MYSQL_PASSWORD` | kiddypass | كلمة المستخدم |
| `MYSQL_PORT` | 3306 | Port خارجي |

## Redis

| المتغير | الافتراضي | الوصف |
|---------|----------|-------|
| `REDIS_PORT` | 6379 | Port خارجي |
| `REDIS_URL` | redis://localhost:6379 | URL للتطوير المحلي |

## MinIO

| المتغير | الافتراضي | الوصف |
|---------|----------|-------|
| `MINIO_ROOT_USER` | minioadmin | مستخدم MinIO |
| `MINIO_ROOT_PASSWORD` | minioadmin123 | كلمة MinIO |
| `MINIO_PORT` | 9000 | API port |
| `MINIO_CONSOLE_PORT` | 9001 | Console port |
| `MINIO_BUCKET` | kiddy-link | Bucket للصور |
| `MINIO_ENDPOINT` | localhost | Host (dev) |
| `MINIO_USE_SSL` | false | SSL |

## API / NestJS

| المتغير | الافتراضي | الوصف |
|---------|----------|-------|
| `NODE_ENV` | development | البيئة |
| `PORT` | 3000 | Port API |
| `API_PORT` | 3000 | Port Docker mapping |
| `DATABASE_URL` | mysql://kiddy:kiddypass@localhost:3306/kiddy_link | Prisma connection |

## JWT

| المتغير | الافتراضي | الوصف |
|---------|----------|-------|
| `JWT_ACCESS_SECRET` | (see .env.example) | Secret للـ access token |
| `JWT_REFRESH_SECRET` | (see .env.example) | Secret للـ refresh token |
| `JWT_ACCESS_EXPIRES` | 15m | مدة access |
| `JWT_REFRESH_EXPIRES` | 7d | مدة refresh |

> **مهم:** غيّر الـ secrets في الإنتاج — 32+ حرف عشوائي.

## Seed (Admin)

| المتغير | الافتراضي | الوصف |
|---------|----------|-------|
| `ADMIN_USERNAME` | admin | اسم مستخدم المديرة |
| `ADMIN_PASSWORD` | Admin@123 | كلمة المرور |
| `ADMIN_NAME` | مديرة الروضة | الاسم المعروض |

## مراحل لاحقة (فارغة حالياً)

| المتغير | المرحلة | الوصف |
|---------|---------|-------|
| `OPENAI_API_KEY` | 3 | تحليل الواجبات |
| `AGORA_APP_ID` | 5 | بث مباشر |
| `AGORA_APP_CERTIFICATE` | 5 | Agora token |
| `FCM_PROJECT_ID` | 2 | Push notifications |
| `FCM_PRIVATE_KEY` | 2 | Firebase service account |
| `FCM_CLIENT_EMAIL` | 2 | Firebase service account |

---

## DATABASE_URL حسب السياق

| السياق | القيمة |
|--------|--------|
| تطوير محلي | `mysql://kiddy:kiddypass@localhost:3306/kiddy_link` |
| داخل Docker API | `mysql://kiddy:kiddypass@mysql:3306/kiddy_link` |

---

## Flutter (dart-define)

| المتغير | الافتراضي | الوصف |
|---------|----------|-------|
| `API_BASE_URL` | `http://10.0.2.2:3000/api` | Base URL للـ API |

```powershell
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:3000/api
```
