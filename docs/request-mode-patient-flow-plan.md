# Request-mode patient flow — implementation plan (v2: status read + patient cancel)

**Date:** Oct 18, 2026
**Backend:** `../project_doctors_hub/doctors_hub_backend` working tree — "Backend gap fixes (G1–G10)" + "Staff booking for call-only chambers" (uncommitted; see `docs/api/CHANGELOG.md` 2026-10-18 entries)
**App:** `doctors-hub-app` (HEAD `82c9604`)

v2 replaces the v1 plan's request-links approach: the backend now exposes first-class
patient endpoints (`status`, `patient-cancel`) keyed by a `patient_token` returned on
booking create. `request-links` stays out of the app (it serves the staff SMS one-tap flow).

---

## Backend evaluation (what changed, what it means for the app)

| # | Backend change | App impact |
|---|---|---|
| 1 | `POST /bookings/doctor/` response now includes `patient_token` (all bookings) and `confirm_code` (request bookings) | Parse both into the booking store; `patient_token` unlocks status read + cancel |
| 2 | **New** `GET /api/v1/bookings/doctor/{id}/status/?phone=` (AllowAny) → `{id, status, source, date, session_key, session_start/end, estimated_time, serial_number, serial_display, confirm_deadline, is_urgent}`; 404 `{code: booking_not_found, detail, detail_bn}` | Live status read for every doctor booking (G4 solved for doctor bookings) |
| 3 | **New** `POST /api/v1/bookings/doctor/{id}/patient-cancel/` (AllowAny) body `{patient_token, reason (3–255)}`; cancels pending requests (`decided_via=patient`, patient SMS queued) **and confirmed bookings** (`status=cancelled` + reason); 404 `invalid_token`, 409 `not_cancellable` | Real cancel for doctor bookings, incl. confirmed instant (G5 solved for doctor bookings) |
| 4 | `TestBooking` gains nullable `preferred_time` (HH:MM, accepted on create, in payloads + SMS) | Send the picked time window as `preferred_time` instead of packing it into `notes` (G8 solved) |
| 5 | `DoctorSpecialty` serializes `display_order`; list accepts `?ordering=display_order` | Use curated order when present (G7 solved) |
| 6 | Flat error envelope `{"code": "<str>", "detail": "<en>", "detail_bn": "<bn>"}` for ApiError/ConflictError 400/409s; field errors keep DRF shape | App's `mapDioError` (code string-or-list, detail/message) is compatible; keep ARB copy (product rule), optionally use `detail_bn` later |
| 7 | OTP now **required** for anonymous doctor/test/service bookings (`400 {code: otp_required, …}`); `123`/`123456` bypass + `otp` echo limited to DEBUG/TESTING; verified-OTP fallback is purpose-scoped | App always sends OTP — compatible. Map the new `otp_required` code to a graceful message |
| 8 | `GET /bookings/patients/lookup/` returns `{found: bool}` only for anonymous callers (full payload needs staff) | **Prefill feature is now dead for the app.** Remove the lookup call + prefill UI (product decision below) |
| 9 | Request-link GET adds serial fields; POST confirm returns the booking payload | Not needed by the app (staff flow) — skip |
| 10 | Staff override: staff with chamber write access can book `call_only` chambers without OTP | App is anonymous — unaffected |
| 11 | OpenAPI regenerated: 104 paths (2 new), 5 new schemas, 13 changed | App's `openapi/openapi.v1.json` must be re-synced |

### Remaining backend asks (non-blocking)

- **B1 (minor):** `patient_token` is injected into the create response in the view but is
  not declared on `DoctorBookingSerializer`/the OpenAPI schema — the app's synced spec
  would not document it. One-line backend fix (`patient_token = serializers.CharField(read_only=True)`)
  keeps the contract truthful. App parses tolerantly either way.
