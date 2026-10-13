# Doctors Hub patient app — rules for coding agents
- Read docs/PLAN.md first. Work one phase at a time; don't start the next phase unasked.
- The design artifact is the visual spec. Match spacing, borders (2px ink, no radius), and copy exactly.
- Never hard-code colours or text styles in features; use core/theme tokens.
- All user-facing strings go in l10n/app_en.arb and app_bn.arb.
- Only call endpoints listed in PLAN.md §4. If you need data that isn't there, stop and write the gap in docs/BACKEND_GAPS.md.
- Check DTO fields against openapi/openapi.v1.json before writing them. Don't guess field names.
- After each task: build_runner, flutter analyze (0 issues), flutter test. Fix before moving on.
- Don't edit generated files by hand.
- Don't add packages outside PLAN.md §3 without noting why in the commit message.

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
