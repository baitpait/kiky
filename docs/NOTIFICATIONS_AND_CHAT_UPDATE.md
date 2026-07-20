# تحديث الدردشة والإشعارات — يوليو 2026

> **التاريخ:** 21 يوليو 2026  
> **المسار:** `E:\Eman Project\`

---

## ملخص

| الميزة | الحالة | اختبار |
|--------|--------|--------|
| درdشة بين **كل الأدوار** (admin ↔ teacher ↔ parent) | ✅ | `test-phase4.ps1` |
| إشعارات per-user + جرس Web عبر API | ✅ | `test-notifications.ps1` |
| تصنيف دقيق `category` من Backend | ✅ | migration + API field |
| واجهة إشعارات محسّنة (فلاتر + تجميع + تفاصيل) | ✅ | يدوي Web |
| تشغيل على الشبكة المحلية (LAN) | ✅ | `start-network.ps1` |
| خط Cairo محلي (بدون Google Fonts CDN) | ✅ | `mobile/assets/fonts/` |

---

## 1. الدردشة — كل الأزواج

### قبل
- درdشة ولي أمر ↔ معلمة فقط

### بعد
| النوع | `ConversationKind` | المشاركون |
|-------|-------------------|-----------|
| معلمة ↔ ولي أمر | `teacher_parent` | teacher + parent (+ student) |
| مديرة ↔ معلمة | `admin_teacher` | admin + teacher |
| مديرة ↔ ولي أمر | `admin_parent` | admin + parent (+ student) |

### Backend
| الملف | التغيير |
|-------|---------|
| `backend/prisma/schema.prisma` | enum `ConversationKind` + FKs nullable |
| `backend/prisma/migrations/20250720120000_chat_all_roles/` | ترحيل DB |
| `backend/src/chat/chat.service.ts` | إنشاء/قائمة/رسائل لكل الأنواع |
| `backend/src/chat/chat.controller.ts` | endpoints محدّثة |
| `backend/src/chat/dto/chat.dto.ts` | DTOs للأنواع الجديدة |

### Flutter
| الملف | التغيير |
|-------|---------|
| `mobile/lib/features/chat/screens/chat_list_screen.dart` | FAB لبدء محادثة لكل دور |
| `mobile/lib/features/chat/screens/chat_room_screen.dart` | عناوين حسب نوع المحادثة |
| `mobile/lib/features/chat/services/chat_repository.dart` | API calls محدّثة |
| `mobile/lib/features/admin/screens/admin_home_screen.dart` | زر الدردشة للمديرة |

### اختبار
```powershell
E:\Eman Project\scripts\test-phase4.ps1
```

---

## 2. الإشعارات — دقة وجودة

### مشاكل كانت موجودة
1. سجل مشترك `userId: null` — الجرس لا ينقص بشكل صحيح
2. التصنيف يُخمّن من نص العنوان/المحتوى (غير دقيق)
3. واجهة بسيطة بدون فلاتر أو تجميع زمني

### الحل — Backend

#### عمود `category`
```sql
-- migration: 20250721000000_notification_category
category ENUM(
  attendance, absence, homework, homework_confirm,
  meal, photo, sticker, live, chat, announcement
) NOT NULL DEFAULT 'announcement'
```

#### مصدر التصنيف لكل نوع إشعار
| المصدر | category |
|--------|----------|
| `attendance.service.ts` — check_in/out | `attendance` |
| `attendance.service.ts` — absent | `absence` |
| `homework.service.ts` — create | `homework` |
| `homework.service.ts` — confirm | `homework_confirm` |
| `homework.service.ts` — grade/sticker | `sticker` |
| `meals.service.ts` | `meal` |
| `admin-content.controller.ts` — photo approve | `photo` |
| `live.service.ts` | `live` |
| `chat.service.ts` — رسالة جديدة | `chat` |
| `admin-content.controller.ts` — broadcast | `announcement` |

#### ملفات Backend رئيسية
| الملف | التغيير |
|-------|---------|
| `push.service.ts` | `notifyUser/Users/ByTarget` + `category` + `createMany` |
| `notifications.service.ts` | قائمة/عداد per-user فقط؛ `markRead` 403 لغير المالك |
| `notifications.controller.ts` | `PUT /notifications/read-all` |

### الحل — Flutter

| الملف | التغيير |
|-------|---------|
| `notification_utils.dart` | parse + style + filter + وقت عربي |
| `notifications_screen.dart` | بطاقات، فلاتر، تجميع (اليوم/أمس/الأسبوع)، bottom sheet |
| `notification_bell_refresh.dart` | تحديث الجرس بعد القراءة |
| `notification_repository.dart` | `markAllRead()` |

#### فلاتر الواجهة
الكل | حضور | واجبات | وجبات | رسائل | إعلانات

#### API endpoints (Web)
```
GET  /api/notifications
GET  /api/notifications/unread-count
PUT  /api/notifications/:id/read
PUT  /api/notifications/read-all
```

### اختبار
```powershell
E:\Eman Project\scripts\test-notifications.ps1
```

---

## 3. تشغيل الشبكة المحلية (LAN)

لاختبار من الهاتف على نفس Wi‑Fi:

```powershell
E:\Eman Project\scripts\start-network.ps1
```

| الخدمة | URL (مثال) |
|--------|------------|
| Web | `http://192.168.x.x:8082/login` |
| API | `http://192.168.x.x:3000/api` |

