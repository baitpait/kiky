#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Generate complete Kiddy Link QOU graduation HTML report with SVG diagrams."""
from pathlib import Path

OUT = Path(__file__).with_name("kiddy-link-graduation-report.html")
DESK = Path.home() / "Desktop" / "kiddy-link-graduation-report.html"

CSS = r"""
@page { size: A4; margin: 2cm; }
* { box-sizing: border-box; }
body { font-family: "Traditional Arabic","Arial","Tahoma",sans-serif; font-size: 15pt; line-height: 1.75; color:#111; margin:0; padding:20px; max-width:210mm; margin-inline:auto; background:#fff; }
h1,h2,h3,h4 { font-family: Arial,Tahoma,sans-serif; color:#0b3d5c; page-break-after:avoid; }
h1 { font-size:21pt; text-align:center; }
h2 { font-size:17pt; border-bottom:2px solid #4A90D9; padding-bottom:6px; margin-top:1.8em; }
h3 { font-size:15pt; margin-top:1.3em; color:#1a5f7a; }
h4 { font-size:14pt; margin-top:1em; }
p { text-align:justify; margin:.55em 0; }
ul,ol { padding-right:1.5em; }
li { margin:.3em 0; }
.center { text-align:center; }
.cover { min-height:90vh; display:flex; flex-direction:column; justify-content:center; align-items:center; text-align:center; page-break-after:always; gap:.35em; }
.cover .uni { font-size:20pt; font-weight:bold; }
.cover .proj-title { font-size:26pt; font-weight:bold; color:#4A90D9; margin:1em 0 .2em; }
.cover .subtitle { font-size:14pt; color:#555; }
.muted { color:#555; font-size:12.5pt; }
.page-break { page-break-before:always; }
table { width:100%; border-collapse:collapse; margin:1em 0; font-size:12.5pt; page-break-inside:avoid; }
th,td { border:1px solid #777; padding:7px 9px; text-align:right; vertical-align:top; }
th { background:#E8F4FC; }
.caption { text-align:center; font-size:12pt; color:#222; margin:0.3em 0 1.2em; font-weight:bold; }
.fig { margin:1em auto; text-align:center; page-break-inside:avoid; }
.fig svg { max-width:100%; height:auto; border:1px solid #ddd; background:#fafcff; }
.note { background:#f4f8fb; border-right:4px solid #4A90D9; padding:10px 14px; margin:1em 0; font-size:12.5pt; }
.mono { font-family:Consolas,monospace; font-size:11.5pt; direction:ltr; unicode-bidi:embed; }
.uc-box { border:1px solid #99b; border-radius:8px; padding:10px 14px; margin:1em 0; background:#fcfdff; page-break-inside:avoid; }
.small { font-size:12pt; }
.wire { border:2px solid #4A90D9; border-radius:16px; width:280px; margin:1em auto; background:#fff; overflow:hidden; page-break-inside:avoid; display:inline-block; vertical-align:top; margin-left:12px; margin-right:12px; }
.wire .bar { background:#4A90D9; color:#fff; padding:10px; text-align:center; font-size:12pt; }
.wire .body { padding:12px; min-height:160px; font-size:11.5pt; }
.wire .nav { display:flex; border-top:1px solid #ddd; font-size:9.5pt; }
.wire .nav span { flex:1; text-align:center; padding:8px 2px; border-left:1px solid #eee; }
.badge { display:inline-block; background:#E8F4FC; border:1px solid #4A90D9; border-radius:6px; padding:2px 8px; margin:2px; font-size:11pt; }
"""


def fig(svg: str, caption: str) -> str:
    return f'<div class="fig">{svg}</div><p class="caption">{caption}</p>'


def oval(x, y, w, h, label, fill="#fff"):
    return (
        f'<ellipse cx="{x}" cy="{y}" rx="{w}" ry="{h}" fill="{fill}" stroke="#333" stroke-width="1.5"/>'
        f'<text x="{x}" y="{y+4}" text-anchor="middle" font-size="11" font-family="Arial">{label}</text>'
    )


def svg_arch():
    svg = """<svg viewBox="0 0 820 420" xmlns="http://www.w3.org/2000/svg">
  <rect width="820" height="420" fill="#f7fbff"/>
  <rect x="220" y="20" width="380" height="70" rx="12" fill="#4A90D9"/>
  <text x="410" y="48" text-anchor="middle" fill="#fff" font-size="18" font-family="Arial">Flutter App (RTL)</text>
  <text x="410" y="72" text-anchor="middle" fill="#e8f4fc" font-size="13" font-family="Arial">Admin / Teacher / Parent</text>
  <line x1="410" y1="90" x2="410" y2="130" stroke="#333" stroke-width="2"/>
  <text x="480" y="115" fill="#333" font-size="12" font-family="Arial">HTTPS + WebSocket</text>
  <rect x="220" y="135" width="380" height="70" rx="12" fill="#2d6a4f"/>
  <text x="410" y="165" text-anchor="middle" fill="#fff" font-size="18" font-family="Arial">NestJS API</text>
  <text x="410" y="188" text-anchor="middle" fill="#d8f3dc" font-size="13" font-family="Arial">REST + JWT + Roles + WS</text>
  <rect x="40" y="255" width="160" height="60" rx="10" fill="#e76f51"/>
  <text x="120" y="292" text-anchor="middle" fill="#fff" font-size="15" font-family="Arial">MySQL</text>
  <rect x="220" y="255" width="160" height="60" rx="10" fill="#f4a261"/>
  <text x="300" y="292" text-anchor="middle" fill="#fff" font-size="15" font-family="Arial">Redis</text>
  <rect x="400" y="255" width="160" height="60" rx="10" fill="#457b9d"/>
  <text x="480" y="292" text-anchor="middle" fill="#fff" font-size="15" font-family="Arial">Storage</text>
  <rect x="580" y="255" width="180" height="60" rx="10" fill="#6d597a"/>
  <text x="670" y="280" text-anchor="middle" fill="#fff" font-size="14" font-family="Arial">Agora + OpenAI</text>
  <text x="670" y="300" text-anchor="middle" fill="#efe" font-size="12" font-family="Arial">Live / Homework AI</text>
  <line x1="280" y1="205" x2="140" y2="250" stroke="#333" stroke-width="2"/>
  <line x1="360" y1="205" x2="300" y2="250" stroke="#333" stroke-width="2"/>
  <line x1="460" y1="205" x2="520" y2="250" stroke="#333" stroke-width="2"/>
  <line x1="540" y1="205" x2="680" y2="250" stroke="#333" stroke-width="2"/>
  <rect x="150" y="345" width="520" height="50" rx="10" fill="#264653"/>
  <text x="410" y="376" text-anchor="middle" fill="#fff" font-size="15" font-family="Arial">Production: kiddylink.baitpait.com/api</text>
</svg>"""
    return fig(svg, "الشكل 1.0 — المعمار العام لنظام Kiddy Link")


