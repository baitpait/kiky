# Kiddy Link — الهوية البصرية
## Connecting Home & Kindergarten

| البند | التفاصيل |
|-------|----------|
| **اسم العلامة** | Kiddy Link |
| **الشعار النصي** | Connecting Home & Kindergarten |
| **ملف الشعار** | `assets/brand/logo.png` |
| **الإصدار** | 1.0 — يوليو 2026 |
| **اللغة في التطبيق** | عربي فقط (RTL) — الشعار الإنجليزي يبقى كما هو في شاشة الدخول |

---

## 1. تحليل الشعار

### 1.1 الرسالة البصرية

الشعار يعبّر عن **الجسر بين البيت والروضة**:

```
🏠 البيت (يسار)  ←── 🔗 Kiddy Link ──→  🏫 الروضة (يمين)
         الأم/المعلمة 🤝 الطفل
```

| العنصر | المعنى |
|--------|--------|
| المرأة + الطفل يداً بيد | التواصل والرعاية بين المعلمة/الأم والطفل |
| حلقة الربط (🔗) | اسم التطبيق — الربط الرقمي بين المنزل والروضة |
| البيت | جانب العائلة — ولي الأمر |
| المدرسة/الروضة | جانب التعليم — المعلمة والإدارة |
| قوس قزح + نجوم | فرح، أمان، بيئة إيجابية للأطفال |
| الغيوم الزرقاء | نعومة، راحة، طفولة |

### 1.2 الشخصية والنبرة (Brand Personality)

| الصفة | الوصف |
|-------|-------|
| **ودود** | أشكال دائرية، ابتسامات، ألوان دافئة |
| **آمن** | ألوان هادئة، لا حدة أو زوايا حادة |
| **موثوق** | أزرق أساسي — ثقة الأهل بالتطبيق |
| **حيوي** | أخضر وبرتقالي — نمو الطفل ونشاطه |
| **بسيط** | رسوم مسطحة/شبه ثلاثية — سهل الفهم لأولياء الأمور |

### 1.3 الكلمات المفتاحية للهوية

```
ربط · أمان · فرح · بساطة · ثقة · طفولة · تواصل
```

---

## 2. لوحة الألوان (Color Palette)

> الألوان مستخرجة من الشعار — تُستخدم في Flutter ThemeData.

### 2.1 الألوان الأساسية (Primary)

| الاسم | Hex | Flutter | الاستخدام |
|-------|-----|---------|-----------|
| **Kiddy Blue** | `#4A90D9` | `Color(0xFF4A90D9)` | AppBar، أزرار رئيسية، روابط، "Kiddy" |
| **Link Green** | `#6BC04B` | `Color(0xFF6BC04B)` | أزرار ثانوية، نجاح، "Link"، تأكيدات |
| **Warm Orange** | `#F5A623` | `Color(0xFFF5A623)` | تنبيهات إيجابية، تمييز، البيت في الشعار |
| **Coral Red** | `#E8634A` | `Color(0xFFE8634A)` | سقف البيت، تنبيهات مهمة (بحذر) |

### 2.2 الألوان المحايدة (Neutrals)

| الاسم | Hex | Flutter | الاستخدام |
|-------|-----|---------|-----------|
| **Cloud White** | `#F7FAFC` | `Color(0xFFF7FAFC)` | خلفية الشاشات |
| **Soft Sky** | `#E8F4FC` | `Color(0xFFE8F4FC)` | بطاقات، خلفيات ثانوية (من غيوم الشعار) |
| **Text Primary** | `#2D3748` | `Color(0xFF2D3748)` | نصوص رئيسية عربية |
| **Text Secondary** | `#718096` | `Color(0xFF718096)` | نصوص فرعية، شعار "Connecting..." |
| **Border Light** | `#E2E8F0` | `Color(0xFFE2E8F0)` | حدود، فواصل |

### 2.3 ألوان الحالة (Semantic)

| الحالة | Hex | الاستخدام |
|--------|-----|-----------|
| نجاح | `#6BC04B` | تأكيد وجبة، حل واجب، حضور |
| تحذير | `#F5A623` | اشتراك قريب الانتهاء، بانتظار موافقة |
| خطأ | `#E8634A` | غياب، رفض، خطأ |
| معلومات | `#4A90D9` | إشعارات عامة |

