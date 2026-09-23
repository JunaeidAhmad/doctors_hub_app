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
