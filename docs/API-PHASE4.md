# API المرحلة 4 — الدردشة WebSocket

> REST: `http://localhost:3000/api`  
> WebSocket: `ws://localhost:3000/ws/chat?token=ACCESS_TOKEN`

---

## القواعد

- **معلمة ↔ ولي أمر فقط** (لا معلمة ↔ إدارة)
- كل محادثة مرتبطة **بطالب** + معلمته + ولي أمره
- رفع صور في الدردشة فقط (مجلد MinIO: `chat/`)
- Push عند كل رسالة جديدة

---

## REST — Conversations

### GET `/conversations`

قائمة محادثات المستخدم (معلمة أو ولي أمر).

### POST `/conversations` — Parent

```json
{ "studentId": 1 }
```

ينشئ محادثة مع معلمة الطفل (أو يعيد الموجودة).

### GET `/conversations/:id/messages`

آخر 200 رسالة.

### POST `/conversations/:id/messages`

```json
{ "body": "مرحباً" }
```

### POST `/conversations/:id/attachments` (multipart)

| Field | Type |
|-------|------|
| file | image (required) |
| body | text (optional) |

### PUT `/conversations/:id/read`

تعليم رسائل الطرف الآخر كمقروءة.

---

## WebSocket — `/ws/chat`

### الاتصال

```
ws://HOST:3000/ws/chat?token=JWT_ACCESS_TOKEN
```

الأدوار المسموحة: `teacher`, `parent` فقط.

### الأحداث (Client → Server)

**انضمام لمحادثة:**
```json
{ "event": "join", "data": { "conversationId": 1 } }
```

**إرسال رسالة:**
```json
{ "event": "send", "data": { "conversationId": 1, "body": "نص الرسالة" } }
```

**Ping:**
```json
{ "event": "ping" }
```

### الأحداث (Server → Client)

```json
{
  "event": "new_message",
  "data": {
    "id": 5,
    "conversationId": 1,
    "senderRole": "teacher",
    "senderId": 2,
    "body": "مرحباً",
    "attachments": [],
    "createdAt": "..."
  }
}
```

---

## Push Notifications

| الحدث | المستلم |
|-------|---------|
| رسالة جديدة | الطرف الآخر في المحادثة |

---

## Flutter

```powershell
flutter run --dart-define=WS_BASE_URL=ws://192.168.1.X:3000
```

الافتراضي للـ emulator: `ws://10.0.2.2:3000`

---

## سينario اختبار

```
1. Admin: ربط معلمة + ولي + طالب
2. Parent: POST /conversations { studentId: 1 }
3. Parent: POST /conversations/1/messages { body: "مرحبا" }
4. Teacher: GET /conversations → يرى المحادثة
5. WebSocket: اتصال بـ token → join → send
6. Parent: POST /conversations/1/attachments (صورة)
```