def svg_rup():
    svg = """<svg viewBox="0 0 820 220" xmlns="http://www.w3.org/2000/svg">
  <rect width="820" height="220" fill="#f7fbff"/>
  <text x="410" y="30" text-anchor="middle" fill="#0b3d5c" font-size="18" font-family="Arial">Rational Unified Process (RUP)</text>
  <rect x="30" y="60" width="160" height="90" rx="12" fill="#4A90D9"/>
  <text x="110" y="100" text-anchor="middle" fill="#fff" font-size="16" font-family="Arial">Inception</text>
  <text x="110" y="125" text-anchor="middle" fill="#eaf" font-size="13" font-family="Arial">الاستهلال</text>
  <rect x="230" y="60" width="160" height="90" rx="12" fill="#2a9d8f"/>
  <text x="310" y="100" text-anchor="middle" fill="#fff" font-size="16" font-family="Arial">Elaboration</text>
  <text x="310" y="125" text-anchor="middle" fill="#eaf" font-size="13" font-family="Arial">التفصيل</text>
  <rect x="430" y="60" width="160" height="90" rx="12" fill="#e9c46a"/>
  <text x="510" y="100" text-anchor="middle" fill="#333" font-size="16" font-family="Arial">Construction</text>
  <text x="510" y="125" text-anchor="middle" fill="#333" font-size="13" font-family="Arial">البناء</text>
  <rect x="630" y="60" width="160" height="90" rx="12" fill="#e76f51"/>
  <text x="710" y="100" text-anchor="middle" fill="#fff" font-size="16" font-family="Arial">Transition</text>
  <text x="710" y="125" text-anchor="middle" fill="#fff" font-size="13" font-family="Arial">الانتقال</text>
  <line x1="190" y1="105" x2="225" y2="105" stroke="#333" stroke-width="3"/>
  <line x1="390" y1="105" x2="425" y2="105" stroke="#333" stroke-width="3"/>
  <line x1="590" y1="105" x2="625" y2="105" stroke="#333" stroke-width="3"/>
</svg>"""
    return fig(svg, "الشكل 1.1 — مراحل منهجية RUP")


def svg_gantt():
    phases = [
        ("الاستهلال", 20, 90, "#4A90D9"),
        ("التفصيل والتحليل", 100, 160, "#2a9d8f"),
        ("البناء والتصميم", 170, 420, "#e9c46a"),
        ("الانتقال والتنفيذ", 430, 520, "#e76f51"),
    ]
    bars = []
    y = 70
    for name, x1, x2, color in phases:
        bars.append(f'<text x="10" y="{y+18}" font-size="13" font-family="Arial" fill="#222">{name}</text>')
        bars.append(
            f'<rect x="{120 + x1 * 1.1:.0f}" y="{y}" width="{(x2 - x1) * 1.1:.0f}" height="28" rx="6" fill="{color}"/>'
        )
        y += 45
    svg = f"""<svg viewBox="0 0 820 280" xmlns="http://www.w3.org/2000/svg">
  <rect width="820" height="280" fill="#f7fbff"/>
  <text x="410" y="28" text-anchor="middle" fill="#0b3d5c" font-size="16" font-family="Arial">مخطط جانت التقديري</text>
  {''.join(bars)}
  <text x="120" y="260" font-size="11" fill="#666" font-family="Arial">الزمن →</text>
</svg>"""
    return fig(svg, "الشكل 1.2 — مخطط جانت التقديري")


