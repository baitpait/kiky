# API المرحلة 2 — Kiddy Link

> Base URL: `http://localhost:3000/api`  
> Swagger: `http://localhost:3000/api/docs`

---

## Students (جديد)

### GET `/students/my-class` — Teacher

طلاب المعلمة المرتبطين بها.

### GET `/students/my-children` — Parent

أطفال ولي الأمر المرتبطين به.

---

## Photos

### POST `/photos` — Teacher (multipart)

| Field | Type | Required |
|-------|------|----------|
| image | file | ✅ |
| studentId | int | ✅ |
| caption | string | — |

**Response:** Photo with `status: pending`

### GET `/photos/my-students` — Teacher

كل صور طلاب المعلمة (كل الحالات).

### GET `/photos/student/:id` — Parent

صور الطفل **المعتمدة فقط** (`approved`).

### GET `/admin/photos/pending` — Admin

قائمة انتظار الموافقة.

### PUT `/admin/photos/:id/approve` — Admin

يوافق + يرسل Push لأولياء الأمور.

### PUT `/admin/photos/:id/reject` — Admin

```json
{ "note": "سبب اختياري" }
```

---

## Attendance

### POST `/attendance` — Teacher

```json
{
  "studentId": 1,
  "type": "check_in",
  "date": "2026-07-13",
  "time": "08:30:00",
  "note": "اختياري"
}
```

`type`: `check_in` | `check_out` | `absent`  
→ Push تلقائي لأولياء الأمور

### GET `/attendance/today` — Teacher

حضور اليوم لطلاب المعلمة.

### GET `/attendance/student/:id` — Parent

سجل حضور الطفل (آخر 60 سجل).

---

## Meals

### POST `/meals/teacher-confirm` — Teacher

```json
{
  "studentId": 1,
  "date": "2026-07-13",
  "mealType": "lunch"
}
```

`mealType`: `breakfast` | `lunch` | `snack`  
→ Push لأولياء الأمور

### POST `/meals/parent-confirm` — Parent

نفس الـ body — تأكيد وجبة في المنزل  
→ Push للمعلمات

### GET `/meals/student/:id` — Parent

سجل وجبات الطفل.

### GET `/meals/today` — Teacher

وجبات اليوم لطلاب المعلمة.

---

## Banners

### GET `/banners` — All roles

بانرات نشطة مفلترة حسب دور المستخدم.

### Admin CRUD

```
GET/POST        /api/admin/banners
PUT/DELETE      /api/admin/banners/:id
```

**POST body:**
```json
{
  "title": "إعلان",
  "body": "نص الإعلان",
  "target": "parents",
  "imageUrl": "http://...",
  "startsAt": "2026-07-01",
  "endsAt": "2026-08-01"
}
```

`target`: `all` | `teachers` | `parents`

---

## Calendar Events

### GET `/calendar-events` — All roles

فعاليات وتقويم نشط.

### Admin CRUD

```
GET/POST        /api/admin/calendar-events
PUT/DELETE      /api/admin/calendar-events/:id
```

**POST body:**
```json
{
  "title": "عطلة عيد",
  "description": "الروضة مغلقة",
  "eventType": "holiday",
  "startDate": "2026-07-20",
  "endDate": "2026-07-25"
}
```

`eventType`: `holiday` | `vacation` | `event`

---

## Notifications & Push

### POST `/devices/register`

```json
{
  "token": "fcm-device-token",
  "platform": "android"
}
```

### GET `/notifications`

إشعارات المستخدم الحالي.

### PUT `/notifications/:id/read`

### POST `/admin/notifications/send` — Admin

```json
{
  "title": "إعلان مهم",
  "body": "نص الإشعار",
  "target": "parents"
}
```

### Push تلقائي (بدون endpoint)

| الحدث | المستلم |
|-------|---------|
| تسجيل حضور/انصراف/غياب | ولي الأمر |
| تأكيد وجبة (معلمة) | ولي الأمر |
| تأكيد وجبة (ولي أمر) | المعلمة |
| موافقة على صورة | ولي الأمر |

> **FCM:** يعمل عند ضبط `FCM_PROJECT_ID`, `FCM_CLIENT_EMAIL`, `FCM_PRIVATE_KEY`.  
> بدونها: الإشعارات تُحفظ في DB وتُسجَّل في logs فقط.

---

## MinIO

الصور تُرفع إلى bucket `kiddy-link/photos/`.  
URL عام: `MINIO_PUBLIC_URL` (افتراضي: `http://localhost:9000`)

---

## سينario اختبار المرحلة 2

```
1. Admin: إنشاء معلمة + ولي + طالب + ربطهم (Swagger)
2. Teacher login → POST /photos (رفع صورة)
3. Admin login → GET /admin/photos/pending → PUT approve
4. Parent login → GET /photos/student/:id (يرى الصورة)
5. Teacher → POST /attendance (check_in)
6. Parent → GET /attendance/student/:id
7. Teacher → POST /meals/teacher-confirm
8. Parent → POST /meals/parent-confirm
9. Admin → POST /admin/banners + GET /banners
10. Admin → POST /admin/calendar-events + GET /calendar-events
```
