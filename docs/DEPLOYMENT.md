# نشر Kiddy Link — المرحلة 6

> **نشر فعلي على baitpait (أغسطس 2026):** انظر  
> **[PRODUCTION_BAITPAIT.md](./PRODUCTION_BAITPAIT.md)** — Webuzo + PM2 + MariaDB (بدون Docker).

## متطلبات السيرفر (فلسطين)

| المكوّن | الحد الأدنى |
|---------|-------------|
| CPU | 2 cores |
| RAM | 4 GB |
| Disk | 40 GB SSD |
| OS | Ubuntu 22.04 LTS |
| Docker | 24+ |
| Domain + SSL | Nginx + Let's Encrypt |

---

## 1. إعداد السيرفر

```bash
# Ubuntu
sudo apt update && sudo apt install -y docker.io docker-compose-plugin nginx certbot

git clone <repo-url> /opt/kiddy-link
cd /opt/kiddy-link
cp .env.example .env
nano .env   # غيّر JWT secrets, passwords, AGORA, FCM, OPENAI
```

---

## 2. تشغيل الإنتاج

```bash
docker compose up -d --build
docker compose logs -f api
```

التحقق:
```bash
curl http://localhost:3000/api/docs
```

---

## 3. Nginx + SSL

```nginx
server {
    listen 443 ssl;
    server_name api.your-domain.ps;

    ssl_certificate /etc/letsencrypt/live/api.your-domain.ps/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.your-domain.ps/privkey.pem;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

WebSocket للدردشة: نفس الـ proxy مع `Upgrade` headers.

---

## 4. MinIO (إنتاج)

- غيّر `MINIO_ROOT_PASSWORD` الافتراضي
- أنشئ bucket `kiddy-link` عبر Console `:9001`
- اضبط `MINIO_PUBLIC_URL` لرابط عام للصور

---

## 5. Flutter — بناء التطبيق

```bash
cd mobile
flutter create . --project-name kiddy_link
flutter pub get

# Android
flutter build apk --release \
  --dart-define=API_BASE_URL=https://api.your-domain.ps/api \
  --dart-define=WS_BASE_URL=wss://api.your-domain.ps

# iOS
flutter build ios --release \
  --dart-define=API_BASE_URL=https://api.your-domain.ps/api
```

---

## 6. متغيرات الإنتاج الإلزامية

```env
JWT_ACCESS_SECRET=<random-64-chars>
JWT_REFRESH_SECRET=<random-64-chars>
ADMIN_PASSWORD=<strong-password>
AGORA_APP_ID=...
AGORA_APP_CERTIFICATE=...
FCM_PROJECT_ID=...
FCM_CLIENT_EMAIL=...
FCM_PRIVATE_KEY=...
OPENAI_API_KEY=...
```

---

## 7. النسخ الاحتياطي

```bash
# MySQL
docker exec kiddy-mysql mysqldump -u kiddy -pkiddypass kiddy_link > backup.sql

# MinIO — نسخ volume minio_data
```

---

## 8. مراقبة

```bash
docker compose ps
docker compose logs api --tail 100
```

---

## 9. App Store / Google Play

1. أنشئ حساب مطوّر
2. أضف سياسة الخصوصية (عربي)
3. لقطات شاشة من 3 الأدوار
4. `flutter build appbundle` للـ Play Store
5. Xcode Archive للـ App Store

---

## 10. قائمة تحقق ما قبل الإطلاق

- [ ] غيّرت كل secrets الافتراضية
- [ ] HTTPS يعمل
- [ ] seed أنشأ admin
- [ ] اختبرت login لـ 3 أدوار
- [ ] اختبرت رفع صورة + موافقة
- [ ] اختبرت واجب + AI
- [ ] اختبرت دردشة WebSocket
- [ ] اختبرت بث Agora (إن وُجد)
- [ ] FCM يعمل على جهاز حقيقي
