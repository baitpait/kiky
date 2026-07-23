# دليل البدء — Kiddy Link

> **24 يوليو 2026** — اقرأ هذا أولاً عند العودة للمشروع

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
| **GitHub** | https://github.com/nahlahalbostnje-ctrl/kiddy-link |

---

## 2. أين وصلنا؟ (24 يوليو)

✅ **مراحل التطوير 1–6 منتهية**  
✅ **جاهزية محلية قبل VPS** — `COMPLETE-PRE-LAUNCH.bat`  
✅ **بث Agora REAL** — مفاتiح في `backend/.env` (محلي)  
✅ **GitHub متزامن** — commit `9a979bc`  
⏳ **Firebase** — مشروع **Kiddy Link** في Console — **Service Account JSON لم يُضبط**  
📋 **VPS** — لاحقاً

📄 التفاصيل: [CHECKPOINT.md](./CHECKPOINT.md)

---

## 3. أول شيء — Firebase

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

## 4. اختبار البث المباشر (يدوي)

| # | الحساب | الإجراء |
|---|--------|---------|
| 1 | `p5teacher` | بث مباشر → بدء البث → اسمح للكاميرا |
| 2 | `p5parent` (Incognito) | بث مباشر → انضم → شاهد الفيديو |
| 3 | `p5teacher` | إنهاء البث |

```powershell
# تنظيف بثوث عالقة إن لزم
E:\Eman Project\scripts\ensure-test-accounts.ps1
```

📄 [PHASE5_LIVE_COMPLETE.md](./PHASE5_LIVE_COMPLETE.md)

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
| بث | `p5teacher` / `p5parent` | `Test@123456` |

---

## 7. إذا شيء ما اشتغل

| المشكلة | الحل |
|---------|------|
| «You already have an active live stream» | `ensure-test-accounts.ps1` ثم Ctrl+Shift+R |
| API لا يرد | `scripts\restart-api.ps1` |
| Web قديم | `scripts\start-web-fast.ps1` |
| MySQL | XAMPP → Start MySQL |
| منفذ مشغول | `scripts\stop-all.ps1` ثم `go.ps1` |

---

## 8. GitHub

https://github.com/nahlahalbostnje-ctrl/kiddy-link

```powershell
cd "E:\Eman Project"
git pull
```

> **ملاحظة:** `backend/.env` (مفاتiح Agora/FCM) **لا تُرفع** — آمن.

---

## 9. التوثيق

| الملف | المحتوى |
|-------|---------|
| [CHECKPOINT.md](./CHECKPOINT.md) | **نقطة التوقف** |
| [PHASE5_LIVE_COMPLETE.md](./PHASE5_LIVE_COMPLETE.md) | البث المباشر |
| [PRE_LAUNCH_LOCAL.md](./PRE_LAUNCH_LOCAL.md) | جاهزية قبل VPS |
| [FCM_SETUP.md](./FCM_SETUP.md) | Firebase |
| [DEPLOYMENT.md](./DEPLOYMENT.md) | النشر |
