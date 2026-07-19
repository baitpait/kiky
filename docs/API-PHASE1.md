# API المرحلة 1 — Kiddy Link

> Base URL: `http://localhost:3000/api`  
> Swagger: `http://localhost:3000/api/docs`  
> Auth: `Authorization: Bearer <accessToken>` (ما عدا endpoints `@Public`)

---

## Auth

### POST `/auth/login` — Public

**Request:**
```json
{
  "username": "admin",
  "password": "Admin@123"
}
```

**Response 200:**
```json
{
  "accessToken": "eyJhbG...",
  "refreshToken": "eyJhbG...",
  "user": {
    "id": 1,
    "username": "admin",
    "role": "admin",
    "name": "مديرة الروضة"
  }
}
```

**Errors:** `401` — Invalid credentials

---

### POST `/auth/refresh` — Public

**Request:**
```json
{
  "refreshToken": "eyJhbG..."
}
```

**Response 200:** نفس شكل login (tokens جديدة)

**Errors:** `401` — Invalid/expired refresh token

---

### POST `/auth/logout` — Public

**Request:**
```json
{
  "refreshToken": "eyJhbG..."
}
```

**Response 200:**
```json
{
  "message": "Logged out successfully"
}
```

---

### GET `/auth/me` — Authenticated

**Response 200:**
```json
{
  "id": 1,
  "username": "admin",
  "role": "admin",
  "name": "مديرة الروضة",
  "phone": null,
  "isActive": true,
  "createdAt": "2026-07-13T...",
  "teacher": null,
  "parent": null
}
```

---

## Admin — Teachers

> **Role required:** `admin`

### GET `/admin/teachers`

قائمة المعلمات النشطات مع user + students linked.

### GET `/admin/teachers/:id`

معلمة واحدة بالتفصيل.

### POST `/admin/teachers`

**Request:**
```json
{
  "username": "teacher1",
  "password": "Teacher@123",
  "name": "المعلمة سارة",
  "phone": "0599123456"
}
```

**Response 201:** Teacher object مع user.

**Errors:** `409` — Username already exists

### PUT `/admin/teachers/:id`

**Request:** (كل الحقول اختيارية)
```json
{
  "name": "سارة المحدّثة",
  "password": "NewPass@123"
}
```

### DELETE `/admin/teachers/:id`

Soft delete — `is_active = false` للمعلمة والـ user.

**Response:**
```json
{ "message": "Teacher deactivated" }
```

---

## Admin — Parents

> **Role required:** `admin`

### GET `/admin/parents`
### GET `/admin/parents/:id`
### POST `/admin/parents`
### PUT `/admin/parents/:id`
### DELETE `/admin/parents/:id`

**POST Request:**
```json
{
  "username": "parent1",
  "password": "Parent@123",
  "name": "أحمد محمد",
  "phone": "0599987654"
}
```

نفس نمط Teachers.

---

## Admin — Students

> **Role required:** `admin`

### GET `/admin/students`

قائمة الطلاب مع parentLinks و teacherLinks.

### GET `/admin/students/:id`

### POST `/admin/students`

**Request:**
```json
{
  "name": "محمد أحمد",
  "className": "الصف الأول",
  "birthDate": "2020-05-15",
  "avatarUrl": null
}
```

### PUT `/admin/students/:id`

### DELETE `/admin/students/:id`

Soft delete — `is_active = false`.

---

## Admin — Linking

### POST `/admin/students/:id/link-parent`

**Request:**
```json
{
  "parentId": 1
}
```

**Response 201:** ParentStudent link object.

**Errors:** `409` — Parent already linked

### POST `/admin/students/:id/link-teacher`

**Request:**
```json
{
  "teacherId": 1
}
```

**Response 201:** TeacherStudent link object.

**Errors:** `409` — Teacher already linked

---

## رموز HTTP الشائعة

| Code | المعنى |
|------|--------|
| 200 | نجاح |
| 201 | تم الإنشاء |
| 401 | غير مصرّح (token/ credentials) |
| 403 | Forbidden (role غير كافٍ) |
| 404 | Not found |
| 409 | Conflict (username مكرر / link موجود) |
| 422 | Validation error (DTO) |

---

## سينario اختبار كامل

```
1. POST /auth/login (admin)
2. POST /admin/teachers
3. POST /admin/parents
4. POST /admin/students
5. POST /admin/students/1/link-teacher { teacherId: 1 }
6. POST /admin/students/1/link-parent { parentId: 1 }
7. POST /auth/login (teacher1) → role: teacher
8. POST /auth/login (parent1) → role: parent
```

---

## APIs قادمة (غير مُنفّذة)

راجع [DEVELOPER_SPEC.md §7](../DEVELOPER_SPEC.md) للقائمة الكاملة:
- Photos, Homework, Stickers, Attendance, Meals
- Live (Agora), Chat (WebSocket), Notifications, AI
