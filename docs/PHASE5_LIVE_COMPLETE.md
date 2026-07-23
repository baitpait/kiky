# المرحلة 5 — البث المباشر (Agora) — دليل كامل

> **23 يوليو 2026**

---

## الهدف

| الدور | الإجراء |
|-------|---------|
| **المعلمة** | تبدأ البث → الكاميرا + الميكروفون |
| **ولي الأمر** | يرى قائمة البثوث → ينضم → **فيديو المعلمة** |

---

## 1. إعداد Agora (مرة واحدة) — **إلزامي للبث الحقيقي**

### أ) إنشاء مشروع

1. [console.agora.io](https://console.agora.io) → سجّل (مجاني)
2. **Project Management → Create**
3. **Authentication:** **Secure mode: APP ID + Token**
4. انسخ:
   - **App ID**
   - **Primary Certificate** (Config → Primary Certificate)

### ب) حفظ في المشروع

```
E:\Eman Project\SETUP-AGORA.bat
```

### ج) تحقق

```powershell
E:\Eman Project\scripts\verify-agora.ps1
```

يجب: `REAL mode` + token طويل (ليس `demo-token`)

### د) أعد بناء Web

```powershell
E:\Eman Project\scripts\start-web-fast.ps1
```

---

## 2. حسابات الاختبار

| الدور | مستخدم | كلمة مرور |
|-------|--------|-----------|
| معلمة | `p5teacher` | `Test@123456` |
| ولي أمر | `p5parent` | `Test@123456` |

```powershell
E:\Eman Project\scripts\ensure-test-accounts.ps1
```

---

## 3. اختبار يدوي — خطوة بخطوة

### المتصفح: Chrome أو Edge — http://localhost:8082/login

| # | الحساب | الإجراء | المتوقع |
|---|--------|---------|---------|
| 1 | `p5teacher` | بث مباشر → **بدء البث** | طلب إذن كاميرا/ميك → معاينة فيديو |
| 2 | `p5parent` | بث مباشر → **انضم** | فيديو المعلمة يظهر |
| 3 | `p5teacher` | **إنهاء البث** | — |
| 4 | `p5parent` | تحديث | «لا يوجد بث» |

> **مهم:** المعلمة تبدأ **قبل** أن ينضم ولي الأمر.  
> استخدم **localhost** — مو `127.0.0.1`.

---

## 4. اختبار API تلقائي

```powershell
E:\Eman Project\scripts\test-phase5.ps1
```

---

## 5. ميزات مُنفّذة

| الميزة | الحالة |
|--------|--------|
| Backend tokens (publisher + audience) | ✅ |
| Web Agora (iris-web-rtc) | ✅ |
| Android/iOS permissions | ✅ |
| استئناف بث المعلمة بعد refresh | ✅ |
| استئناف تلقائي عند ضغط «بدء البث» مرة ثانية | ✅ |
| تحديث تلقائي قائمة البث لولي الأمر | ✅ |
| إشعار push عند بدء البث | ✅ |
| Agora REAL mode (مفاتiح في `.env`) | ✅ محلي |

---

## 6. استكشاف الأخطاء

| المشكلة | الحل |
|---------|------|
| «You already have an active live stream» | `ensure-test-accounts.ps1` + Ctrl+Shift+R — أو اضغط «بدء البث» (يستأنف تلقائياً بعد التحديث) |
| «وضع تجريبي» | `SETUP-AGORA.bat` + restart API |
| شاشة سوداء (معلمة) | اسمح للكاميرا في المتصفح |
| ولي الأمر لا يرى فيديو | المعلمة في شاشة البث + Agora REAL |
| `p5teacher` لا يعمل | `ensure-test-accounts.ps1` |
| Agora init failed | App ID/Certificate صحيح + Secure mode |

---

## 7. الملفات

| الملف | الوظيفة |
|-------|---------|
| `backend/src/live/live.service.ts` | tokens + بث |
| `mobile/lib/features/live/` | شاشات + Agora helper |
| `mobile/web/index.html` | iris-web-rtc script |
| `scripts/test-phase5.ps1` | اختبار API |

---

## 8. بدون Agora

- API يعمل في **demo mode**
- لا فيديو حقيقي — بطاقة «وضع تجريبي» فقط

**للإطلاق:** Agora keys **إلزامية**.
