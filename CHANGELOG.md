# CHANGELOG — Kiddy Link

All notable changes documented per phase.

---

## [Phase 1] — 2026-07-13 — Foundation ✅

### Added

**Infrastructure**
- Monorepo structure (`mobile/`, `backend/`, `docs/`)
- `docker-compose.yml` — MySQL 8, Redis 7, MinIO, NestJS API
- `.env.example`, `.gitignore`, `.cursorrules`
- `backend/Dockerfile` (multi-stage)

**Backend**
- NestJS 10 scaffold with TypeScript strict mode
- Prisma schema — all 24 tables from DEVELOPER_SPEC §6
- Initial migration `20250713120000_init`
- Seed: admin user + 3 sticker levels + 3 sample stickers
- Auth module: login, refresh, logout, me
- JWT: access 15m, refresh 7d, bcrypt passwords
- Global guards: JwtAuthGuard, RolesGuard
- Admin module: CRUD teachers, parents, students
- Link endpoints: parent_student, teacher_student
- Soft delete via `is_active`
- Swagger at `/api/docs`

**Mobile**
- Flutter scaffold with Arabic RTL
- Theme from BRAND_IDENTITY (Cairo font, Kiddy colors)
- Login screen with FormKey validation
- AuthProvider + secure storage
- ApiClient (HTTP)
- go_router with role-based redirect
- Admin / Teacher / Parent home screens (placeholders)

**Documentation**
- `docs/` — full project documentation (8 files)
- Updated `README.md`

### Not included (deferred)

- Flutter admin CRUD screens (APIs ready)
- `android/` / `ios/` folders (requires `flutter create`)
- Docker/Flutter not verified on dev machine (not in PATH)

---

## [Phase 2] — 2026-07-13 — Daily Content ✅

### Added

**Backend**
- StorageModule (MinIO upload)
- PhotosModule — upload, list, admin approve/reject
- AttendanceModule — record + today + history + push
- MealsModule — teacher/parent confirm + history + push
- NotificationsModule — FCM PushService, device register, list
- ContentModule — public banners + calendar
- Admin: photos approval, banners CRUD, calendar CRUD, send notification
- StudentsModule — my-class, my-children endpoints
- UsersService — teacher/parent verification helpers

**Mobile**
- Teacher screens: upload photo, attendance, meals
- Parent screens: photos album, attendance, meals + child switcher
- Admin screen: pending photos approval
- ApiClient: multipart upload, PUT, list helpers
- image_picker dependency

**Documentation**
- docs/API-PHASE2.md
- Updated PHASES.md, docs/README.md

### Notes
- FCM works when credentials set; otherwise DB notifications + log stub
- MinIO bucket auto-created on API start

---

## [Phase 2] — Planned (superseded — completed above)

- Photo album + admin approval
- Manual attendance + Push
- Meals (dual confirm) + Push
- Calendar + banners

---

## [Phase 3] — 2026-07-13 — Homework + Stickers + AI ✅

### Added

**Backend**
- AdminStickersController — levels + stickers CRUD
- HomeworkModule — full workflow with push notifications
- AiService — OpenAI integration with rule-based fallback
- Student stickers endpoints (GET/PUT/DELETE)
- Internal AI endpoint for admin testing

**Mobile**
- AdminStickersScreen — manage levels and stickers
- TeacherHomeworkScreen — create + grade homework
- ParentHomeworkScreen — view + confirm
- ParentStickersScreen — earned stickers grid

**Documentation**
- docs/API-PHASE3.md

---

## [Phase 3] — Planned (superseded — completed above)

- Sticker management APIs
- Homework flow + OpenAI integration

---

## [Phase 4] — 2026-07-13 — Chat WebSocket ✅

### Added

**Backend**
- ChatModule — conversations, messages, attachments
- ChatGateway — WebSocket `/ws/chat` with JWT
- MinIO chat folder for image attachments
- Push on new messages

**Mobile**
- ChatListScreen, ChatRoomScreen
- WebSocket real-time + image upload
- web_socket_channel dependency

**Documentation**
- docs/API-PHASE4.md

---

## [Phase 4] — Planned (superseded — completed above)

- Chat WebSocket
- Message attachments (MinIO)

---

## [Phase 5] — 2026-07-13 — Agora Live Streaming ✅

### Added

**Backend**
- LiveModule — start/end/active/join endpoints
- Agora RTC token generation (publisher + audience)
- Push notification when live starts
- Demo mode without Agora credentials

