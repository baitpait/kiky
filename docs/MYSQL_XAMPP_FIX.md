# إصلاح MySQL في XAMPP — 16 يوليو 2026

## المشكلة

MySQL يطفى فوراً بعد Start في XAMPP Control Panel.

## الأخطاء في السجل (`C:\xampp\mysql\data\mysql_error.log`)

```
File 'aria_log.00000001' not found
Could not open mysql.plugin table
Table '.\mysql\proxies_priv' is marked as crashed
```

## السبب

ملفات Aria و جداول النظام (`mysql` database) تالفة — غالباً بسبب إغلاق XAMPP بشكل غير صحيح.

## الحل الذي نُفّذ

1. نسخ احتياطي إلى: `E:\Eman Project\mysql-backup-20260716-183855`
2. استعادة `aria_log*` من `C:\xampp\mysql\backup\`
3. استعادة جداول النظام من `C:\xampp\mysql\backup\mysql\`
4. تشغيل `aria_chk -o -f` لإصلاح الجداول

> **قاعدة `kiddy_link` لم تُمس** — باقي قواعد البيانات أيضاً موجودة.

## إذا تكررت المشكلة

```powershell
# 1. أوقفي MySQL من XAMPP
# 2. شغّلي:
Copy-Item "C:\xampp\mysql\backup\aria_log*" "C:\xampp\mysql\data\" -Force
Copy-Item "C:\xampp\mysql\backup\mysql\*" "C:\xampp\mysql\data\mysql\" -Force
Remove-Item "C:\xampp\mysql\data\mysql.pid" -Force -ErrorAction SilentlyContinue
# 3. Start MySQL من XAMPP
```

## نصائح للوقاية

- أوقفي MySQL من XAMPP قبل إغلاق الجهاز
- لا تقتلي عملية `mysqld` بالقوة
- اعملي نسخ احتياطي دوري لـ `kiddy_link` عبر phpMyAdmin → Export
