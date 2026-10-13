# Backend gaps (specialty taxonomy v3)

Found while building the grouped specialty dropdown. No new endpoints were
called; all data comes from `GET /specialties/?canonical_only=true` (§4).

1. **`openapi/schema.yaml` is stale.** The committed copy has no
   `is_umbrella`, `is_popular`, `formal_name`, or `parents` on
   `DoctorSpecialty`, but `DoctorSpecialtySerializer` already returns them.
   Action: re-fetch `/api/schema/` into `openapi/schema.yaml`.

2. **`display_order` is not serialized.** `DoctorSpecialty` has
   `display_order` (taxonomy curation order 1–24) but
   `DoctorSpecialtySerializer.fields` omits it, and the list view orders by
   `name`. The app currently sorts umbrellas by aggregated doctor count desc
   as an approximation. Request: include `display_order` and allow
   `?ordering=display_order`.

3. **Umbrella `doctor_count` is direct-only.** The list queryset annotates
   `Count('doctors')`, which is ~0 for umbrellas (doctors are tagged with
   leaves). `specialty_doctor_counts()` already computes distinct
   umbrella+children counts. Request: use the aggregated count for
   `is_umbrella=True` rows so clients don't have to approximate with sums.
