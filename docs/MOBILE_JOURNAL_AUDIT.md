# Field journal accessibility audit — 10 October 2026

| Priority | Flow and evidence | Player impact | Implemented change |
| --- | --- | --- | --- |
| P2 | The build 7 [iPad reward capture](release-draft/product-page/captures/ipad-11-field-tasks.png) truncates the help sentence; `FieldJournalView` used fixed three-reward/four-power pages. | Assistance prices and formation instructions become difficult to read in a narrow sheet or with larger text. | Wrap the full copy and adapt page capacity to available height and Dynamic Type. |
| P2 | Journal navigation depended on horizontal dragging. | VoiceOver users lacked a named page adjustment control. | Add an adjustable “Journal pages” value, descriptive reward actions and Reduce Motion-aware page updates. |

Orbit Bloom is a native iPhone/iPad garden arcade with a light botanical palette and dimensional sprites. This focused change keeps the existing journal entry point, reward rules, native sheet exit, assistance prices and horizontal swipe interaction. The primary loop remains island → puzzle/farm/rally → persistent progress; sign-in, supply purchases and settings retain their current routes.

Before: two fixed reward pages and one fixed power page, regardless of text size or sheet height. After: one to three rewards or one to four powers per page, full wrapping, an inline navigation title, a visible page count and an adjustable accessibility action. Accessibility text places the claim button below the reward description. The selected entry survives a change in page capacity, preventing rotation from taking the player back to unrelated entries. No vertical scrolling was added.

SwiftUI implementation is in `OrbitBloom/Views/RootView.swift`, using GeometryReader, DynamicTypeSize, native accessibility actions and the existing palette. Each claim target remains at least 44 points high. Decorative headings yield space at accessibility text sizes; formation diagrams retain spoken labels.

The skill's static scan examined 56 files and reported P0=0, P1=20, P2=6 and P3=0. Its findings are heuristic: included research code and image controls already hidden from accessibility require manual interpretation. The full local output is `evidence/build8-mobile-static-scan.txt`; this is a focused journal correction, not a claim that every static signal or app-wide accessibility concern has been resolved.

Verification: the real iPhone UI traverses all six rewards and four powers at the first accessibility text size, checks bounds, non-overlap, reachable controls, both end boundaries and zero scroll views. The connected farm flow checks claiming, crafting and saved progress; iPad checks full wrapping in portrait and power controls in landscape. Actual captures, test results and exact counts are recorded in [TEST_REPORT.md](TEST_REPORT.md) and [build 8 verification](release-draft/build8/verification.json).

VoiceOver speech/focus order, its adjustment gesture on hardware, all extreme text sizes and smaller devices remain unverified. The page adjustment is implemented and statically reviewed; the automated traversal uses real touch swipes, not VoiceOver. Live Apple account/cloud/purchase checks retain the existing limitations.
