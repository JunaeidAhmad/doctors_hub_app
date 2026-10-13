# Doctors Hub — Flutter App Plan: Catch Up With Backend v1

Oct 13, 2026&#32;

## Summary

The Flutter app still speaks the pre-Part-1 API, so doctor booking cannot work today: it sends a removed `slot` field and never sends the required `session_key`. It also shows no chambers anywhere, because it reads `affiliations`, which Part 5 renamed to `chambers`. This plan brings the app onto the v1 contract (`docs/api/openapi.v1.json`, Parts 1–7) in 11 phases, one opencode session each.

Verified on Oct 13, 2026 by reading both repos (`doctors_hub_app` and `doctors_hub`, backend + web client), not from the changelogs alone.

| Phase | What it fixes | Size |
| --- | --- | --- |
| 0 | Contract file, PLAN.md §4, CLAUDE.md, gaps doc | docs only |
| 1 | Network: `/api/v1`, app-config gate, `X-App-*` headers, 426, error `code` | \~4 files |
| 2 | Models and repositories match v1 shapes (`chambers`, `facility`, nullable prices) | \~15 files |
| 3 | Filters by ID, `facility_id`, routes, tests list from `/facility-tests/search/` | \~8 files |
| 4 | Real OTP on every flow, as the web does it (today the sheet never sends one) | 1 widget + repo |
| 5 | Doctor booking by mode: sessions from availability, instant and request | booking flow |
| 6 | Call mode: OTP, then chamber numbers | new screen |
| 7 | Test booking: `collection_type`, home pickup thana | 1 screen |
| 8 | Hospitals tab in the bottom bar, hospital page | shell + 1 screen |
| 9 | Hospital-service booking | 1 screen |
| 10 | Bookings tab, no invented data, final checks | \~6 files |

**How to run it.** Save this doc as `docs/v1-migration-plan.md` in `doctors_hub_app`. Paste the Agent rules into `CLAUDE.md`. One opencode session per phase, in order: `Do Phase N of docs/v1-migration-plan.md. Read CLAUDE.md first.` Move on only when the phase's "Done when" passes.

## Agent rules (paste into CLAUDE.md)

These replace the "Small commits" line in today's `CLAUDE.md`; the rest of that file stays.

```markdown
# Rules for the v1 migration (docs/v1-migration-plan.md)

Doctors Hub patient app (Flutter). Backend contract: openapi/openapi.v1.json.
Do only the phase you are given.

Working method
- Do NOT run any git command. Edit the codebase directly.
- Do NOT create backup folders or notes files. Report in your final message.
- Read a file in full before editing it. Find code by searching; never
  trust a line number. If something the phase names does not exist, stop
  and say what you found.
- Field names come from openapi/openapi.v1.json only. Never guess a key,
  never read a legacy spelling as a fallback (no `json['a'] ?? json['b']`).
- Change only what the phase lists. Note anything else in the final message.

Product rules
- Serial first: a booking shows session and serial; any time is labelled
  approximate ("approx. 6:10 PM").
- No invented data. A missing value shows nothing or a neutral label.
  Never make up a booking ref, a price, a date, a name or a slot.
  Ratings and review counts are the one exception.
- Tolerant parsing: ignore unknown fields; every enum has an `unknown`
  value; only `required` fields are non-nullable.
- Every new user-facing string goes in app_en.arb and app_bn.arb.
- No new package unless the phase names it.

Checks at the end of every phase (paste the real output in your report)
  flutter gen-l10n
  dart run build_runner build -d   (only if the project uses it)
  flutter analyze                  (0 issues)
  flutter test
  dart run tool/smoke.dart         (from Phase 1 on; needs network)

Final report: files changed, commands run with output, anything not done
and why.
```

## What changed: app today vs v1

Every row was checked against the app's source and the backend's serializers, services and `openapi.v1.json`. "Broken" means the feature fails or shows wrong data now; "silent" means the request succeeds but the filter or field is ignored.

