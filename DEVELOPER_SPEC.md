# Kiddy Link — مواصفات المبرمج
## Connecting Home & Kindergarten

| البند | التفاصيل |
|-------|----------|
| **الإصدار** | 1.0 |
| **التاريخ** | يوليو 2026 |
| **المنصة** | تطبيق موبايل فقط (Flutter) |
| **اللغة** | عربي فقط — RTL |
| **النطاق** | روضة واحدة |
| **الاستضافة** | سيرفر خاص — فلسطين |

---

## 1. نظرة عامة

**Kiddy Link** تطبيق يربط الروضة بأولياء الأمور. ليس نظام محاسبة ولا اشتراكات ولا دفع.

**تطبيق واحد (Flutter)** — عند تسجيل الدخول يُعرض واجهة مختلفة حسب الدور: مديرة، معلمة، أو ولي أمر. **لا يوجد موقع ويب.**

### الأدوار

| الدور | الوصف |
|-------|-------|
| **مديرة الروضة** | إدارة كاملة: حسابات، موافقات، تقويم، بانرات، إشعارات، **إدارة الملصقات** |
| **المعلمة** | تفاعل يومي: صور، واجبات، حضور، وجبات، بث مباشر، دردشة |
| **ولي الأمر** | متابعة طفله/أطفاله: صور، واجبات، حضور، وجبات، بث، دردشة |

### خارج النطاق (Out of Scope)

- دفع / اشتراكات / محاسبة
- تطبيق ويب أو لوحة ويب منفصلة — **كل شيء داخل تطبيق Flutter** (انظر §12)
- تسجيل ذاتي للمستخدمين
- دردشة المعلمة ↔ الإدارة
- SMS / WhatsApp
- QR للحضور
- عدة روضات (Multi-tenant)
- لغة إنجليزية
- تسجيل البث المباشر

---

## 2. Stack التقني

```
┌─────────────────────────────────────┐
│      Flutter App (عربي RTL)         │
│         iOS + Android               │
└──────────────┬──────────────────────┘
               │ HTTPS + WebSocket
┌──────────────▼──────────────────────┐
│     NestJS API (سيرفر فلسطين)       │
│   REST + WebSocket (دردشة/Realtime) │
└──────────────┬──────────────────────┘
               │
   ┌───────────┼───────────┬──────────────┐
   ▼           ▼           ▼              ▼
  MySQL      Redis      MinIO/FS       FCM/APNs
 (بيانات)   (cache)     (صور)         (Push)
               │
        ┌──────┴──────┐
        ▼             ▼
     Agora         OpenAI API
   (بث مباشر)    (تحليل الواجبات)
```

### التقنيات

| الطبقة | التقنية |
|--------|---------|
| Mobile | Flutter 3.x + Dart |
| Backend | NestJS + TypeScript |
| Database | **MySQL 8.x** |
| ORM | Prisma أو TypeORM |
| Cache/Queue | Redis |
| تخزين الصور | MinIO أو مجلدات على السيرفر |
| Proxy/SSL | Nginx |
| حاويات | Docker (موصى به) |
| Push | Firebase Cloud Messaging (FCM) + APNs |
| بث مباشر | Agora SDK |
| AI | OpenAI API (أو بديل متاح) |

---

## 3. المصادقة والحسابات

- **لا يوجد تسجيل ذاتي** — المديرة تنشئ كل الحسابات
- المديرة تعطي **اسم مستخدم + كلمة مرور** لكل مستخدم
- JWT Access Token + Refresh Token
- ولي الأمر يمكن ربطه بأكثر من طالب — تبديل بين الأطفال داخل التطبيق

### الأدوار (RBAC)

```typescript
enum UserRole {
  ADMIN   = 'admin',    // مديرة الروضة
  TEACHER = 'teacher',  // معلمة
  PARENT  = 'parent',   // ولي أمر
}
```

---

## 4. نظام الملصقات (Stickers) — إدارة + مستويات

> **مهم:** الملصقات **ليست ثابتة في الكود**. المديرة تضيفها وتعدّلها من **شاشات الإدارة داخل التطبيق**، ولكل ملصق **مستوى** خاص.

### 4.1 مستويات الملصقات (Sticker Levels)

المديرة تعرّف المستويات، مثال:

| المستوى | الاسم | اللون | الترتيب |
|---------|-------|-------|---------|
| 1 | مبتدئ | 🟢 أخضر | 1 |
| 2 | متوسط | 🟡 أصفر | 2 |
| 3 | متقدم | 🔴 أحمر | 3 |