**Mobile**
- TeacherLiveScreen — broadcaster
- ParentLiveScreen — audience viewer
- agora_rtc_engine + permission_handler

**Documentation**
- docs/API-PHASE5.md

---

## [Phase 5] — Planned (superseded — completed above)

- Agora live streaming

---

## [Phase 6] — 2026-07-13 — Launch Prep ✅

### Added

**Mobile**
- AdminBannersScreen — CRUD banners
- AdminCalendarScreen — CRUD calendar events
- AdminNotifyScreen — send push to target groups
- ParentCalendarScreen — view events
- ContentRepository + ApiClient.delete()
- Admin/Parent home menu links

**Documentation**
- docs/API-PHASE6.md
- docs/DEPLOYMENT.md — server deploy guide (Palestine)
- docs/PROJECT_SUMMARY.md
- scripts/verify.ps1

### Notes

- Full runtime test requires Docker Desktop + Flutter SDK on dev machine

---

## [Quality & Admin CRUD] — 2026-07-14 ✅

### Mobile
- AdminTeachersScreen, AdminParentsScreen, AdminStudentsScreen — full CRUD + link
- AdminRepository — all `/api/admin/*` endpoints
- Removed silent "API/Swagger" menu tiles
- AdminBannersScreen — error + retry states

### Cursor Rules
- `.cursor/rules/dynamic-interactive.mdc` — no static/dead UI
- `.cursor/rules/programmer-mentor.mdc` — explain, test, gate next step

### Documentation
- docs/ADMIN_CRUD.md, docs/DEVELOPMENT_WORKFLOW.md
- scripts/notify-test-failure.ps1

### Environment (HP machine)