| Area | App today (file) | v1 contract | Effect | Phase |
| --- | --- | --- | --- | --- |
| Base URL | `…/api` (`api_client.dart`) | `…/api/v1`; `/api/app-config/` stays unversioned | works via deprecated alias | 1 |
| Client headers | none | `X-App-Platform`, `X-App-Build` on every call; 426 gate | no update gating | 1 |
| Error bodies | reads `detail` / `message` | also `code` (DRF sends it as a list: `{"code":["request_too_late"]}`), `error` on tests search | mode errors unreadable | 1 |
| Doctor chambers | reads `affiliations` (`doctor.dart`) | `chambers` on list and detail | **broken**: no chambers, no fee, no booking | 2 |
| Chamber facility | `facility_name`, `location_details.*` | `facility` object: `display_name`, `address`, `area`, `district`, (detail adds `phone`, `division_id`…) | **broken**: name falls back to "Chamber" | 2 |
| Chamber mode | not read | `booking_mode`: `instant` / `request` / `call_only` | call-only chambers get a booking form the API refuses | 2, 5, 6 |
| Next available | not read | `chambers[].next_available` `{date, session_start, remaining}` | missed feature | 2 |
| Doctor search params | `division`, `district`, `area` (names), `facility` / `hospital` (name) | `division_id`, `district_id`, `thana_id`, `facility_id` (UUID) | **silent**: Home and Hospitals links don't filter | 3 |
| Specialties | `?canonical_only=true` | param removed; plain array | harmless, remove | 3 |
| Hospital rows | `location_details`, `address_line`, `bn_name` | flat facility summary: `address`, `area_bn`, `district_bn`, `division_bn`; `id` = location id | address missing | 2 |
| All facilities | `GET /locations/` | not in the patient surface (may change) | fragile | 3 |
| Test list | `/tests/` + one `/facility-tests/?test=` per card, division filtered client-side | `/facility-tests/search/` returns tests with offerings, filters by `division_id`/`district_id`/`thana_id` server-side | N+1 calls; `/tests/`, `/facility-tests/` are outside the frozen surface | 3 |
| Lab offering | `price` → 0.0 when null; `discount_percent as num` | `price` null = "price at counter"; show `calculated_price`; `discount_percent` is a decimal **string**; `report_time_hours` | **broken**: ৳0 shown; cast throws on discounted labs | 2 |
| OTP verify | sends `code` | `otp_code` | **broken** (but never called) | 4 |
| OTP sheet | collects 6 digits, never calls send; `REQUIRE_OTP` defaults `false` | send, then pass `otp_code` on the booking/lead POST | no real OTP | 4 |
| Patient lookup | reads flat `patient_name` | `{found, patient:{name, age, gender}}` | **broken**: prefill never fills | 2 |
| Doctor booking | `slot: "HH:MM"`, `gender` | `session_key` (from availability), `patient_gender`; legacy keys → 400 | **broken**: every booking fails | 5 |
| Slots | 30-min slots generated on the phone | sessions with capacity, `next_serial`, `estimated_time`, `status` from `/affiliations/{id}/availability/` | wrong model | 5 |
| Booking result | invents `DH-xxxxx` ref; expects `confirmed` copy | `status` `confirmed` (instant) or `pending` + `serial_number: null` (request); `estimated_time`, `session_start/end`, `confirm_deadline`, `is_urgent` | invented data; request mode shows nothing right | 5 |
| Call mode | absent | `POST /bookings/call-leads/` → `numbers[]` | missing | 6 |
| Test booking | no `collection_type`; address only in `notes` | `collection_type` `center`/`home`; home needs `pickup_thana_id` + `pickup_address_line`; date ≤ 30 days | **broken** for home pickup | 7 |
| Status enum | not stored | adds `expired` | must parse | 8 |

## Phase 0: Contract and docs

The app's reference files describe the v1 backend before any code changes, so later phases check field names against the right source.

1. Copy `doctors_hub/docs/api/openapi.v1.json` into the app as `openapi/openapi.v1.json`. Delete `openapi/schema.yaml` (it predates Part 1 and has no `chambers`, `session_key` or `booking_mode`).
2. Copy `doctors_hub/docs/api/VERSIONING.md` into the app as `docs/API_VERSIONING.md`, unchanged. It is the backend's own instructions for this app.
3. In `docs/PLAN.md`:
   - §4 table: replace it with the patient surface list from `API_VERSIONING.md` plus `GET /api/app-config/`. Point every row at v1 shapes. Remove `/tests/`, `/facility-tests/` and `/locations/` (not in the frozen surface).
   - §4 gaps 1, 4 and 5 are closed by the backend (availability endpoint, `collection_type`, OTP rules); mark them "closed, see v1-migration-plan". Gaps 2 (payments) and 3 (patient cancel) stay open.
   - §3 packages: add `package_info_plus` (build number for `X-App-Build`) and `url_launcher` (`tel:` links in call mode and "Call the chamber").
   - §7 rules: point to the new `CLAUDE.md`.
4. Update `doctors-hub-flutter-plan.md` (the root copy of PLAN.md) the same way, or delete it and leave a one-line pointer to `docs/PLAN.md`. Keep one copy.
5. `docs/BACKEND_GAPS.md`: gap 1 (stale schema) closed by step 1; gap 3 (umbrella `doctor_count`) closed: the backend now fills `doctor_count` from aggregated counts. Gap 2 (`display_order`) is still open. Add the open gaps listed at the end of this plan.
6. Paste the Agent rules into `CLAUDE.md`, replacing the "Small commits" line and changing "openapi/schema.yaml" to "openapi/openapi.v1.json".

**Done when:** `grep -rn "schema.yaml\|canonical_only\|affiliations" docs CLAUDE.md` returns nothing outside history notes. `python3 -c "import json;json.load(open('openapi/openapi.v1.json'))"` exits 0.

## Phase 1: Network layer

Every request goes to `/api/v1`, identifies the app build, and turns the backend's error codes into something screens can switch on.

1. **Base URL.** Replace the `API_BASE_URL` define with `API_ORIGIN` (default `https://doctors-hub.onrender.com`). `ApiClient` sets Dio's `baseUrl` to `$origin/api/v1/`. App-config is fetched from the absolute URL `$origin/api/app-config/`. Add a unit test that `/doctors/` resolves to `…/api/v1/doctors/` (Dio joins base and path; the test proves it).
2. **Headers on every request** (an `onRequest` interceptor): `X-App-Platform` = `android` or `ios`, `X-App-Build` = the integer build number from `package_info_plus`, `Accept-Language` = `en`/`bn` (already there). Read the build number once at startup in `main.dart` and pass it in; don't call the plugin per request.
3. **App-config at start.** New `core/app_config/` with a model for `AppConfigResponse` and a provider that calls it once on launch (before the first screen loads data):
   - `client.status == ok` → continue;
   - `update_available` → a dismissible banner on Home with `update_message.<locale>` and a button to `platforms.<platform>.store_url`;
   - `update_required` → the full-screen update page (step 4);
   - `api.deprecations.v1.sunset_on` set → the same soft banner;
   - the call fails (offline, timeout) → continue silently; never block the app on app-config. Unknown `status` values are treated as `ok` (tolerant parsing).
