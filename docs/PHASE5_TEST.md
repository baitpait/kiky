# دليل اختبار المرحلة 5 — بث Agora

> **التاريخ:** 16 يوليو 2026

---

## اختبار تلقائي (API)

```powershell
E:\Eman Project\scripts\test-phase5.ps1
```

يختبر:
- بدء بث (معلمة) + token publisher
- `GET /live/my-active`
- منع بث ثانٍ نشط (400)
- `GET /live/active` (ولي أمر)
- `POST /live/:id/join` (audience token)
- منع ولي الأمر من بدء بث (403)
- إنهاء البث + إزالته من القائمة النشطة
- منع الانضمام لبث منتهٍ (404)

> بدون `AGORA_APP_ID` في `.env` يعمل وضع **demo** (`token: demo-token`).

---

## حسابات الاختبار

| الدور | المستخدم | كلمة المرور |
|-------|----------|-------------|
| معلمة | `p5teacher` | `Test@123456` |
| ولي أمر | `p5parent` | `Test@123456` |

---

## اختبار يدوي (Web / Mobile)

1. **إعداد Agora** — راجع [AGORA_SETUP.md](./AGORA_SETUP.md) (مطلوب للبث الحقيقي)
2. سجّل دخول كـ `p5teacher` → البث المباشر → ابدأ بثاً → **اسمح للكاميرا/الميك**
3. سجّل دخول كـ `p5parent` → البث المباشر → انضم → يظهر فيديو المعلمة
4. على Web: Chrome/Edge + `localhost:8082`

---

## إعداد Agora (اختياري)

```env
AGORA_APP_ID=your-app-id
AGORA_APP_CERTIFICATE=your-certificate
AGORA_TOKEN_EXPIRE=3600
```

---

## مراجع

- [API-PHASE5.md](./API-PHASE5.md)
- [CHECKPOINT.md](./CHECKPOINT.md)
