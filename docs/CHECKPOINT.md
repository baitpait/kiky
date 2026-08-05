# نقطة التوقف — Kiddy Link
> **التاريخ:** 4 أغسطس 2026 — **آخر جلسة**  
> **المسار المحلي (Mac):** `.../kiddy-link`  
> **الإنتاج:** https://kiddylink.baitpait.com/api  
> **GitHub:** https://github.com/nahlahalbostnje-ctrl/kiddy-link

---

## 🟢 ابدأ من هنا

📄 **[PRODUCTION_BAITPAIT.md](./PRODUCTION_BAITPAIT.md)** — تشغيل الإنتاج + أوامر الصيانة

| الخدمة | URL |
|--------|-----|
| **API إنتاج** | https://kiddylink.baitpait.com/api |
| **APK** | `~/Desktop/kiddy-link-release.apk` |
| **دخول مديرة** | `admin` / `100200300` |
| **GitHub** | https://github.com/nahlahalbostnje-ctrl/kiddy-link |

---

## آخر تحديث (4 أغسطس 2026)

| الميزة | الحالة | التوثيق |
|--------|--------|---------|
| **نشر Backend على baitpait** | ✅ PM2 :3010 | [PRODUCTION_BAITPAIT.md](./PRODUCTION_BAITPAIT.md) |
| **دومين API + SSL** | ✅ | `kiddylink.baitpait.com/api` |
| **Agora REAL (إنتاج + محلي)** | ✅ | مفاتيح في `.env` — لا تُرفع Git |
| **APK مربوط بالإنتاج** | ✅ | سطح المكتب |
| **Bottom navigation shells** | ✅ | commit `cce31f2` |
| **Firebase FCM** | ⏳ | [FCM_SETUP.md](./FCM_SETUP.md) |
| **WebSocket عبر Apache** | ⏳ | يحتاج `proxy_wstunnel` |

---

## أين وصلنا؟

| المرحلة | المحتوى | API | Web | اختبار |
|---------|---------|-----|-----|--------|
| **1** | Auth + CRUD + ربط | ✅ | ✅ | — |
| **2** | صور، حضور، وجبات، بانرات | ✅ | ✅ | `test-phase2.ps1` ✅ |
| **3** | واجبات، ملصقات، AI | ✅ | ✅ | `test-phase3.ps1` ✅ |
| **4** | درdشة WebSocket (**كل الأدوار**) | ✅ | ✅ | `test-phase4.ps1` ✅ |
| **5** | بث Agora (REAL + استئناف) | ✅ | ✅ | `test-phase5.ps1` ✅ |
| **6** | فحص إطلاق محلي | ✅ | ✅ | `test-phase6.ps1` ✅ |
| **Pre-launch** | جاهزية قبل VPS | ✅ | ✅ | `pre-launch-local.ps1` ✅ |
| **Brand** | الهوية البصرية v1.0 | — | ✅ | يدوي |

**الخلاصة:** التطوير **1–6 منتهي** + **Backend منشور على الإنتاج** + **APK جاهز**. المتبقي: **FCM** + تحسين **WebSocket** + (اختياري) واجهة Web على الدومين.

---

## الخطوة الجاية

| # | المهمة | كيف |
|---|--------|-----|
| 1 | **اختبار APK على جهاز حقيقي** | تثبيت `kiddy-link-release.apk` → دخول `admin` / `100200300` |
| 2 | **Firebase Service Account** | [FCM_SETUP.md](./FCM_SETUP.md) + `google-services.json` |
| 3 | **WebSocket للدردشة** | تفعيل `proxy_wstunnel` — [PRODUCTION_BAITPAIT.md](./PRODUCTION_BAITPAIT.md) |
| 4 | **(اختياري) رفع Flutter Web** | إلى `/home/baitpait/public_html/kiddylink` |

---

## حسابات سريعة