def svg_actors():
    svg = """<svg viewBox="0 0 820 280" xmlns="http://www.w3.org/2000/svg">
  <rect width="820" height="280" fill="#f7fbff"/>
  <rect x="310" y="100" width="200" height="70" rx="12" fill="#264653"/>
  <text x="410" y="142" text-anchor="middle" fill="#fff" font-size="18" font-family="Arial">Kiddy Link</text>
  <circle cx="120" cy="80" r="16" fill="#4A90D9"/><line x1="120" y1="96" x2="120" y2="135" stroke="#4A90D9" stroke-width="4"/><line x1="98" y1="112" x2="142" y2="112" stroke="#4A90D9" stroke-width="4"/><line x1="120" y1="135" x2="100" y2="170" stroke="#4A90D9" stroke-width="4"/><line x1="120" y1="135" x2="140" y2="170" stroke="#4A90D9" stroke-width="4"/>
  <text x="120" y="200" text-anchor="middle" font-size="14" font-family="Arial">المديرة</text>
  <circle cx="700" cy="80" r="16" fill="#e76f51"/><line x1="700" y1="96" x2="700" y2="135" stroke="#e76f51" stroke-width="4"/><line x1="678" y1="112" x2="722" y2="112" stroke="#e76f51" stroke-width="4"/><line x1="700" y1="135" x2="680" y2="170" stroke="#e76f51" stroke-width="4"/><line x1="700" y1="135" x2="720" y2="170" stroke="#e76f51" stroke-width="4"/>
  <text x="700" y="200" text-anchor="middle" font-size="14" font-family="Arial">ولي الأمر</text>
  <circle cx="410" cy="230" r="16" fill="#2a9d8f"/><line x1="410" y1="214" x2="410" y2="175" stroke="#2a9d8f" stroke-width="3"/>
  <text x="410" y="265" text-anchor="middle" font-size="14" font-family="Arial">المعلمة</text>
  <line x1="150" y1="100" x2="310" y2="125" stroke="#888" stroke-dasharray="4"/>
  <line x1="670" y1="100" x2="510" y2="125" stroke="#888" stroke-dasharray="4"/>
  <line x1="410" y1="214" x2="410" y2="170" stroke="#888" stroke-dasharray="4"/>
</svg>"""
    return fig(svg, "الشكل 3.1 — المتفاعلون في نظام Kiddy Link")


def svg_usecase_all():
    cases = [
        (410, 50, 90, 20, "تسجيل الدخول", "#E8F4FC"),
        (200, 105, 95, 20, "إدارة الحسابات", "#E8F4FC"),
        (200, 150, 95, 20, "موافقة الصور", "#E8F4FC"),
        (200, 195, 100, 20, "تقويم/بانرات", "#E8F4FC"),
        (200, 240, 95, 20, "إدارة الملصقات", "#E8F4FC"),
        (410, 105, 90, 20, "تسجيل حضور", "#d8f3dc"),
        (410, 150, 90, 20, "تأكيد وجبات", "#d8f3dc"),
        (410, 195, 95, 20, "رفع صور ألبوم", "#d8f3dc"),
        (410, 240, 90, 20, "واجبات منزلية", "#d8f3dc"),
        (410, 285, 85, 20, "بث مباشر", "#d8f3dc"),
        (620, 105, 95, 20, "متابعة الطفل", "#ffe8d6"),
        (620, 150, 90, 20, "عرض الصور", "#ffe8d6"),
        (620, 195, 90, 20, "عرض واجبات", "#ffe8d6"),
        (620, 240, 85, 20, "مشاهدة بث", "#ffe8d6"),
        (520, 330, 90, 20, "دردشة", "#f1e6ff"),
    ]
    body = "".join(oval(*c) for c in cases)
    svg = f"""<svg viewBox="0 0 820 390" xmlns="http://www.w3.org/2000/svg">
  <rect width="820" height="390" fill="#f7fbff"/>
  <rect x="120" y="20" width="580" height="350" rx="8" fill="none" stroke="#4A90D9" stroke-width="2"/>
  <text x="410" y="18" text-anchor="middle" font-size="14" fill="#0b3d5c" font-family="Arial">Kiddy Link</text>
  <text x="50" y="180" text-anchor="middle" font-size="13" font-family="Arial">مديرة</text>
  <text x="770" y="140" text-anchor="middle" font-size="13" font-family="Arial">ولي أمر</text>
  <text x="770" y="300" text-anchor="middle" font-size="13" font-family="Arial">معلمة</text>
  {body}
</svg>"""
    return fig(svg, "الشكل 3.2 — مخطط حالات الاستخدام للنظام كامل")


def svg_usecase_role(title, caption, color, cases):
    items = []
    mid = (len(cases) + 1) // 2
    for i, lab in enumerate(cases):
        col = 0 if i < mid else 1
        row = i if col == 0 else i - mid
        x = 230 if col == 0 else 480
        y = 70 + row * 40
        items.append(oval(x, y, 105, 17, lab, "#fff"))
    svg = f"""<svg viewBox="0 0 700 300" xmlns="http://www.w3.org/2000/svg">
  <rect width="700" height="300" fill="#f7fbff"/>
  <rect x="140" y="25" width="520" height="255" rx="8" fill="none" stroke="{color}" stroke-width="2"/>
  <text x="400" y="20" text-anchor="middle" font-size="14" fill="#0b3d5c" font-family="Arial">{title}</text>
  <circle cx="60" cy="140" r="14" fill="{color}"/>
  <text x="60" y="175" text-anchor="middle" font-size="12" font-family="Arial">ممثل</text>
  {''.join(items)}
</svg>"""
    return fig(svg, caption)


