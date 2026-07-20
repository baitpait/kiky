# إصلاحات الصور والإشعارات

> **17 يوليو 2026**

---

## مشكلة الصور (Web)

### الأعراض
- الصورة لا تُرفع من المتصفح
- الألبوم فارغ أو أيقونة `broken_image`
- الموافقة في لوحة المديرة بدون صورة

### الأسباب
1. **CORS:** Flutter Web (8082) يحتاج `Access-Control-Allow-Origin` لتحميل صور من API (3000)
2. **localhost vs 127.0.0.1:** روابط قديمة `http://localhost:3000/...` لا تعمل إذا فتحت التطبيق بـ `127.0.0.1`
3. **مسارات مطلقة:** كانت تُحفظ بـ host ثابت

### الإصلاحات

| الملف | التغيير |
|-------|---------|
| `backend/src/main.ts` | CORS middleware على `/uploads/` |
| `backend/src/storage/storage.service.ts` | حفظ مسار نسبي `/uploads/photos/...` |
| `backend/src/photos/photos.service.ts` | تطبيع روابط قديمة عند القراءة |
| `backend/src/photos/dto/photos.dto.ts` | `@Transform` لـ `studentId` من multipart |
| `mobile/lib/shared/utils/media_url_utils.dart` | بناء URL حسب host المتصفح |
| `mobile/lib/features/parent/screens/parent_photos_screen.dart` | refresh + خطأ + نافذة معاينة |
| `mobile/lib/features/teacher/screens/teacher_upload_photo_screen.dart` | MIME + retry 401 |
| `mobile/lib/core/api/api_client.dart` | retry JWT على `uploadMultipart` |

---

## مشكلة الإشعارات

### الأعراض
- الجرس 🔔 لا ينقص بعد قراءة إشعار المديرة
- إشعار البث الجماعي يبقى «غير مقروء»

### الأسباب
1. إشعار واحد مشترك (`userId: null`) لكل المستخدمين
2. `markRead` كان يتجاهل الإشعارات الجماعية
3. Flutter كان يتتبع القراءة محلياً فقط

### الإصلاحات

| الملف | التغيير |
|-------|---------|
| `backend/src/notifications/push.service.ts` | `notifyByTarget` → سجل لكل مستخدم + **`category`** |
| `backend/src/notifications/notifications.service.ts` | `markRead` يحدّث `isRead` دائماً + **قائمة/عداد لكل مستخدم فقط** (`userId`) |
| `backend/prisma/migrations/20250721000000_notification_category/` | عمود `category` ENUM + backfill للإشعارات القديمة |
| `mobile/lib/features/notifications/notification_utils.dart` | تصنيف من API + fallback + فلاتر |
| `mobile/lib/features/notifications/screens/notifications_screen.dart` | API markRead + refresh الجرس + فلاتر + تجميع |

> **21 يوليو 2026:** التفاصيل الكاملة في [NOTIFICATIONS_AND_CHAT_UPDATE.md](./NOTIFICATIONS_AND_CHAT_UPDATE.md)

---

## قواعد مهمة

1. **الصورة لا تظهر لولي الأمر إلا بعد موافقة المديرة**
2. استخدم **http://localhost:8082/login** (ليس 127.0.0.1)
3. `MINIO_ENABLED=false` → صور في `backend/uploads/`
4. FCM Push حقيقي غير مفعّل — الإشعارات في DB فقط

---

## اختبار

```powershell
E:\Eman Project\scripts\test-phase2.ps1
E:\Eman Project\scripts\test-parent-ui.ps1
E:\Eman Project\scripts\test-notifications.ps1
```