### 2.4 ألوان مستويات الملصقات (اقتراح من الهوية)

| المستوى | اللون | Hex |
|---------|-------|-----|
| مبتدئ | أخضر فاتح | `#6BC04B` |
| متوسط | برتقالي | `#F5A623` |
| متقدم | أزرق | `#4A90D9` |

> المديرة يمكنها تغيير الألوان من الإعدادات — هذه قيم افتراضية متناسقة مع الشعار.

### 2.5 تدرج الشعار (للخلفيات الاختيارية)

```dart
// mobile/lib/core/theme/brand_gradients.dart
static const logoGradient = LinearGradient(
  colors: [Color(0xFF4A90D9), Color(0xFF6BC04B)],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);
```

---

## 3. الخطوط (Typography)

### 3.1 التطبيق (عربي)

| الاستخدام | الخط | الوزن | الحجم |
|-----------|------|-------|-------|
| عناوين رئيسية | **Cairo** أو **Tajawal** | Bold (700) | 24–28sp |
| عناوين فرعية | Cairo / Tajawal | SemiBold (600) | 18–20sp |
| نص عادي | Cairo / Tajawal | Regular (400) | 14–16sp |
| نص صغير | Cairo / Tajawal | Regular (400) | 12sp |
| أزرار | Cairo / Tajawal | SemiBold (600) | 16sp |

```yaml
# pubspec.yaml
fonts:
  - family: Cairo
    fonts:
      - asset: assets/fonts/Cairo-Regular.ttf
      - asset: assets/fonts/Cairo-SemiBold.ttf
        weight: 600
      - asset: assets/fonts/Cairo-Bold.ttf
        weight: 700
```

### 3.2 الشعار (إنجليزي — شاشة الدخول فقط)

| العنصر | النمط |
|--------|-------|
| **Kiddy Link** | خط دائري عريض (Rounded/Bubble) — مثل الشعار |
| **Connecting Home & Kindergarten** | Sans-serif رفيع، لون `#718096`، حجم أصغر |

> لا تُستخدم خطوط الشعار الإنجليزية في واجهة التطبيق العربية — فقط في Splash / Login مع صورة الشعار.

---

## 4. أسلوب الواجهة (UI Style)

### 4.1 المبادئ

| المبدأ | التطبيق |
|--------|---------|
| **زوايا دائرية** | `BorderRadius.circular(16)` للبطاقات، `12` للأزرار |
| **ظلال ناعمة** | `BoxShadow(blurRadius: 12, color: black12)` — لا ظلال حادة |
| **مساحات بيضاء** | padding سخي — التطبيق يُشعر بالراحة لا الازدحام |
| **أيقونات** | Rounded/Material Symbols — نمط ودود |
| **صور** | `ClipRRect` بزوايا 12–16 |

### 4.2 المكونات

#### الأزرار

| النوع | الخلفية | النص | Radius |
|-------|---------|------|--------|
| Primary | `#4A90D9` | أبيض | 12 |
| Secondary | `#6BC04B` | أبيض | 12 |
| Outline | شفاف | `#4A90D9` | 12 |
| Ghost | شفاف | `#718096` | 12 |

#### البطاقات (Cards)

```
خلفية: أبيض #FFFFFF
حد: #E2E8F0 أو بدون حد
Radius: 16
Padding: 16
ظل: خفيف
```

#### شريط التطبيق (AppBar)

```
خلفية: #4A90D9
نص/أيقونات: أبيض
ارتفاع: 56
بدون ظل حاد (elevation: 0)
```

#### شريط التنقل السفلي (Bottom Nav)

```
خلفية: أبيض
نشط: #4A90D9
غير نشط: #718096
```

### 4.3 المسافات (Spacing Scale)

| Token | القيمة |
|-------|--------|
| `xs` | 4 |
| `sm` | 8 |
| `md` | 16 |
| `lg` | 24 |
| `xl` | 32 |
| `xxl` | 48 |

### 4.4 الأيقونات والرسوم

