# دليل البدء — Kiddy Link

> **23 يوليو 2026** — اقرأ هذا أولاً عند العودة للمشروع

---

## 1. تشغيل كل شيء

```powershell
E:\Eman Project\START.bat
```

**المتطلب:** XAMPP → MySQL شغّال (3306)

| الخدمة | URL |
|--------|-----|
| **Web** | http://localhost:8082/login |
| **API** | http://localhost:3000/api |

---

## 2. أين وصلنا؟ (23 يوليو)

✅ **مراحل التطوير 1–6 منتهية**  
✅ **جاهزية محلية قبل VPS** — `COMPLETE-PRE-LAUNCH.bat`  
⏳ **Firebase** — مشروع **Kiddy Link** في Console — **Service Account JSON لم يُضبط**  
⏳ **Agora** — مفاتiح فارغة  
📋 **VPS** — لاحقاً

📄 التفاصيل: [CHECKPOINT.md](./CHECKPOINT.md)

---

## 3. أول شيء بكرة — Firebase

1. [Firebase Console](https://console.firebase.google.com) → مشروع **Kiddy Link**
2. ⚙️ **Project settings** → **Service accounts**
3. **Generate new private key** → حمّل JSON
4. شغّل:

```powershell
E:\Eman Project\SETUP-FCM-JSON.bat
```

5. تحقق:

```powershell
E:\Eman Project\scripts\verify-fcm.ps1
```

📄 [FCM_SETUP.md](./FCM_SETUP.md)

---

## 4. ثاني شيء — Agora (اختياري)

```powershell
E:\Eman Project\SETUP-AGORA.bat
```

📄 [AGORA_SETUP.md](./AGORA_SETUP.md)

---

## 5. فحص شامل

```powershell
E:\Eman Project\COMPLETE-PRE-LAUNCH.bat
```

---

## 6. حسابات سريعة

| الدور | مستخدم | كلمة مرور |
|-------|--------|-----------|
| مديرة | `admin` | `Admin@123` |
| معلمة | `p2teacher` | `Test@123456` |
| ولي أمر | `p2parent` | `Test@123456` |

---

## 7. إذا شيء ما اشتغل

| المشكلة | الحل |
|---------|------|
| API لا يرد | `scripts\restart-api.ps1` |
| Web 404 | `scripts\start-web-fast.ps1` |
| MySQL | XAMPP → Start MySQL |
| منفذ مشغول | `scripts\stop-all.ps1` ثم `go.ps1` |

---

## 8. GitHub

https://github.com/nahlahalbostnje-ctrl/kiddy-link

```powershell
cd "E:\Eman Project"
git pull
```

---

## 9. التوثيق

| الملف | المحتوى |
|-------|---------|
| [CHECKPOINT.md](./CHECKPOINT.md) | **نقطة التوقف** |
| [PRE_LAUNCH_LOCAL.md](./PRE_LAUNCH_LOCAL.md) | جاهزية قبل VPS |
| [FCM_SETUP.md](./FCM_SETUP.md) | Firebase |
| [DEPLOYMENT.md](./DEPLOYMENT.md) | النشر |
