# دليل التثبيت على Windows — Kiddy Link

> آخر تحديث: 14 يوليو 2026  
> **مكان المشروع:** `E:\Eman Project\`

---

## الحالة الحالية على جهازك

| الأداة | الحالة | المسار |
|--------|--------|--------|
| المشروع | ✅ محفوظ | `E:\Eman Project\` |
| Node.js v24 | ✅ | عالمي |
| Flutter 3.44.6 | ✅ | `C:\src\flutter` |
| XAMPP MySQL | ✅ | `C:\xampp` — منفذ 3306 |
| NestJS API | ✅ | منفذ 3000 |
| Flutter Web | ✅ | http://localhost:8082/login |
| Docker Desktop | ⚠️ | يحتاج WSL2 + مدير |
| Android SDK | ❌ | للموبايل لاحقاً |

---

## تشغيل سريع (الطريقة الحالية — بدون Docker)

```powershell
powershell -File "E:\Eman Project\scripts\start-local.ps1"
```

أو يدوياً:
```powershell
# 1. شغّل MySQL من XAMPP Control Panel

# 2. API
cd "E:\Eman Project\backend"
npm run start:dev

# 3. التطبيق
cd "E:\Eman Project\mobile"
E:\Eman Project\scripts\start-web-fast.ps1
```

| الرابط | الاستخدام |
|--------|-----------|
| http://localhost:8082/login | التطبيق |
| http://localhost:3000/api/docs | Swagger |
| admin / Admin@123 | تسجيل الدخول |

---

## 1. Flutter (تم ✅)

Flutter مثبت في:
```
C:\src\flutter
```

وأُضيف إلى PATH. **أعد فتح Terminal** أو Cursor لتفعيل PATH.

تحقق:
```powershell
flutter --version
flutter doctor
```

---

## 2. Docker Desktop

### إذا لم يعمل التثبيت التلقائي

1. افتح **Docker Desktop** من قائمة Start
2. وافق على شروط الاستخدام
3. انتظر حتى يظهر "Docker is running" (أيقونة الحوت خضراء)
4. قد يطلب **إعادة تشغيل** الجهاز أول مرة

### تحقق:
```powershell
docker --version
docker compose version
```

### تشغيل المشروع:
```powershell
cd "e:\Eman Project"
docker compose up -d --build
```

### فتح Swagger:
```
http://localhost:3000/api/docs
```
**Login:** `admin` / `Admin@123`

---

## 3. تشغيل Flutter

### خيار أ — Chrome (سريع للتجربة)
```powershell
cd "e:\Eman Project\mobile"
flutter run -d chrome
```

### خيار ب — Android (للموبايل الحقيقي)

1. ثبّت **Android Studio**: https://developer.android.com/studio
2. من Android Studio → SDK Manager → ثبّت Android SDK
3. وصّل هاتفك بـ USB مع تفعيل **USB Debugging**
4. ```powershell
   flutter doctor
   flutter run
   ```

### خيار ج — Windows Desktop
```powershell
# يحتاج Visual Studio مع "Desktop development with C++"
flutter run -d windows
```

---

## 4. حل المشاكل الشائعة

### Docker: "Cannot connect to Docker daemon"
→ شغّل Docker Desktop وانتظر حتى يصبح جاهزاً

### MySQL: Authentication failed
→ استخدم Docker (يُنشئ قاعدة البيانات تلقائياً):
```powershell
docker compose up -d --build
```

### Flutter: Android SDK not found
→ ثبّت Android Studio أو استخدم `flutter run -d chrome`

### API لا يستجيب
→ تأكد أن Docker يعمل: `docker compose ps`

---

## 5. أوامر سريعة

```powershell
# تحقق من المشروع
powershell -File "e:\Eman Project\scripts\verify.ps1"

# إيقاف Docker
docker compose down

# إعادة بناء API فقط
docker compose up -d --build api

# سجلات API
docker compose logs -f api
```

---

## 6. الخطوة التالية

1. ✅ شغّل **Docker Desktop**
2. ✅ نفّذ `docker compose up -d --build`
3. ✅ افتح http://localhost:3000/api/docs
4. ✅ نفّذ `flutter run -d chrome` في مجلد mobile
