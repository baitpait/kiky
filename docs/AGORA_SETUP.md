# إعداد Agora — بث مباشر حقيقي

> **21 يوليو 2026**

---

## لماذا يظهر «وضع تجريبي»؟

إذا `AGORA_APP_ID` أو `AGORA_APP_CERTIFICATE` فارغين في `backend/.env`، الـ API يُرجع `demo: true` ولا يعمل فيديو حقيقي.

---

## الخطوات (مرة واحدة)

### 1. إنشاء مشروع Agora

1. سجّل في [console.agora.io](https://console.agora.io)
2. **Projects → Create** → نوع: **Secure mode: APP ID + Token**
3. انسخ:
   - **App ID**
   - **Primary Certificate** (من Project → Config)

### 2. ضبط `.env`

**الطريقة السريعة:** انقر مرتين على `SETUP-AGORA.bat` في جذر المشروع.

**أو يدوياً** — افتح `E:\Eman Project\backend\.env`:

```env
AGORA_APP_ID=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
AGORA_APP_CERTIFICATE=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
AGORA_TOKEN_EXPIRE=3600
```

### 3. تحقق

```powershell
E:\Eman Project\scripts\verify-agora.ps1
```

يجب أن يظهر `REAL mode` و token طويل (ليس `demo-token`).

### 4. أعد تشغيل API

```powershell
E:\Eman Project\scripts\restart-api.ps1
```

### 5. أعد بناء Web (بعد تحديث Agora)

```powershell
E:\Eman Project\scripts\start-web-fast.ps1
```

---

## اختبار يدوي

| الخطوة | الحساب | الإجراء |
|--------|--------|---------|
| 1 | `p5teacher` / `Test@123456` | بث مباشر → بدء → **اسمح للكاميرا/الميك** |
| 2 | `p5parent` / `Test@123456` | بث مباشر → انضم → يظهر فيديو المعلمة |

> استخدم **localhost:8082** — WebRTC يعمل على localhost بدون HTTPS.

---

## اختبار API

```powershell
E:\Eman Project\scripts\test-phase5.ps1
```

مع Agora مُعدّ: `agora.demo` = `false` و token طويل (ليس `demo-token`).

---

## Web — متطلبات

- سكربت `iris-web-rtc` مُضاف في `mobile/web/index.html`
- متصفح Chrome/Edge حديث
- إذن الكاميرا والميكروفون للموقع

---

## Android / iOS

- Android: `CAMERA` + `RECORD_AUDIO` في `AndroidManifest.xml` ✅
- iOS: أضف في `Info.plist` إن نشرت على iPhone:
  - `NSCameraUsageDescription`
  - `NSMicrophoneUsageDescription`

---

## استكشاف الأخطاء

| المشكلة | الحل |
|---------|------|
| «وضع تجريبي» | أضف مفاتيح Agora في `.env` + restart API |
| شاشة سوداء | اسمح للمتصفح بالكاميرا؛ تأكد المعلمة بدأت البث أولاً |
| `Agora init failed` | تحقق App ID/Certificate؛ Project في Secure mode |
| ولي الأمر لا يرى فيديو | المعلمة يجب أن تبقى في شاشة البث أثناء المشاهدة |

---

## مراجع

- [API-PHASE5.md](./API-PHASE5.md)
- [PHASE5_TEST.md](./PHASE5_TEST.md)
- [NOTIFICATIONS_AND_CHAT_UPDATE.md](./NOTIFICATIONS_AND_CHAT_UPDATE.md)