def svg_activity(caption, steps, color="#4A90D9"):
    parts = []
    y = 70
    parts.append(f'<ellipse cx="260" cy="30" rx="40" ry="16" fill="{color}"/><text x="260" y="35" text-anchor="middle" fill="#fff" font-size="12">بداية</text>')
    for s in steps:
        parts.append(f'<line x1="260" y1="{y-20}" x2="260" y2="{y}" stroke="#333"/>')
        if s.startswith("؟"):
            parts.append(f'<polygon points="260,{y} 360,{y+22} 260,{y+44} 160,{y+22}" fill="#fff3cd" stroke="#333"/>')
            parts.append(f'<text x="260" y="{y+27}" text-anchor="middle" font-size="11">{s[1:]}</text>')
            y += 60
        else:
            parts.append(f'<rect x="140" y="{y}" width="240" height="36" rx="8" fill="#fff" stroke="#333"/>')
            parts.append(f'<text x="260" y="{y+23}" text-anchor="middle" font-size="12">{s}</text>')
            y += 55
    parts.append(f'<line x1="260" y1="{y-15}" x2="260" y2="{y}" stroke="#333"/>')
    parts.append(f'<ellipse cx="260" cy="{y+16}" rx="40" ry="16" fill="#e76f51"/><text x="260" y="{y+21}" text-anchor="middle" fill="#fff" font-size="12">نهاية</text>')
    h = y + 50
    svg = f'<svg viewBox="0 0 520 {h}" xmlns="http://www.w3.org/2000/svg"><rect width="520" height="{h}" fill="#f7fbff"/>{"".join(parts)}</svg>'
    return fig(svg, caption)


def svg_class():
    classes = [
        (40, 30, "User", ["id", "username", "role", "is_active"]),
        (220, 30, "Student", ["id", "name", "class"]),
        (400, 30, "Teacher", ["id", "user_id"]),
        (580, 30, "Parent", ["id", "user_id"]),
        (40, 160, "Attendance", ["student_id", "type", "date"]),
        (220, 160, "Photo", ["url", "status"]),
        (400, 160, "Homework", ["title", "grade"]),
        (580, 160, "MealRecord", ["student_id", "status"]),
        (40, 290, "Conversation", ["kind"]),
        (220, 290, "Message", ["content", "sent_at"]),
        (400, 290, "LiveStream", ["channel", "status"]),
        (580, 290, "Notification", ["title", "category"]),
        (310, 420, "Sticker", ["name", "level_id"]),
    ]
    boxes = []
    for x, y, name, attrs in classes:
        boxes.append(f'<rect x="{x}" y="{y}" width="150" height="105" fill="#fff" stroke="#0b3d5c"/>')
        boxes.append(f'<rect x="{x}" y="{y}" width="150" height="26" fill="#4A90D9"/>')
        boxes.append(f'<text x="{x+75}" y="{y+18}" text-anchor="middle" fill="#fff" font-size="13" font-family="Arial">{name}</text>')
        for i, line in enumerate(attrs):
            boxes.append(f'<text x="{x+8}" y="{y+48+i*16}" font-size="11" font-family="Consolas">{line}</text>')
    svg = f"""<svg viewBox="0 0 780 550" xmlns="http://www.w3.org/2000/svg">
  <rect width="780" height="550" fill="#f7fbff"/>
  {''.join(boxes)}
  <line x1="115" y1="135" x2="115" y2="160" stroke="#333"/>
  <line x1="295" y1="135" x2="295" y2="160" stroke="#333"/>
  <line x1="190" y1="80" x2="220" y2="80" stroke="#333"/>
  <line x1="370" y1="80" x2="400" y2="80" stroke="#333"/>
</svg>"""
    return fig(svg, "الشكل 3.6 — مخطط الأصناف (Class Diagram)")


def svg_sequence(caption, actors, messages, fail=False):
    n = len(actors)
    width = 100 + n * 150
    height = 80 + len(messages) * 38 + 40
    parts = [f'<rect width="{width}" height="{height}" fill="#f7fbff"/>']
    parts.append('<defs><marker id="arr" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto"><path d="M0,0 L6,3 L0,6 Z" fill="#222"/></marker></defs>')
    xs = []
    for i, a in enumerate(actors):
        x = 80 + i * 150
        xs.append(x)
        fill = "#e76f51" if fail and i == n - 1 else "#4A90D9"
        parts.append(f'<rect x="{x-45}" y="15" width="90" height="30" rx="6" fill="{fill}"/>')
        parts.append(f'<text x="{x}" y="35" text-anchor="middle" fill="#fff" font-size="12">{a}</text>')
        parts.append(f'<line x1="{x}" y1="45" x2="{x}" y2="{height-15}" stroke="#999" stroke-dasharray="4"/>')
    y = 75
    for fr, to, msg in messages:
        x1, x2 = xs[fr], xs[to]
        parts.append(f'<line x1="{x1}" y1="{y}" x2="{x2}" y2="{y}" stroke="#222" stroke-width="1.5" marker-end="url(#arr)"/>')
        parts.append(f'<text x="{(x1+x2)/2}" y="{y-7}" text-anchor="middle" font-size="11">{msg}</text>')
        y += 38
    svg = f'<svg viewBox="0 0 {width} {height}" xmlns="http://www.w3.org/2000/svg">{"".join(parts)}</svg>'
    return fig(svg, caption)


def wireframe(title, items, tabs):
    nav = "".join(f"<span>{t}</span>" for t in tabs)
    body = "".join(f"<div class='badge'>{i}</div>" for i in items)
    return f"<div class='wire'><div class='bar'>{title}</div><div class='body'>{body}</div><div class='nav'>{nav}</div></div>"


