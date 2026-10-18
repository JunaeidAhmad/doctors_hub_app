# Backend Part 8 catch-up — patient app implementation plan

**Date:** Oct 18, 2026
**App repo:** `https://github.com/JunaeidAhmad/doctors_hub_app.git` (HEAD `82c9604`, v1 migration Phases 0–10 complete)
**Backend repo:** `../project_doctors_hub/doctors_hub_backend` (HEAD `87ad15a` "Part 6–7" + uncommitted working tree = **Part 8**: "Booking fixes, morning requests, and access fixes")

The backend's uncommitted Part 8 work changes a handful of API behaviours. Most of it is staff/admin-facing; only **one patient-facing behaviour change** plus **contract/doc sync** reaches this app. v1 is still not frozen (`API_FROZEN_VERSIONS = ()`), so additive changes are allowed.

---

## Delta analysis (backend working tree vs app)

| # | Backend change | Patient-facing? | App action |
|---|---|---|---|
| 1 | `bookings/request_rules.py`: request sessions starting **before 12:00 Dhaka** close **2 h** before start (was 1 h) and get `confirm_deadline = start − 1 h`; non-morning sessions keep the 1 h cutoff. Same `400 {"code":"request_too_late"}`; new bilingual `detail`. | **Yes** | **Implement** (Phase 1) |
| 2 | `openapi.v1.json`: `AffiliationBookingSettings` gains `pending_requests` (readOnly int); `ContactNumberCreate`/`ContactNumberCreateRequest.phone` lose their regex `pattern`. | No (staff schemas) | Sync the spec copy (Phase 2) |
| 3 | `docs/api/VERSIONING.md` (backend): request-mode section now says the app must mirror the morning cutoff and show the server's `request_too_late` message. | Doc | Sync `docs/API_VERSIONING.md` (Phase 3) |
| 4 | Web-client bugs fixed in the same working tree (`age`→`patient_age`, `gender`→`patient_gender`, `otp_code` sent; no invented `'Male'` default). | Doc | Refresh the stale note in `docs/BACKEND_GAPS.md` (Phase 3) |
| 5 | Permission gates (`booking_requests.view/edit`, `call_leads.view`, `roles.view/edit`), `PatientViewSet` scoping + super-admin-only delete, contact-number delete `400 {"code":"in_use"}`, SMS outbox `sending`/`claimed_at`, staff quiet hours 06:00–22:00, `pending_requests` UI. | No — admin/staff surface | Nothing (out of scope, see below) |

Already correct in the app (verified, no work): call-lead payload keys (`patient_age`/`patient_gender`/`otp_code`), optional gender (no invented default), `booking_mode_call_only`/`request_too_late` code handling, `confirm_deadline`/`is_urgent` display (server-computed), OTP rule (never verify first).

---

## Phase 1 — Mirror the request-mode morning cutoff (code + tests)

Backend rule: session start `< 12:00` → cutoff = start − 2 h; otherwise → start − 1 h (both Dhaka time).

1. `lib/core/utils/dhaka_time.dart`: replace `startsWithinHour` with
   `requestCutoffReached({required DateTime now, required String dateIso, required String sessionStart})` —
   same `parseDhaka` plumbing, but `morning = hour < 12` picks `2 h` vs `1 h` before `start`. Keep it pure (injectable `now`) so tests freeze the clock.
2. `lib/features/booking/presentation/doctor_booking_step1_screen.dart` (~line 435): swap the
   `DhakaTime.startsWithinHour(...)` call for `DhakaTime.requestCutoffReached(...)`. Keep the
   `l10n.tooLateToRequest` disabled label (matches web copy "Requests closed…"). Delete the now-unused helper.
3. `test/unit/doctor_booking_test.dart` ("request 1-hour rule (frozen clock)" group → rename "request cutoff rule"):
   - non-morning session (e.g. 17:00): enabled at 16:01, disabled at 15:59;
   - morning session (e.g. 09:00): enabled at 07:01, disabled at 06:59;
   - boundary exactly at cutoff → disabled (mirror backend `now > cutoff`… i.e. `now >= start - cutoff`);
   - instant mode unaffected by the cutoff.
4. ARB: no new keys needed; existing `tooLateToRequest` / `errRequestTooLate` copy stays.

**Done when:** `flutter analyze` 0 issues; `flutter test` green including the cutoff group; grep finds no `startsWithinHour`.

---

## Phase 2 — Sync `openapi/openapi.v1.json`

The app's copy is otherwise identical to the backend working copy (102 paths, 215 schemas). Apply only these three schema diffs:

- `AffiliationBookingSettings`: add `"pending_requests": {"type": "integer", "readOnly": true}`.
- `ContactNumberCreate.phone`: remove `"pattern": "^(?:\\+8801|8801|01)[3-9]\\d{8}$"` (keep `maxLength: 20`).
- `ContactNumberCreateRequest.phone`: same pattern removal (keep `maxLength`/`minLength`).

**Done when:** a python comparison of `paths` and `components.schemas` between the backend working copy and the app copy reports zero diffs.

---

## Phase 3 — Docs sync

1. `docs/API_VERSIONING.md` — in the `request` bullet (~line 150): add the morning rule: sessions starting before 12:00 close 2 h before start (others 1 h); the app mirrors this when disabling sessions and, on a `request_too_late` 400, shows its ARB copy (server `detail` mixes en+bn in one string — gap G9 — so the app copy stays authoritative; note this).
2. `docs/BACKEND_GAPS.md` — the closing "web-client bugs" note is stale: both are fixed in the backend repo's working tree. Rewrite the sentence to say they were fixed in the web client (Part 8), not in this app's scope. G1–G9 remain open as recorded.
3. Leave `docs/v1-migration-plan.md` as the historical record (no edits).

**Done when:** both docs match the statements above; no new doc files created.

---

## Phase 4 — Verification

- `flutter gen-l10n` (only if ARB touched; not expected in Phase 1).
- `flutter analyze` → 0 issues.
- `flutter test` → all green.
- `dart run tool/smoke.dart` → all endpoints print 200 (needs network; confirms nothing else drifted).
- Staging manual: pick a request-mode chamber with a morning session → session becomes disabled 2 h before start with "Too late to request — call the chamber"; an evening session stays enabled until 1 h before. Instant flow unchanged.

---

## Out of scope (staff/admin surface — do not touch)

- `pending_requests` on `GET/PUT /api/v1/affiliations/{id}/booking-settings/` (staff-only; the app never calls it).
- `booking_requests.*`, `call_leads.view`, `roles.view/edit` permission gates; `PatientViewSet` scoping and super-admin-only delete; contact-number delete `400 {"code":"in_use"}`.
- SMS outbox internals (`sending` status, `claimed_at`), staff quiet hours, `doctor_display_name` SMS fix.
- Backend security items still open for the owner (unchanged): `123`/`123456` OTP bypass without a DEBUG guard, `patients/lookup` unverified data, DEBUG `otp` echo.

## Risks / notes

- The Part 8 changes are **uncommitted and possibly not yet deployed** to `https://doctors-hub.onrender.com`. The client-side cutoff mirror is harmless either way, but the staging check in Phase 4 only passes against a backend running Part 8.
- No new packages, no new endpoints, no DTO field changes — existing parsing (tolerant, `unknown` fallbacks) needs no model edits.
