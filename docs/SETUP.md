# دليل التشغيل — Kiddy Link

## المتطلبات

| الأداة | الإصدار | الاستخدام |
|--------|---------|-----------|
| Node.js | 20+ | Backend |
| Docker Desktop | latest | MySQL, Redis, MinIO, API |
| Flutter | 3.x | Mobile |
| Git | any | version control |

---

## 1. إعداد البيئة

```powershell
cd "e:\Eman Project"
copy .env.example .env
```

راجع [ENVIRONMENT.md](./ENVIRONMENT.md) لتفاصيل كل متغير.

---

## 2. التشغيل الكامل (Docker — موصى به)

```powershell
docker compose up -d --build
```

انتظر حتى تصبح الخدمات healthy، ثم:

| الخدمة | URL |
|--------|-----|
| API | http://localhost:3000 |
| Swagger | http://localhost:3000/api/docs |
| MinIO Console | http://localhost:9001 (minioadmin / minioadmin123) |
| MySQL | localhost:3306 |
| Redis | localhost:6379 |

### التحقق

```powershell
curl http://localhost:3000/api/docs
```

### إيقاف

```powershell
docker compose down
```

### إيقاف + حذف البيانات

```powershell
docker compose down -v
```

---

## 3. تطوير Backend محلياً

### 3.1 البنية التحتية فقط

```powershell
docker compose up -d mysql redis minio
```

### 3.2 تشغيل API

```powershell
cd backend
copy ..\.env.example .env
npm install
npx prisma migrate deploy
npm run prisma:seed
npm run start:dev
```

API: http://localhost:3000 — Swagger: http://localhost:3000/api/docs

### 3.3 أوامر Prisma مفيدة

```powershell
npx prisma studio          # واجهة DB
npx prisma migrate dev       # migration جديدة (تطوير)
npm run prisma:seed          # إعادة seed
npm run build                # compile TypeScript
```

---

## 4. تشغيل Mobile (Flutter)

### 4.1 أول مرة — إنشاء platform folders

```powershell
cd mobile
flutter create . --project-name kiddy_link
flutter pub get
```

### 4.2 Emulator (Android)

Android emulator يستخدم `10.0.2.2` بدل `localhost` (مُعدّ افتراضياً في `api_constants.dart`).

```powershell
flutter run
```

### 4.3 جهاز حقيقي

استبدل `YOUR_IP` بع IP جهازك على الشبكة:

```powershell
flutter run --dart-define=API_BASE_URL=http://192.168.1.X:3000/api
```

### 4.4 iOS Simulator

```powershell
flutter run --dart-define=API_BASE_URL=http://localhost:3000/api
```

---

## 5. اختبار سريع (Swagger أو curl)

### تسجيل دخول Admin

```powershell
curl -X POST http://localhost:3000/api/auth/login `
  -H "Content-Type: application/json" `
  -d '{"username":"admin","password":"Admin@123"}'
```

### إنشاء معلمة (استبدل TOKEN)

```powershell
curl -X POST http://localhost:3000/api/admin/teachers `
  -H "Authorization: Bearer TOKEN" `
  -H "Content-Type: application/json" `
  -d '{"username":"teacher1","password":"Teacher@123","name":"المعلمة سارة"}'
```

---

## 6. بيانات Seed الافتراضية

| البند | القيمة |
|-------|--------|
| Admin username | `admin` |
| Admin password | `Admin@123` |
| مستويات ملصقات | مبتدئ، متوسط، متقدم |
| ملصقات | شاطر، متعاون، مبدع |

---

## 7. استكشاف الأخطاء

| المشكلة | الحل |
|---------|------|
| `docker` not found | ثبّت Docker Desktop |
| `flutter` not found | ثبّت Flutter SDK وأضفه لـ PATH |
| API لا يتصل بـ MySQL | تأكد `docker compose ps` — mysql healthy |
| Flutter: connection refused | تحقق من `API_BASE_URL` و IP |
| Prisma migrate fails | تأكد `DATABASE_URL` في `backend/.env` |
| Port 3000 مشغول | غيّر `API_PORT` في `.env` |

---

## 8. سير عمل التطوير

```
1. docker compose up -d mysql redis minio
2. cd backend && npm run start:dev
3. cd mobile && flutter run
4. Swagger للاختبار: /api/docs
5. Commits: feat: / fix: / chore: (Conventional Commits)
```