> الأسماء والألوان قابلة للتخصيص من الإدارة.

### 4.2 الملصقات (Stickers)

المديرة تضيف ملصقات وترتبط كل واحدة بمستوى:

| الملصق | المستوى | الوصف |
|--------|---------|-------|
| شاطر | مبتدئ | التزام وأداء جيد |
| متعاون | متوسط | تعاون مع الآخرين |
| مبدع | متقدم | إبداع في الحل |

كل ملصق يحتوي:
- اسم (عربي)
- أيقونة/صورة
- مستوى (FK → sticker_levels)
- وصف اختياري
- حالة (نشط / معطّل)

### 4.3 تدفق الواجب + AI + الملصق

```
1. المعلمة تعطي واجب/نشاط لطالب أو مجموعة
2. ولي الأمر يرى الواجب ويؤكد: "تم الحل"
3. المعلمة تصحح الواجب (درجة/ملاحظة)
4. AI يحلل الواجب المصحّح
5. AI يختار ملصقاً من الملصقات النشطة (حسب المستوى والتحليل)
6. يُضاف الملصق لحساب الطالب
7. يظهر لولي الأمر على ملف الطفل
```

### 4.4 قواعد AI

- AI يختار من **قائمة الملصقات النشطة** فقط (لا ينشئ ملصقات جديدة)
- يأخذ بالاعتبار **مستوى الملصق** ومحتوى/جودة الواجب
- يُسجَّل: `assigned_by: 'ai'` + `homework_id` + `sticker_id`
- المعلمة يمكنها **تعديل أو إلغاء** الملصق بعد AI (اختياري — يُحدد في التطوير)

---

## 5. الميزات التفصيلية

### 5.1 المديرة

| الميزة | التفاصيل |
|--------|----------|
| إدارة الطلاب | CRUD — اسم، صف، ربط معلمة، ربط ولي/أولياء |
| إدارة المعلمات | CRUD + بيانات دخول |
| إدارة أولياء الأمور | CRUD + ربط بطلاب + بيانات دخول |
| التقويم السنوي | عطلات، إجازات، فعاليات |
| البانرات | إعلانات مخصصة (للمعلمات / لأولياء الأمور / للجميع) |
| الإشعارات | إرسال Push (للجميع / معلمات / أولياء أمور) |
| موافقة الصور | الموافقة أو الرفض قبل النشر في الألبوم |
| **إدارة الملصقات** | إضافة/تعديل/تعطيل ملصقات + مستوياتها |
| **إدارة المستويات** | إضافة/تعديل مستويات الملصقات |

### 5.2 المعلمة

| الميزة | التفاصيل |
|--------|----------|
| ألبوم الصور | رفع صور لطلابها فقط — اسم + تاريخ — **بانتظار موافقة المديرة** |
| بث مباشر | **المعلمة فقط** تبدأ البث عبر Agora — يظهر لأولياء الأمور مع اسم البث |
| الواجبات | إعطاء أنشطة/واجبات منزلية |
| تصحيح الواجبات | تصحيح بعد تأكيد ولي الأمر |
| الحضور | تسجيل حضور وانصراف يدوياً لكل طالب |
| الوجبات | تأكيد أن الطفل تناول الوجبة في الروضة |
| الدردشة | مع أولياء الأمور لطلابها — رفع صور في الدردشة |
| عرض الملصقات | ملصقات طلابها |

### 5.3 ولي الأمر

| الميزة | التفاصيل |
|--------|----------|
| تبديل الأطفال | إذا لديه أكثر من طالب |
| ألبوم الصور | مشاهدة صور طفله المنشورة فقط |
| البث المباشر | مشاهدة بث معلمته |
| الواجبات | عرض + تأكيد "تم الحل" |
| ملصقات الطفل | عرض الملصقات المكتسبة (مع المستوى) |
| التقويم | عطلات وفعاليات |
| البانرات | إعلانات موجهة له |
| الحضور | مشاهدة حضور/غياب/انصراف + إشعارات Push |
| الوجبات | تأكيد تناول الوجبة |
| الدردشة | مع معلمة الطفل — رفع صور في الدردشة |

### 5.4 الإشعارات (Push فقط)