| الدور | المستخدم | كلمة المرور |
|-------|----------|-------------|
| مديرة | `admin` | `Admin@123` |
| معلمة | `p2teacher` | `Test@123456` |
| ولي أمر | `p2parent` | `Test@123456` |
| **بث مباشر** | `p5teacher` / `p5parent` | `Test@123456` |

> كل الحسابات: [ACCOUNTS.md](./ACCOUNTS.md)

---

## اختبارات تلقائية (آخر تشغيل 24 يوليو)

```powershell
E:\Eman Project\scripts\pre-launch-local.ps1   # شامل
E:\Eman Project\scripts\test-all.ps1           # مراحل 2–5 + إشعارات + FCM
E:\Eman Project\scripts\test-phase5.ps1        # بث + استئناف
```

| السكربت | النتيجة |
|---------|---------|
| `pre-launch-local.ps1` | ✅ PRE-LAUNCH LOCAL: COMPLETE |
| `test-phase2.ps1` … `test-phase5.ps1` | ✅ ALL PASSED |
| `test-notifications.ps1` | ✅ ALL PASSED |
| `test-fcm.ps1` | ✅ ALL PASSED |
| `test-parent-ui.ps1` | ✅ ALL OK |
| `test-phase6.ps1` | ✅ READY FOR LAUNCH PREP |
| `flutter test` | ✅ |

---

## سكربتات مهمة

| السكربت / BAT | الوظيفة |
|---------------|---------|
| `START.bat` | تشغيل كامل |
| `COMPLETE-PRE-LAUNCH.bat` | **فحص شامل قبل VPS** |
| `SETUP-FCM-JSON.bat` | FCM من ملف JSON |
| `SETUP-AGORA.bat` | Agora |
| `scripts/ensure-test-accounts.ps1` | تفعيل حسابات + إنهاء بثوث عالقة |
| `scripts/go.ps1` | stop + start + health |
| `scripts/verify-fcm.ps1` | فحص FCM |
| `scripts/verify-agora.ps1` | فحص Agora |
| `scripts/start-web-fast.ps1` | بناء Web سريع |

---

## حالة المفاتiح (.env)

| المتغير | الحالة |
|---------|--------|
| `AGORA_APP_ID` / `AGORA_APP_CERTIFICATE` | ✅ **مضبوط محلياً** — REAL mode — **غير مرفوع Git** |
| `FCM_PROJECT_ID` / `FCM_*` | ⏳ فارغ — مشروع Firebase **Kiddy Link** جاهز في Console |
| `OPENAI_API_KEY` | ⏳ فارغ — AI fallback |
| التخزين | ✅ `MINIO_ENABLED=false` → `backend/uploads/` |

---

## Commits الأخيرة (GitHub)

| Commit | المحتوى |
|--------|---------|
| `9a979bc` | استئناف البث بدل رفض duplicate start |
| `565caa8` | إصلاح PushRegistrationService |
| `04b62a5` | بث Agora REAL + استئناف + مشاهدة ولي الأمر |
| `46e40c3` | Pre-launch + FCM/Agora setup tooling |

---

## فهرس التوثيق

| الملف | المحتوى |
|-------|---------|
| [START_TOMORROW.md](./START_TOMORROW.md) | **ابدأ من هنا** |
| [CHECKPOINT.md](./CHECKPOINT.md) | هذا الملف |
| [PHASE5_LIVE_COMPLETE.md](./PHASE5_LIVE_COMPLETE.md) | **دليل البث الكامل** |
| [PRE_LAUNCH_LOCAL.md](./PRE_LAUNCH_LOCAL.md) | جاهزية قبل VPS |
| [FCM_SETUP.md](./FCM_SETUP.md) | Firebase / FCM |
| [AGORA_SETUP.md](./AGORA_SETUP.md) | Agora بث |
| [DEPLOYMENT.md](./DEPLOYMENT.md) | النشر VPS |
| [GITHUB_SETUP.md](./GITHUB_SETUP.md) | GitHub |
| [../CHANGELOG.md](../CHANGELOG.md) | سجل التغييرات |

---

*آخر تحديث: 24 يوليو 2026 — 1:15 ص*
