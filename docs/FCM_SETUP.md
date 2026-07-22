# إعداد FCM — Push Notifications

> **22 يوليو 2026**

---

## الوضع الحالي

| المنصة | الإشعارات | الحالة |
|--------|-----------|--------|
| **Web** | جرس + polling من API | ✅ يعمل |
| **Backend** | حفظ في DB + FCM عند وجود مفاتيح | ✅ |
| **Android/iOS** | FCM push | ⏳ يحتاج Firebase |

---

## 1. Backend (مرة واحدة)

### أ) Firebase Console

1. [console.firebase.google.com](https://console.firebase.google.com)
2. أنشئ مشروع (أو استخدم موجود)
3. **Project Settings → Service accounts → Generate new private key**
4. من ملف JSON انسخ:
   - `project_id` → `FCM_PROJECT_ID`
   - `client_email` → `FCM_CLIENT_EMAIL`
   - `private_key` → `FCM_PRIVATE_KEY`

### ب) حفظ في `.env`

**الطريقة السريعة:**
```
E:\Eman Project\SETUP-FCM.bat
```

**أو يدوياً** في `backend/.env`:
```env
FCM_PROJECT_ID=your-project-id
FCM_CLIENT_EMAIL=firebase-adminsdk-xxxxx@your-project.iam.gserviceaccount.com
FCM_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
```

### ج) تحقق

```powershell
E:\Eman Project\scripts\verify-fcm.ps1
E:\Eman Project\scripts\test-fcm.ps1
```

---

## 2. Mobile (عند بناء APK/IPA)

```bash
cd mobile
dart pub global activate flutterfire_cli
flutterfire configure
```

ثم أضف في `pubspec.yaml`:
```yaml
firebase_core: ^3.8.0
firebase_messaging: ^15.1.5
```

فعّل `PushRegistrationService.registerIfAvailable()` في:
`mobile/lib/core/push/push_registration_service.dart`

- Android: `google-services.json` في `android/app/`
- iOS: `GoogleService-Info.plist` في `ios/Runner/`

---

## 3. API

```
POST /api/devices/register
Authorization: Bearer <token>
Body: { "token": "fcm-device-token", "platform": "android" | "ios" }
```

---

## استكشاف الأخطاء

| المشكلة | الحل |
|---------|------|
| `[Push stub]` في logs | أضف FCM keys + restart API |
| Web لا يستلم push | طبيعي — Web يستخدم الجرس |
| Device register 401 | سجّل دخول أولاً |

---

## مراجع

- [ENVIRONMENT.md](./ENVIRONMENT.md)
- [NOTIFICATIONS_AND_CHAT_UPDATE.md](./NOTIFICATIONS_AND_CHAT_UPDATE.md)
