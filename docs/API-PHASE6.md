# API — المرحلة 6 (تقويم + بانرات + إشعارات + نشر)

> Base URL: `http://localhost:3000/api`  
> Auth: `Authorization: Bearer <access_token>`

---

## 1. البانرات (Admin)

### GET `/admin/banners`
قائمة كل البانرات (نشطة وغير نشطة).

### POST `/admin/banners`
```json
{
  "title": "مرحباً بالعام الدراسي",
  "imageUrl": "https://example.com/banner.jpg",
  "linkUrl": "https://example.com",
  "targetRole": "all",
  "sortOrder": 1
}
```
`targetRole`: `all` | `admin` | `teacher` | `parent`

### PUT `/admin/banners/:id`
تحديث بانر.

### DELETE `/admin/banners/:id`
إلغاء تفعيل (soft delete).

---

## 2. التقويم (Admin)

### GET `/admin/calendar-events`

### POST `/admin/calendar-events`
```json
{
  "title": "رحلة مدرسية",
  "description": "رحلة إلى حديقة الحيوان",
  "eventDate": "2026-09-15T08:00:00.000Z",
  "eventType": "trip"
}
```
`eventType`: `holiday` | `trip` | `meeting` | `activity` | `other`

### PUT `/admin/calendar-events/:id`

### DELETE `/admin/calendar-events/:id`

---

## 3. إشعارات Push (Admin)

### POST `/admin/notifications/send`
```json
{
  "target": "all_parents",
  "title": "تذكير",
  "body": "غداً إجازة رسمية"
}
```
`target`: `all` | `all_teachers` | `all_parents` | `all_users`

---

## 4. عرض المحتوى (كل الأدوار)

### GET `/banners`
بانرات نشطة مفلترة حسب دور المستخدم.

### GET `/calendar-events`
أحداث التقويم النشطة.

---

## 5. Flutter — شاشات المرحلة 6

| الشاشة | الدور | المسار |
|--------|-------|--------|
| AdminBannersScreen | admin | إدارة البانرات |
| AdminCalendarScreen | admin | إدارة التقويم |
| AdminNotifyScreen | admin | إرسال إشعار |
| ParentCalendarScreen | parent | عرض التقويم |

---

## 6. النشر

راجع [DEPLOYMENT.md](./DEPLOYMENT.md) للتفاصيل الكاملة.

```bash
docker compose up -d --build
```

---

## أمثلة curl

```bash
# تسجيل دخول
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"Admin@123"}'

# إنشاء بانر
curl -X POST http://localhost:3000/api/admin/banners \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title":"مرحباً","imageUrl":"https://x.com/b.jpg","targetRole":"all","sortOrder":1}'

# التقويم
curl http://localhost:3000/api/calendar-events \
  -H "Authorization: Bearer TOKEN"
```