4. **426 Upgrade Required.** Any response with status 426 maps to a new `UpdateRequiredFailure` holding `code` (`app_update_required` / `api_version_retired`), `store_url` (top level, or `update.store_url` for retired) and `message.en` / `message.bn`. A provider holds it; `go_router`'s `redirect` sends every route to a new `/update-required` screen (outside the shell, no back) while it is set. Copy and button use `message.<locale>` and open `store_url` with `url_launcher`; if `store_url` is empty, show the message and no button.
5. **Error mapping** in `mapDioError`:
   - read `code` and `detail` as either a string or a one-item list (DRF wraps `ValidationError` values in lists: `{"code":["request_too_late"],"detail":["…"]}`);
   - also read `error` (string, sent by `/facility-tests/search/`) and `message` (OTP endpoints);
   - field errors = every other key whose value is a string or a list of strings; `code`, `detail`, `error`, `message`, `success` are never field errors;
   - add `String? code` to `ValidationFailure`, and map **409** to a `ValidationFailure` too (call-leads returns `409 {"code":"no_numbers"}`);
   - the user-facing message for a known `code` comes from the ARB files, not the server's text (the server's `detail` is English + Bangla in one string). Keys: `errBookingModeCallOnly`, `errRequestTooLate`, `errNotCallMode`, `errNoNumbers`.
6. **Smoke script** (`tool/smoke.dart`): call app-config, then each patient-surface GET under `/api/v1`, print status and count. Drop `?canonical_only=true` and `/tests/`; add `/facility-tests/search/?page_size=5` and one `/affiliations/<id>/availability/` using the first chamber id from `/doctors/`.

**Done when:** unit tests pass for: the URL join; headers present on a recorded request; `mapDioError` on these bodies — `{"code":["request_too_late"],"detail":["x"]}` → code `request_too_late`; `{"session_key":["This session is fully booked."]}` → field error, no code; `{"error":"Invalid value"}` → message; a 409 `{"code":"no_numbers"}`; a 426 for each of the two codes. Smoke script prints 200 for every endpoint against Render.

## Phase 2: Models and repositories

Every DTO parses exactly the v1 shape, with one shared facility model, so screens show chambers, addresses and prices again.

1. **Fixtures first.** Add `--record` to `tool/smoke.dart`: it saves trimmed real responses to `test/fixtures/v1/` (`doctors_list.json`, `doctor_detail.json` for a doctor with 2+ chambers, `availability.json`, `hospitals.json`, `facility_tests_search.json`, `patient_lookup_not_found.json`). Hand-write `doctor_booking_instant.json`, `doctor_booking_request.json`, `test_booking.json`, `call_lead.json` and `patient_lookup_found.json` from the schemas in `openapi.v1.json` (never post real bookings to record them).
2. **`FacilitySummary`** (`core/models/facility_summary.dart`), one model for every nested `facility`: `id`, `slug`, `name`, `branch`, `displayName`, `address`, `area`/`areaBn`, `district`/`districtBn`, `division`/`divisionBn`, `thanaId`, `districtId`, `divisionId`, `phone`, `logo`, `image`, `locationType`, `ownershipType`. All optional except `id` and `displayName`. `localizedArea(locale)` etc. pick the `_bn` value when the locale is `bn` and it's non-empty. The doctor list's `FacilityMini` (`id`, `slug`, `display_name`, `address`, `area`, `district`) parses into the same class.
3. **Doctor and chambers** (`features/doctors/domain/models/`):
   - rename `DoctorAffiliation` to `Chamber` and `Doctor.affiliations` to `Doctor.chambers`, read from the `chambers` key; update every call site (list, profile, Home cards, booking steps 1 and 2);
   - `Chamber`: `id`, `fee` (`double?`, parsed from the decimal string), `chamberType`, `bookingMode` (`instant` / `request` / `callOnly` / `unknown`), `facility` (`FacilitySummary`), `schedules` (`dayOfWeek`, `startTime`, `endTime`; `id` only on detail), `nextAvailable` (`date`, `sessionStart`, `remaining`, or null), and detail-only `advanceBookingDays`, `isActive`;
   - `Doctor`: add `primarySpecialty`, `isVerified`, `bmdcNumber`, `specialtyDisplay` (`en`/`bn`, detail only); `about` reads `about` only (the `description` alias is gone); `rating` stays a parsed decimal string;
   - `minFee` ignores null fees; `primaryChamber` = first chamber (the API orders them).
4. **Hospital** reads the flat facility summary the API sends (`HospitalSerializer.to_representation` spreads `FacilitySummary` into the top level) plus `category {id, slug, name}`, `doctor_count`, `test_count`, `emergency_phone`. Delete the `location_details` branch, `address_line`, `bn_name` and the `doctors_count` fallback. `id` is the location id; Phase 3 passes it as `facility_id`.
5. **Tests** (new `features/tests/domain/models/test_search.dart`): `TestSearchGroup` (`id`, `slug`, `name`, `code`, `categoryId/Name/Slug`, `description`, `fastingRequired`, `preparationInstructions`, `sampleType`, `reportTimeHours`, `minPrice?`, `maxPrice?`, `offeringCount`, `pricedOfferingCount`, `homeCollectionCount`, `offerings`) and `LabOffering` (`id`, `facility`, `price?`, `calculatedPrice?`, `discountPercent?` parsed from a string, `homeSampleCollection`, `homeSampleCharge?`, `homeSampleNote`, `reportTimeHours?`, `isAvailable`). Rules: shown price = `calculatedPrice ?? price`; both null → the label "Price at counter" and the lab sorts last; report time = offering hours, else test hours, else nothing (ignore the free-text `report_time`, due to be dropped). `TestCategory` gains `centerCount`, `order`. Remove `DiagnosticTest.facility_tests` and the old `FacilityTest` once Phase 3 stops using them.
6. **Booking responses** (`features/booking/domain/models/`): `BookingStatus` enum (`pending`, `confirmed`, `cancelled`, `completed`, `noShow`, `expired`, `unknown`); `DoctorBookingResult` (`id`, `status`, `serialNumber?`, `serialDisplay?`, `estimatedTime?`, `sessionStart`, `sessionEnd`, `date`, `fee?`, `doctorName`, `facility`, `confirmDeadline?`, `isUrgent`, `source`); `TestBookingResult` (`id`, `status`, `pickupDate`, `collectionType`, `price?`, `testName`, `facility`); `CallLeadResult` (`id`, `doctorName`, `facility {id, displayName}`, `numbers [{label, phone}]`). Delete `BookingResponse` and its invented `DH-…` ref and `SL-…` serial.
7. **Patient lookup** reads `{found, patient: {name, phone, age, gender}}`; `gender` is lowercase `male`/`female`/`other` or blank.
8. **Repositories**: `DoctorRepository` and `HospitalRepository` return the new models; `BookingRepository.lookupPatient` uses the new parser. Leave search params to Phase 3.

