# Doctors Hub Patient App (Flutter) — Implementation Plan for Agentic Build

Source of truth for this build:

- **Design:** "Doctors Hub / Patient app v2" — https://claude.ai/artifact/2VJAmF6MhXPryKgWwesXPC (iOS + Android frames, interactive prototype)
- **Backend:** Django 5 + DRF, repo `JunaeidAhmad/doctors_hub`, folder `doctors_hub_backend/`. OpenAPI schema at `GET /api/schema/`, Swagger at `/api/docs/`. Prod base URL `https://doctors-hub.onrender.com/api`.
- **Scope:** patient-facing mobile app only. No admin, doctor, or facility-staff features. No backend changes except the optional ones listed in §4.

The plan is split into phases an agent can run one at a time. Each phase lists its tasks, the files it touches, and a **Done when** checklist the agent must verify before stopping.

---

## 1. Product summary (what the design specifies)

Book doctors and lab tests across Bangladesh **without an account**. Patient enters name + BD mobile number at checkout; bookings are saved on the device and texted to the patient.

Screens (from the prototype's navigation stack):

| Route | Screen | Reached from |
|---|---|---|
| `/` | **Home** — 3-way search card (Doctors / Diagnostics / Hospitals tabs, category dropdown, division dropdown, red search button), Specialties grid (2 col, numbered 01–08), Popular doctors (horizontal cards), Diagnostic test categories (3 col), Hospitals (category chips + 3 rows) | Tab bar |
| `/doctors` | **Find a doctor** — kicker "N DOCTORS · SPECIALTY", specialty dropdown, search input with Clear, removable filter chips (division, "At <hospital>"), doctor rows (photo, name, specialty · degree, primary chamber, "+ N more chambers", ★ rating, years, "from ৳fee"), empty state | Tab bar, Home |
| `/tests` | **Diagnostics** — test-type dropdown, search, division chip, test cards (category tag, report time, fasting tag, name, description, usual price range, top 2 labs with price + "Home pickup / At lab only", "+ N more labs" toggle) | Tab bar, Home |
| `/hospitals` | **Hospitals** — category dropdown, search, division chip, hospital rows (initials tile, name, category · area, division, doctor count) → opens `/doctors?hospital=<id>` | Home |
| `/doctors/:id` | **Doctor profile** — portrait, specialty kicker, name, degrees, stats row (years / rating+reviews / chambers), About, Chambers list (days · hours · fee). Sticky CTA "Visit fee from ৳X — Book a visit" | Doctor rows/cards |
| `/doctors/:id/book` | **Step 1 of 2: Where and when?** — chamber radio list, 7-day date strip (off-days greyed, "Not at this chamber that day"), slot grid grouped by shift (booked slots struck through). Sticky CTA "Continue" (disabled until slot chosen) | Profile |
| `/doctors/:id/confirm` | **Step 2 of 2: Almost there** — summary (Doctor / When / Where), patient name, `+88` phone with inline validation, payment choice (Pay at counter / Pay now with bKash·Nagad·Card). CTA "Confirm booking" or "Pay ৳X with bKash" | Step 1 |
| `/tests/:testId/labs/:labId/book` | **Book a test** — fasting warning, sample collection (Visit lab / Home pickup, disabled if not offered) + address field, day strip, time windows, then the same patient + payment block | Test card lab row |
| `/success` | **You're booked** — red status bar, booking ref, For / At / When / Pay, contextual note, "See my bookings" / "Back to home". Clears the back stack | After booking |
| `/bookings` | **Bookings** — "N UPCOMING", "Saved on this phone", list with date tile, kind label (DOCTOR VISIT / LAB TEST), title, time · place, pay tag, Cancel; empty state with "Find a doctor" | Tab bar (badge = count) |

Bottom tab bar (Home, Doctors, Tests, Bookings) shows only on the root screens. Tapping a tab resets that stack and its filters.

---

## 2. Design system (extracted from the artifact)

Implement once in `lib/core/theme/`. Every widget reads from these tokens; no hard-coded colours in feature code.

**Colours**

| Token | Hex | Use |
|---|---|---|
| `ink` | `#201E1D` | Text, 2px borders, dark chips, selected tab fills |
| `surface` | `#F3F2F2` | App background, tiles |
| `paper` | `#FFFFFF` | Cards, inputs |
| `accent` | `#EC3013` | Primary CTA, selected date/slot, kickers, success bar |
| `accentHover` / `accentPressed` | `#DD2B0F` / `#AE1800` | Pressed states; `#AE1800` also for links ("See all →") |
| `accentTint` / `accentTint2` / `accentWash` | `#FFE0D9` / `#FFC4B8` / `#FFF2EF` | Tag bg, tile pressed, selected radio row bg |
| `accentDeep` | `#7C1405` | Text on `accentTint` |
| `muted` | `#605D5D` | Secondary text |
| `mutedLight` | `#9B9797` | Disabled text |
| `line` / `lineSoft` | `#BAB6B6` / `#D7D3D3` | Row dividers, disabled borders |
| `fill` / `fillOff` | `#EAE9E9` / `#E2DFDF` | Neutral tags, off-day tiles |
| `ink2` | `#2D2B2B` | Body text on tags |

**Type:** Archivo 400/600/800 for everything; JetBrains Mono 500 for kickers, numbers in grids, and labels like "STEP 1 OF 2". Bundle the fonts as assets (don't fetch at runtime). **Archivo has no Bengali glyphs** — add Noto Sans Bengali (or Hind Siliguri) as `fontFamilyFallback` so Bangla text renders.

Scale used in the design: H1 32/800 tracking −0.025em line-height 1.02–1.05; H2 18/800; body 15; secondary 13; tag 11/600; kicker mono 11/500 uppercase.

**Shape and layout:** zero border radius everywhere. 2px `ink` borders on cards, inputs, and grids. Grids are built as "2px gaps on an ink background" so the lines look like a single rule — implement as a `GridView` inside a `DecoratedBox(color: ink)` with `mainAxisSpacing: 2, crossAxisSpacing: 2`. Horizontal page padding 16. Controls are 48 high (inputs, dropdowns), primary button 52, chips 30–34.

**Shared widgets to build first** (`lib/core/widgets/`): `DhScaffold` (status bar colour switch for success screen), `Kicker`, `InkBorderBox`, `RuleGrid`, `DhDropdown` (square select with ▼), `DhSearchField` (⌕ icon, Clear button), `FilterChipDark` (label + ×), `PrimaryCtaButton` (label left, → right), `StickyCtaBar` (kicker + sub on left, button right, disabled grey `#BAB6B6`), `RadioRow`, `DateStrip`, `SlotGrid`, `PhoneField` (+88 prefix, numeric, 11 digits), `PhotoPlaceholder` (135° striped fill with initials), `EmptyState`, `ErrorState` with retry, `SkeletonRow`.

---

## 3. Architecture and stack

- Flutter stable (3.x), Dart 3, null-safe, Material 3 with a fully custom theme.
- **State:** `flutter_riverpod` + `riverpod_annotation`/`riverpod_generator`.
- **Routing:** `go_router` with a `StatefulShellRoute` for the 4 tabs; booking flow routes are pushed above the shell so the tab bar hides.
- **Network:** `dio` with interceptors: base URL from `--dart-define=API_BASE_URL`, `Accept-Language` (en/bn), timeouts (15s connect / 30s receive; Render cold starts are slow), retry once on timeout for GETs, error mapping to a sealed `AppFailure`.
- **Models:** `freezed` + `json_serializable`. Hand-write DTOs only for the endpoints in §4, check them against `openapi/schema.yaml` (commit a copy fetched from `/api/schema/`). Map DTOs to domain models in the data layer; UI never sees DTOs.
- **Local storage:** `shared_preferences` for locale and last-used patient (name, phone); a small JSON store (or `hive_ce`) for the bookings list.
- **i18n:** `flutter_localizations` + `gen-l10n` with `app_en.arb` and `app_bn.arb`. Show `bn_name` fields from the API when locale is `bn`, falling back to `name`. Bangla digits for numbers and ৳ amounts in `bn` via `intl` `NumberFormat`.
- **Quality:** `very_good_analysis` (or `flutter_lints` strict), `mocktail`, `golden_toolkit`/`alchemist` for goldens, `integration_test`.

Folder layout (feature-first):

```
lib/
  main.dart, app.dart, bootstrap.dart
  core/  theme/ widgets/ network/ l10n/ utils/ (phone, currency, dates) storage/
  features/
    home/        data/ domain/ presentation/
    doctors/     (list, profile)
    booking/     (doctor slot picker, confirm, success)
    tests/       (catalogue, lab booking)
    hospitals/
    bookings/    (local history)
    location/    (divisions/districts cache)
l10n/app_en.arb, app_bn.arb
openapi/schema.yaml
test/  integration_test/
```

---

## 4. Backend contract (verified against the repo)

All list endpoints use DRF `PageNumberPagination`: `?page=&page_size=` (max 100), response `{count, next, previous, results}`. Handle both paginated and bare-list responses in one `unwrapList()` helper (the web client does this too).

| App need | Endpoint | Notes |
|---|---|---|
| Home counts, dropdown options | `GET /search-metadata/`, `GET /search-facets/` | Check shape in schema; use for specialty/test counts on Home |
| Divisions | `GET /divisions/` (districts: `/districts/?division=`) | Cache 24h. "All Bangladesh" is client-side = no param |
| Specialties | `GET /specialties/?canonical_only=true` | Has `bn_name` |
| Doctor search | `GET /doctors/?specialty=&division=&district=&area=&hospital=&search=&gender=&fee_max=&day=&page=` | `search` matches English and Bangla names, specialty, facility, about |
| Doctor detail | `GET /doctors/{id-or-slug}/` | Includes affiliations (chambers) with schedules (`day_of_week`, `start_time`, `end_time`) and fee |
| Test categories | `GET /test-categories/?page_size=100` | |
| Tests | `GET /tests/?category=&search=` | `fasting_required`, `report_time_hours`, `preparation_instructions` |
| Labs offering a test | `GET /facility-tests/?test=&category=&location=&search=` | `price`, `discount_percent`, `report_time`, `home_sample_collection`, `home_sample_charge`, `home_sample_note`. **No division filter** — filter by the nested location's division client-side |
| Hospital categories | `GET /hospital-categories/` | |
| Hospitals | `GET /hospitals/?category=&division=&search=&page=` | Facility objects are nested under `location_details`; port the web's `flattenFacility` logic into the mapper |
| OTP | `POST /bookings/otp/send/ {phone, purpose}`, `POST /bookings/otp/verify/` | Use purpose `doctor_booking` / `test_booking` — the booking serializer checks OTP under those purposes |
| Returning patient prefill | `GET /bookings/patients/lookup/?phone=` | Returns `{found, ...}` |
| Book doctor | `POST /bookings/doctor/ {affiliation_id, date: YYYY-MM-DD, slot: "HH:MM", patient_name, patient_phone, otp_code?, patient_age?, gender?, notes?}` | Server validates slot is inside schedule hours and assigns `serial_number` / `serial_display` (e.g. `SL-004`) — show this on Success |
| Book test | `POST /bookings/test/ {facility_test_id, pickup_date, patient_name, patient_phone, pickup_address_line?, otp_code?, notes?}` | Response includes `price`, `test_name`, `center_name` |

Phone rule (matches backend validator and design): `^01[3-9]\d{8}$` after stripping spaces; send without `+88`.

### Gaps between design and backend — decisions for the agent

Build around these. Don't invent endpoints.

1. **Booked-slot availability.** No endpoint returns taken slots; the backend assigns serial numbers. **v1:** generate 30-minute slots client-side from the chamber's schedule for that weekday and show all as open. If the server rejects a slot, show its message and return to the picker. *Optional backend add:* `GET /affiliations/{id}/availability/?date=` to enable strike-through.
2. **Payments.** No payment endpoints. **v1:** ship "Pay at the counter" only. Keep the "Pay now" UI behind a `kPayInAppEnabled = false` flag.
3. **My bookings and cancel.** Booking list/update endpoints are admin-only (`PublicCreateAdminManage`). The design already says "Saved on this phone", so store the POST response locally. **Cancel** removes the booking locally and shows "Call the chamber to cancel" with the facility phone if one is available. Server-side cancel needs a new endpoint (e.g. phone + OTP-verified cancel).
4. **Test time window.** `TestBooking` has `pickup_date` but no time field. Send the chosen window in `notes` (`"Window: 7:00–9:00 am"`) and keep it in the local record.
5. **OTP.** The design has no OTP step, but the backend supports it. Add a bottom sheet on the Confirm CTA: send OTP, then 6-digit input with a 60-second resend timer, then POST the booking with `otp_code`. Put this behind a `kRequireOtp` flag (default `true` for prod).
6. **Home sample charge.** Add `home_sample_charge` to the total when Home pickup is chosen, and show it as a line in the CTA sub-text.

**Backend issues to fix before launch** (outside this app's scope, flag to the owner): `verify_otp` and `verify_otp_helper` accept `123` / `123456` as a universal code; `send_otp` returns the OTP in the response when `DEBUG` is on, and the default is `True` if the setting is missing. Also `/bookings/patients/lookup/` returns patient data for any phone number without verification.

---

## 5. Phased build plan

Each phase = one agent session. At the end of every phase the agent runs `dart run build_runner build -d`, `flutter analyze` (zero warnings), `flutter test`, and commits with a conventional message.

### Phase 0 — Scaffold (small)
- `flutter create --org com.doctorshub --platforms android,ios doctors_hub_app`; set min iOS 13, Android minSdk 23.
- Add dependencies from §3; configure `analysis_options.yaml`, `l10n.yaml`, flavors via `--dart-define` (`API_BASE_URL`, `REQUIRE_OTP`, `PAY_IN_APP`).
- Fetch `/api/schema/` into `openapi/schema.yaml`.
- Add `CLAUDE.md` (see §7).
- **Done when:** app launches to a placeholder, CI script `tool/check.sh` runs analyze + test green.

### Phase 1 — Design system and shell
- Theme tokens, text styles, fonts (Archivo, JetBrains Mono, Bengali fallback).
- All shared widgets from §2, each with a widget test and a golden (light only, 390×844).
- `go_router` shell with 4 tabs, hide-tab-bar rule, tab badge for bookings count, reset-on-tab-tap behaviour.
- A `/_gallery` debug route showing every widget.
- **Done when:** goldens match the artifact visually (agent opens the artifact HTML locally, screenshots the matching element, and compares by eye); tab navigation works.

### Phase 2 — Networking and data layer
- Dio client, interceptors, `AppFailure` mapping (offline, timeout, 4xx field errors → message, 5xx, 429).
- DTOs + mappers + repositories for: divisions, specialties, doctors (list/detail), test categories, tests, facility tests, hospital categories, hospitals, search metadata/facets, OTP, patient lookup, bookings (create).
- `flattenFacility` port and `unwrapList` helper with unit tests using JSON fixtures in `test/fixtures/` (record real responses from the prod API once, then trim).
- In-memory + persisted cache (5 min TTL, 24h stale fallback on error), same idea as the web client.
- **Done when:** repository unit tests pass against fixtures; a `tool/smoke.dart` script hits the live API for each GET and prints counts.

### Phase 3 — Home + search
- Home screen with all 5 sections, driven by real data; skeletons while loading; per-section error/retry.
- 3-way search card state (tab, category per tab, division) → navigates to Doctors / Tests / Hospitals with filters applied.
- Specialty tile → Doctors filtered; test category tile → Tests filtered; hospital chip switches the 3 rows; "See all" links.
- **Done when:** widget tests cover tab switching and each navigation target; no layout overflow at 320 px width or with text scale 1.3.

### Phase 4 — Doctors list + profile
- Paginated infinite list (`page_size=20`), debounced search (350 ms), specialty dropdown, filter chips (division, hospital) with ×, kicker count from `count`, empty state.
- Keyword aliases from the design (heart→cardio, skin→derm, child/kid/baby→peds, bone/knee→ortho, ear/nose/throat→ent, brain/head→neuro, women/pregnan→gyn): the backend already has a specialty-alias system, so rely on `search` first. Only add client aliases if smoke tests show misses.
- Profile screen + sticky CTA "Visit fee from ৳X".
- **Done when:** list scrolls through 3+ pages on live data; profile renders a doctor with 1 and with 3+ chambers; deep link `/doctors/<slug>` works.

### Phase 5 — Doctor booking flow
- Step 1: chamber radio list (select resets date to first open day), 7-day date strip starting today (Asia/Dhaka), off-day logic from schedules, slot generation (§4 gap 1), CTA summary "Thu 24 — 10:30 am".
- Step 2: summary, name, phone (+88, digits only, max 11, inline error only after 11 digits), prefill from last patient and from `patients/lookup`, payment block (counter only unless flag).
- OTP sheet (flag), submit, map server field errors to inputs, double-submit guard.
- Success screen (red status bar, `serial_display` + booking ref), save to local bookings, replace stack.
- **Done when:** integration test books a doctor end-to-end against a mocked Dio adapter; manual run against staging creates a real booking.

### Phase 6 — Tests catalogue + test booking
- Tests screen: type dropdown, search, division chip, cards with lab rows sorted by price, expand/collapse "+ N more labs", usual price range = min–max of offering labs.
- Test booking: fasting banner from `fasting_required` / `preparation_instructions`, collection choice (disable Home pickup if `home_sample_collection == false`), address required for home, day strip, time windows (`7–9 am`, `9–11 am`, `11 am–1 pm`, `4–6 pm`), shared patient/payment block, total including home charge.
- **Done when:** same bar as Phase 5, for tests.

### Phase 7 — Hospitals + Bookings tab
- Hospitals list (category dropdown, search, division chip) → Doctors filtered by `hospital`.
- Bookings tab: local store, sorted upcoming-first, past bookings greyed or in a "Past" section, badge count = upcoming, Cancel per §4 gap 3, empty state.
- **Done when:** bookings survive app restart; badge updates live.

### Phase 8 — Bangla, accessibility, polish
- Full `app_bn.arb`, language toggle (Home header or a small settings sheet), Bangla digits, `bn_name` everywhere, Bengali font fallback verified on device.
- Semantics labels on icon-only buttons, 48dp tap targets, text scale up to 1.5 without clipping, focus order.
- Offline banner, pull-to-refresh on lists, haptics on slot select.
- App icon and splash (ink background, red "." mark), Android 13+ themed icon.
- **Done when:** goldens pass in both locales; manual TalkBack/VoiceOver pass on the booking flow.

### Phase 9 — Release prep
- Crash reporting (Sentry or Firebase Crashlytics), basic analytics events (search, profile_view, booking_started, booking_completed).
- Release signing, `flutter build appbundle` / `ipa`, store listing screenshots from goldens.
- **Done when:** release builds install and complete a booking on physical Android and iOS devices.

---

## 6. Testing strategy

- **Unit:** mappers, phone/currency/date utils, slot generation (weekday mapping, shifts crossing noon, empty schedule), filter-to-query-param builders.
- **Widget:** every screen in loading / data / empty / error states with fake repositories.
- **Golden:** shared widgets + each screen at 390×844, en and bn.
- **Integration:** two happy paths (doctor, test) and one failure path (server rejects slot) with a mocked HTTP adapter; one smoke test against staging behind `--dart-define=LIVE=true`.

---

## 7. Agent operating rules (put in `CLAUDE.md` at repo root)

```md
# Doctors Hub patient app — rules for coding agents
- Read docs/PLAN.md first. Work one phase at a time; don't start the next phase unasked.
- The design artifact is the visual spec. Match spacing, borders (2px ink, no radius), and copy exactly.
- Never hard-code colours or text styles in features; use core/theme tokens.
- All user-facing strings go in l10n/app_en.arb and app_bn.arb.
- Only call endpoints listed in PLAN.md §4. If you need data that isn't there, stop and write the gap in docs/BACKEND_GAPS.md.
- Check DTO fields against openapi/schema.yaml before writing them. Don't guess field names.
- After each task: build_runner, flutter analyze (0 issues), flutter test. Fix before moving on.
- Small commits, conventional messages. Don't edit generated files by hand.
- Don't add packages outside PLAN.md §3 without noting why in the commit message.
```

---

## 8. Open questions for the product owner

1. Should OTP be required for every booking in v1, or only when the phone number is new?
2. Which payment gateway is planned (SSLCommerz, bKash PGW, Nagad)? This decides whether "Pay now" ships in v1.
3. Is a backend availability endpoint (§4 gap 1) acceptable, or do we switch the UI to "You'll be serial #N" instead of fixed time slots?
4. Does the app need hospital service booking? The backend supports it but the design doesn't show it.
5. Is the default language English with a Bangla toggle, or does it follow the device locale?
