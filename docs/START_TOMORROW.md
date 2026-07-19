# دليل البدء — Kiddy Link

> **19 يوليو 2026** — اقرأ هذا أولاً عند العودة للمشروع

---

## 1. تشغيل كل شيء (نقرة واحدة)

```powershell
E:\Eman Project\START.bat
```

أو:

```powershell
E:\Eman Project\scripts\go.ps1
```

**المتطلب:** XAMPP → MySQL شغّال (منفذ 3306)

---

## 2. التحقق السريع

```powershell
E:\Eman Project\scripts\health-check.ps1
```

| الخدمة | URL |
|--------|-----|
| **Web** | http://localhost:8082/login |
| **API** | http://localhost:3000/api |

> ⚠️ المنفذ **8082** — ليس 8081.

---

## 3. اختبار تلقائي شامل

```powershell
E:\Eman Project\scripts\test-all.ps1
E:\Eman Project\scripts\test-phase6.ps1
E:\Eman Project\scripts\test-parent-ui.ps1
```

---

## 4. فحص يدوي (Web)

### الهوية البصرية
1. افتح http://localhost:8082/login
2. Splash → Login (تدرج + شعار)
3. `admin` → AppBar أزرق + شارة «مديرة»
4. `p2teacher` → AppBar أخضر
5. `p2parent` → AppBar برتقالي

📄 [BRAND_IMPLEMENTATION.md](./BRAND_IMPLEMENTATION.md)

### صور + إشعارات
1. `p2teacher` / `Test@123456` → رفع صورة
2. `admin` / `Admin@123` → موافقة الصور
3. `p2parent` / `Test@123456` → ألبوم + 🔔 إشعارات

### باقي الميزات
| الحساب | الميزة |
|--------|--------|
| `p3parent` | واجبات + ملصقات |
| `p4parent` | درdشة |
| `p5teacher` ثم `p5parent` | بث (demo على Web) |

> الحسابات الكاملة: [ACCOUNTS.md](./ACCOUNTS.md)

---

## 5. إذا شيء ما اشتغل

| المشكلة | الحل |
|---------|------|
| رابط غلط / صفحة قديمة | استخدم **8082** وليس 8081 |
| API لا يرد | `scripts\restart-api.ps1` |
| Web فارغ / 404 | `scripts\start-web-fast.ps1` |
| MySQL | شغّل XAMPP → Start MySQL |
| صور لا تظهر | Ctrl+Shift+R + تأكد موافقة المديرة |
| منفذ مشغول | `scripts\stop-all.ps1` ثم `go.ps1` |

---

## 6. التوثيق الكامل

| الملف | المحتوى |
|-------|---------|
| [CHECKPOINT.md](./CHECKPOINT.md) | **نقطة التوقف الرئيسية** |
| [PROJECT_SUMMARY.md](./PROJECT_SUMMARY.md) | ملخص شامل |
| [BRAND_IMPLEMENTATION.md](./BRAND_IMPLEMENTATION.md) | الهوية البصرية |
| [PHASES.md](./PHASES.md) | حالة المراحل 1–6 |
| [ACCOUNTS.md](./ACCOUNTS.md) | كل الحسابات |
| [PHOTOS_NOTIFICATIONS_FIX.md](./PHOTOS_NOTIFICATIONS_FIX.md) | إصلاحات الصور والإشعارات |