**Done when:** a parser test per fixture passes, including: a doctor list row whose `chambers[0].facility.display_name` is non-empty; a detail with 2+ chambers and `booking_mode`; a lab with `price: null` showing no amount; a lab with `discount_percent: "10.00"`; an unknown `booking_mode` and `status` parse to `unknown`. `grep -rn "location_details\|affiliations\|address_line\|'description'" lib` returns nothing. Updated `test/unit/hospital_and_test_models_test.dart` passes.

## Phase 3: Filters, routes and the tests list

Every filter sends the ID the backend reads, so Home, Hospitals and the filter chips actually narrow results, and the tests tab loads in one call.

1. **Doctor search params** (`DoctorRepository.searchDoctors`): only `search`, `specialty` (slug), `division_id`, `district_id`, `thana_id`, `facility_id` (UUID), `day`, `gender`, `page`, `page_size`. Delete the `division` / `district` / `area` / `hospital` / `facility` name params and their "All …" string checks. The backend ignores unknown params, so a leftover name param fails silently.
2. **Hospital search params** (`HospitalRepository.getHospitals`): `category` (slug or id), `division_id`, `district_id`, `thana_id`, `ownership_type`, `search`, `page`, `page_size`. Delete the name params.
3. **Facility picker on Doctors.** `facilitiesProvider` reads `GET /locations/`, which is outside the frozen surface. Switch it to the `facilities` list of `GET /search-metadata/` (`id`, `slug`, `display_name`, `area`, `district`), cached for the session. Delete `getAllFacilities` and its `/hospitals/?page_size=100` fallback.
4. **Specialties**: drop `?canonical_only=true`.
5. **Routes carry IDs** (`app_router.dart`):
   - `/doctors?specialty=<slug>&division_id=<int>&facility_id=<uuid>&facility_name=<label>&search=<q>`. `facility_name` is only the chip label ("At \<hospital>"); the filter uses `facility_id`.
   - `/hospitals?category=<slug>&division_id=<int>&search=<q>`.
   - `/tests?category=<slug>&division_id=<int>&search=<q>`.
   - Home's search card keeps the selected division as its id, not its name. Hospital rows (Hospitals screen and Home) push `/doctors?facility_id=${h.id}&facility_name=${h.displayName}`.
   - Screens init their filter state from these params; the division chip label comes from `divisionsProvider` by id.
6. **Tests list from `/facility-tests/search/`.** New `TestRepository.searchTests({q, testcat, divisionId, districtId, thanaId, fulfillment, ownership, ordering = 'price', page, pageSize = 20})` returning the groups, `count`, `next` and `facets`. `page_size` is capped at 50 by the server. The catalogue screen:
   - one call per page, infinite scroll, debounced search (350 ms) sent as `q`;
   - category dropdown sends `testcat` (slug); division/district/thana chips send IDs (server-side now; delete the client-side division, district, area, fulfillment and ownership filtering in `getFacilityTestsForTest`);
   - card "usual price" = `min_price`–`max_price` from the group (hide when both null); labs listed from `offerings`, cheapest first (server order), top 2 shown, "+ N more labs" expands the rest locally;
   - fulfillment and ownership filter chips can show counts from `facets`. Delete `getTests`, `getFacilityTestsForTest`, `DiagnosticTest` and `FacilityTest` when nothing uses them.
7. **Test booking entry.** The lab row pushes `/tests/:testId/labs/:labId/book` and hands the chosen `TestSearchGroup` and `LabOffering` to the booking screen through a provider (not by re-fetching). Delete `singleTestDetailsProvider`, which downloads page 1 of `/tests/` and falls back to a made-up "Diagnostic Test". On a cold deep link with no provider value, show "This test isn't loaded" with a button back to `/tests` (no single-offering endpoint is in the patient surface; see gaps).

**Done when:** unit tests for both query builders (only v1 keys, never a name param). Widget tests: Home → Doctors with a division sends `division_id`; a hospital row sends `facility_id`; the tests tab issues exactly one request per page. `grep -rn "'/locations/'\|'/tests/'\|'/facility-tests/'\|queryParams\['division'\]" lib` returns nothing. Manual: pick Dhaka on Home → the doctors kicker count drops below the unfiltered count.

## Phase 4: Real OTP, as the web does it

Every booking and call lead uses a real OTP, the same way the web's booking modals do: send a code, the patient types it, and the code goes on the booking POST as `otp_code`. Today's app sheet never sends a code, and `REQUIRE_OTP` defaults to off.

**The rule the backend imposes** (`bookings/serializers.py: verify_otp_helper`): a booking or lead accepts an `otp_code` only while that code is still unverified. `POST /bookings/otp/verify/` marks it verified, so calling verify first and then sending the same code makes the booking fail. The app never calls verify.

| Flow | OTP `purpose` (as the web sends it) | Code goes on |
| --- | --- | --- |
| Doctor booking | `doctor_booking` | `POST /bookings/doctor/` |
| Test booking | `test_booking` | `POST /bookings/test/` |
| Hospital-service booking | `hospital_service_booking` | `POST /bookings/hospital-service/` |
| Call lead | `call_lead` | `POST /bookings/call-leads/` |

