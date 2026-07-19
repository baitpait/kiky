# API المرحلة 5 — بث Agora المباشر

> **المعلمة فقط** تبدأ البث — أولياء الأمور مشاهدة (audience)

---

## الإعداد

```env
AGORA_APP_ID=your-app-id
AGORA_APP_CERTIFICATE=your-certificate
AGORA_TOKEN_EXPIRE=3600
```

بدون هذه القيم: API يعيد `demo: true` و `token: "demo-token"`.

---

## Endpoints

### POST `/live/start` — Teacher

```json
{ "title": "حصة الصباح" }
```

**Response:**
```json
{
  "stream": {
    "id": 1,
    "title": "حصة الصباح",
    "channelName": "kiddy-1-abc12345",
    "status": "active",
    "teacherId": 1
  },
  "agora": {
    "appId": "...",
    "channelName": "kiddy-1-abc12345",
    "token": "006...",
    "uid": 2,
    "role": "publisher",
    "demo": false
  }
}
```

→ Push لأولياء أمور طلاب المعلمة

### POST `/live/end` — Teacher

```json
{ "streamId": 1 }
```

### GET `/live/active` — Parent

قائمة البثوث النشطة لمعلمات أطفال ولي الأمر.

### POST `/live/:id/join` — Parent

**Response:** نفس شكل `agora` مع `role: "audience"`

### GET `/live/my-active` — Teacher

البث النشط الحالي إن وُجد.

---

## Agora Flutter

```yaml
# pubspec.yaml
agora_rtc_engine: ^6.3.2
permission_handler: ^11.3.1
```

### Teacher (Broadcaster)
1. `POST /live/start`
2. `RtcEngine` → `clientRoleBroadcaster`
3. `joinChannel` with publisher token
4. `POST /live/end` عند الانتهاء

### Parent (Audience)
1. `GET /live/active`
2. `POST /live/:id/join`
3. `clientRoleAudience` → مشاهدة فقط

---

## Push

| الحدث | المستلم |
|-------|---------|
| بدء بث | أولياء أمور طلاب المعلمة |

---

## سينario اختبار

```
1. ضبط AGORA_APP_ID + CERTIFICATE في .env
2. Teacher: POST /live/start
3. Parent: GET /live/active
4. Parent: POST /live/1/join
5. Teacher: POST /live/end
```

---

## ملاحظات Android/iOS

بعد `flutter create .` أضف صلاحيات الكاميرا والميكروفون في:
- `android/app/src/main/AndroidManifest.xml`
- `ios/Runner/Info.plist`

راجع [Agora Flutter Quickstart](https://docs.agora.io/en/video-calling/get-started/get-started-sdk?platform=flutter)
