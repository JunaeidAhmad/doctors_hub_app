# Backend gaps

Status of the original gaps found while building the specialty taxonomy v3:

1. **Stale contract copy.** *Closed:* Phases 0+1 of `docs/v1-migration-plan.md` replace the old `openapi/schema.yaml` with `openapi/openapi.v1.json`, the source of truth.
2. **`display_order` is not serialized.** *Still open.* `DoctorSpecialty` has `display_order` (taxonomy curation order 1–24) but `DoctorSpecialtySerializer.fields` omits it, and the list view orders by `name`. The app sorts by doctor count desc as an approximation. Request: include `display_order` and allow `?ordering=display_order`. (v1-migration-plan G7)
3. **Umbrella `doctor_count` is direct-only.** *Closed:* the backend now fills `doctor_count` from aggregated umbrella + leaf counts.

## Open gaps from the v1 migration (`docs/v1-migration-plan.md`)

The plan works around every gap below without new endpoints.

| # | Gap | Where | What the app does meanwhile |
| --- | --- | --- | --- |
| G1 | `Hospital` and `DiagnosticCenter` in `openapi.v1.json` omit the facility fields `to_representation` adds (`name`, `display_name`, `address`, `area`…). Generated models would be wrong. | `facilities/serializers.py` | hand-parses the real payload (`FacilitySummary`) |
| G2 | OTP is optional on `/bookings/doctor/` and `/bookings/test/` (checked only when `otp_code` is sent); `123` / `123456` still pass everywhere; `send` returns the code when `DEBUG`; `patients/lookup` returns data for any phone. | `bookings/serializers.py`, `bookings/views.py` | always sends OTP |
| G3 | The "verified in the last 10 minutes" fallback ignores `purpose`. | `verify_otp_helper` | never relies on it; posts `otp_code` with the booking/lead |
| G4 | No patient-readable booking status. A request becomes confirmed, cancelled or expired on the server; the app only hears by SMS. Ask: a status read keyed by booking id + phone (or a token returned on create). | patient surface | deadline message on the Bookings tab |
| G5 | No patient cancel endpoint. | patient surface | local remove + "call the chamber" |
| G6 | No single lab-offering read in the patient surface, so a cold deep link to a test booking can't load. | `/facility-tests/{id}/` not in the patient surface | "This test isn't loaded" state with a way back |
| G7 | `display_order` still not serialized on specialties. | `DoctorSpecialtySerializer` | sorts by doctor count |
| G8 | Test bookings have no time field. | `TestBooking` | window in `notes` |
| G9 | Error codes come as a list in 400s (`{"code":["…"]}`) but a string in 409s, and `detail` mixes English and Bangla in one string. Ask: plain-string `code`, separate `detail_en` / `detail_bn`. | `bookings/services.py`, `views.py` | reads both forms; copy from the ARB files |

Two web-client bugs seen on the way (not the app's scope): `getRequestByCode` calls `/bookings/requests/{code}/`, but the route is `/bookings/request-links/{code}/`; and the web call modal sends `age` / `gender` instead of `patient_age` / `patient_gender`, and verifies the OTP before posting the lead, which works only through the G3 fallback.