Call leads are the one place the app differs from the web on purpose. The web's call modal calls verify and then posts the lead without a code, which only works through the backend's "verified in the last 10 minutes" fallback (gap G3). The app posts `otp_code` with the lead, which is what the backend's call-lead contract specifies. The patient sees the same thing.

1. **Repository.** `sendOtp(phone, purpose)` posts `{phone, purpose}` and returns `expires_in`. Delete `verifyOtp` (it also sends the wrong key, `code` instead of `otp_code`), so no screen can call it by mistake.
2. **`core/widgets/otp_sheet.dart`**, replacing `_OtpVerificationModal`:
   - opens with the normalized phone (`01XXXXXXXXX`) and a purpose, and sends the code on open;
   - 6-digit numeric input, autofocus, SMS autofill hint (`AutofillHints.oneTimeCode`);
   - resend after 60 s (a new send replaces the old code on the server);
   - takes `Future<AppFailure?> Function(String code) onSubmit`; stays open with a spinner while it runs; a `ValidationFailure` with an `otp_code` field error shows that message under the input and keeps the sheet open; any other failure closes the sheet and returns it to the caller; success closes it;
   - 429 shows "Too many attempts, wait a minute" and disables resend for 60 s. Never show or autofill the `otp` value a DEBUG backend adds to the send response.
3. **Always on.** Delete the `REQUIRE_OTP` define: like the web, every flow asks for OTP.
4. Strings: sheet title, "Code sent to {phone}", resend countdown, invalid-code and rate-limit messages, en + bn.

**Done when:** widget tests with a fake repository: the sheet calls send once on open with the given purpose; a submit returning an `otp_code` field error keeps it open with the message; success closes it; resend is disabled for 60 s. `grep -rn "otp/verify\|REQUIRE_OTP" lib` returns nothing.

## Phase 5: Doctor booking by mode (instant and request)

The patient picks a real session from the availability endpoint and gets a serial (instant) or a "we'll call you" request (request); client-generated 30-minute slots go away.

