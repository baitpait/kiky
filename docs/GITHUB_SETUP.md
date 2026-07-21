# ربط GitHub — Kiddy Link

> **21 يوليو 2026**

**GitHub username:** `nahlahalbostnje`  
**Repo URL (after push):** https://github.com/nahlahalbostnje/kiddy-link

---

- حساب GitHub: [github.com/signup](https://github.com/signup)
- GitHub CLI مُثبّت ✅ (`gh` — تم تثبيته عبر winget)

---

## خطوة واحدة (PowerShell)

```powershell
E:\Eman Project\scripts\setup-github.ps1
```

1. يفتح المتصفح لتسجيل الدخول في GitHub (مرة واحدة)
2. ينشئ repo خاص: **`kiddy-link`**
3. يرفع كل الكود (commitين: notifications + Agora live)

---

## يدوياً (بدون سكربت)

```powershell
cd "E:\Eman Project"
gh auth login
gh repo create kiddy-link --private --source=. --remote=origin --push
```

---

## بعد الرفع

```powershell
gh repo view --web
```

---

## أمان

- ملف `.env` **مُستثنى** من Git (`.gitignore`) — لا تُرفع كلمات السر
- استخدم `.env.example` كمرجع

---

## Commits المحفوظة محلياً

| Commit | المحتوى |
|--------|---------|
| `e54b0b5` | درdشة + إشعارات |
| `53e0d5c` | بث Agora حقيقي + توثيق |