| الحدث | المستلم |
|-------|---------|
| تسجيل حضور | ولي الأمر |
| تسجيل انصراف | ولي الأمر |
| غياب | ولي الأمر |
| واجب جديد | ولي الأمر |
| تأكيد حل الواجب | المعلمة |
| ملصق جديد (AI) | ولي الأمر |
| صورة جديدة (بعد الموافقة) | ولي الأمر |
| بث مباشر بدأ | أولياء الأمور |
| تأكيد وجبة (ولي الأمر) | المعلمة |
| تأكيد وجبة (معلمة) | ولي الأمر |
| رسالة دردشة جديدة | الطرف الآخر |
| إعلان/بانر من المديرة | حسب الاستهداف |

---

## 6. قاعدة البيانات (MySQL)

### 6.1 الجداول الرئيسية

```
═══ المستخدمون ═══
users
user_sessions

═══ الروضة ═══
students
teachers
parents
parent_student        -- ربط ولي أمر ↔ طالب (many-to-many)
teacher_student       -- ربط معلمة ↔ طالب

═══ المحتوى ═══
photos                -- ألبوم الصور (بانتظار موافقة)
photo_approvals
banners
calendar_events

═══ الواجبات والملصقات ═══
sticker_levels        -- مستويات الملصقات (من الإدارة)
stickers              -- الملصقات (من الإدارة، مرتبطة بمستوى)
homeworks
homework_submissions  -- تأكيد ولي الأمر + تصحيح المعلمة
student_stickers      -- ملصقات مكتسبة (من AI أو يدوي)

═══ الحضور والوجبات ═══
attendance_records
meal_records

═══ البث ═══
live_streams

═══ الدردشة ═══
conversations         -- معلمة ↔ ولي أمر
messages
message_attachments

═══ الإشعارات ═══
notifications
device_tokens         -- FCM tokens
```

### 6.2 جداول الملصقات (تفصيل)

#### sticker_levels