- API يستمع على `0.0.0.0:3000` (`backend/src/main.ts`)
- Web يُخدم عبر `spa_server.py` على `0.0.0.0:8082`

---

## 4. إصلاحات الكود (يوليو 21)

| الإصلاح | الملفات |
|---------|---------|
| `LabeledDropdown` بدل `DropdownButtonFormField.value` الم deprecated | admin + teacher + parent + homework screens |
| `mounted` check بعد async | `admin_students_screen.dart` |
| `safe_admin_feedback.dart` | snackbars آمنة بعد async |
| `scripts/clean-cache.ps1` | تنظيف cache Flutter |
| Cairo font محلي | `pubspec.yaml` + `assets/fonts/` |

### Analyzer
- **0 errors / 0 warnings** — متبقي ~21 `info` (const + dart:html web-only — مقبول لـ Flutter Web)

---

## 5. حسابات الاختبار

| الدور | المستخدم | كلمة السر |
|-------|----------|-----------|
| مديرة | `admin` | `Admin@123` |
| معلمة (دردشة) | `p4teacher` | `Test@123456` |
| ولي أمر (دردشة) | `p4parent` | `Test@123456` |
| معلمة (مرحلة 2) | `p2teacher` | `Test@123456` |
| ولي أمر (مرحلة 2) | `p2parent` | `Test@123456` |

---

## 6. سكربتات مهمة

```powershell
E:\Eman Project\scripts\go.ps1              # تشغيل كامل
E:\Eman Project\scripts\stop-all.ps1          # إيقاف API + Web
E:\Eman Project\scripts\start-network.ps1     # LAN للهاتف
E:\Eman Project\scripts\health-check.ps1      # فحص صحة
E:\Eman Project\scripts\test-notifications.ps1
E:\Eman Project\scripts\test-phase4.ps1
E:\Eman Project\scripts\clean-cache.ps1
E:\Eman Project\scripts\start-web-fast.ps1
```

---

## 7. ترحيل قاعدة البيانات (مرة واحدة)

إذا لم تُطبَّق الترحيلات بعد:

```powershell
Get-Content "E:\Eman Project\backend\prisma\migrations\20250720120000_chat_all_roles\migration.sql" | C:\xampp\mysql\bin\mysql.exe -u root kiddy_link
Get-Content "E:\Eman Project\backend\prisma\migrations\20250721000000_notification_category\migration.sql" | C:\xampp\mysql\bin\mysql.exe -u root kiddy_link
cd "E:\Eman Project\backend"
npx prisma generate
npm run build
```

---

## 8. ملاحظات

- **FCM:** غير مفعّل — الإشعارات في DB فقط (مناسب لـ Web)
- **الإشعارات القديمة** بدون `category` دقيقة: fallback من النص في Flutter
- استخدم **localhost** للصور (CORS) — راجع `docs/PHOTOS_NOTIFICATIONS_FIX.md`
