# نشر الإنتاج — kiddylink.baitpait.com

> **التاريخ:** 4 أغسطس 2026  
> **الطريقة:** Webuzo (Apache) + Node/PM2 + MariaDB + Redis — **بدون Docker**  
> **الحالة:** Backend يعمل علناً + APK مبني مربوط بالسيرفر

---

## روابط سريعة

| الخدمة | الرابط |
|--------|--------|
| **API** | https://kiddylink.baitpait.com/api |
| **دخول API** | `POST /api/auth/login` |
| **WebSocket (مخطط)** | `wss://kiddylink.baitpait.com` |
| **مجلد الموقع (واجهة)** | `/home/baitpait/public_html/kiddylink` |
| **كود Backend** | `/home/baitpait/kiddy-link/backend` |

---

## بيانات السيرفر

| البند | القيمة |
|--------|--------|
| المضيف / IP | `104.207.65.64` |
| Hostname | `server1.newcarpal.com` |
| SSH مستخدم | `root` |
| الدومين | `kiddylink.baitpait.com` |
| لوحة | Webuzo (Apache) |
| نظام | Ubuntu 24.04 |

### اتصال SSH (من جهاز التطوير)

المفتاح المحلي (لا يُرفع على Git):

```bash
# ~/.ssh/config
Host kiddylink-server
  HostName 104.207.65.64
  User root
  IdentityFile ~/.ssh/baitpait_ed25519
  IdentitiesOnly yes

ssh kiddylink-server
```

---

## حساب المديرة (إنتاج)

| | |
|---|---|
| المستخدم | `admin` |
| كلمة المرور | `100200300` |

تغيير كلمة المرور لاحقاً:

```bash
ssh kiddylink-server
# عدّل ADMIN_PASSWORD في /home/baitpait/kiddy-link/backend/.env
cd /home/baitpait/kiddy-link/backend
sudo -u baitpait npx ts-node prisma/seed.ts   # يزامن كلمة المرور
```

---

## مكوّنات التشغيل

| المكوّن | التفاصيل |
|---------|----------|
| **API** | NestJS عبر PM2 باسم `kiddy-api` على `127.0.0.1:3010` |
| **قاعدة البيانات** | MariaDB — قاعدة `kiddy_link` — مستخدم `kiddy`@`localhost` |
| **Redis** | `127.0.0.1:6379` (محلي فقط) |
| **التخزين** | محلي (`MINIO_ENABLED=false`) — مجلد `uploads/` |
| **Agora** | مضبوط في `.env` على السيرفر (وضع REAL) |
| **FCM** | ⏳ غير مضبوط بعد |
| **Docker** | غير مستخدم على هذا السيرفر |

> كلمة مرور قاعدة البيانات و JWT موجودة فقط في  
> `/home/baitpait/kiddy-link/backend/.env` — **لا تُرفع على Git**.

---

## Apache Reverse Proxy

ملف مخصص (لا يُمسَح عند إعادة توليد Webuzo بسهولة):

`/var/webuzo-data/apache2/custom/domains/kiddylink.baitpait.com.conf`

| المسار العام | الهدف الداخلي |
|--------------|----------------|
| `/api` | `http://127.0.0.1:3010/api` |
| `/uploads` | `http://127.0.0.1:3010/uploads` |
| `/ws` | `ws://127.0.0.1:3010/ws` |

ملاحظة: موديول `proxy_wstunnel` غير مفعّل حالياً — دردشة WebSocket قد تحتاج تفعيله لاحقاً.

بعد تعديل الملف:

```bash
/usr/local/apps/apache2/bin/httpd -t
kill -USR1 $(pgrep -f '/usr/local/apps/apache2' | head -1)
```

---

## أوامر التشغيل والصيانة

```bash
ssh kiddylink-server

# حالة API
sudo -u baitpait bash -lc 'export HOME=/home/baitpait; pm2 list'
sudo -u baitpait bash -lc 'export HOME=/home/baitpait; pm2 logs kiddy-api --lines 50'

# إعادة تشغيل
sudo -u baitpait bash -lc 'export HOME=/home/baitpait; pm2 restart kiddy-api'

# بعد رفع كود جديد
cd /home/baitpait/kiddy-link/backend
sudo -u baitpait npm ci
sudo -u baitpait npm run build
sudo -u baitpait npx prisma migrate deploy
sudo -u baitpait bash -lc 'export HOME=/home/baitpait; pm2 restart kiddy-api'
```

فحص سريع للـ API:

```bash
curl -s -X POST https://kiddylink.baitpait.com/api/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"username":"admin","password":"100200300"}'
# المتوقع: HTTP 201 + accessToken
```

---

## بناء APK (مرتبط بالإنتاج)

```bash
cd mobile
flutter build apk --release \
  --dart-define=API_BASE_URL=https://kiddylink.baitpait.com/api \
  --dart-define=WS_BASE_URL=wss://kiddylink.baitpait.com
```

| البند | القيمة |
|--------|--------|
| مخرجات البناء | `mobile/build/app/outputs/flutter-apk/app-release.apk` |
| نسخة سطح المكتب (4 أغسطس 2026) | `~/Desktop/kiddy-link-release.apk` |
| التوقيع | debug (للتثبيت المباشر — ليس Play Store) |
| `google-services.json` | غير موجود بعد (FCM) |

إصلاح Gradle المستخدم للبناء: AGP `8.9.1` + Kotlin `2.1.0` في `mobile/android/settings.gradle.kts`.

---

## خطوات النشر المنفّذة (ملخص)

1. فحص السيرفر (Node 20، PM2، MariaDB، بدون Docker)  
2. إنشاء قاعدة `kiddy_link` + مستخدم `kiddy`  
3. تثبيت Redis  
4. رفع Backend إلى `/home/baitpait/kiddy-link/backend`  
5. إنشاء `.env` + `npm ci`  
6. `build` + `migrate` + `seed` + تشغيل PM2 على المنفذ **3010**  
7. ربط `https://kiddylink.baitpait.com/api` عبر Apache  
8. بناء APK مربوط بالإنتاج  

---

## المتبقي

| المهمة | الأولوية |
|--------|----------|
| تفعيل `proxy_wstunnel` للدردشة | متوسطة |
| Firebase FCM + `google-services.json` | متوسطة |
| رفع واجهة Flutter Web إلى `public_html/kiddylink` | اختيارية |
| MinIO أو تخزين صور إنتاجي | لاحقاً |
| توقيع APK بمفتاح release لـ Play Store | قبل المتجر |
| تدوير مفتاح SSH (انكشف في محادثة) | أمان |

---

## مراجع

- دليل النشر العام (Docker): [DEPLOYMENT.md](./DEPLOYMENT.md)  
- Agora: [AGORA_SETUP.md](./AGORA_SETUP.md)  
- FCM: [FCM_SETUP.md](./FCM_SETUP.md)  
- نقطة التوقف: [CHECKPOINT.md](./CHECKPOINT.md)  