| العمود | النوع | الوصف |
|--------|-------|-------|
| id | INT PK AUTO | |
| name | VARCHAR(50) | اسم المستوى (مبتدئ، متوسط، متقدم) |
| color | VARCHAR(7) | لون hex (#00FF00) |
| sort_order | INT | ترتيب العرض |
| is_active | BOOLEAN | |
| created_at | DATETIME | |

#### stickers

| العمود | النوع | الوصف |
|--------|-------|-------|
| id | INT PK AUTO | |
| name | VARCHAR(100) | اسم الملصق (شاطر، مبدع...) |
| icon_url | VARCHAR(500) | رابط الأيقونة |
| level_id | INT FK | → sticker_levels |
| description | TEXT | وصف اختياري |
| is_active | BOOLEAN | |
| created_at | DATETIME | |

#### student_stickers

| العمود | النوع | الوصف |
|--------|-------|-------|
| id | INT PK AUTO | |
| student_id | INT FK | |
| sticker_id | INT FK | |
| homework_id | INT FK NULL | المصدر |
| assigned_by | ENUM('ai','teacher','admin') | |
| note | TEXT NULL | ملاحظة AI أو المعلمة |
| created_at | DATETIME | |

### 6.3 جداول أساسية أخرى

#### users

| العمود | النوع | الوصف |
|--------|-------|-------|
| id | INT PK AUTO | |
| username | VARCHAR(50) UNIQUE | |
| password_hash | VARCHAR(255) | |
| role | ENUM('admin','teacher','parent') | |
| name | VARCHAR(100) | |
| phone | VARCHAR(20) NULL | |
| is_active | BOOLEAN | |
| created_at | DATETIME | |

#### students

| العمود | النوع | الوصف |
|--------|-------|-------|
| id | INT PK AUTO | |
| name | VARCHAR(100) | |
| class_name | VARCHAR(50) | الصف/المجموعة |
| birth_date | DATE NULL | |
| avatar_url | VARCHAR(500) NULL | |
| is_active | BOOLEAN | |
| created_at | DATETIME | |

#### photos

| العمود | النوع | الوصف |
|--------|-------|-------|
| id | INT PK AUTO | |
| teacher_id | INT FK | |
| student_id | INT FK | |
| image_url | VARCHAR(500) | |
| caption | VARCHAR(255) NULL | |
| status | ENUM('pending','approved','rejected') | |
| published_at | DATETIME NULL | |
| created_at | DATETIME | |

#### homeworks

| العمود | النوع | الوصف |
|--------|-------|-------|
| id | INT PK AUTO | |
| teacher_id | INT FK | |
| student_id | INT FK | |
| title | VARCHAR(200) | |
| description | TEXT | |
| due_date | DATE NULL | |
| status | ENUM('assigned','submitted','graded') | |
| created_at | DATETIME | |

#### homework_submissions

| العمود | النوع | الوصف |
|--------|-------|-------|
| id | INT PK AUTO | |
| homework_id | INT FK | |
| parent_confirmed | BOOLEAN DEFAULT FALSE | ولي الأمر أكد الحل |
| parent_confirmed_at | DATETIME NULL | |
| teacher_grade | VARCHAR(50) NULL | |
| teacher_note | TEXT NULL | |
| ai_analysis | JSON NULL | نتيجة تحليل AI |
| graded_at | DATETIME NULL | |

#### attendance_records

| العمود | النوع | الوصف |
|--------|-------|-------|
| id | INT PK AUTO | |
| student_id | INT FK | |
| teacher_id | INT FK | |
| type | ENUM('check_in','check_out','absent') | |
| date | DATE | |
| time | TIME | |
| note | VARCHAR(255) NULL | |
| created_at | DATETIME | |

#### meal_records

| العمود | النوع | الوصف |
|--------|-------|-------|
| id | INT PK AUTO | |
| student_id | INT FK | |
| date | DATE | |
| meal_type | ENUM('breakfast','lunch','snack') | |
| teacher_confirmed | BOOLEAN DEFAULT FALSE | |
| parent_confirmed | BOOLEAN DEFAULT FALSE | |
| teacher_confirmed_at | DATETIME NULL | |
| parent_confirmed_at | DATETIME NULL | |

---

## 7. واجهات API (REST)

### 7.1 المصادقة

```
POST   /api/auth/login
POST   /api/auth/refresh
POST   /api/auth/logout
GET    /api/auth/me
```

### 7.2 المديرة — إدارة الحسابات

```
GET/POST        /api/admin/teachers
GET/PUT/DELETE  /api/admin/teachers/:id
GET/POST        /api/admin/parents
GET/PUT/DELETE  /api/admin/parents/:id
GET/POST        /api/admin/students
GET/PUT/DELETE  /api/admin/students/:id
POST            /api/admin/students/:id/link-parent
POST            /api/admin/students/:id/link-teacher
```

### 7.3 المديرة — الملصقات والمستويات

```
GET/POST        /api/admin/sticker-levels
GET/PUT/DELETE  /api/admin/sticker-levels/:id
GET/POST        /api/admin/stickers
GET/PUT/DELETE  /api/admin/stickers/:id
```

### 7.4 المديرة — محتوى

```
GET/POST        /api/admin/banners
GET/PUT/DELETE  /api/admin/banners/:id
GET/POST        /api/admin/calendar-events
GET/PUT/DELETE  /api/admin/calendar-events/:id
GET             /api/admin/photos/pending
PUT             /api/admin/photos/:id/approve
PUT             /api/admin/photos/:id/reject
POST            /api/admin/notifications/send
```

### 7.5 الصور

```
POST   /api/photos              (معلمة — رفع)
GET    /api/photos/student/:id  (ولي أمر — صور طفله المعتمدة)
GET    /api/photos/my-students  (معلمة — صور طلابها)
```

### 7.6 الواجبات

```
POST   /api/homeworks                    (معلمة — إنشاء)
GET    /api/homeworks/student/:id        (ولي أمر)
PUT    /api/homeworks/:id/confirm        (ولي أمر — تأكيد الحل)
PUT    /api/homeworks/:id/grade          (معلمة — تصحيح → يُفعَّل AI)
GET    /api/homeworks/:id/sticker        (الملصق الناتج)
```

### 7.7 ملصقات الطالب

```
GET    /api/students/:id/stickers        (ملصقات الطالب)
PUT    /api/student-stickers/:id         (معلمة — تعديل/إلغاء)
```

### 7.8 الحضور

```
POST   /api/attendance                   (معلمة — تسجيل)
GET    /api/attendance/student/:id       (ولي أمر — سجل الطفل)
GET    /api/attendance/today             (معلمة — حضور اليوم)
```

### 7.9 الوجبات

```
POST   /api/meals/teacher-confirm        (معلمة)
POST   /api/meals/parent-confirm         (ولي أمر)
GET    /api/meals/student/:id            (سجل وجبات الطفل)
```

### 7.10 البث المباشر

```
POST   /api/live/start                   (معلمة — يُنشئ Agora token)
POST   /api/live/end                     (معلمة)
GET    /api/live/active                  (أولياء الأمور — البث النشط)
```

### 7.11 الدردشة (WebSocket + REST)

```
GET    /api/conversations
GET    /api/conversations/:id/messages
POST   /api/conversations/:id/messages
POST   /api/conversations/:id/attachments

WS     /ws/chat                          (رسائل فورية)
```

### 7.12 أخرى

```
GET    /api/banners
GET    /api/calendar-events
GET    /api/notifications
PUT    /api/notifications/:id/read
POST   /api/devices/register             (FCM token)
```

### 7.13 AI (داخلي — Backend)

```
POST   /api/internal/ai/analyze-homework
  Body: { homework_id, submission_id }
  Response: { suggested_sticker_id, analysis, confidence }
```

> يُستدعى تلقائياً بعد تصحيح المعلمة. يختار ملصقاً من `stickers` النشطة.

---

## 8. شاشات التطبيق (Flutter)

> **الهوية البصرية:** الألوان، الخطوط، الزوايا، والشعار — راجع `BRAND_IDENTITY.md`

### 8.1 مشتركة

- شاشة تسجيل الدخول
- شاشة الإشعارات
- شاشة الملف الشخصي

### 8.2 المديرة

| # | الشاشة |
|---|--------|
| 1 | لوحة التحكم (إحصائيات سريعة) |
| 2 | إدارة المعلمات |
| 3 | إدارة أولياء الأمور |
| 4 | إدارة الطلاب + الربط |
| 5 | موافقة الصور (قائمة انتظار) |
| 6 | إدارة البانرات |
| 7 | التقويم السنوي |
| 8 | إرسال إشعارات |
| 9 | **إدارة مستويات الملصقات** |
| 10 | **إدارة الملصقات** |
| 11 | إنشاء/تعديل حساب |

### 8.3 المعلمة

| # | الشاشة |
|---|--------|
| 1 | الرئيسية (طلابي اليوم) |
| 2 | قائمة طلابي |
| 3 | ملف طالب (حضور، واجبات، ملصقات) |
| 4 | رفع صور (ألبوم) |
| 5 | إنشاء واجب |
| 6 | تصحيح واجبات |
| 7 | تسجيل حضور/انصراف |
| 8 | تأكيد وجبات |
| 9 | بدء بث مباشر |
| 10 | الدردشة (أولياء الأمور) |
| 11 | التقويم |

### 8.4 ولي الأمر

| # | الشاشة |
|---|--------|
| 1 | الرئيسية (ملخص الطفل) |
| 2 | تبديل بين الأطفال (إن وُجد) |
| 3 | ألبوم الصور |
| 4 | الواجبات (+ تأكيد الحل) |
| 5 | ملصقات الطفل |
| 6 | الحضور والغياب |
| 7 | الوجبات (+ تأكيد) |
| 8 | مشاهدة البث المباشر |
| 9 | الدردشة (المعلمة) |
| 10 | التقويم والبانرات |

---

## 9. تكاملات خارجية

### 9.1 Agora (بث مباشر)

- المعلمة تطلب token من Backend → `POST /api/live/start`
- Backend ينشئ Agora RTC token
- Flutter يستخدم `agora_rtc_engine`
- ولي الأمر ينضم كـ audience فقط

### 9.2 OpenAI (تحليل الواجبات)

```
Input:  عنوان الواجب + وصف + ملاحظة المعلمة + الدرجة
        + قائمة الملصقات النشطة مع مستوياتها
Output: { sticker_id, reason, confidence }
```

- يُختار الملصق من القائمة المعرّفة من الإدارة فقط
- يُحفظ التحليل في `homework_submissions.ai_analysis`

### 9.3 FCM (Push Notifications)

- تسجيل device token عند تسجيل الدخول
- Backend يرسل عبر Firebase Admin SDK

---

## 10. الأمان

| البند | التفاصيل |
|-------|----------|
| HTTPS | إلزامي (SSL عبر Nginx) |
| كلمات المرور | bcrypt hashing |
| JWT | Access (15 دقيقة) + Refresh (7 أيام) |
| صلاحيات | Middleware يتحقق من Role لكل endpoint |
| الصور | ولي الأمر يرى صور طفله فقط |
| الدردشة | معلمة ↔ ولي أمر طلابها فقط |
| رفع الملفات | تحقق من النوع والحجم (max 10MB) |
| Rate Limiting | على login و API |

---

## 11. خطة التطوير

### المرحلة 1 — الأساس (4 أسابيع)

- [ ] إعداد NestJS + MySQL + Docker على السيرفر
- [ ] Auth + RBAC (3 أدوار)
- [ ] CRUD حسابات (مديرة تنشئ)
- [ ] ربط طالب ↔ معلمة ↔ ولي أمر
- [ ] Flutter: تسجيل دخول + هيكل التطبيق

### المرحلة 2 — المحتوى اليومي (3 أسابيع)

- [ ] ألبوم صور + موافقة المديرة
- [ ] حضور/انصراف يدوي + Push
- [ ] وجبات (تأكيد مزدوج) + Push
- [ ] تقويم + بانرات

### المرحلة 3 — الواجبات والملصقات (3 أسابيع)

- [ ] إدارة مستويات وملصقات (مديرة)
- [ ] واجبات: إنشاء → تأكيد ولي الأمر → تصحيح
- [ ] تكامل AI → اقتراح ملصق
- [ ] عرض ملصقات الطالب

### المرحلة 4 — التواصل (2 أسابيع)

- [ ] دردشة معلمة ↔ ولي أمر (نص + صور)
- [ ] WebSocket للرسائل الفورية
- [ ] Push عند رسالة جديدة

### المرحلة 5 — البث المباشر (1-2 أسبوع)

- [ ] تكامل Agora
- [ ] بدء/إنهاء بث (معلمة)
- [ ] مشاهدة (ولي أمر)

### المرحلة 6 — إطلاق

- [ ] اختبار شامل
- [ ] نشر على السيرفر
- [ ] رفع على App Store + Google Play

**المدة الإجمالية المتوقعة: 13-15 أسبوع**

---

## 12. لوحة تحكم المديرة — داخل التطبيق فقط

**قرار نهائي:** لا توجد لوحة ويب. المديرة تستخدم **نفس تطبيق Flutter** بصلاحيات Admin.

### آلية العمل

```
تسجيل دخول المديرة
    → التطبيق يكتشف role = admin
    → يعرض واجهة المديرة (وليس واجهة المعلمة أو ولي الأمر)
```

### شاشات الإدارة داخل التطبيق

| الشاشة | الوظيفة |
|--------|---------|
| لوحة التحكم | إحصائيات سريعة (طلاب، معلمات، صور بانتظار الموافقة) |
| إدارة الحسابات | إنشاء/تعديل معلمات، أولياء أمور، طلاب |
| موافقة الصور | قائمة انتظار → موافقة / رفض |
| البانرات والتقويم | إعلانات + فعاليات |
| الملصقات والمستويات | CRUD كامل |
| الإشعارات | إرسال Push موجّه |

> تطبيق واحد — 3 واجهات حسب الدور (Admin / Teacher / Parent).

---

## 13. هيكل المشروع

```
kiddy-link/
├── mobile/                  # Flutter App
│   ├── lib/
│   │   ├── core/            # theme, router, constants
│   │   ├── features/
│   │   │   ├── auth/
│   │   │   ├── admin/
│   │   │   ├── teacher/
│   │   │   ├── parent/
│   │   │   ├── photos/
│   │   │   ├── homework/
│   │   │   ├── stickers/
│   │   │   ├── attendance/
│   │   │   ├── meals/
│   │   │   ├── chat/
│   │   │   ├── live/
│   │   │   └── notifications/
│   │   └── shared/          # widgets, models, services
│   └── pubspec.yaml
│
├── backend/                 # NestJS API
│   ├── src/
│   │   ├── auth/
│   │   ├── users/
│   │   ├── students/
│   │   ├── photos/
│   │   ├── homework/
│   │   ├── stickers/
│   │   ├── attendance/
│   │   ├── meals/
│   │   ├── chat/
│   │   ├── live/
│   │   ├── notifications/
│   │   ├── ai/
│   │   └── admin/
│   ├── prisma/              # أو typeorm migrations
│   └── package.json
│
├── docker-compose.yml       # MySQL + Redis + MinIO + API
├── nginx/
└── docs/
    └── DEVELOPER_SPEC.md    # هذا الملف
```

---

## 14. أولويات التنفيذ

```
1. Auth + RBAC + حسابات          ← الأساس
2. ربط طالب/معلمة/ولي أمر        ← العلاقات
3. حضور + وجبات + Push            ← قيمة يومية فورية
4. صور + موافقة                   ← محتوى مرئي
5. ملصقات (إدارة + مستويات)       ← قبل الواجبات
6. واجبات + AI                    ← تمييز المشروع
7. دردشة                          ← تواصل
8. بث Agora                       ← الأخير
9. تقويم + بانرات                 ← يمكن بالتوازي
```

---

> **نهاية مواصفات المبرمج — الإصدار 1.0**
>
> Kiddy Link · يوليو 2026 · سيرفر فلسطين · MySQL · Flutter
