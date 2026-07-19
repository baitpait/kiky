# سير العمل — التطوير والتدريب

## دور Cursor AI

**مساعد مبرمج + مدرب** لمدير المشروع (ليس مجرد مولّد كود).

## القواعد (`.cursor/rules/`)

| الملف | الغرض |
|-------|--------|
| `dynamic-interactive.mdc` | لا نصوص ثابتة، لا أزرار صامتة، كل شيء من DB |
| `programmer-mentor.mdc` | شرح + اختبار + لا انتقال قبل التأكد |

## بعد كل تعديل

1. **شرح بسيط بالعربي** (ماذا / لماذا / كيف / كيف تختبر)
2. **اختبار** (`npm run build`, `flutter analyze`, smoke يدوي)
3. **تأكيد** من المدير قبل المرحلة التالية

## إبلاغ فشل الاختبار

```powershell
# احفظ التقرير في docs/test-reports/
powershell -File "scripts\notify-test-failure.ps1" `
  -Subject "Kiddy Link - test failed" `
  -BodyFile "docs\test-reports\2026-07-14-example.md"
```

يفتح مسودة بريد إلى: **baitpait@gmail.com**

## معايير الجودة

- [ ] كل زر يعمل
- [ ] كل قائمة من API
- [ ] loading / empty / error
- [ ] موثّق في `docs/`