- Project path: `E:\Eman Project\`
- Flutter 3.44.6 at `C:\src\flutter`
- XAMPP MySQL on port 3306 (database `kiddy_link`)
- API runs via `npm run start:dev` (no Docker required for dev)
- Flutter web on http://localhost:8081

### Backend fixes

- Import `UsersModule` in Photos, Attendance, Meals, Homework, Chat, Live, Content modules
- `StorageService`: graceful fallback when MinIO unavailable

### Mobile fixes

- Fix blank screen: single GoRouter instance in StatefulWidget
- `ApiConstants`: use `localhost` for web (`kIsWeb`)
- Loading screen during auth init
- Fix import paths, teacher home icon, homework screen syntax
- `flutter create` — android/ios/web folders added

### Documentation

- `docs/FULL_DOCUMENTATION.md` — complete final documentation
- `docs/SETUP_WINDOWS.md` — Windows guide
- `scripts/start-local.ps1` — one-click local start
- `scripts/install-and-run-admin.ps1` — Docker admin install

---

## [Phase 2 Testing + Local Storage] — 2026-07-15 ✅

### Backend
- `StorageService`: local fallback `backend/uploads/` when `MINIO_ENABLED=false`
- `main.ts`: serve `/uploads/` statically
- Photo upload fix for dev without MinIO

### Scripts
- `scripts/restart-api.ps1` — clean API restart (fixes EADDRINUSE)
- `scripts/start-all.ps1` — smart start (detects running API)
- `scripts/spa_server.py` — SPA fallback for Flutter web routes
- `scripts/start-web-fast.ps1` — web on port **8082**
- `scripts/test-phase2.ps1` — automated Phase 2 API tests

### Mobile
- Dynamic API host for web (`api_host_web.dart`)
- Admin dashboard restructure per DEVELOPER_SPEC §8.2 + §12
- Teacher/Parent UI restructure per §8.3 / §8.4
- `admin_accounts_screen.dart`, split sticker screens
- `docs/ADMIN_CRUD.md`, `docs/TEACHER_PARENT_UI.md`
- `docs/PHASE2_TEST.md`

### Test results
- `test-phase2.ps1`: ALL PASSED (photos via curl multipart)

---

## [Phase 3 Testing + Fixes] — 2026-07-15 ✅

### Backend fixes
- Grade flow: AI runs before status → `graded` (atomic UX)
- `GET /homeworks/:id/sticker` — authorization (parent/teacher/admin)
- `GET /stickers/active` — teacher can list active stickers
- `ai.service.ts` — NestJS exceptions instead of generic Error
- Sticker update validates active sticker

### Mobile
- `homework_repository.dart` — unified API layer
- Teacher homework: validation, error states, pull-to-refresh
- Parent homework: show grade, note, sticker after grading
- Parent stickers: error states, homework source, refresh
- Teacher student profile: edit/delete stickers (§4.4)

### Scripts & docs
- `scripts/test-phase3.ps1` — 16 automated tests
- `docs/PHASE3_TEST.md`, updated `docs/API-PHASE3.md`
- `docs/CHECKPOINT.md` — session checkpoint (read first on return)
- Updated `docs/PHASES.md`, `docs/PROJECT_SUMMARY.md`, `docs/README.md`

### Test accounts
- Phase 2: `p2teacher` / `p2parent` / Phase2 Student
- Phase 3: `p3teacher` / `p3parent` / Phase3 Student
- Password: `Test@123456`

### Test results
- `test-phase3.ps1`: ALL PASSED (16/16)
- Flutter web build: success (`build/web`)

### Known issues (for next session)
- No Git repository initialized
- Group homework (multiple students) not implemented
- Sticker icon upload (URL text only)
- MinIO disabled — local uploads for dev
- See `docs/CHECKPOINT.md` for full list

---

## [Phases 4–6 + Fixes] — 2026-07-16/17 — Complete Local Testing ✅

### Phases 4–6
- Phase 4: chat REST + WebSocket tests (`test-phase4.ps1`, `ws-chat-test.js`)
- Phase 5: Agora live API tests (`test-phase5.ps1`, demo mode)
- Phase 6: pre-launch check (`test-phase6.ps1`, `test-all.ps1`)
- Docs: `PHASE4_TEST.md`, `PHASE5_TEST.md`, `PHASE6_TEST.md`

### Notifications fix
- `push.service.ts`: broadcast creates per-user notification records
- `notifications.service.ts`: `markRead` works for all notifications
- Flutter: bell count syncs after read; removed local-only broadcast tracking

### Photos fix (Web)
- CORS headers on `/uploads/` static files
- Storage returns relative paths `/uploads/photos/...`
- `photos.service.ts`: normalize legacy absolute URLs on read
- `media_url_utils.dart`: resolve URLs for current browser host
- Parent album: refresh, error state, tap-to-preview
- Teacher upload: shared MIME utils, JWT retry on multipart

### Parent UI
- `test-parent-ui.ps1` — all parent screens API check

### Test accounts (added)
- Phase 4: `p4teacher` / `p4parent`
- Phase 5: `p5teacher` / `p5parent`

### Documentation
- `docs/CHECKPOINT.md` — updated 17 Jul 2026
- `docs/START_TOMORROW.md` — quick start guide
- `docs/ACCOUNTS.md` — all credentials
- `docs/PHOTOS_NOTIFICATIONS_FIX.md` — fix details

### Test results
- All phase scripts: ALL PASSED
- `test-phase6.ps1`: READY FOR LAUNCH PREP
- Photos API + CORS: verified

### Remaining for production
- VPS deploy (`DEPLOYMENT.md`)
- FCM push keys
- Agora on real mobile devices
- Replace placeholder `logo.png` with official brand asset

---

## [Brand Identity v1.0] — 2026-07-19 — UI Theme ✅

### Added

**Theme (`mobile/lib/core/theme/`)**
- `app_colors.dart` — full palette + `roleAccent()`
- `app_theme.dart` — `buildAppTheme()`, `forRole()`, Cairo via Google Fonts
- `brand_gradients.dart` — splash + logo gradients
- `app_spacing.dart` — xs … xxl tokens

**Widgets**
- `brand_logo.dart` — loads `assets/brand/logo.png`
- `splash_screen.dart` — gradient + logo + blue loader
- `role_badge.dart` — admin / teacher / parent badge

**Screens**
- Login redesigned per BRAND_IDENTITY §5.2
- Admin / Teacher / Parent home: `Theme(forRole)` + RoleBadge on welcome card
- `main.dart`: Splash during auth init

**Assets**
- `mobile/assets/brand/logo.png` (placeholder)
- `pubspec.yaml`: brand asset entry

### Documentation
- `docs/BRAND_IMPLEMENTATION.md` — full implementation reference
- Updated `CHECKPOINT.md`, `PROJECT_SUMMARY.md`, `README.md`, `START_TOMORROW.md`
- Fixed outdated Web port 8081 → 8082 in docs

### Test results
- `flutter build web --release`: success
- Web served at http://localhost:8082/login

### Notes
- English logo text only in logo image (not duplicate Flutter text on login)
- Role AppBar colors: admin=blue, teacher=green, parent=orange
