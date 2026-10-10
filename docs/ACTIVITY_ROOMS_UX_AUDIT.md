# Separate activity rooms — build 10

Orbit Bloom is a native iPhone/iPad garden arcade with a light botanical palette. The player needs to distinguish the puzzle campaign from planting and driving, enter the intended activity, and find a reliable route back. This focused audit used the mobile-app-ux-auditor skill, native views, routing, save code, simulator interactions and screenshots. It preserves the established wallet, sequential island unlocks and guest/account flows.

## Findings and implementation

| Priority | Evidence before the change | Player impact | Implemented change |
| --- | --- | --- | --- |
| P1 | Farm and Rally were small decorative gates beside the puzzle path in GardenView. | Two different activities looked like scenery or campaign stops. | Separate labeled room entrances, each with its own 3D miniature, purpose, Enter label and no-life-cost explanation. |
| P2 | The Rally lobby reused LivingGarden artwork. | The player could not recognize a driving destination before starting. | Original 3D garage, rover, orchard and marked route preview with start, pickups and finish landmarks. |
| P2 | Farm was a uniform grid; the room exit looked like a secondary text link. | The place and escape route were difficult to read. | Farm terrace map with six numbered interactive plots; prominent Exit Farm room / Exit Rally room controls naming the Island destination. |
| P2 | Plot status used light text against a light surface. | Planting and harvesting states had weak contrast. | Dark status text and a darker green harvest state. |

Before: island → decorative gate → farm grid or generic garden hero → small return link. After: island → labeled Farm/Rally room door → distinct activity map → explicit Island exit. The tool shed stays inside the Farm room, accessible by its labeled button or a horizontal swipe. Rally's active road also names its exit destination. The puzzle retains its separate life-aware Back/abandon confirmation.

The initial native check found the room entrances exposed as accessibility containers rather than buttons; removing the extra wrapper restored proper button traits and stable existing openFarm/openRace identifiers. Screenshot review found duplicated text shadows and an invisible extruded route. Compositing the card before its shadow and drawing a continuous ground-plane road mesh fixed both. Tall iPad views also cropped the diorama's sides; the camera now fits both the available width and height during layout and rotation. Initial diagnostic failures are excluded from final passing evidence.

## Visual and interaction system

ActivityRoomView builds original SceneKit meshes for terrain, greenhouse/garage, pond, flowers, orchard trees, route markings and a small delivery rover. Rounded geometry, physically based materials and directional shadows give the rooms depth while retaining the game's colors and sprite art. Interactive crops use the existing illustrated sprite assets on tilted beds over the 3D terrace; they are not fully modeled 3D crop meshes. The road is a preview of the existing 440-metre rally, not additional playable tracks.

Door miniatures are static. Detailed maps render at 30 fps, cache their scene across farm timer updates and release it when leaving. Reduce Motion disables the rover's idle action and room crossfade. Entrances stack at accessibility text sizes. Doors, exits, plots and race actions have descriptive labels; decorative SceneKit trees are hidden from the accessibility hierarchy. Existing account, shop, pause, purchase and save screens remain reachable from the HUD and established flows.

## Verification and limits

The new room UI case checks both door labels and non-overlapping bounds, all six live plots, actual planting, room exits, route identity, real swipe steering, crafting access, save retention after leaving/relaunching, accessibility-medium text and absence of vertical scrolling. The iPad release case also rotates the Farm map to landscape and checks all six plots and exit bounds. Native room captures and exact final counts are in [build 10 verification](release-draft/build10/verification.json) and [TEST_REPORT.md](TEST_REPORT.md).

The skill's static scan examined 55 files before and 56 after, with P0=0, P1=21, P2=7, P3=0 in both runs. These are triage signals, including research code and decorative images already hidden from accessibility, not confirmed defects or an app-wide accessibility score. Logs are evidence/build10-mobile-static-scan.txt and evidence/build10-mobile-static-scan-after.txt.

Physical VoiceOver speech, extreme text sizes, smaller phones, battery/frame-rate profiling, live Game Center/iCloud round trips and signed sandbox purchases require device checks. The simulator checks establish the specified room flows and bounds, not universal accessibility or hardware performance.
