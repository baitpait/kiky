# البنية التقنية — Kiddy Link

## نظرة عامة

```
┌─────────────────────────────────────┐
│      Flutter App (عربي RTL)         │
│         iOS + Android               │
│   admin │ teacher │ parent          │
└──────────────┬──────────────────────┘
               │ HTTPS (+ WebSocket في المرحلة 4)
┌──────────────▼──────────────────────┐
│     NestJS API (Port 3000)          │
│   REST + Swagger /api/docs          │
│   JWT Auth + RBAC                   │
└──────────────┬──────────────────────┘
               │
   ┌───────────┼───────────┬──────────────┐
   ▼           ▼           ▼              ▼
  MySQL      Redis      MinIO          FCM/APNs
 (Prisma)   (cache)    (صور/مرفقات)   (Push — مرحلة 2)
               │
        ┌──────┴──────┐
        ▼             ▼
     Agora         OpenAI
   (مرحلة 5)     (مرحلة 3)
```

---

## Monorepo

```
Eman Project/
├── mobile/                 # Flutter 3.x
├── backend/                # NestJS + Prisma
├── docs/                   # هذا التوثيق
├── docker-compose.yml
├── .env.example
├── DEVELOPER_SPEC.md
├── BRAND_IDENTITY.md
└── PROJECT_START_PROMPT.md
```

---

## الأدوار (RBAC)

| Role | الوصف | الواجهة Flutter |
|------|-------|-----------------|
| `admin` | مديرة الروضة | `/admin` |
| `teacher` | معلمة | `/teacher` |
| `parent` | ولي أمر | `/parent` |

- **تطبيق واحد** — لا لوحة ويب
- **لا تسجيل ذاتي** — المديرة تنشئ الحسابات
- ولي الأمر يمكن ربطه بعدة طلاب (`parent_student`)

---

## المصادقة (Auth Flow)

```
1. POST /api/auth/login { username, password }
   → { accessToken, refreshToken, user }

2. طلبات API: Header Authorization: Bearer <accessToken>

3. Access منتهي → POST /api/auth/refresh { refreshToken }
   → tokens جديدة (الجلسة القديمة تُ revoked)

4. POST /api/auth/logout { refreshToken }
   → revoke session
```

| Token | المدة | Secret |
|-------|-------|--------|
| Access | 15 دقيقة | `JWT_ACCESS_SECRET` |
| Refresh | 7 أيام | `JWT_REFRESH_SECRET` |

- كلمات المرور: **bcrypt** (rounds: 12)
- Refresh tokens: مخزّنة كـ SHA-256 hash في `user_sessions`

---

## Guards (Backend)

| Guard | الوظيفة |
|-------|---------|
| `JwtAuthGuard` | يتحقق من Bearer token (global) |
| `RolesGuard` | يتحقق من `@Roles(UserRole.admin)` |
| `@Public()` | يستثني endpoint من JWT |

---

## Soft Delete

لا حذف فعلي للسجلات الحساسة:

| الكيان | الآلية |
|--------|--------|
| users | `is_active = false` |
| teachers / parents | `is_active = false` + user |
| students | `is_active = false` |

---

## Docker Compose Services

| Service | Container | Port | Image |
|---------|-----------|------|-------|
| mysql | kiddy-mysql | 3306 | mysql:8.0 |
| redis | kiddy-redis | 6379 | redis:7-alpine |
| minio | kiddy-minio | 9000, 9001 | minio/minio |
| api | kiddy-api | 3000 | build ./backend |

عند بدء `api`: `prisma migrate deploy` → `seed` → `node dist/main.js`

---

## قرارات معمارية

| القرار | السبب |
|--------|-------|
| Admin داخل Flutter | DEVELOPER_SPEC §12 — لا لوحة ويب |
| Prisma schema كامل من البداية | تجنّب migrations متكررة لاحقاً |
| MinIO من المرحلة 1 | جاهز للصور (مرحلة 2) |
| OpenAI من Backend فقط | أمان — Flutter لا يستدعي AI |
| الملصقات من DB | المديرة تديرها — AI يختار من القائمة النشطة |

---

## خارج النطاق

دفع · اشتراكات · محاسبة · موقع ويب · SMS · WhatsApp · QR حضور · عدة روضات · إنجليزي · تسجيل ذاتي · درdشة معلمة-إدارة