**What each mode shows** (same rules as the web's `utils/bookingMode.js` and `VERSIONING.md` "Booking by mode"):

| Mode | Chamber badge | Button | Session picker | Before submit | After submit |
| --- | --- | --- | --- | --- | --- |
| `instant` | Instant booking | Book appointment | yes | seats left, next serial, approx. time | serial + session + approx. time, status `confirmed` |
| `request` | Booking by request | Request appointment | yes | seats left only | "Request sent, the chamber will call you", no serial, no time, status `pending` |
| `call_only` | Book by phone | Get phone number | no | weekly hours only | numbers (Phase 6) |
| `unknown` | none | none | no | weekly hours only | — |

Request mode hides the next serial before submit as well: staff may move the request to another date or session when they confirm, so the number shown would often be wrong.

1. **Pure helper** `features/booking/domain/booking_mode.dart`: `bookingModeView(Chamber)` → `{mode, badgeKey, buttonKey, showSessions, showSeatCounts, showSerial, canBook}`. Unit-test every mode.
2. **Cards and profile.** Each chamber row shows its badge and keeps weekly days and hours. Doctor rows and Home cards may show `next_available` ("Next: Thu · 5:00 PM · 12 left") for `instant` and `request` chambers only. The profile CTA follows the selected (or first) chamber's mode; `call_only` opens Phase 6's screen; `unknown` shows no CTA.
3. **Availability.** `DoctorRepository.getAvailability(chamberId, from, days)` → `GET /affiliations/{id}/availability/?from=YYYY-MM-DD&days=N`, `from` = today in Asia/Dhaka (UTC+6, no DST), `days` = `min(advanceBookingDays ?? 14, 14)` (the server also caps it). Parse `dates[]` (`date`, `weekday`, `status`, `has_schedule`, `sessions[]`) and sessions (`session_key`, `start_time`, `end_time`, `capacity`, `booked`, `remaining`, `next_serial`, `estimated_time`, `status`, `note`). Statuses `available` / `full` / `ended` / `closed`, plus `unknown`.
4. **Step 1** (`doctor_booking_step1_screen.dart`), for `instant` and `request` chambers only:
   - chamber radio list (only bookable chambers selectable; others show their badge and "Call" or nothing);
   - date strip from `dates[]`: `available` enabled; `full` shown with "Full"; `closed` or no schedule greyed, "Not at this chamber that day";
   - a session list replaces the slot grid: "Evening · 5:00–9:00 PM", then for instant "Next serial #N · approx. 6:10 PM · N left", for request "N left"; non-`available` sessions disabled with their reason; a non-empty `note` shown under the session;
   - request mode: a session starting in under 1 hour is disabled with "Too late to request — call the chamber" (backend rule B7; the server still has the final say);
   - CTA sub-text "Thu 24 · 5:00–9:00 PM"; Continue passes `chamber`, `date`, `session_key` and the session's display window to step 2. Re-fetch availability when the screen regains focus.
   - Delete `SlotGenerator`, `slot_grid.dart` and `slot_generator_test.dart`.
5. **Step 2** (`doctor_booking_step2_screen.dart`):
   - fields: name, phone, optional age, optional gender (`male` / `female` / `other`); prefill name, age and gender from `patients/lookup` when `found`, and name/phone from the last patient on this device;
   - payment block unchanged (counter only; `PAY_IN_APP` stays off);
   - request copy: button "Send request", a line "The chamber will call {phone} to confirm";
   - submit opens the OTP sheet (`purpose: doctor_booking`), whose `onSubmit` posts `{affiliation_id, date, session_key, patient_name, patient_phone, patient_age?, patient_gender?, notes?, otp_code}` to `/bookings/doctor/`. Never send `slot` or `gender`: legacy keys now return 400;
   - errors: a `session_key` or `date` field error (full, ended, cancelled, too far ahead) → back to step 1 with the message and fresh availability; `request_too_late` → the ARB message, back to step 1; `booking_mode_call_only` (mode changed since load) → replace with the Phase 6 screen; double-submit guard stays.
6. **Success screen** by `status`:
   - `confirmed`: "You're booked", `serial_display`, session window, "approx. {estimated\_time}", facility, fee; if `serial_number` is null, say "Your serial will come by SMS" and show no number;
   - `pending`: "Request sent", "{facility} will call you at {phone} to confirm. You'll also get an SMS." Show "Expect a call by {confirm\_deadline}" (Dhaka time); if `is_urgent`, "before the session starts". No serial, no time;
   - booking reference = the booking `id`'s first 8 characters, upper-case, labelled "Booking ID". Never a made-up `DH-` number.
7. **Local record.** `BookingItem` gains `status`, `bookingMode`, `affiliationId`, `doctorSlug`, `sessionStart`, `sessionEnd`, `estimatedTime?`, `confirmDeadline?`, `isUrgent`; `timeSlot` becomes the session window. Store under a new key `dh_saved_bookings_v2`; on first read, migrate v1 entries with `status: unknown` and drop the v1 key.

**Done when:** unit tests for `bookingModeView`, availability parsing and the request 1-hour rule (frozen clock). An integration test on a mocked Dio adapter books an instant chamber (request body has `session_key`, `patient_gender`, `otp_code`, no `slot`; success shows the serial) and a request chamber (success shows no serial). A test where the server answers `{"session_key":["This session is fully booked."]}` returns to step 1 with that message. Manual on staging: one instant booking shows a serial; one request booking shows "we'll call you".

## Phase 6: Call mode

For a `call_only` chamber the patient gives name and phone, passes OTP, and sees the chamber's numbers as tap-to-call buttons; there is no date, session or serial anywhere on this path.

1. **Route** `/doctors/:id/call?chamber=<chamberId>`, pushed above the shell. Reached from the profile CTA, the chamber row's "Get phone number" button, and Phase 5's `booking_mode_call_only` fallback.
2. **Form step:** doctor name, chamber `facility.displayName`, the weekly days and hours from `schedules`, then name, phone, optional age and gender (same widgets and prefill as booking step 2). Button "Get phone number".
3. **Submit** opens the OTP sheet with `purpose: call_lead`; `onSubmit` calls new `BookingRepository.createCallLead` → `POST /bookings/call-leads/` with `{affiliation_id, patient_name, patient_phone, patient_age?, patient_gender?, otp_code}`. Use these canonical keys (the web modal sends `age`/`gender`, which the serializer ignores; don't copy it).
4. **Numbers step:** for each `numbers[]` item a full-width button with `label` (blank label → no label) and the phone, opening `tel:` via `url_launcher`, plus a copy icon (`Clipboard`). Below: the weekly hours again, and "Call during these hours". No booking is created, so nothing goes to the Bookings tab.
5. **Errors:** `not_call_mode` (400) → the chamber changed mode; reload the doctor and send the patient to the right flow with a short message. `no_numbers` (409) → "This chamber has no phone number listed yet. Please try another chamber." Field errors map to the inputs.
6. **Repeat visits:** keep the last result per chamber in memory for 30 minutes (the server also reuses the lead for 30 minutes), so going back and forward doesn't ask for OTP again. Never write the numbers to `shared_preferences`.
7. Add `POST /bookings/call-leads/` to PLAN.md §4 if Phase 0 missed it.

**Done when:** widget test on a fake repository: the screen has no date or session widget at any step; OTP success shows two `tel:` buttons from the fixture; `no_numbers` shows the message and no buttons. Manual on staging: one `call_only` chamber shows numbers only after OTP.

## Phase 7: Test booking

The test booking sends the collection type and, for home pickup, a thana and address, which the backend now requires; today home pickup always fails.

1. **Input:** the `TestSearchGroup` and `LabOffering` from Phase 3's provider. Fasting banner from `fastingRequired` and `preparationInstructions`.
2. **Collection:** "Visit lab" = `center`; "Home pickup" = `home`, disabled when `homeSampleCollection` is false (show `homeSampleNote` under it when non-empty). Home pickup needs a thana picker (division → district → thana from the existing location providers, preselected from the tests tab filter when set) and the address line. Both required before Continue.
3. **Date strip:** today to today + 6 days (Asia/Dhaka); the server rejects dates over 30 days ahead. Time windows (`7–9 am`, `9–11 am`, `11 am–1 pm`, `4–6 pm`) still have no API field: keep sending `notes: "Window: 7:00–9:00 am"`, and stop appending the address to `notes` (it has its own field now).
4. **Total:** shown price (`calculatedPrice ?? price`) plus `homeSampleCharge` when home pickup is chosen. If both prices are null, show "Price confirmed at the lab" and no total; never ৳0.
5. **Submit:** OTP sheet with `purpose: test_booking`, then `POST /bookings/test/` with `{facility_test_id, pickup_date, collection_type, pickup_thana_id?, pickup_address_line?, patient_name, patient_phone, patient_age?, patient_gender?, notes, otp_code}`.
6. **Errors:** field errors on `collection_type`, `pickup_thana_id`, `pickup_address_line`, `pickup_date` go to those inputs; `facility_test_id` ("currently unavailable", "center is inactive") → a message and back to the tests tab.
7. **Success and local record:** test bookings are still created `pending` (Part 7 kept their flow), so the success screen says "Booking received — the lab will contact you to confirm" with the test, lab, date and window. Store `price` from the response (the server's snapshot) plus the home charge shown, `status`, `collectionType` and the booking ID as in Phase 5.

**Done when:** integration test on a mocked adapter: a home-pickup booking sends `collection_type: home`, `pickup_thana_id` and `pickup_address_line`; a lab visit sends `collection_type: center` and neither pickup field; a null-price offering never shows ৳0. Manual on staging: one home-pickup booking succeeds.

## Phase 8: Hospitals tab and hospital page

Hospitals becomes a tab in the bottom bar, and tapping a hospital opens its own page (details, contact numbers, services, doctors) instead of jumping straight to a doctor list.

The design artifact has no hospital page or 5-tab bar. Build both from the existing theme tokens and shared widgets (`InkBorderBox`, `Kicker`, `RuleGrid`, `RadioRow`, `PrimaryCtaButton`), same borders and spacing as the other screens.

1. **Bottom bar: 5 tabs** — Home, Doctors, Tests, Hospitals, Bookings (Bookings stays last and keeps its badge). In `app_router.dart` move `/hospitals` out of the root-navigator routes into a new `StatefulShellBranch` between Tests and Bookings, keeping its query params (`category`, `division_id`, `search`). Same rules as the other tabs: the bar shows on root screens only, tapping a tab resets its stack and filters. Labels en + bn; check the bar at 320 px width and text scale 1.3 (shrink the label style if five don't fit, never truncate a Bangla label).
2. **Hospital rows open the hospital page.** On the Hospitals tab and Home, a hospital row now pushes `/hospitals/:idOrSlug`. This replaces Phase 3 step 5's rule that hospital rows push `/doctors?facility_id=…`; the doctors link moves onto the hospital page.
3. **Hospital page** `/hospitals/:idOrSlug`, pushed above the shell. New `HospitalRepository.getHospital(idOrSlug)` → `GET /hospitals/{location}/` (accepts slug or id). Parse into the Phase 2 `Hospital` model plus `description`, `open_timing`, `ambulance_phone`, `services [{id, name, icon}]`. Show, top to bottom, hiding any empty field:
   - name (`display_name`), category, area and district (`_bn` in Bangla), address, `open_timing`;
   - call buttons (`tel:` via `url_launcher`) for `phone`, `emergency_phone`, `ambulance_phone`, each labelled;
   - `description`;
   - **Services**: one row per `services[]` item with a "Book" button (Phase 9); no services → hide the section;
   - "Doctors here ({doctor\_count})" → `/doctors?facility_id=<id>&facility_name=<display_name>`, hidden when the count is 0;
   - "Tests here ({test\_count})" → `/tests?location_id=<id>&location_name=<display_name>`, hidden when 0. Add `location_id` to the Phase 3 tests query (the search endpoint accepts it) and show it as a removable chip. Loading skeleton, error with retry, and 404 → "Hospital not found" with a way back.
4. **PLAN.md §1**: update the tab-bar line to five tabs and add the hospital page and the service booking screen to the routes table.

**Done when:** widget tests: the shell has five tabs and the Hospitals tab keeps its filters across tab switches; a hospital row pushes `/hospitals/<id>`; the hospital page hides empty phone rows and the Services section when `services` is empty; "Doctors here" pushes `facility_id`. Deep link `/hospitals/<slug>` opens the page. No overflow at 320 px.

## Phase 9: Hospital-service booking

A patient books one of a hospital's services (a check-up package, for example) for a date and a preferred time, the same booking the web's `HospitalServiceBookingModal` makes; the hospital then contacts them to confirm.

1. **Route** `/hospitals/:idOrSlug/services/:serviceId/book`, pushed above the shell from a service row's "Book" on the hospital page. The page hands the `Hospital` and service over through a provider. On a cold deep link, fetch `GET /hospitals/{location}/` again (it is in the patient surface) and find the service in `services[]`; not there → "This hospital doesn't offer this service" with a way back.
2. **Form:**
   - summary: service name, hospital `display_name`, area;
   - date strip: today to today + 6 days (Asia/Dhaka); the server accepts up to 30 days ahead;
   - preferred time chips: "Morning (9 am–12 pm)", "Afternoon (12–4 pm)", "Evening (4–8 pm)", "Any time". The server stores `preferred_time` as free text (max 50 characters, the web uses a text box with "10:00 AM"); send the chip's English label so staff can read it in either app language;
   - patient name, phone, optional age and gender, optional notes; prefill from `patients/lookup` and the last patient, as in Phase 5;
   - no price: hospital services carry no fee in the API, so show none.
3. **Submit:** OTP sheet with `purpose: hospital_service_booking`, then new `BookingRepository.bookHospitalService` → `POST /bookings/hospital-service/` with `{hospital_id, service_id, booking_date, preferred_time, patient_name, patient_phone, patient_age?, patient_gender?, notes?, otp_code}`. `hospital_id` is the hospital's `id` (a hospital's id is its location id). Never send the legacy keys `hospital`, `service`, `date` or `gender`: they now return 400.
4. **Response model** `HospitalServiceBookingResult` (`id`, `status`, `booking_date`, `preferred_time`, `service_name`, `facility`). Errors: `service_id` ("does not offer the selected service") and `hospital_id` ("inactive") → message and back to the hospital page; `booking_date` → under the date strip.
5. **Success:** service bookings are created `pending`, so the success screen says "Request received — {hospital} will contact you to confirm", with service, date, preferred time and the Booking ID (first 8 characters of `id`). Save a `BookingItem` with `type: service`, kind label "HOSPITAL SERVICE", `status`, the hospital's `phone` for the Bookings tab's "Call" button.
6. Add `GET /hospitals/{location}/` and `POST /bookings/hospital-service/` to PLAN.md §4 if Phase 0 missed them.

**Done when:** integration test on a mocked adapter: the request body has `hospital_id`, `service_id`, `booking_date`, `preferred_time`, `otp_code` and none of the legacy keys; the success screen shows no serial and no price; the item appears in the Bookings tab. Manual on staging: one service booking succeeds and shows in the admin panel.

## Phase 10: Bookings tab, invented data, final checks

The Bookings tab shows each booking's real state, no screen shows a made-up value, and the whole app passes one end-to-end run on staging.

1. **Bookings tab** (`bookings_screen.dart`):
   - tag per item: `confirmed` → "Confirmed"; `pending` doctor request → "Awaiting confirmation"; `pending` test → "Awaiting lab"; pending hospital service → "Awaiting hospital"; `unknown` (migrated v1 items) → no tag;
   - serial shown only for confirmed doctor bookings; time shown as the session window plus "approx. {time}" when present;
   - a pending request past its `confirm_deadline` shows "Not confirmed in time. If you didn't get an SMS, call the chamber." (the server has marked it `expired`, but the app can't read that; see gaps);
   - "upcoming" = session end (or test date end of day) is after now in Asia/Dhaka, not just "date ≥ today";
   - Cancel stays local: remove the item and show "To cancel, call {facility}" with a `tel:` button when `facility.phone` is known. There is still no patient cancel endpoint.
2. **Invented-data sweep.** `grep -rnE "'General Physician'|'Chamber'|'Lab Test'|'Diagnostic Lab'|'Diagnostic Test'|DH-|TEST-|'2024-01-01'|'18:00'|\?\? 0\.0" lib` and decide every hit:

   | The code | Decision |
   | --- | --- |
   | A fallback that looks like real data (a specialty, facility, test name, date, time, ref, price) | removed: show nothing or a neutral label |
   | A route param default (`date ?? '2024-01-01'`, `slot ?? '18:00'`) | removed: a missing param shows the error state and a way back |
   | A price defaulted to 0 | removed: null price shows "Price confirmed at the lab" or nothing |
   | Empty-state or error copy ("No doctors found") | kept |
   | Rating and review-count defaults | kept (product exception) |
3. **Strings.** Every string added in Phases 1–9 exists in `app_en.arb` and `app_bn.arb`; `flutter gen-l10n` reports no untranslated keys. Bangla screens use `_bn` facility fields where present.
4. **Final checks** on staging, paste results in the report:
   - `flutter analyze` 0 issues; `flutter test` all pass; `tool/smoke.dart` 200 on every endpoint;
   - one booking per mode: instant (serial shown), request ("we'll call you", then confirm it in the admin panel and check the SMS), call-only (numbers after OTP);
   - one lab visit and one home-pickup test booking; one hospital-service booking started from the Hospitals tab;
   - the update gate: set `APP_ANDROID_MIN_BUILD` on staging above the installed build → the update page appears on the next request; set it back;
   - one full pass in Bangla;
   - `grep -rn "/api/[a-z]" lib | grep -v "api/v1\|app-config"` returns nothing.
5. Tell the backend owner the app is on v1, so v1 can be frozen (`API_FROZEN_VERSIONS`) on the day the first store build ships.

**Done when:** every check in step 4 passes and the sweep table has a decision for every grep hit.

## Backend gaps and owner decisions

The plan works around every gap below without new endpoints; each one goes into `docs/BACKEND_GAPS.md` in Phase 0.

**Backend gaps found while reading the code**

| # | Gap | Where | What the app does meanwhile |
| --- | --- | --- | --- |
| G1 | `Hospital` and `DiagnosticCenter` in `openapi.v1.json` omit the facility fields `to_representation` adds (`name`, `display_name`, `address`, `area`…). Generated models would be wrong. | `facilities/serializers.py` | hand-parses the real payload (Phase 2) |
| G2 | OTP is optional on `/bookings/doctor/` and `/bookings/test/` (checked only when `otp_code` is sent); `123` / `123456` still pass everywhere; `send` returns the code when `DEBUG`; `patients/lookup` returns data for any phone. | `bookings/serializers.py`, `bookings/views.py` | always sends OTP (Phase 4) |
| G3 | The "verified in the last 10 minutes" fallback ignores `purpose`. | `verify_otp_helper` | never relies on it |
| G4 | No patient-readable booking status. A request becomes confirmed, cancelled or expired on the server; the app only hears by SMS. Ask: a status read keyed by booking id + phone (or a token returned on create). | patient surface | deadline message (Phase 8) |
| G5 | No patient cancel endpoint. | patient surface | local remove + "call the chamber" |
| G6 | No single lab-offering read in the patient surface, so a cold deep link to a test booking can't load. | `/facility-tests/{id}/` not in `PATIENT_SURFACE` | "not loaded" state (Phase 3) |
| G7 | `display_order` still not serialized on specialties. | `DoctorSpecialtySerializer` | sorts by doctor count |
| G8 | Test bookings have no time field. | `TestBooking` | window in `notes` |
| G9 | Error codes come as a list in 400s (`{"code":["…"]}`) but a string in 409s, and `detail` mixes English and Bangla in one string. Ask: plain-string `code`, separate `detail_en` / `detail_bn`. | `bookings/services.py`, `views.py` | reads both forms; copy from ARB |

Two web-client bugs seen on the way (not this plan's scope): `getRequestByCode` calls `/bookings/requests/{code}/`, but the route is `/bookings/request-links/{code}/`; and the web call modal sends `age` / `gender` instead of `patient_age` / `patient_gender`, and verifies the OTP before posting the lead, which works only through the G3 fallback.

**Decisions (answered Oct 13)**

- [x] Request mode hides the next serial before submit: **yes**.
- [x] Booking reference = first 8 characters of the booking id: **keep as is**.
- [x] OTP: **implement it as the web and backend do** (Phase 4): send, then post the code with the booking or lead, on all four flows.
- [x] Hospital-service booking: **include it** (Phase 9).
- [x] Hospitals gets its own tab in the bottom bar (Phase 8).
