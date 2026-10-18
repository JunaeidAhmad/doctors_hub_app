# Backend gaps

Status of the original gaps found while building the specialty taxonomy v3:

1. **Stale contract copy.** *Closed:* Phases 0+1 of `docs/v1-migration-plan.md` replace the old `openapi/schema.yaml` with `openapi/openapi.v1.json`, the source of truth.
2. **`display_order` is not serialized.** *Closed (2026-10-18):* the backend serializes `display_order` and accepts `?ordering=display_order`; the app sorts by it when present.
3. **Umbrella `doctor_count` is direct-only.** *Closed:* the backend now fills `doctor_count` from aggregated umbrella + leaf counts.

## Gaps from the v1 migration (`docs/v1-migration-plan.md`)

The backend's 2026-10-18 update ("Backend gap fixes (G1–G10)") closed most of these.

| # | Gap | Status |
| --- | --- | --- |
| G1 | `Hospital` / `DiagnosticCenter` schemas omit the flat facility fields `to_representation` adds. | *Closed:* response payloads unchanged; the OpenAPI schemas now declare the flat fields (`FacilityResponseFieldsMixin`). |
| G2 | OTP weaknesses (`123`/`123456` universal, DEBUG `otp` echo, unverified lookup). | *Closed backend-side:* OTP is required for anonymous bookings (`400 {code: otp_required}`); bypass codes and the `otp` echo are DEBUG/TESTING-only; lookup is scoped. The app always sends `otp_code`. |
| G3 | The "verified in the last 10 minutes" fallback ignores `purpose`. | *Closed:* the fallback is now scoped by `purpose`. |
| G4 | No patient-readable booking status. | *Closed for doctor bookings:* `GET /bookings/doctor/{id}/status/?phone=` (anonymous; phone must match). Still open for test and hospital-service bookings — the app keeps local tags and the deadline copy there. |
| G5 | No patient cancel endpoint. | *Closed for doctor bookings:* `POST /bookings/doctor/{id}/patient-cancel/ {patient_token, reason}` cancels pending requests and confirmed bookings. Test/service bookings remain local-remove only. |
| G6 | No single lab-offering read in the patient surface, so a cold deep link to a test booking can't load. | *Still open:* "This test isn't loaded" state with a way back. |
| G7 | `display_order` still not serialized on specialties. | *Closed:* serialized, plus `?ordering=display_order`; the app sorts by it. |
| G8 | Test bookings have no time field. | *Closed:* nullable `preferred_time` ("HH:MM"), accepted on create and returned in payloads; the app sends the picked window start instead of stuffing it into `notes`. |
| G9 | Error `code` list-vs-string and mixed-language `detail`. | *Closed backend-side:* ApiError/ConflictError use the flat `{code, detail, detail_bn}` envelope (plain-string code, separate en/bn); DRF field errors keep their per-field shape. Request-link 404/410 bodies also carry `code`/`detail_bn`. The app reads `code` as string-or-list and keeps ARB copy for user-facing text. |
| G10 | `confirm_code` not serialized. | *Closed:* `confirm_code` plus a new `patient_token` are in the create response; status and patient-cancel are keyed by them. Minor schema drift: `patient_token` is injected in the view but not declared on the serializer, so it is absent from the OpenAPI schema (the app parses it tolerantly). |

**Patient lookup privacy change (2026-10-18):** anonymous callers get `{found: bool}` only
(the patient payload requires authenticated staff). The app's phone-prefill used the
anonymous lookup, so it was removed; prefill now comes only from the last patient saved on
the device.

**Web-client bugs seen on the way (not this app's scope):** both fixed in the web client in
the 2026-10-18 update — `getRequestByCode` now calls `/bookings/request-links/{code}/`, and
the call modal sends `patient_age` / `patient_gender` / `otp_code`.
