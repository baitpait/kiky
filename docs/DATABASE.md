# قاعدة البيانات — MySQL + Prisma

> Schema: `backend/prisma/schema.prisma`  
> Migration: `backend/prisma/migrations/20250713120000_init/`  
> ORM: Prisma 6.x

---

## مخطط العلاقات (مبسّط)

```
users ──┬── teacher (1:1)
        ├── parent (1:1)
        └── user_sessions (1:N)

teacher ── teacher_student ── student ── parent_student ── parent

student ──┬── photos
          ├── homeworks ── homework_submissions
          ├── student_stickers ── stickers ── sticker_levels
          ├── attendance_records
          └── meal_records

teacher + parent + student ── conversations ── messages ── message_attachments
```

---

## الجداول

### المستخدمون

#### `users`

| العمود | النوع | ملاحظات |
|--------|-------|---------|
| id | INT PK | AUTO |
| username | VARCHAR(50) | UNIQUE |
| password_hash | VARCHAR(255) | bcrypt |
| role | ENUM | admin, teacher, parent |
| name | VARCHAR(100) | |
| phone | VARCHAR(20) | nullable |
| is_active | BOOLEAN | soft delete |
| created_at | DATETIME | |

#### `user_sessions`

| العمود | النوع | ملاحظات |
|--------|-------|---------|
| id | INT PK | |
| user_id | INT FK | → users |
| refresh_token_hash | VARCHAR(255) | SHA-256 |
| expires_at | DATETIME | |
| is_revoked | BOOLEAN | logout |
| created_at | DATETIME | |

---

### الروضة

#### `students`

| العمود | النوع |
|--------|-------|
| id | INT PK |
| name | VARCHAR(100) |
| class_name | VARCHAR(50) |
| birth_date | DATE nullable |
| avatar_url | VARCHAR(500) nullable |
| is_active | BOOLEAN |
| created_at | DATETIME |

#### `teachers`

| العمود | النوع |
|--------|-------|
| id | INT PK |
| user_id | INT FK UNIQUE → users |
| is_active | BOOLEAN |
| created_at | DATETIME |

#### `parents`

| العمود | النوع |
|--------|-------|
| id | INT PK |
| user_id | INT FK UNIQUE → users |
| is_active | BOOLEAN |
| created_at | DATETIME |

#### `parent_student` (M:N)

| العمود | النوع |
|--------|-------|
| id | INT PK |
| parent_id | INT FK |
| student_id | INT FK |
| created_at | DATETIME |

UNIQUE: `(parent_id, student_id)`

#### `teacher_student` (M:N)

| العمود | النوع |
|--------|-------|
| id | INT PK |
| teacher_id | INT FK |
| student_id | INT FK |
| created_at | DATETIME |

UNIQUE: `(teacher_id, student_id)`

---

### المحتوى

#### `photos`

| العمود | النوع |
|--------|-------|
| id | INT PK |
| teacher_id | INT FK |
| student_id | INT FK |
| image_url | VARCHAR(500) |
| caption | VARCHAR(255) nullable |
| status | ENUM: pending, approved, rejected |
| published_at | DATETIME nullable |
| created_at | DATETIME |

#### `photo_approvals`

| العمود | النوع |
|--------|-------|
| id | INT PK |
| photo_id | INT FK |
| admin_id | INT FK → users |
| action | VARCHAR(20) |
| note | VARCHAR(255) nullable |
| created_at | DATETIME |

#### `banners`

| العمود | النوع |
|--------|-------|
| id | INT PK |
| title | VARCHAR(200) |
| body | TEXT |
| image_url | VARCHAR(500) nullable |
| target | ENUM: all, teachers, parents |
| is_active | BOOLEAN |
| starts_at / ends_at | DATETIME nullable |
| created_at | DATETIME |

#### `calendar_events`

| العمود | النوع |
|--------|-------|
| id | INT PK |
| title | VARCHAR(200) |
| description | TEXT nullable |
| event_type | ENUM: holiday, vacation, event |
| start_date | DATE |
| end_date | DATE nullable |
| is_active | BOOLEAN |
| created_at | DATETIME |

---

### الواجبات والملصقات

#### `sticker_levels`

| العمود | النوع |
|--------|-------|
| id | INT PK |
| name | VARCHAR(50) |
| color | VARCHAR(7) hex |
| sort_order | INT |
| is_active | BOOLEAN |
| created_at | DATETIME |

**Seed:** مبتدئ (#6BC04B), متوسط (#F5A623), متقدم (#4A90D9)

#### `stickers`

| العمود | النوع |
|--------|-------|
| id | INT PK |
| name | VARCHAR(100) |
| icon_url | VARCHAR(500) |
| level_id | INT FK |
| description | TEXT nullable |
| is_active | BOOLEAN |
| created_at | DATETIME |

**Seed:** شاطر, متعاون, مبدع

#### `homeworks`

| status | ENUM: assigned, submitted, graded |

#### `homework_submissions`

| ai_analysis | JSON nullable — نتيجة OpenAI |

#### `student_stickers`

| assigned_by | ENUM: ai, teacher, admin |

---

### الحضور والوجبات

#### `attendance_records`

| type | ENUM: check_in, check_out, absent |

#### `meal_records`

| meal_type | ENUM: breakfast, lunch, snack |
| teacher_confirmed / parent_confirmed | BOOLEAN |

UNIQUE: `(student_id, date, meal_type)`

---

### البث والدردشة والإشعارات

| الجدول | المرحلة | ملاحظات |
|--------|---------|---------|
| `live_streams` | 5 | Agora channel |
| `conversations` | 4 | teacher + parent + student |
| `messages` | 4 | sender_role |
| `message_attachments` | 4 | MinIO URLs |
| `notifications` | 2 | Push |
| `device_tokens` | 2 | FCM tokens |

---

## Seed

```powershell
cd backend
npm run prisma:seed
```

ينشئ:
1. Admin user (إن لم يكن موجوداً)
2. 3 مستويات ملصقات
3. 3 ملصقات نموذجية

---

## Prisma Studio

```powershell
cd backend
npx prisma studio
```

يفتح واجهة web على http://localhost:5555
