# Kiddy Link — برومبت بداية المشروع
## انسخ المحتوى داخل صندوق "البرومبت" وأرسله في Cursor لبدء التطوير

---

```
أنت مهندس برمجيات Senior. ابدأ مشروع Kiddy Link من الصفر حسب المواصفات أدناه.
اقرأ أولاً: DEVELOPER_SPEC.md و .cursorrules في جذر المشروع — والتزم بهما حرفياً.

═══════════════════════════════════════
📱 المشروع: Kiddy Link
   Connecting Home & Kindergarten
═══════════════════════════════════════

الوصف:
تطبيق موبايل (Flutter) يربط روضة أطفال واحدة بأولياء الأمور.
ليس نظام محاسبة. لا دفع. لا اشتراكات. لا موقع ويب.
عربي فقط — RTL. الاستضافة على سيرفر خاص في فلسطين.

الأدوار (3 واجهات في تطبيق واحد):
- admin   → مديرة الروضة (لوحة تحكم داخل التطبيق)
- teacher → معلمة
- parent  → ولي أمر (يمكن ربطه بأكثر من طالب)

═══════════════════════════════════════
🛠 Stack التقني (إلزامي)
═══════════════════════════════════════

mobile/     → Flutter 3.x + Dart (عربي RTL)
backend/    → NestJS + TypeScript
database    → MySQL 8.x + Prisma
cache       → Redis
storage     → MinIO (صور + مرفقات الدردشة)
proxy       → Nginx + SSL
containers  → Docker Compose
push        → FCM + APNs
live        → Agora SDK (المعلمة تبدأ البث فقط)
ai          → OpenAI API (تحليل الواجبات — من Backend فقط)

═══════════════════════════════════════
📁 هيكل المشروع المطلوب
═══════════════════════════════════════

kiddy-link/
├── mobile/
│   └── lib/
│       ├── core/           # theme, router, constants, api_client
│       ├── features/
│       │   ├── auth/
│       │   ├── admin/      # لوحة المديرة داخل التطبيق
│       │   ├── teacher/
│       │   ├── parent/
│       │   ├── photos/
│       │   ├── homework/
│       │   ├── stickers/
│       │   ├── attendance/
│       │   ├── meals/
│       │   ├── chat/
│       │   ├── live/
│       │   └── notifications/
│       └── shared/
├── backend/
│   └── src/
│       ├── auth/
│       ├── users/
│       ├── students/
│       ├── photos/
│       ├── homework/
│       ├── stickers/
│       ├── attendance/
│       ├── meals/
│       ├── chat/
│       ├── live/
│       ├── notifications/
│       ├── ai/
│       └── admin/
├── docker-compose.yml
├── .env.example
├── .cursorrules
├── .cursorignore
└── DEVELOPER_SPEC.md

═══════════════════════════════════════
🎯 المهمة الآن: المرحلة 1 — الأساس
═══════════════════════════════════════

نفّذ بالترتيب:

1. إنشاء هيكل Monorepo أعلاه
2. docker-compose.yml: MySQL + Redis + MinIO
3. backend: NestJS scaffold + Prisma + MySQL schema (كل الجداول من DEVELOPER_SPEC.md §6)
4. prisma/seed.ts: مستخدم admin افتراضي + مستويات ملصقات + ملصقات نموذجية
5. Auth module: login, refresh, logout, JWT guards, RBAC (admin/teacher/parent)
6. Admin APIs: CRUD معلمات، أولياء أمور، طلاب + ربط parent_student و teacher_student
7. mobile: Flutter scaffold عربي RTL + تسجيل دخول + توجيه حسب الدور
8. Swagger على /api/docs
9. .env.example + .gitignore + .cursorignore
10. README.md: تعليمات التشغيل المحلي

═══════════════════════════════════════
⚠️ قواعد صارمة
═══════════════════════════════════════

- المديرة تنشئ الحسابات — لا تسجيل ذاتي
- لا لوحة ويب — إدارة المديرة داخل Flutter
- الملصقات من الإدارة مع مستويات (sticker_levels + stickers) — ليست ثابتة في الكود
- AI يختار ملصقاً من القائمة النشطة فقط — لا يستدعى من Flutter مباشرة
- الدردشة: ولي أمر ↔ معلمة فقط (لا معلمة ↔ إدارة)
- الصور: المعلمة ترفع للألبوم (بموافقة المديرة) | ولي الأمر يرفع في الدردشة فقط
- Soft delete: is_active / is_deleted — لا حذف فعلي للسجلات الحساسة
- التحقق من المدخلات في Backend (DTOs) و Flutter (FormKey)
- Commits: Conventional Commits (feat:, fix:, chore:)
- الكود بالإنجليزية | الشروحات لي بالعربية

═══════════════════════════════════════
🚫 خارج النطاق — لا تبنِها
═══════════════════════════════════════

دفع | اشتراكات | محاسبة | موقع ويب | SMS | WhatsApp
QR حضور | عدة روضات | إنجليزي | تسجيل ذاتي | دردشة معلمة-إدارة

═══════════════════════════════════════
✅ معيار الإنجاز للمرحلة 1
═══════════════════════════════════════

- docker compose up يشغّل MySQL + Redis + MinIO + API
- seed ينشئ admin + مستويات ملصقات
- المديرة تسجّل دخول من Flutter → تظهر واجهة Admin
- المديرة تنشئ معلمة + ولي أمر + طالب وربطهم
- المعلمة وولي الأمر يسجّلان دخول → واجهات مختلفة
- Swagger يوثّق كل endpoints المرحلة 1

ابدأ الآن. أنشئ الملفات فعلياً. لا تكتفِ بخطة — نفّذ الكود.
بعد الانتهاء، أعطني ملخصاً بالعربية لما تم إنشاؤه وكيف أشغّل المشروع محلياً.
```

---

## كيفية الاستخدام

1. افتح مجلد `aymam` في Cursor
2. تأكد من وجود `DEVELOPER_SPEC.md` و `.cursorrules`
3. انسخ المحتوى داخل صندوق البرومبت أعلاه
4. الصقه في محادثة Cursor Agent جديدة
5. راجع المخرجات ثم انتقل للمرحلة 2 (صور + حضور + وجبات)

## المراحل التالية (برومبتات منفصلة)

| المرحلة | المحتوى |
|---------|---------|
| 2 | صور + موافقة مديرة + حضور + وجبات + Push |
| 3 | ملصقات + واجبات + AI |
| 4 | دردشة WebSocket |
| 5 | Agora بث مباشر |
| 6 | تقويم + بانرات + اختبار + نشر |