- **B2 (open, G4/G5 for other types):** no status read / patient cancel for test and
  hospital-service bookings. App keeps local-only cancel + static tags for those.

### Product decisions (defaults assumed in the phases below)

- **P1:** Drop patient-lookup prefill (backend privacy change; keeping it would call an
  endpoint that can no longer return data).
- **P2:** Offer real "Cancel" on confirmed doctor bookings (backend supports it) — replaces
  the old local-remove + "call the facility" workaround for doctor bookings only.
- **P3:** Confirming a request stays a staff action (admin/SMS link). The app only shows
  status; no patient self-confirm.

---

## Phase 0 — Docs + gap register

1. `docs/BACKEND_GAPS.md`: close G7, G8, G10; mark G2/G3 closed backend-side (OTP hardened);
   mark G4/G5 **closed for doctor bookings** (status + patient-cancel) and note the
   remaining test/service-booking hole (B2); add B1 (patient_token schema declaration);
   note the lookup privacy change (P1).
2. `docs/PLAN.md` §4: add `GET /bookings/doctor/{id}/status/?phone=` and
   `POST /bookings/doctor/{id}/patient-cancel/` rows; update the patient-lookup row
   (`{found}` only for anonymous) and the book-doctor row (`patient_token`, `confirm_code`
   in the response); note `preferred_time` on book-test.
3. `docs/API_VERSIONING.md`: extend the `request` bullet — status refresh + patient cancel
   via `patient_token`; OTP is mandatory for anonymous bookings; error envelope is
   `code/detail/detail_bn`.

**Done when:** docs match the backend CHANGELOG entries; no code changes.

## Phase 1 — Models, store, OpenAPI sync

1. `DoctorBookingResult`: add `patientToken` (and `confirmCode`, parsed tolerantly; not
   used by the app beyond storage for now).
2. `BookingItem`: add `patientToken` (+ `confirmCode`?) nullable fields, tolerant
   JSON round-trip (missing → null), `dh_saved_bookings_v2` additive (no key bump).
3. Sync `openapi/openapi.v1.json` with the backend working copy (104 paths / 220 schemas):
   python-compare `paths` + `components.schemas` until zero diffs. If B1 has landed,
   `patient_token` will be included; otherwise the runtime field is parsed tolerantly.
4. Fixtures: extend `test/fixtures/v1/doctor_booking_request.json` and
   `doctor_booking_instant.json` with `patient_token` (+ `confirm_code` on request).

**Done when:** parser tests pass with/without the new fields; spec comparison = zero diffs.

## Phase 2 — Repository

In `booking_repository.dart`:

1. `Future<DoctorBookingStatusResult> getDoctorBookingStatus(String id, String phone)` →
   `GET /bookings/doctor/{id}/status/?phone=` (canonicalize phone client-side with the
   existing validator before sending). 404 `booking_not_found` → null-ish result.
2. `Future<void> cancelDoctorBooking(String id, {required String patientToken, required String reason})` →
   `POST /bookings/doctor/{id}/patient-cancel/`. Map 404 `invalid_token` and 409
   `not_cancellable` through the existing `AppFailure` shapes.
3. `DoctorBookingStatusResult` model: `BookingStatus status`, `serialNumber`,
   `serialDisplay`, `estimatedTime`, `confirmDeadline`, `isUrgent`, `source`.
4. Test booking: extend `booking_request.dart` to send `preferred_time` (window start,
   "HH:MM") and stop putting the window into `notes`.

**Done when:** repo unit tests cover status 200/404, cancel 200/404/409, and
`preferred_time` in the request body.

## Phase 3 — Bookings tab UI

In `bookings_screen.dart` + `localBookingsProvider`:

1. **Refresh:** pull-to-refresh refreshes doctor bookings that have a `patientToken`
   (bounded list; no timers). Merge: `pending` → keep; `confirmed` → tag "Confirmed" +
   serial/approx-time when `serial_display` is present (else existing "serial by SMS");
   `cancelled` → tag "Cancelled" (+ reason if any); `expired` → existing
   "Not confirmed in time…" copy; past-deadline `pending` keeps that copy.
