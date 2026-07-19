# Backend — NestJS

> المسار: `backend/`  
> Entry: `src/main.ts`  
> Prefix: `/api`

---

## هيكل المجلدات

```
backend/
├── prisma/
│   ├── schema.prisma       # كل الجداول
│   ├── seed.ts             # admin + stickers
│   └── migrations/
├── src/
│   ├── main.ts             # bootstrap + Swagger
│   ├── app.module.ts
│   ├── auth/               # ✅ Phase 1
│   ├── admin/              # ✅ Phase 1
│   ├── users/              # placeholder module
│   ├── students/           # placeholder module
│   ├── prisma/             # PrismaService (global)
│   ├── common/
│   │   ├── decorators/     # @Roles, @Public, @CurrentUser
│   │   └── guards/         # JwtAuthGuard, RolesGuard
│   ├── photos/             # Phase 2
│   ├── homework/           # Phase 3
│   ├── stickers/           # Phase 3
│   ├── attendance/         # Phase 2
│   ├── meals/              # Phase 2
│   ├── chat/               # Phase 4
│   ├── live/               # Phase 5
│   ├── notifications/      # Phase 2
│   └── ai/                 # Phase 3
├── Dockerfile
└── package.json
```

---

## الوحدات المُفعّلة (Phase 1)

### AuthModule

| File | الوظيفة |
|------|---------|
| `auth.controller.ts` | login, refresh, logout, me |
| `auth.service.ts` | JWT, sessions, bcrypt |
| `strategies/jwt.strategy.ts` | Passport JWT validation |
| `dto/login.dto.ts` | DTOs + validation |

**Global guards** (via APP_GUARD):
- `JwtAuthGuard` — كل route محمي إلا `@Public()`
- `RolesGuard` — يتحقق من `@Roles()`

### AdminModule

| File | الوظيفة |
|------|---------|
| `admin.controller.ts` | REST endpoints |
| `admin.service.ts` | CRUD + linking logic |
| `dto/admin.dto.ts` | Create/Update/Link DTOs |

**Decorator:** `@Roles(UserRole.admin)` على Controller

### PrismaModule

- `@Global()` — PrismaService متاح في كل module
- `$connect` on init, `$disconnect` on destroy

---

## Scripts

```json
{
  "start:dev": "nest start --watch",
  "build": "nest build",
  "prisma:generate": "prisma generate",
  "prisma:migrate": "prisma migrate dev",
  "prisma:seed": "ts-node prisma/seed.ts",
  "db:setup": "prisma migrate deploy && ts-node prisma/seed.ts"
}
```

---

## Swagger

- URL: `/api/docs`
- Bearer auth configured
- Tags: `Auth`, `Admin`

---

## Validation

Global `ValidationPipe`:
- `whitelist: true` — يحذف حقول غير معرّفة
- `forbidNonWhitelisted: true` — يرفض حقول زائدة
- `transform: true` — يحوّل types (e.g. string → number)

---

## Docker

```dockerfile
# Multi-stage build
# CMD: migrate deploy → seed → node dist/main.js
```

---

## إضافة module جديد (مراحل لاحقة)

```powershell
cd backend
nest g module photos
nest g controller photos
nest g service photos
```

ثم أضف في `app.module.ts` و `@Roles()` حسب الدور.

---

## Dependencies الرئيسية

| Package | الاستخدام |
|---------|-----------|
| @nestjs/* | Framework |
| @prisma/client | ORM |
| bcrypt | Password hashing |
| passport-jwt | JWT strategy |
| class-validator | DTO validation |
| @nestjs/swagger | API docs |
