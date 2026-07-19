# API المرحلة 3 — ملصقات + واجبات + AI

> Base URL: `http://localhost:3000/api`

---

## تدفق الواجب الكامل

```
1. POST /homeworks          → معلمة تنشئ واجب (status: assigned)
2. PUT  /homeworks/:id/confirm → ولي أمر يؤكد "تم الحل" (submitted)
3. PUT  /homeworks/:id/grade   → معلمة تصحّح → AI يختار ملصق (graded)
4. GET  /students/:id/stickers → عرض ملصقات الطفل
```

---

## Admin — Sticker Levels

```
GET/POST        /api/admin/sticker-levels
PUT/DELETE      /api/admin/sticker-levels/:id
```

**POST:**
```json
{
  "name": "مبتدئ",
  "color": "#6BC04B",
  "sortOrder": 1
}
```

---

## Admin — Stickers

```
GET/POST        /api/admin/stickers
PUT/DELETE      /api/admin/stickers/:id
```

**POST:**
```json
{
  "name": "شاطر",
  "iconUrl": "/stickers/shatir.png",
  "levelId": 1,
  "description": "التزام وأداء جيد"
}
```

---

## Homework

### POST `/homeworks` — Teacher

```json
{
  "studentId": 1,
  "title": "تمرين الأرقام",
  "description": "اكتب الأرقام من 1 إلى 10",
  "dueDate": "2026-07-20"
}
```

→ Push لولي الأمر

### GET `/homeworks/my-students` — Teacher

### GET `/homeworks/student/:id` — Parent

### PUT `/homeworks/:id/confirm` — Parent

→ Push للمعلمة

### PUT `/homeworks/:id/grade` — Teacher

```json
{
  "teacherGrade": "ممتاز",
  "teacherNote": "أحسنت!"
}
```

**Response:**
```json
{
  "homeworkId": 1,
  "grade": "ممتاز",
  "ai": {
    "sticker_id": 3,
    "reason": "إبداع في الحل",
    "confidence": 0.85
  }
}
```

→ AI يختار من الملصقات النشطة فقط  
→ Push لولي الأمر

### GET `/homeworks/:id/sticker`

الملصق المرتبط بالواجب (ولي أمر / معلمة / مديرة).

### GET `/stickers/active` — Teacher

قائمة الملصقات النشطة لتعديل ملصقات الطلاب يدوياً.

---

## Student Stickers

### GET `/students/:id/stickers`

ولي أمر أو معلمة (لطلابهم فقط).

### PUT `/student-stickers/:id` — Teacher

```json
{
  "stickerId": 2,
  "note": "تعديل المعلمة"
}
```

### DELETE `/student-stickers/:id` — Teacher

إلغاء الملصق.

---

## AI (Internal)

### POST `/internal/ai/analyze-homework` — Admin

```json
{
  "homework_id": 1,
  "submission_id": 1
}
```

يُستدعى تلقائياً بعد `grade` — هذا endpoint للاختبار اليدوي.

---

## OpenAI Configuration

| المتغير | الوصف |
|---------|-------|
| `OPENAI_API_KEY` | مفتاح API |
| `OPENAI_MODEL` | افتراضي: `gpt-4o-mini` |

**بدون API key:** يستخدم النظام picker قاعدي حسب الدرجة (ممتاز→متقدم، جيد→متوسط).

---

## سينario اختبار

```
1. Admin: GET /admin/sticker-levels (seed موجود)
2. Teacher: POST /homeworks
3. Parent: GET /homeworks/student/1 → PUT confirm
4. Teacher: PUT /homeworks/1/grade { "teacherGrade": "ممتاز" }
5. Parent: GET /students/1/stickers
6. GET /homeworks/1/sticker
```
