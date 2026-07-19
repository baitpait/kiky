# دليل المرحلة 6 — ما قبل الإطلاق

> **التاريخ:** 16 يوليو 2026

---

## ما تغطيه المرحلة 6

| البند | الحالة محلياً |
|-------|---------------|
| شاشات Admin: بانرات، تقويم، إرسال إشعار | ✅ |
| شاشات Parent: تقويم + بانرات | ✅ |
| إشعارات في التطبيق (🔔) | ✅ |
| توثيق النشر `DEPLOYMENT.md` | ✅ |
| فحص ما قبل الإطلاق | `test-phase6.ps1` |

> **النشر على سيرفر حقيقي** (Docker + Nginx + SSL) يحتاج VPS — لا يُنفَّذ على جهاز التطوير.

---

## فحص شامل محلي

```powershell
# كل الاختبارات (2-5 + واجهة ولي الأمر)
E:\Eman Project\scripts\test-all.ps1

# فحص الإطلاق + تشغيل كل ما سبق
E:\Eman Project\scripts\test-phase6.ps1
```

---

## قائمة قبل الإنتاج

- [ ] غيّر `JWT_ACCESS_SECRET` و `JWT_REFRESH_SECRET`
- [ ] غيّر `ADMIN_PASSWORD`
- [ ] اضبط `AGORA_APP_ID` + `AGORA_APP_CERTIFICATE`
- [ ] اضبط MinIO أو تخزين صور للإنتاج
- [ ] اضبط FCM للإشعارات الحقيقية
- [ ] HTTPS + Nginx (راجع `DEPLOYMENT.md`)
- [ ] بناء Flutter release مع `API_BASE_URL` للسيرفر

---

## مراجع

- [DEPLOYMENT.md](./DEPLOYMENT.md)
- [API-PHASE6.md](./API-PHASE6.md)
- [CHECKPOINT.md](./CHECKPOINT.md)
