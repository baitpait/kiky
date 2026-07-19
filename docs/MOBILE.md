# Mobile — Flutter

> المسار: `mobile/`  
> Entry: `lib/main.dart`  
> اللغة: **عربي RTL فقط**  
> الهوية: [BRAND_IMPLEMENTATION.md](./BRAND_IMPLEMENTATION.md)

---

## هيكل المجلدات

```
mobile/lib/
├── main.dart                    # Splash + MaterialApp.router
├── core/
│   ├── theme/
│   │   ├── app_colors.dart      # BRAND_IDENTITY §2
│   │   ├── app_theme.dart       # buildAppTheme + forRole
│   │   ├── brand_gradients.dart
│   │   └── app_spacing.dart
│   ├── constants/api_constants.dart
│   ├── api/api_client.dart
│   ├── router/app_router.dart
│   └── storage/token_storage.dart  # web + mobile
├── features/
│   ├── auth/                    # login + AuthProvider
│   ├── admin/                   # لوحة المديرة + CRUD
│   ├── teacher/                 # واجهة المعلمة
│   ├── parent/                  # واجهة ولي الأمر
│   ├── homework/                # Phase 3
│   ├── stickers/                # Phase 3
│   ├── chat/                    # Phase 4
│   ├── live/                    # Phase 5
│   └── notifications/           # Phase 2
└── shared/
    ├── widgets/
    │   ├── brand_logo.dart
    │   ├── splash_screen.dart
    │   └── role_badge.dart
    ├── models/
    └── services/
```

---

## Dependencies (pubspec.yaml)

| Package | الاستخدام |
|---------|-----------|
| google_fonts | خط Cairo |
| http | API calls |
| flutter_secure_storage | tokens (mobile) |
| provider | state management |
| go_router | navigation |
| flutter_localizations | RTL |
| image_picker | رفع صور |
| web_socket_channel | درdشة |
| agora_rtc_engine | بث مباشر |

---

## Theme — BRAND_IDENTITY v1.0

| اللون | Hex | الاستخدام |
|-------|-----|-----------|
| Kiddy Blue | `#4A90D9` | AppBar افتراضي، أزرار primary |
| Link Green | `#6BC04B` | secondary، AppBar معلمة |
| Warm Orange | `#F5A623` | AppBar ولي أمر |
| Coral Red | `#E8634A` | errors |
| Cloud White | `#F7FAFC` | scaffold |
| Soft Sky | `#E8F4FC` | خلفيات Splash |

```dart
AppTheme.light              // ثيم عام
AppTheme.forRole('admin')   // AppBar حسب الدور
```

- بطاقات: `BorderRadius.circular(16)`
- أزرار: `BorderRadius.circular(12)`
- RTL: `Directionality(textDirection: TextDirection.rtl)`

---

## Auth Flow

```
SplashScreen (أثناء init)
  → LoginScreen
  → AuthProvider.login()
  → POST /auth/login
  → token storage (secure / localStorage على Web)
  → go_router redirect:
       admin   → /admin
       teacher → /teacher
       parent  → /parent
```

---

## Routing (go_router)

| Path | Screen | Role |
|------|--------|------|
| `/login` | LoginScreen | public |
| `/admin` | AdminHomeScreen | admin |
| `/teacher` | TeacherHomeScreen | teacher |
| `/parent` | ParentHomeScreen | parent |

---

## API Client (Web)

```dart
// api_constants.dart — يستخدم hostname المتصفح
static String get baseUrl => 'http://${apiHost}:3000/api';
```

> استخدم **localhost** في المتصفح — لا `127.0.0.1` (CORS للصور).

---

## شاشات العلامة

| الشاشة | الملف | المواصفة |
|--------|-------|----------|
| Splash | `shared/widgets/splash_screen.dart` | §5.1 |
| Login | `features/auth/screens/login_screen.dart` | §5.2 |
| Admin Home | `features/admin/screens/admin_home_screen.dart` | AppBar أزرق |
| Teacher Home | `features/teacher/screens/teacher_home_screen.dart` | AppBar أخضر |
| Parent Home | `features/parent/screens/parent_home_screen.dart` | AppBar برتقالي |

---

## Assets

```
mobile/assets/brand/logo.png
```

---

## التشغيل

### Web (الطريقة الموصى بها)

```powershell
E:\Eman Project\scripts\start-web-fast.ps1
```

→ http://localhost:8082/login

### يدوي

```powershell
cd mobile
flutter pub get
flutter build web --release
# ثم serve من build/web على :8082
```

### Android / iOS

```powershell
cd mobile
flutter pub get
flutter run
```

---

## المراحل المكتملة في Mobile

| Phase | الشاشات |
|-------|---------|
| 1 | Login + 3 home screens + Admin CRUD |
| 2 | صور، حضور، وجبات، بانرات، تقويم |
| 3 | واجبات، ملصقات |
| 4 | درdشة WebSocket |
| 5 | بث Agora (Web stub) |
| 6 | إشعارات، بانرات admin، تقويم |
| Brand | Splash, Login, Role theme |

---

*آخر تحديث: 19 يوليو 2026*
