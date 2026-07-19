# دليل اختبار المرحلة 4 — الدردشة

> **التاريخ:** 16 يوليو 2026  
> **المتطلبات:** API على `http://localhost:3000` + MySQL (XAMPP)

---

## اختبار تلقائي

```powershell
E:\Eman Project\scripts\test-phase4.ps1
```

يختبر:
- إنشاء حسابات `p4teacher` / `p4parent` + طالب Phase4 Student
- فتح محادثة (ولي أمر)
- إرسال رسائل REST (ولي + معلمة)
- جلب الرسائل + تعليم مقروء
- رفع صورة في الدردشة (curl + PNG)
- منع المديرة من الدردشة (403)
- WebSocket: join + send + استقبال `new_message`

---

## حسابات الاختبار

| الدور | المستخدم | كلمة المرور |
|-------|----------|-------------|
| معلمة | `p4teacher` | `Test@123456` |
| ولي أمر | `p4parent` | `Test@123456` |
| مديرة | `admin` | `Admin@123` |

---

## اختبار يدوي (Web)

1. شغّل API + Web:
   ```powershell
   E:\Eman Project\START.bat
   ```
2. سجّل دخول كـ `p4parent` → المحادثات → افتح محادثة الطالب
3. أرسل رسالة نصية
4. سجّل دخول كـ `p4teacher` (نافذة خاصة) → المحادثات → تأكد من وصول الرسالة
5. أرسل صورة من المعرض — يجب أن تظهر بدون خطأ MIME
6. تأكد أن الرسالة لا تتكرر مرتين عند إرسال صورة

---

## WebSocket يدوي

```
ws://localhost:3000/ws/chat?token=ACCESS_TOKEN
```

```json
{ "event": "join", "data": { "conversationId": 1 } }
{ "event": "send", "data": { "conversationId": 1, "body": "مرحباً" } }
```

---

## مراجع

- [API-PHASE4.md](./API-PHASE4.md)
- [CHECKPOINT.md](./CHECKPOINT.md)