2. **Cancel (doctor bookings):** "Cancel" action on pending request AND confirmed doctor
   bookings with `patientToken` → dialog with mandatory reason (3–255 chars, client-side
   ARB validation) → `cancelDoctorBooking` → mark locally `cancelled`. On 409
   `not_cancellable` → refresh status once and show the tag. Local-remove fallback stays
   only for test/service bookings (B2).
3. **Remove prefill (P1):** drop the `patients/lookup` call and its UI from
   `doctor_booking_step2`, `doctor_call`, `test_booking`, `hospital_service_booking`.
   Keep the last-used name/phone prefill from `dh_last_patient_*`.
4. **OTP copy:** map the new `otp_required` failure to the existing OTP-required copy
   (should never fire — the app always asks for OTP).
5. New ARB keys (en + bn): `cancelBooking`, `cancelReasonHint`, `cancelReasonRequired`,
   `bookingCancelledTag`, `cancelRequestFailed`, `serialBySms` (exists), etc. — follow
   existing tag/theme styles.

**Done when:** widget tests: refresh flips pending→confirmed (with serial), shows
cancelled; cancel requires reason; confirmed instant booking shows Cancel and a successful
cancel marks it cancelled; test/service bookings keep local-remove; no lookup call is
recorded; no overflow at 320px / 1.3 text scale.

## Phase 4 — Tests catalogue (preferred_time) + specialty ordering

1. `test_booking_screen.dart`: send the selected window start as `preferred_time`
   (`07:00` / `10:00` / `13:00` / `16:00` matching the existing windows); drop the
   `"Window: …"` note. Update `test/unit/test_booking_test.dart`.
2. `Specialty` model (`specialty.dart`): parse `display_order` (int?) and sort specialty
   lists by `display_order` when present (fallback: current doctor-count sort). Update
   `specialty_dropdown_test.dart`.

**Done when:** unit tests pass; test-booking request bodies contain `preferred_time` and
no window note; specialty ordering test covers display_order + fallback.

## Phase 5 — Success screen + verification

1. `booking_success_screen.dart`: request branch adds "You'll see the outcome here; pull to
   refresh on the Bookings tab" (new ARB key); instant branch unchanged.
2. Verification: `flutter gen-l10n`, `flutter analyze` (0 issues), `flutter test`,
   `dart run tool/smoke.dart` (all 200; optionally smoke `status` with a known
   id+phone and expect 404 `booking_not_found` shape — no real data).
3. Staging manual (needs the updated backend deployed):
   - instant booking → Bookings tab → Cancel with reason → tag flips to Cancelled; admin
     panel shows `decided_via: patient`.
   - request booking → staff confirms in admin → pull-to-refresh shows Confirmed + serial.
   - request booking → patient cancels before deadline → admin panel + patient SMS.
   - test booking with a picked window → admin panel shows `preferred_time`.

## Out of scope

- Staff accept/reject flow, SMS one-tap links, `request-links` usage in the app (P3).
- Status read / cancel for test and hospital-service bookings (B2 — backend ask).
- API versioning code (unchanged; see `docs/backend-part8-catchup-plan.md` assessment).
- OTP hardening is backend-side; the app only maps `otp_required` copy.

## Risks

- Backend changes are **uncommitted and possibly not yet deployed**; Phases 2–5 end-to-end
  checks need the updated backend. The client work is tolerant and safe either way.
- `patient_token` (16 chars) is a bearer secret for cancel; store it only in the local
  bookings store (already device-private).
- `status` is keyed by booking id + phone; phone must canonicalize to `01XXXXXXXXX` —
  reuse the existing validator before sending.
- P1 (prefill removal) is a UX regression by backend design; flag to the product owner.
