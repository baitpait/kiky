# Kiddy Link — التوثيق النهائي الكامل

> **تاريخ:** 14 يوليو 2026  
> **الحالة:** المراحل 1–6 مكتملة + تم التشغيل المحلي على Windows

---

## 1. مكان حفظ المشروع على جهازك

```
E:\Eman Project\
```

| المجلد/الملف | المحتوى |
|--------------|---------|
| `E:\Eman Project\mobile\` | تطبيق Flutter (عربي RTL) |
| `E:\Eman Project\backend\` | API NestJS + Prisma |
| `E:\Eman Project\docs\` | كل التوثيق |
| `E:\Eman Project\scripts\` | سكربتات التشغيل والتحقق |
| `E:\Eman Project\.env` | إعدادات البيئة المحلية |
| `E:\Eman Project\docker-compose.yml` | Docker (للإنتاج الكامل) |

### أدوات مثبتة خارج المشروع

| الأداة | المسار |
|--------|--------|
| Flutter SDK | `C:\src\flutter` |
| XAMPP MySQL | `C:\xampp\mysql` |
| Node.js | مثبت عالمياً (v24) |

---

## 2. ما بُني (المراحل 1–6)

| المرحلة | المحتوى |
|---------|---------|
| **1** | Auth JWT, RBAC, Admin CRUD, Flutter login |
| **2** | صور, حضور, وجبات, Push, MinIO |
| **3** | ملصقات, واجبات, AI (OpenAI + fallback) |
| **4** | دردشة REST + WebSocket |
| **5** | بث Agora مباشر |
| **6** | بانرات, تقويم, إشعارات, دليل النشر |

### الأرقام

- **24** جدول MySQL
- **60+** API endpoint
- **25+** شاشة Flutter
- **17** وحدة Backend
- **15+** ملف توثيق

---

## 3. التشغيل المحلي (كما يعمل على جهازك)

### المتطلبات الشغّالة

| الخدمة | الحالة | المنفذ |
|--------|--------|--------|
| XAMPP MySQL | ✅ | 3306 |
| NestJS API | ✅ | 3000 |
| Flutter Web | ✅ | 8082 |
| MinIO | ⏳ يحتاج Docker | 9000 |
| Redis | ⏳ يحتاج Docker | 6379 |

### تشغيل يومي (بدون Docker)

**الخطوة 1 — تأكد أن XAMPP MySQL شغّال**

**الخطوة 2 — شغّل الـ API:**
```powershell
cd "E:\Eman Project\backend"
npm run start:dev
```

**الخطوة 3 — شغّل التطبيق:**
```powershell
cd "E:\Eman Project\mobile"
E:\Eman Project\scripts\start-web-fast.ps1
```

### الروابط

| الخدمة | URL |
|--------|-----|
| التطبيق | http://localhost:8082/login |
| Swagger API | http://localhost:3000/api/docs |
| API Base | http://localhost:3000/api |

### تسجيل الدخول الافتراضي

```
اسم المستخدم: admin
كلمة المرور: Admin@123
```

---

## 4. قاعدة البيانات

| البند | القيمة |
|-------|--------|
| المحرك | MySQL (XAMPP / MariaDB) |
| اسم القاعدة | `kiddy_link` |
| المستخدم | `kiddy` |
| كلمة المرور | `kiddypass` |
| Host | `localhost:3306` |

**إعادة بناء القاعدة:**
```powershell
cd "E:\Eman Project\backend"
npx prisma db push
npx prisma db seed
```

---

## 5. الإصلاحات التي تمت أثناء التشغيل

### Backend
- إضافة `UsersModule` لـ: Photos, Attendance, Meals, Homework, Chat, Live, Content
- `StorageService` لا يتعطل إذا MinIO غير متاح (وضع dev)

### Flutter
- إصلاح شاشة بيضاء: GoRouter يُنشأ مرة واحدة فقط
- `ApiConstants`: `localhost` للويب بدل `10.0.2.2`
- شاشة تحميل أثناء `AuthProvider.init()`
- إصلاح imports في `app_router.dart`
- إصلاح `teacher_home_screen` (أيقونة ناقصة)
- إصلاح `parent_homework_screen` (syntax)
- `flutter create` — أُضيفت مجلدات android/ios/web

### البيئة
- Flutter 3.44.6 في `C:\src\flutter`
- قاعدة بيانات XAMPP بدل Docker للتطوير
- سكربتات: `verify.ps1`, `install-and-run-admin.ps1`, `start-local.ps1`

---

## 6. فهرس التوثيق

| الملف | المحتوى |
|-------|---------|
| [README.md](../README.md) | نظرة عامة |
| [docs/README.md](./README.md) | فهرس التوثيق |
| [docs/PHASES.md](./PHASES.md) | المراحل 1–6 |
| [docs/ARCHITECTURE.md](./ARCHITECTURE.md) | البنية التقنية |
| [docs/SETUP.md](./SETUP.md) | التشغيل العام |
| [docs/SETUP_WINDOWS.md](./SETUP_WINDOWS.md) | Windows خطوة بخطوة |
| [docs/DEPLOYMENT.md](./DEPLOYMENT.md) | النشر على السيرفر |
| [docs/PROJECT_SUMMARY.md](./PROJECT_SUMMARY.md) | ملخص سريع |
| [docs/API-PHASE1.md](./API-PHASE1.md) … [API-PHASE6.md](./API-PHASE6.md) | APIs |
| [DEVELOPER_SPEC.md](../DEVELOPER_SPEC.md) | المواصفات الكاملة |
| [BRAND_IDENTITY.md](../BRAND_IDENTITY.md) | الهوية البصرية |
| [CHANGELOG.md](../CHANGELOG.md) | سجل التغييرات |

---

## 7. هيكل المشروع الكامل

```
E:\Eman Project\
├── mobile/                    # Flutter 3.44 — عربي RTL
│   ├── lib/
│   │   ├── core/              # theme, api, router, constants
│   │   ├── features/          # auth, admin, teacher, parent, chat, live...
│   │   └── shared/
│   ├── android/ ios/ web/     # منصات (flutter create)
│   └── pubspec.yaml
├── backend/                   # NestJS 10
│   ├── src/
│   │   ├── auth/ admin/ photos/ attendance/ meals/
│   │   ├── homework/ stickers/ ai/ chat/ live/
│   │   ├── content/ notifications/ storage/ users/
│   │   └── prisma/
│   ├── prisma/schema.prisma   # 24 جدول
│   └── package.json
├── docs/                      # التوثيق الكامل
├── scripts/
│   ├── verify.ps1
│   ├── start-local.ps1
│   └── install-and-run-admin.ps1
├── docker-compose.yml
├── .env / .env.example
├── README.md
├── CHANGELOG.md
├── DEVELOPER_SPEC.md
├── BRAND_IDENTITY.md
└── PROJECT_START_PROMPT.md
```

---

## 8. الأدوار والشاشات

### Admin (مديرة)
- الرئيسية, بانرات, تقويم, إشعارات, ملصقات, موافقة صور

### Teacher (معلمة)
- رفع صور, حضور, وجبات, واجبات, دردشة, بث مباشر

### Parent (ولي أمر)
- صور, حضور, وجبات, واجبات, ملصقات, تقويم, دردشة, بث

---

## 9. للنشر على السيرفر (فلسطين)

راجع [DEPLOYMENT.md](./DEPLOYMENT.md):
1. Ubuntu 22.04 + Docker
2. `docker compose up -d --build`
3. Nginx + SSL
4. `flutter build apk` / `flutter build appbundle`

---

## 10. ملاحظات مهمة

- **رفع الصور** يحتاج MinIO → شغّل Docker كاملاً
- **Push Notifications** يحتاج FCM credentials في `.env`
- **البث المباشر** يحتاج Agora credentials (أو وضع demo)
- **AI للملصقات** يحتاج `OPENAI_API_KEY` (أو fallback تلقائي)
- **Docker** يحتاج WSL2 + صلاحيات مدير — استخدم `scripts/install-and-run-admin.ps1`

---

*آخر تحديث: 14 يوليو 2026 — Kiddy Link v1.0*
