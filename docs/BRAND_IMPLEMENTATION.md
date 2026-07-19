# تطبيق الهوية البصرية — Kiddy Link v1.0

> **التاريخ:** 19 يوليو 2026  
> **المرجع:** [BRAND_IDENTITY.md](../BRAND_IDENTITY.md)  
> **الحالة:** ✅ مُطبّق في Flutter Web

---

## ملخص

تم تنفيذ دليل الهوية البصرية v1.0 في تطبيق Flutter — ألوان، خطوط، Splash، Login، وتمييز AppBar حسب الدور.

| البند | القيمة |
|-------|--------|
| اسم العلامة | Kiddy Link |
| الشعار النصي | Connecting Home & Kindergarten (داخل صورة الشعار فقط) |
| ملف الشعار | `mobile/assets/brand/logo.png` |
| اللغة | عربي RTL — الشعار الإنجليزي في Splash/Login فقط |
| خط التطبيق | Cairo (Google Fonts) |

---

## ملفات الثيم

```
mobile/lib/core/theme/
├── app_colors.dart       # §2 — كل الألوان + roleAccent()
├── app_theme.dart        # §7 — buildAppTheme() + forRole()
├── brand_gradients.dart  # §2.5 — splash + logoGradient
└── app_spacing.dart      # §4.3 — xs … xxl
```

### الألوان الأساسية

| الاسم | Hex | Flutter |
|-------|-----|---------|
| Kiddy Blue | `#4A90D9` | `AppColors.kiddyBlue` |
| Link Green | `#6BC04B` | `AppColors.linkGreen` |
| Warm Orange | `#F5A623` | `AppColors.warmOrange` |
| Coral Red | `#E8634A` | `AppColors.coralRed` |
| Cloud White | `#F7FAFC` | `AppColors.cloudWhite` |
| Soft Sky | `#E8F4FC` | `AppColors.softSky` |
| Text Primary | `#2D3748` | `AppColors.textPrimary` |
| Text Secondary | `#718096` | `AppColors.textSecondary` |
| Border Light | `#E2E8F0` | `AppColors.borderLight` |

### تمييز الدور (§6)

| الدور | اللون | الاستخدام |
|-------|-------|-----------|
| admin (مديرة) | `#4A90D9` | AppBar + RoleBadge |
| teacher (معلمة) | `#6BC04B` | AppBar + RoleBadge |
| parent (ولي أمر) | `#F5A623` | AppBar + RoleBadge |

```dart
Theme(data: AppTheme.forRole('admin'), child: ...)
```

---

## المكوّنات المشتركة

| الملف | الوظيفة |
|-------|---------|
| `lib/shared/widgets/brand_logo.dart` | عرض `assets/brand/logo.png` |
| `lib/shared/widgets/splash_screen.dart` | §5.1 — تدرج + شعار + مؤشر أزرق |
| `lib/shared/widgets/role_badge.dart` | §6 — شارة الدور في بطاقة الترحيب |

---

## الشاشات

### Splash (§5.1)

- **متى:** أثناء `AuthProvider.init()` في `main.dart`
- **خلفية:** `#E8F4FC → #F7FAFC`
- **وسط:** logo.png
- **أسفل:** `CircularProgressIndicator` بلون `#4A90D9`

### Login (§5.2)

- **خلفية:** نفس تدرج Splash
- **أعلى:** `BrandLogo` (140px)
- **عنوان عربي:** «مرحباً بك في كيدي لينك»
- **وصف:** «ربط الروضة بالبيت»
- **نموذج:** بطاقة بيضاء radius 16
- **زر:** Primary Blue
- **ملاحظة:** لا نص إنجليزي منفصل — النص الإنجليزي داخل صورة الشعار فقط (§3.2)

### Home حسب الدور

| الشاشة | AppBar | RoleBadge |
|--------|--------|-----------|
| `admin_home_screen.dart` | أزرق | «مديرة» |
| `teacher_home_screen.dart` | أخضر | «معلمة» |
| `parent_home_screen.dart` | برتقالي | «ولي أمر» |

---

## الأصول

```
mobile/assets/brand/
└── logo.png    # الشعار الكامل (placeholder — استبدله بالشعار الرسمي)
```

**pubspec.yaml:**

```yaml
flutter:
  assets:
    - assets/brand/logo.png
```

> إذا توفر `logo-original.jpeg` الرسمي، انسخه كـ `logo.png` بنفس المسار.

---

## UI Style (§4)

| العنصر | القيمة |
|--------|--------|
| بطاقات | radius 16, elevation 2, shadow black12 |
| أزرار | radius 12, padding 24×14 |
| AppBar | ارتفاع 56, elevation 0 |
| حقول إدخال | filled white, radius 12 |
| scaffold | `#F7FAFC` |

---

## التشغيل والفحص

```powershell
E:\Eman Project\scripts\start-web-fast.ps1
```

| URL | المحتوى |
|-----|---------|
| http://localhost:8082/login | Splash → Login → Home |

**فحص يدوي:**

1. Splash — تدرج + شعار + تحميل أزرق
2. Login — عربي + بطاقة بيضاء
3. `admin` → AppBar أزرق + شارة مديرة
4. `p2teacher` → AppBar أخضر
5. `p2parent` → AppBar برتقالي

---

## ما يجب تجنّبه (§8)

- ❌ زوايا حادة (0 radius)
- ❌ خطوط إنجليزية في الواجهة العربية
- ❌ ألوان نيون
- ❌ ازدحام عناصر
- ✅ زوايا 12–16، Cairo، ألوان الشعار، مساحات بيضاء

---

## ربط بالوثائق

| الملف | العلاقة |
|-------|---------|
| [BRAND_IDENTITY.md](../BRAND_IDENTITY.md) | المواصفة الأصلية |
| [MOBILE.md](./MOBILE.md) | هيكل Flutter + Auth |
| [DEVELOPER_SPEC.md](../DEVELOPER_SPEC.md) | §14 واجهات المستخدم |
| [CHECKPOINT.md](./CHECKPOINT.md) | نقطة التوقف الحالية |

---

*آخر تحديث: 19 يوليو 2026*