- **الملصقات (Stickers):** أسلوب رسومي/كرتوني متناسق مع الشعار — دائري، ملون، بحدود ناعمة
- **الصور الشخصية:** دائرية `CircleAvatar`
- **حالة فارغة (Empty State):** رسوم بسيطة بألوان العلامة (أزرق + أخضر)

---

## 5. شاشات العلامة التجارية

### 5.1 Splash Screen

```
خلفية: تدرج #E8F4FC → #F7FAFC
وسط: logo.png (الشعار الكامل)
أسفل: مؤشر تحميل بلون #4A90D9
```

### 5.2 Login Screen

```
أعلى: logo.png (حجم متوسط)
عنوان عربي: "مرحباً بك في كيدي لينك"
وصف: "ربط الروضة بالبيت"
حقول: username + password — بطاقة بيضاء بزوايا 16
زر دخول: Primary Blue
```

### 5.3 أيقونة التطبيق (App Icon)

- اقتصاص الجزء المركزي: **حلقة الربط 🔗** أو **الطفل + الحلقة**
- خلفية: `#4A90D9` أو تدرج أزرق-أخضر
- بدون نص صغير (غير مقروء على الموبايل)

---

## 6. تطبيق الهوية حسب الدور

| الدور | لون تمييزي | الاستخدام |
|-------|------------|-----------|
| **مديرة** | `#4A90D9` (أزرق) | AppBar، شارة الدور |
| **معلمة** | `#6BC04B` (أخضر) | AppBar، شارة الدور |
| **ولي أمر** | `#F5A623` (برتقالي) | AppBar، شارة الدور |

> اللون التمييزي **إضافة بسيطة** — الهوية الأساسية واحدة. لا تغيّر البنية العامة.

---

## 7. مرجع Flutter — `theme.dart`

```dart
// mobile/lib/core/theme/app_colors.dart
abstract class AppColors {
  static const kiddyBlue = Color(0xFF4A90D9);
  static const linkGreen = Color(0xFF6BC04B);
  static const warmOrange = Color(0xFFF5A623);
  static const coralRed = Color(0xFFE8634A);
  static const cloudWhite = Color(0xFFF7FAFC);
  static const softSky = Color(0xFFE8F4FC);
  static const textPrimary = Color(0xFF2D3748);
  static const textSecondary = Color(0xFF718096);
  static const borderLight = Color(0xFFE2E8F0);
}

// mobile/lib/core/theme/app_theme.dart
ThemeData buildAppTheme({Color? roleAccent}) {
  final accent = roleAccent ?? AppColors.kiddyBlue;
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Cairo',
    colorScheme: ColorScheme.light(
      primary: accent,
      secondary: AppColors.linkGreen,
      surface: Colors.white,
      error: AppColors.coralRed,
    ),
    scaffoldBackgroundColor: AppColors.cloudWhite,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.kiddyBlue,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.kiddyBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
```

---

## 8. ما يجب تجنّبه

| ❌ لا | ✅ نعم |
|-------|--------|
| زوايا حادة (0 radius) | زوايا دائرية 12–16 |
| ألوان نيون صارخة | ألوان الشعار المعتدلة |
| خطوط إنجليزية في الواجهة العربية | Cairo / Tajawal |
| ظلال ثقيلة | ظلال خفيفة |
| ازدحام عناصر | مساحات بيضاء سخية |
| أيقونات حادة/تقنية | أيقونات ودودة ومبسطة |

---

## 9. الأصول (Assets)

```
assets/brand/
├── logo.png              # الشعار الكامل
├── logo-original.jpeg    # النسخة الأصلية
├── app_icon.png          # (يُنشأ لاحقاً) أيقونة المتجر
└── splash_logo.png       # (اختياري) نسخة مبسطة للـ Splash
```

---

## 10. ربط بالوثائق الأخرى

| الملف | العلاقة |
|-------|---------|
| `DEVELOPER_SPEC.md` | §14 واجهات المستخدم |
| `.cursorrules` | §9 FRONTEND INTEGRITY — يشير لهذا الملف |
| `mobile/lib/core/theme/` | تنفيذ الألوان والخطوط |

---

> **نهاية دليل الهوية البصرية — الإصدار 1.0**
>
> Kiddy Link · يوليو 2026 · مصدر الألوان: شعار التطبيق الرسمي
