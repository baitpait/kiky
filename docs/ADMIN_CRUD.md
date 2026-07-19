# Admin Dashboard — حسب DEVELOPER_SPEC.md

> لوحة المديرة داخل Flutter فقط — §8.2 + §12

## الشاشات (بالترتيب §8.2)

| # | الشاشة | الملف | API |
|---|--------|-------|-----|
| 1 | لوحة التحكم (إحصائيات سريعة) | `admin_home_screen.dart` | `GET /api/admin/stats` |
| 2 | إدارة المعلمات | `admin_teachers_screen.dart` | `/api/admin/teachers` |
| 3 | إدارة أولياء الأمور | `admin_parents_screen.dart` | `/api/admin/parents` |
| 4 | إدارة الطلاب + الربط | `admin_students_screen.dart` | `/api/admin/students` + link |
| 5 | موافقة الصور (قائمة انتظار) | `admin_pending_photos_screen.dart` | `/api/admin/photos/pending` |
| 6 | إدارة البانرات | `admin_banners_screen.dart` | `/api/admin/banners` |
| 7 | التقويم السنوي | `admin_calendar_screen.dart` | `/api/admin/calendar-events` |
| 8 | إرسال إشعارات | `admin_notify_screen.dart` | `/api/admin/notifications/send` |
| 9 | إدارة مستويات الملصقات | `admin_sticker_levels_screen.dart` | `/api/admin/sticker-levels` |
| 10 | إدارة الملصقات | `admin_stickers_screen.dart` | `/api/admin/stickers` |
| 11 | إنشاء/تعديل حساب | `admin_accounts_screen.dart` | — (توجيه لشاشات الحسابات) |

## تجميع القوائم (§12)

- **إدارة الحسابات:** #2, #3, #4, #11
- **موافقة الصور:** #5
- **البانرات والتقويم:** #6, #7
- **الملصقات والمستويات:** #9, #10
- **الإشعارات:** #8

## إحصائيات لوحة التحكم (§12)

ثلاثة أرقام رئيسية فقط في الأعلى:
- معلمات
- طلاب
- صور بانتظار الموافقة

## Repositories

- `admin_repository.dart` — معلمات، أولياء، طلاب، stats
- `content_repository.dart` — بانرات، تقويم، إشعارات
- `sticker_repository.dart` — مستويات وملصقات

## تشغيل

```powershell
E:\Eman Project\scripts\start-all.ps1
```

Login: `admin` / `Admin@123` → http://localhost:8082/login
