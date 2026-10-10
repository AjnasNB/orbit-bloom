# Connected garden and board redesign — build 12

## Brief and reference research

The user supplied a Gardenscapes puzzle reference and asked for a bigger, consistent map with intuitive game controls. Chrome inspection of [Playrix’s official Gardenscapes page](https://playrix.com/games/gardenscapes) and the [official iPhone screenshot gallery](https://apps.apple.com/us/app/gardenscapes/id1105855019) showed a dominant board, a dedicated goal/move rail, a booster rail, dimensional pieces, and an inhabited garden environment. These are layout observations, not evidence about proprietary game rules or implementation. No Playrix art, character, brand, screenshot or code is included in the app.

Applied skill: `/Users/ajnasnb/.agents/skills/mobile-app-ux-auditor/SKILL.md`.

## Findings and implementation

| Priority | Evidence before | Fix |
| --- | --- | --- |
| P1 | Root constrained GardenView to 650 points. Stacked room cards, title, primary action and project card left a small separate diorama. | The home map fills its safe-area viewport. Compact floating HUD, task button and dock retain readable named room entrances. |
| P1 | Each campaign page replaced a boxed floating island; scenery did not connect beyond its border. | Original SceneKit terrain, river and promenade extend beyond the viewport. Current and neighboring seeded districts share the same palette, cottage, fountain, bridges, fruit trees and flower beds. The route continues off both edges. |
| P1 | Puzzle used one narrow vertical column on iPad landscape. Goal, booster and utility rows competed with the board. | iPad landscape uses goal/turn and booster side rails. Portrait uses a compact mission strip and bottom controls. Warm recessed tiles, larger original botanical sprites and an azure stone courtyard improve separation. |
| P1 | A real board-power test tapped just after shuffle and the turn stayed unchanged: the visual piece was still traveling while its model target had moved. | Shuffle uses a finite 450-ms animation and a 500-ms input lock. Final coordinates and one spent shuffle are saved before animation, and a run token prevents an old completion reopening a new attempt. |
| P2 | Booster shadows were being applied separately to label glyphs. | Composite each booster and level control before applying its outer shadow. |
| P1 | The iPad exit check reported a 24.5-point accessible Keep playing target when its minimum frame was outside the Button label. | A visible 48-point label surface now owns the confirmation button’s target. |
| P2 | Active puzzle balances had shop action labels despite being unavailable. | Read-only balance labels now describe actual lives/coins. Back and pause retain explicit confirmation and life accounting. |

The existing 1,020 stages, 102 district pages, progressive difficulty, seven activities, paid-item economy, private Apple saves and unlock rules remain implemented by their existing models. Horizontal swipes turn map pages; locked districts offer a return to the open district rather than a start bypass. There is no vertical map scrolling. All level buttons remain native, labeled and at least 54 points; room and utility controls retain at least 44-point targets. Accessibility actions provide page changes without gestures. Decorative SceneKit/Canvas elements do not handle input or participate in accessibility.

Scene geometry is limited to three districts, not all 1,020 stops. Static scenery requests no continuous idle animation; resizing updates camera framing and teardown releases the scene. Reduced-motion settings suppress interactive transition/press animation. This is a bounded implementation, not a measured hardware-performance claim.

## Verification

See the build-12 section of `TEST_REPORT.md` and `release-draft/build12/verification.json` for final test results and native screenshot provenance. Historical build-11 results and submitted screenshots remain separate.

The static mobile scan was triaged: its reported missing labels include intentionally accessibility-hidden decoration, vendor samples and controls with labels on their enclosing buttons; its notification finding includes accessibility announcements. Scanner counts are suggestions, not confirmed issue totals. Automated target/frame checks and real gameplay gestures are the primary evidence for these changes. Physical VoiceOver speech/focus, smallest hardware, iPad split view, hardware performance/audio and human difficulty require separate checks.

## Distribution boundary

Build 11 was submitted to Apple and recorded Waiting for Review on 10 October. Build 12 is a subsequent UI revision. Updating source or the local preview does not change the submitted binary. Do not upload build-12 screenshots as if they were captured from build 11, and do not cancel the existing review automatically for this UI request.