USE_CASES = [
    ("تسجيل الدخول", "جميع الأدوار", "وجود حساب منشأ من المديرة",
     "فتح التطبيق ← إدخال البيانات ← POST /auth/login ← استلام التوكن ← التوجيه حسب الدور",
     "بيانات خاطئة أو حساب غير نشط ← رسالة خطأ عربية", "الدخول للواجهة الخاصة بالدور"),
    ("إدارة الحسابات", "المديرة", "تسجيل دخول المديرة",
     "إنشاء/تعديل/تعطيل معلمة أو ولي أمر وربط الأطفال", "بيانات ناقصة أو اسم مستخدم مكرر", "ظهور الحساب في القوائم"),
    ("الموافقة على الصور", "المديرة", "صور بحالة pending",
     "عرض الصور المعلقة ← موافقة/رفض ← تحديث الحالة", "رفض الصورة", "ظهور الصورة لولي الأمر مع إشعار"),
    ("إدارة التقويم والبانرات", "المديرة", "صلاحية مديرة",
     "إضافة/تعديل أحداث وبانرات", "حقول غير مكتملة", "عرض المحتوى للمستخدمين"),
    ("إدارة الملصقات والمستويات", "المديرة", "صلاحية مديرة",
     "إدارة sticker_levels والملصقات", "تعطيل مستوى مستخدم", "استخدام الملصقات في التحفيز"),
    ("تسجيل الحضور", "المعلمة", "معلمة مرتبطة بطلاب",
     "اختيار الطالب ← check-in/out ← حفظ السجل", "طالب غير مرتبط", "تحديث ملخص ولي الأمر"),
    ("تأكيد الوجبات", "المعلمة / ولي الأمر", "سجل يومي للطفل",
     "تأكيد الوجبة وحفظ MealRecord", "لا يوجد سجل", "تحديث حالة الوجبة"),
    ("رفع صور الألبوم", "المعلمة", "تسجيل دخول المعلمة",
     "اختيار صورة ← رفع ← حالة pending", "نوع ملف غير مدعوم", "انتظار موافقة المديرة"),
    ("الواجبات المنزلية", "المعلمة / ولي الأمر", "طالب مرتبط",
     "إنشاء واجب ← متابعة/رفع ← تقييم/AI", "ملف غير صالح", "حفظ الواجب والتقييم"),
    ("بدء بث مباشر", "المعلمة", "مفاتيح Agora مضبوطة",
     "POST /live/start ← قناة وتوكن ← بدء البث", "بث نشط أو مفاتيح ناقصة", "إشعار أولياء الأمور"),
    ("مشاهدة البث", "ولي الأمر", "بث نشط لمعلمة الطفل",
     "فتح البث ← join ← استلام توكن", "لا يوجد بث نشط", "عرض الفيديو"),
    ("الدردشة", "معلمة ↔ ولي أمر", "ارتباط بنفس الطفل",
     "فتح محادثة ← إرسال نص/مرفق", "غير مصرح / شبكة", "حفظ الرسالة"),
    ("متابعة الطفل", "ولي أمر", "أطفال مرتبطون",
     "عرض ملخص الحضور والصور والواجبات", "لا أطفال ← رسالة فارغة", "التنقل للتفاصيل"),
]


def use_cases_html():
    parts = []
    for i, (name, actor, pre, main, alt, post) in enumerate(USE_CASES, 1):
        parts.append(f"""
<div class="uc-box">
<h4>{i}) توثيق حالة الاستخدام: {name}</h4>
<ul>
<li><strong>الممثل الأساسي:</strong> {actor}</li>
<li><strong>المتطلب السابق:</strong> {pre}</li>
<li><strong>خطوات العمل الرئيسية:</strong> {main}</li>
<li><strong>المسار البديل:</strong> {alt}</li>
<li><strong>العمليات اللاحقة:</strong> {post}</li>
</ul>
</div>""")
    return "\n".join(parts)


