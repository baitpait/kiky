# إعداد MinIO — تخزين الصور

> **22 يوليو 2026**

---

## الوضع الحالي (تطوير محلي)

| الوضع | متى | الحالة |
|-------|-----|--------|
| **Local uploads** | `MINIO_ENABLED=false` | ✅ افتراضي على XAMPP |
| **MinIO** | `MINIO_ENABLED=true` + Docker | اختياري |

الملفات تُحفظ في `backend/uploads/` وتُخدم عبر `/uploads/...`

---

## تفعيل MinIO محلياً (اختياري)

### 1. Docker

```powershell
cd "E:\Eman Project"
docker compose up -d minio
```

Console: http://localhost:9001 (minioadmin / minioadmin123)

### 2. `.env`

```env
MINIO_ENABLED=true
MINIO_ENDPOINT=localhost
MINIO_PORT=9000
MINIO_ACCESS_KEY=minioadmin
MINIO_SECRET_KEY=minioadmin123
MINIO_BUCKET=kiddy-link
MINIO_PUBLIC_URL=http://localhost:9000
```

### 3. تحقق

```powershell
E:\Eman Project\scripts\verify-minio.ps1
```

---

## الإنتاج (VPS)

1. غيّر `MINIO_ROOT_PASSWORD` في docker-compose
2. أنشئ bucket `kiddy-link`
3. اضبط `MINIO_PUBLIC_URL` لرابط عام (عبر Nginx)
4. راجع [DEPLOYMENT.md](./DEPLOYMENT.md)

---

## استكشاف الأخطاء

| المشكلة | الحل |
|---------|------|
| MinIO unavailable | `MINIO_ENABLED=false` أو شغّل Docker |
| صور لا تظهر | تأكد `MINIO_PUBLIC_URL` صحيح + CORS |
