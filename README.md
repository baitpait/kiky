# Kiddy Link

**Connecting Home & Kindergarten** — تطبيق موبايل يربط روضة أطفال واحدة بأولياء الأمور.

| | |
|---|---|
| **الحالة** | المراحل 1–6 ✅ + الهوية البصرية ✅ |
| **اللغة** | عربي RTL |
| **Stack** | Flutter · NestJS · MySQL (XAMPP) |

---

## تشغيل سريع (Windows — XAMPP)

```powershell
E:\Eman Project\START.bat
```

أو:

```powershell
E:\Eman Project\scripts\go.ps1
```

| الخدمة | URL |
|--------|-----|
| **التطبيق** | http://localhost:8082/login |
| **API** | http://localhost:3000/api |
| **Swagger** | http://localhost:3000/api/docs |
| **Login** | `admin` / `Admin@123` |

> **مكان المشروع:** `E:\Eman Project\`  
> **نقطة التوقف:** [docs/CHECKPOINT.md](./docs/CHECKPOINT.md)  
> **التوثيق الكامل:** [docs/README.md](./docs/README.md)

---

## التوثيق

📚 **[docs/README.md](./docs/README.md)** — فهرس التوثيق الكامل

| الملف | المحتوى |
|-------|---------|
| [docs/CHECKPOINT.md](./docs/CHECKPOINT.md) | **نقطة التوقف — اقرأ أولاً** |
| [docs/BRAND_IMPLEMENTATION.md](./docs/BRAND_IMPLEMENTATION.md) | الهوية البصرية — التنفيذ |
| [docs/PHASES.md](./docs/PHASES.md) | حالة المراحل 1–6 |
| [docs/PROJECT_SUMMARY.md](./docs/PROJECT_SUMMARY.md) | ملخص شامل |
| [docs/SETUP_WINDOWS.md](./docs/SETUP_WINDOWS.md) | Windows + XAMPP |
| [DEVELOPER_SPEC.md](./DEVELOPER_SPEC.md) | المواصفات الكاملة |
| [BRAND_IDENTITY.md](./BRAND_IDENTITY.md) | الهوية البصرية — المواصفة |
| [CHANGELOG.md](./CHANGELOG.md) | سجل التغييرات |

---

## هيكل المشروع

```
Eman Project/
├── mobile/              # Flutter (عربي RTL + Brand v1.0)
├── backend/             # NestJS + Prisma
├── docs/                # التوثيق
├── scripts/             # تشغيل + اختبار
└── README.md
```

---

## ما تم إنجازه

- **المراحل 1–6:** Auth, CRUD, صور, حضور, وجبات, واجبات, ملصقات, AI, درdشة, بث, نشر
- **اختبارات:** `test-phase2.ps1` … `test-phase6.ps1` — ALL PASSED
- **الهوية البصرية v1.0:** Splash, Login, ألوان, AppBar حسب الدور
- **Web:** http://localhost:8082/login

---

## Mobile

```powershell
cd mobile
flutter pub get
flutter build web --release
```

أو: `scripts\start-web-fast.ps1`

راجع [docs/MOBILE.md](./docs/MOBILE.md) و [docs/BRAND_IMPLEMENTATION.md](./docs/BRAND_IMPLEMENTATION.md).

