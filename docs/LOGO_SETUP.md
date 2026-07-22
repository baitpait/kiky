# إعداد الشعار الرسمي

> **22 يوليو 2026**

---

## الملف الحالي

```
mobile/assets/brand/logo.png
```

حالياً **placeholder** — يعمل للتطوير والعرض.

---

## الاستبدال

1. جهّز الشعار الرسمي:
   - PNG شفاف
   - 512×512 px (أو أكبر مربع)
   - خلفية شفافة

2. استبدل الملف:
   ```
   E:\Eman Project\mobile\assets\brand\logo.png
   ```

3. أعد بناء Web:
   ```powershell
   E:\Eman Project\scripts\start-web-fast.ps1
   ```

4. (اختياري) أيقونات التطبيق:
   ```bash
   cd mobile
   flutter pub run flutter_launcher_icons
   ```
   > يحتاج إضافة `flutter_launcher_icons` في pubspec — عند بناء المتاجر.

---

## أماكن ظهور الشعار

- Splash Screen
- Login Screen
- AppBar (حسب الدور)

📄 [BRAND_IMPLEMENTATION.md](./BRAND_IMPLEMENTATION.md)