def build() -> str:
    return f"""<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1"/>
<title>Kiddy Link — مشروع تخرج كامل — جامعة القدس المفتوحة</title>
<style>{CSS}</style>
</head>
<body>

<section class="cover">
  <div>بسم الله الرحمن الرحيم</div>
  <div class="uni">جامعة القدس المفتوحة</div>
  <div>فرع دورا / [الفرع]</div>
  <div>كلية التكنولوجيا والعلوم التطبيقية</div>
  <div>تخصص أنظمة المعلومات الحاسوبية</div>
  <div class="proj-title">Kiddy Link</div>
  <div class="subtitle">كيدي لينك — ربط الروضة بالبيت</div>
  <div class="subtitle">Connecting Home &amp; Kindergarten</div>
  <p class="muted">تطبيق موبايل يربط روضة أطفال واحدة بأولياء الأمور</p>
  <p style="margin-top:1.5em"><strong>إعداد:</strong><br>[اسم الطالب/ة الرباعي]</p>
  <p><strong>إشراف:</strong><br>[اسم المشرف/ة]</p>
  <p class="muted" style="margin-top:2em">قُدّم هذا المشروع استكمالًا لمتطلبات الحصول على درجة البكالوريوس<br>في تخصص أنظمة المعلومات الحاسوبية — العام 2026</p>
</section>

<section class="page-break"><h1>الملخص</h1>
<p>يتلخص هذا المشروع في بناء تطبيق موبايل باسم <strong>Kiddy Link</strong> يهدف إلى ربط روضة أطفال واحدة بأولياء الأمور رقميًا، بما يسهّل متابعة الأطفال يوميًا ويعزّز التواصل بين البيت والروضة ضمن قناة رسمية وآمنة.</p>
<ul>
<li><strong>مديرة الروضة:</strong> إدارة الحسابات، الموافقات، التقويم، البانرات، الإشعارات، والملصقات.</li>
<li><strong>المعلمة:</strong> الحضور، الوجبات، الصور، الواجبات، البث المباشر، والدردشة مع أولياء الأمور.</li>
<li><strong>ولي الأمر:</strong> متابعة أطفاله ومشاهدة البث والدردشة مع المعلمة.</li>
</ul>
<table>
<tr><th>البند</th><th>التفاصيل</th></tr>
<tr><td>النطاق</td><td>روضة واحدة — عربي RTL — بدون دفع أو تسجيل ذاتي</td></tr>
<tr><td>الموبايل</td><td>Flutter (Dart)</td></tr>
<tr><td>الخادم</td><td>NestJS + Prisma</td></tr>
<tr><td>قاعدة البيانات</td><td>MySQL / MariaDB</td></tr>
<tr><td>خدمات</td><td>Redis، Storage، Agora، OpenAI</td></tr>
<tr><td>الإنتاج</td><td class="mono">https://kiddylink.baitpait.com/api</td></tr>
</table>
</section>

<section class="page-break"><h1>الإهداء</h1>
<p>إلى الأهل الكرام، وإلى المشرف والأساتذة الأفاضل، وإلى كل من آمن بفكرة ربط البيت بالروضة رقميًا.</p>
</section>

<section class="page-break"><h1>فهرس المحتويات</h1>
<ol>
<li>الملخص</li><li>الإهداء</li><li>المقدمة</li><li>المكونات الرئيسية</li>
<li>الفصل الأول: الاستهلال</li><li>الفصل الثاني: التفصيل والتحليل</li>
<li>الفصل الثالث: البناء والتصميم</li><li>الفصل الرابع: الانتقال والتنفيذ</li>
<li>المصادر والمراجع</li>
</ol>
<h2>فهرس الأشكال</h2>
<ul class="small">
<li>1.0 المعمار العام — 1.1 RUP — 1.2 جانت</li>
<li>3.1 المتفاعلون — 3.2 إلى 3.5 حالات الاستخدام</li>
<li>3.6 الأصناف — 3.9+ الأنشطة — 3.25+ الشاشات — 3.38+ التسلسلية</li>
</ul>
</section>

<section class="page-break"><h1>المقدمة</h1>
<p>مع توسّع التطبيقات الذكية، أصبحت روضات الأطفال بحاجة إلى قناة تواصل رقمية موثوقة تربط الإدارة والمعلمات بأولياء الأمور، بعيدًا عن تشتت الرسائل عبر واتساب. من هنا جاءت فكرة <strong>Kiddy Link</strong>: تطبيق موبايل عربي بالكامل بواجهات حسب الدور، مع خادم مركزي للبيانات والصلاحيات والإشعارات والبث.</p>
</section>

<section><h1>المكونات الرئيسية للمشروع</h1>
<p>أربعة فصول وفق RUP: الاستهلال، التفصيل والتحليل، البناء والتصميم، ثم الانتقال والتنفيذ.</p></section>

<section class="page-break"><h1>الفصل الأول: مرحلة الاستهلال</h1>
<h2>ملخص المشروع</h2>
<p>Kiddy Link تطبيق موبايل يربط روضة واحدة بأولياء الأمور عبر ثلاث واجهات. الحسابات تُنشأ بواسطة المديرة فقط. تم بناء API ونشره وتشغيل تجربة APK.</p>
{svg_arch()}
<h2>نبذة عن النظام</h2>
<p>Client–Server: Flutter ↔ NestJS عبر HTTPS/WS، MySQL للبيانات، Redis مساعد، تخزين ملفات، Agora للبث، OpenAI لتحليل الواجبات من الخادم فقط.</p>
<h2>منهجية البحث (RUP)</h2>
{svg_rup()}
<ul>
<li><strong>Inception:</strong> الفكرة والنطاق والأهداف.</li>
<li><strong>Elaboration:</strong> المشكلة والمتطلبات والجدوى.</li>
<li><strong>Construction:</strong> UML والبناء.</li>
<li><strong>Transition:</strong> الاختبار والنشر.</li>
</ul>
<h2>أهداف المشروع</h2>
<ul>
<li>قناة رقمية موثوقة بين الروضة والبيت.</li>
<li>إدارة مركزية للصلاحيات والموافقات.</li>
<li>توثيق يومي للمعلمة ومتابعة لولي الأمر.</li>
<li>نشر API وإصدار APK للتجربة.</li>
</ul>
<table>
<tr><th>المرحلة</th><th>المدة</th><th>المخرجات</th></tr>
<tr><td>الاستهلال</td><td>أسبوعان</td><td>نطاق وأهداف</td></tr>
<tr><td>التفصيل</td><td>3 أسابيع</td><td>تحليل وجدوى</td></tr>
<tr><td>البناء</td><td>8–10 أسابيع</td><td>UML + كود</td></tr>
<tr><td>الانتقال</td><td>2–3 أسابيع</td><td>اختبار ونشر</td></tr>
</table>
<p class="caption">جدول 1.1 — الجدول الزمني التقديري</p>
{svg_gantt()}
</section>

<section class="page-break"><h1>الفصل الثاني: مرحلة التفصيل والتحليل</h1>
<h2>أهمية المشروع</h2>
<ul>
<li>تنظيم التواصل بدل القنوات العشوائية.</li>
<li>توثيق يوم الطفل في مكان واحد.</li>
<li>رقابة المديرة على الصور والصلاحيات.</li>
<li>شفافية لولي الأمر.</li>
</ul>
<h2>مشكلة البحث</h2>
<p>صعوبة إدارة التواصل اليومي بشكل منظم وآمن، وضياع المعلومات عبر المحادثات الجماعية، والحاجة إلى نظام رقمي لروضة واحدة بتطبيق عربي للأدوار الثلاثة.</p>
<h2>أساليب جمع البيانات</h2>
<ul>
<li>مقابلات مع مديرة/معلمة/ولي أمر.</li>
<li>ملاحظة التواصل الحالي.</li>
<li>مراجعة DEVELOPER_SPEC ومخطط Prisma.</li>
</ul>
<h2>الجدوى</h2>
<ul>
<li><strong>فنية:</strong> Flutter + NestJS + MySQL + Redis + Agora.</li>
<li><strong>مادية:</strong> سيرفر + نطاق + SSL، وعائد تنظيمي تربوي.</li>
</ul>
<table>
<tr><th>الكيان</th><th>الوصف</th><th>حقول</th></tr>
<tr><td>User</td><td>حسابات</td><td>username, role, is_active</td></tr>
<tr><td>Student</td><td>طفل</td><td>name, links</td></tr>
<tr><td>AttendanceRecord</td><td>حضور</td><td>student_id, type</td></tr>
<tr><td>Photo</td><td>صور</td><td>url, status</td></tr>
<tr><td>Homework</td><td>واجبات</td><td>title, grade</td></tr>
<tr><td>Conversation/Message</td><td>دردشة</td><td>content</td></tr>
<tr><td>LiveStream</td><td>بث</td><td>channel, status</td></tr>
<tr><td>Notification</td><td>إشعارات</td><td>title, category</td></tr>
</table>
<p class="caption">جدول 2.2 — قاموس بيانات مبسّط</p>
</section>

<section class="page-break"><h1>الفصل الثالث: مرحلة البناء والتصميم</h1>
{svg_actors()}
{svg_usecase_all()}
{svg_usecase_role("حالات الاستخدام — المديرة", "الشكل 3.3 — المديرة", "#4A90D9",
["إدارة حسابات", "موافقة صور", "تقويم", "بانرات", "إشعارات", "ملصقات", "دخول"])}
{svg_usecase_role("حالات الاستخدام — المعلمة", "الشكل 3.4 — المعلمة", "#2a9d8f",
["حضور", "وجبات", "رفع صور", "واجبات", "بث مباشر", "دردشة", "دخول"])}
{svg_usecase_role("حالات الاستخدام — ولي الأمر", "الشكل 3.5 — ولي الأمر", "#e76f51",
["متابعة طفل", "صور معتمدة", "واجبات", "حضور", "مشاهدة بث", "دردشة", "دخول"])}

<h2>توثيق حالات الاستخدام</h2>
{use_cases_html()}

<h2>مخططات الأنشطة</h2>
{svg_activity("الشكل 3.9 — أنشطة تسجيل الدخول", ["فتح شاشة الدخول", "إدخال البيانات", "إرسال /auth/login", "؟نجاح؟", "حفظ التوكن", "التوجيه حسب الدور"])}
{svg_activity("الشكل 3.10 — أنشطة موافقة صورة", ["فتح الموافقات", "عرض الصورة", "موافقة أو رفض", "تحديث الحالة", "إشعار عند الموافقة"], "#2a9d8f")}
{svg_activity("الشكل 3.11 — أنشطة تسجيل حضور", ["فتح قائمة الطلاب", "اختيار طالب", "check-in/out", "حفظ السجل", "تحديث ملخص ولي الأمر"], "#e9c46a")}
{svg_activity("الشكل 3.12 — أنشطة بدء بث", ["طلب بدء البث", "التحقق من الصلاحية", "إنشاء قناة Agora", "توليد توكن", "إشعار أولياء الأمور"], "#e76f51")}
{svg_activity("الشكل 3.13 — أنشطة الدردشة", ["فتح المحادثة", "كتابة رسالة", "إرسال REST/WS", "؟نجاح؟", "عرض الرسالة"], "#6d597a")}

{svg_class()}

<h2>تصميم الشاشات</h2>
<table>
<tr><th>الشاشة</th><th>الدور</th><th>الوظيفة</th><th>مصدر البيانات</th></tr>
<tr><td>تسجيل الدخول</td><td>الكل</td><td>مصادقة</td><td>/auth/login</td></tr>
<tr><td>لوحة المديرة</td><td>مديرة</td><td>إحصائيات</td><td>dashboard stats</td></tr>
<tr><td>الحسابات</td><td>مديرة</td><td>CRUD</td><td>teachers/parents/students</td></tr>
<tr><td>الموافقات</td><td>مديرة</td><td>اعتماد صور</td><td>pending photos</td></tr>
<tr><td>طلاب/يومي</td><td>معلمة</td><td>حضور ووجبات وصور</td><td>attendance/meals/photos</td></tr>
<tr><td>رئيسية ولي الأمر</td><td>ولي أمر</td><td>ملخص طفل</td><td>children + summary</td></tr>
<tr><td>الصور/التعلّم</td><td>ولي أمر</td><td>ألبوم وواجبات</td><td>photos/homeworks</td></tr>
<tr><td>الدردشة</td><td>معلمة/ولي أمر</td><td>محادثات</td><td>conversations</td></tr>
<tr><td>البث</td><td>معلمة/ولي أمر</td><td>Agora</td><td>live/start|join</td></tr>
</table>
<p class="caption">جدول 3.1 — توثيق الشاشات</p>
<div class="center">
{wireframe("تسجيل الدخول", ["اسم المستخدم", "كلمة المرور", "زر دخول"], ["—"])}
{wireframe("لوحة المديرة", ["إحصائيات", "معلمات", "طلاب", "صور معلّقة"], ["رئيسية", "حسابات", "موافقات", "دردشة", "المزيد"])}
{wireframe("المعلمة", ["طلاب الصف", "حضور اليوم", "اختصارات"], ["رئيسية", "طلاب", "يومي", "دردشة", "المزيد"])}
{wireframe("ولي الأمر", ["اختيار طفل", "ملخص حضور", "صور/واجبات"], ["رئيسية", "صور", "تعلّم", "دردشة", "المزيد"])}
</div>
<p class="caption">الأشكال 3.25–3.28 — إطارات سلكية للشاشات الرئيسية</p>

<h2>المخططات التسلسلية</h2>
{svg_sequence("الشكل 3.38 — تسلسلي تفاؤلي لتسجيل الدخول", ["التطبيق", "API", "DB"],
[(0,1,"POST /auth/login"), (1,2,"تحقق المستخدم"), (2,1,"OK"), (1,0,"JWT")])}
{svg_sequence("الشكل 3.39 — تسلسلي تشاؤمي لتسجيل الدخول", ["التطبيق", "API", "DB"],
[(0,1,"POST /auth/login"), (1,2,"بحث"), (2,1,"فشل"), (1,0,"401")], True)}
{svg_sequence("الشكل 3.40 — تفاؤلي لموافقة صورة", ["مديرة", "API", "DB", "ولي أمر"],
[(0,1,"اعتماد"), (1,2,"approved"), (2,1,"OK"), (1,3,"إشعار")])}
{svg_sequence("الشكل 3.41 — تشاؤمي لموافقة صورة", ["مديرة", "API", "DB"],
[(0,1,"اعتماد"), (1,2,"غير موجودة"), (2,1,"404"), (1,0,"خطأ")], True)}
{svg_sequence("الشكل 3.42 — تفاؤلي لتسجيل حضور", ["معلمة", "API", "DB"],
[(0,1,"POST /attendance"), (1,2,"insert"), (2,1,"OK"), (1,0,"نجاح")])}
{svg_sequence("الشكل 3.43 — تفاؤلي لبدء بث", ["معلمة", "API", "Agora", "ولي أمر"],
[(0,1,"/live/start"), (1,2,"token"), (2,1,"OK"), (1,3,"إشعار"), (1,0,"channel")])}
{svg_sequence("الشكل 3.44 — تفاؤلي للدردشة", ["مرسل", "API/WS", "DB", "مستقبل"],
[(0,1,"send message"), (1,2,"save"), (2,1,"OK"), (1,3,"دفع/WS")])}
{svg_sequence("الشكل 3.45 — تشاؤمي للدردشة", ["مرسل", "API", "DB"],
[(0,1,"send"), (1,2,"غير مصرح"), (2,1,"403"), (1,0,"خطأ")], True)}
</section>

<section class="page-break"><h1>الفصل الرابع: مرحلة الانتقال والتنفيذ</h1>
<h2>الاختبار</h2>
<p>اختبار الدخول حسب الدور، الحسابات، الحضور، الوجبات، الصور والموافقة، الواجبات، الدردشة، والبث، مع حالات الخطأ والفراغ.</p>
<h2>تطوير النظام</h2>
<p>بناء NestJS/Prisma وFlutter، ثم إصلاح الملاحظات وربط الإنتاج (PM2 على 3010 + Apache Proxy).</p>
<h2>الاختبار النهائي</h2>
<ul>
<li>وحدات → ترابط → تكامل → نظام كامل عبر APK الإنتاج.</li>
</ul>
<h2>النتائج</h2>
<ul>
<li>تطبيق عربي متعدد الأدوار.</li>
<li>API على <span class="mono">https://kiddylink.baitpait.com/api</span>.</li>
<li>متابعة يومية وتواصل وبث.</li>
<li>APK للتجربة.</li>
</ul>
<h2>المشاكل والتوصيات</h2>
<ul>
<li>تعقيد التكامل، حجم APK، استكمال FCM، WebSocket عبر Proxy.</li>
<li>توصيات: FCM، proxy_wstunnel، توقيع Release، اختبارات آلية، تقارير أغنى.</li>
</ul>
<h2>المصادر والمراجع</h2>
<ul>
<li>جامعة القدس المفتوحة — هندسة البرمجيات / تحليل الأنظمة / قواعد البيانات</li>
<li>Flutter / NestJS / Prisma / Agora Docs</li>
<li>https://kiddylink.baitpait.com</li>
</ul>
</section>

<section class="page-break center">
<h1>تم بحمد الله</h1>
<p class="muted">Kiddy Link — Connecting Home &amp; Kindergarten</p>
<div class="note" style="text-align:right">
<strong>للتحويل إلى Word:</strong> افتح الملف في Microsoft Word (ملف ← فتح ← HTML)، أو اطبع PDF من المتصفح. استبدل [اسم الطالب] و[المشرف] و[الفرع].
</div>
</section>
</body></html>
"""


def main():
    html = build()
    OUT.write_text(html, encoding="utf-8")
    DESK.write_text(html, encoding="utf-8")
    print(f"WROTE {OUT} ({OUT.stat().st_size} bytes)")
    print(f"DESK  {DESK} ({DESK.stat().st_size} bytes)")


if __name__ == "__main__":
    main()
