# الجاهزية المحلية — قبل النشر على VPS

> **22 يوليو 2026**

---

## تشغيل فحص شامل

```powershell
E:\Eman Project\COMPLETE-PRE-LAUNCH.bat
```

أو:

```powershell
E:\Eman Project\scripts\pre-launch-local.ps1
```

---

## ما يُفحص تلقائياً

| الفحص | السكربت | مطلوب |
|-------|---------|-------|
| MySQL + API + Web | `health-check.ps1` | ✅ |
| التخزين (local/MinIO) | `verify-minio.ps1` | ✅ |
| Agora | `verify-agora.ps1` | ⚠️ مفاتiح |
| FCM | `verify-fcm.ps1` | ⚠️ مفاتiح |
| إشعارات | `test-notifications.ps1` | ✅ |
| FCM API | `test-fcm.ps1` | ✅ |
| مراحل 2–5 | `test-all.ps1` | ✅ |
| إطلاق | `test-phase6.ps1` | ✅ |

---

## حالة «جاهز محلياً»

```
✅ كل مراحل التطوير 1–6
✅ اختبارات API تلقائية
✅ Web على localhost:8082
✅ إشعارات DB + جرس Web
⏳ Agora فيديو حقيقي → مفاتiح (SETUP-AGORA.bat)
⏳ FCM موبايل → مفاتiح (SETUP-FCM.bat)
⏳ شعار رسمي → logo.png
📋 VPS → لاحقاً (DEPLOYMENT.md)
```

---

## خطوات بعد الفحص (بدون VPS)

1. **Agora:** `SETUP-AGORA.bat` — [AGORA_SETUP.md](./AGORA_SETUP.md)
2. **FCM:** `SETUP-FCM.bat` — [FCM_SETUP.md](./FCM_SETUP.md)
3. **شعار:** [LOGO_SETUP.md](./LOGO_SETUP.md)
4. **فحص يدوي:** [START_TOMORROW.md](./START_TOMORROW.md) §4

---

## النشر (لاحقاً)

📄 [DEPLOYMENT.md](./DEPLOYMENT.md)
