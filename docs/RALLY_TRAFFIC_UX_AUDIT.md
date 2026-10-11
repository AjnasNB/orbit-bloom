# Rally traffic guide — 11 October 2026

Orbit Bloom is an iPhone/iPad garden arcade with a cartoon world and seven connected rooms. This pass addresses understanding and accessibility in the existing Harvest Rally flow. Its stakes are a short run, unbanked coins and optional farm cargo; no purchase or puzzle life is required.

| Priority | Evidence and impact | Change |
| --- | --- | --- |
| P1 | The adjustable road exposed only the player's current lane. A VoiceOver player had no description of the next collision or pickup lane. | A core `nextTraffic` preview uses the actual unresolved crossing. Both the road and guide expose numbered lanes; VoiceOver receives brief barrier/coin announcements during active play. |
| P2 | The road rendered a variable obstacle range without explicit IDs, while its count changes from 10 to 18 across traffic tiers. | Give each obstacle its crossing ID so the rendered set follows the difficulty count. |
| P1 | Maximum accessibility text pushed Start rally out of the viewport. Later screenshots exposed truncation in three-lane labels despite passing position checks. | Shorter lobby copy, a compact illustrated route, stacked safety information, shorter exit/pause actions and bounded text scaling in the dense HUD/diagram. Full traffic descriptions remain available through accessibility values. |

Before: enter room → read instructions → start → infer all traffic from the moving road.

After: enter room → start → read the three numbered next-traffic lanes → swipe horizontally or adjust the road with VoiceOver → pause with both the road and preview frozen → resume or take the visible exit. Result rewards retain the existing save and life rules.

The original SceneKit room, cartoon rover, collision shapes, audio, coin flights and normal navigation remain. The lane diagram uses words, numbers, icons and a current-lane outline as well as color. VoiceOver cues stop while paused or inactive; its lane adjustment still respects pause. The three-column diagram, counters and secondary steering hint scale up to the largest regular text size to preserve the playable arena. Primary large-text instructions and actions remain scalable.

The mobile UX skill's static scan inspected 68 Swift/iOS files and reported 46 P1 and 11 P2 signals. These are triage signals, including reference-project files and false positives on explicitly hidden decorative images. They are not 57 verified app defects. This change is based on the actual road semantics, range, simulator interactions and native screenshots.

Build-14 verification records the final core/native/phone/iPad runs and original screenshots in `release-draft/build14/`. The initial out-of-bounds lobby failure and the timed UI-test steering failure remain separately recorded. The latter test had waited through the first live crossing before steering; immediate real swipe input replaces that extra polling delay. No fake result or reward shortcut was used. The final phone bundle also retains a room-relaunch entrance failure; the test now waits for the fresh home view and resolves new entrance queries, and the focused rerun passes.

Physical VoiceOver speech timing/focus, hardware performance/audio and smaller phones remain unverified. High-tier speech usability needs a device walkthrough; deterministic engine pickup checks do not establish human reaction time. The accessibility result screen was not exercised at maximum text size in this focused pass.
