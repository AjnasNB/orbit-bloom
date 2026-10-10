# Seven-room UX audit

This audit starts with observed friction and the remaining verification work. It uses the mobile-app-ux-auditor workflow, current SwiftUI/core source and read-only native logs. The latest 10 October 2026 evidence records 107 unique passing cases across runs: 49 core, 47 native, nine iPhone and two iPad. Both fresh valid iPad bundles pass; galleries are exported and QA simulators shut down. Build 11 was submitted at 16:47 India time and is Waiting for Review, with twenty matching native screenshots processed and internal TestFlight QA assigned. Apple approval and real-player cloud/ranking/purchase verification remain distinct from that submission.

## Findings

| Priority / state | Screen or flow | Evidence | Player impact | Response or next check |
| --- | --- | --- | --- | --- |
| P1, corrected; targeted traversal passed | Room directory swipes | `build11-native-rooms2.log` lost `islandHub` during a swipe. The original simultaneous drag also triggered a room button. `IslandHubView`, `WorldEventsView` and `RoomRecordsView` now use a high-priority horizontal drag. NativeRooms4's seven-door traversal passed. | Browsing could unexpectedly enter a game or activate an action. | Keep the gesture cancellation rule; verify action-page drags as well as ordinary room taps. A drag is not a purchase, claim or ranking action. |
| P1, corrected; phone and iPad checks passed | Activity targets and short-height layout | NativeRooms2 exposed an activity-toolbar bounds failure. NativeRooms3 reported targets about 21 and 20.3 points high. Current activity chrome has explicit 48-point buttons, a compact layout and separate help. FinalPhone's largest-text case passed in 262.032 seconds; the fresh iPad seven-room portrait/landscape case passed in 210.940 seconds. | An exit or game tile could be difficult to hit or leave the visible area. | Retain those bounds/target checks. Smaller phones, split-screen and physical low-vision checks still need their own evidence. |
| P1, corrected; maximum-text rerun passed | Maximum-text event/record sheets | NativeRooms4 failed at line 205 waiting for event/offline controls. Event/record roots now explicitly contain accessibility children before their identifiers. FinalPhone passed the complete nine-event-page and eleven-record-page flow with the child-specific assertions. | Missing child discovery prevented verifying the event state and action. | Keep the explicit containers and real child assertions. The passing native tree/bounds checks do not establish physical VoiceOver speech or live Apple ranking behavior. |
| P1, addressed in design; comprehension still needs player testing | Discovering the shared garden and seven games | `RootView` retains the campaign island, named Farm/Rally doors and adds `openIslandHub`. The hub gives Lio a story, the actual next restoration project, named mechanics and distinct miniatures. NativeRooms4 found all seven destinations and their exits. | A collection of unrelated buttons did not explain why the activities shared resources or where the player was. | Keep the visible domain and concrete room labels. Ask new players to explain what stars restore and how to return; automated traversal does not prove comprehension. |
| P2, corrected; skill and seven-door return flows passed | Re-entering after a room clear | `RootView` retains `selectedHubRoom` and passes `initialRoom`. RoomReturnFinal's four-win case passes in 103.084 seconds with direct returned-door checks. NormalGallery's corrected seven-door case passes in 65.450 seconds, reopening the hub after the intentional Farm/Rally Island exit. | Replaying the keeper welcome after every success added an unnecessary choice step. | Keep both verified paths: skill results return to their room door; Farm/Rally retain the labeled Island exit and reopen the hub at their retained door. |
| P2, guarded; basic help flow passed | Large-text help-sheet pagination | Help now uses a high-priority 35-point drag. FinalPhone's maximum-text case passed real help swipes and Done taps. The test swipes instruction text rather than starting on Done. | A swipe begun on the close control could compete with its tap action. | Retain the verified basic help flow; a focused drag-on-Done check remains useful. No such conflict is claimed as a confirmed native failure. |
| P2, explicit current product rule | Leaving or closing a new skill room | `IslandActivityView` pauses on scene inactivity but stores the current attempt in local view state. Exit hints, normal-size footer, pause copy and paged help state that unfinished attempts are discarded. Completed results go through `GameModel.completeActivity()` and durable saving. | Players may assume an Apple-backed garden also resumes an unfinished pipe, memory, timing or star-tile board. | Retain the save boundary in entry/help/review copy and test interruptions with players. Consider persisting these attempts separately if that expectation is common. Never advertise that every unfinished activity resumes. |

The remaining entries describe follow-up friction or verification conditions, not new confirmed failures. No P0 defect is established by this scoped audit. That does not replace the broader save, purchase and release checks.

## Design read and player problem

Orbit Bloom is a native, portrait-first garden arcade for iPhone and iPad. Its intended player wants short, varied activities that visibly contribute to a place they understand. The implementation is under build-11 integration testing. Its visual register is a bright botanical island, warm paper surfaces, dimensional pieces, a character portrait and small original 3D scenes. Optional purchases and account saves raise the importance of clear costs, durable rewards and truthful status.

The user's concern was concrete: Farm and Rally were difficult to distinguish, the garden felt like disconnected pages, and navigation did not convey a lived-in game world. Seven destinations must therefore explain their actions and purpose, show a visible exit, and remain legible without a vertically scrolling menu. A miniature alone is not a usable room label.

Lio is a keeper apprentice restoring Aurora Atoll after the Great Eclipse disrupted its moonseed irrigation. The island is his domain. The greenhouse, moonseed beds, starlight pond, observatory, aurora grove and pollinators are the six ordered restoration projects already present in the progression system. The hub displays the actual project count, star balance and next project; each project costs two earned stars. The story supplies context for the existing economy rather than inventing completed construction or introducing a mandatory paid gate.

The seven-game combination uses familiar puzzle, farming, driving, memory, timing and spatial-game families with a shared restoration story. This is not a claim that these mechanics have never existed elsewhere.

## Navigation before and after

Before: campaign island → puzzle path or separate Farm/Rally entrances, with limited explanation of their shared purpose.

After: campaign island → Explore 7 rooms → Lio's story and actual restoration checkpoint → horizontal room pages → named activity → explicit exit or saved result → directory. Skill-room saving/exiting returns to the selected room page, verified by RoomReturnFinal. Farm/Rally retain their labeled Island exit; NormalGallery verifies reopening the hub at their retained door. The direct campaign, Farm and Rally entrances remain usable. The directory is a discovery route, not a replacement for the authoritative sequential campaign map.

| Flow | Current path and recovery |
| --- | --- |
| First launch | Loading screen advances automatically to the island. No account, payment or permission gate precedes local play. |
| Discover a room | `openIslandHub` → keeper welcome → `chooseIslandRoom` → named door. At accessibility sizes, story and project are separate pages. `exitIslandHub` stays available. |
| Bloom | The Bloom door returns to the campaign island. Select an unlocked stage and start its puzzle. Back opens an abandonment confirmation: the already spent life remains spent, with no second life charge. |
| Farm | Enter Farm Terraces through either entrance; plant, water and harvest six saved plots, or craft in the shed. The labeled room header returns to the island. |
| Rally | Enter the delivery lobby, read the route, start a 22-second run, swipe lanes, pause/resume, then finish and bank the actual result. The lobby has a visible island exit. |
| Four skill rooms | Enter the board, consult instructions, play, then explicitly save a win and return to that room page. Retry and restart have no life cost. Exiting an unfinished attempt discards it. Saved return/next-challenge behavior passed the focused four-win rerun. |
| Events | The island globe opens a native sheet. Each event identifies its time, goal, reward and action; Done closes it. Without a recent trusted clock, the page explains that rooms work offline and offers Retry clock. |
| Records | The trophy opens four personal records and ranking information. Completed local records remain visible without an Apple connection; worldwide ranking is an explicit optional Apple action. |
| Settings/account/supplies | Existing settings and shop flows remain available from the island. Account connection is optional. Supplies show StoreKit prices; the new rooms do not require a purchase to enter or understand a rule. |

All seven room destinations remain available. Campaign stops unlock sequentially; room availability is not an invented seven-step unlock chain.

## Exact room mechanisms and connected benefits

| Room | What the player does | What feeds the shared island |
| --- | --- | --- |
| Bloom Circuits | Swipe neighboring botanical pieces, make power formations and clear the stage goal/frost within its move budget. | Campaign stars, coins and farm water. One puzzle life is spent at start; a win returns it. |
| Farm Terraces | Plant roses/apples, water and harvest six persistent plots, then craft tools from compost. | Produce, compost, tools and delivery cargo. Crops use elapsed growth time. No puzzle-life cost. |
| Harvest Rally | Swipe horizontally between three lanes, avoid barriers and collect road pickups. Five difficulty tiers advance with successful deliveries. | Result coins and a farm-cargo delivery bonus. No puzzle-life cost. |
| Canal Weave | Tap a pipe to rotate it clockwise; connect the top-left inlet to the bottom-right outlet before turns run out. | Each newly cleared sequential challenge awards one star, 25 coins and two farm water. |
| Firefly Trail | Watch numbered lantern signals, then repeat the same sequence. Longer sequences/rounds increase the challenge. | The same first-clear reward; saved challenge count and personal best. |
| Windmill Works | Start the dial, then tap Charge inside its marked window. The window becomes tighter as levels advance; VoiceOver offers guided timing. | The same first-clear reward; saved challenge count and personal best. |
| Moon Observatory | Swipe a numbered star tile into the adjacent gap; order the chart left to right, row by row, with the gap last. | The same first-clear reward; saved challenge count and personal best. |

The campaign has 1,020 stages across 102 map pages, with ten ordered stops per page. The four new skill rooms each support up to 1,000 seeded procedural challenges; this is not 4,000 individually authored 3D worlds. Their completed rewards/records persist. Their unfinished attempts currently do not. Duplicate result collection cannot mint another first-clear star.

Optional world bonuses use shared UTC windows: a rotating skill event every six hours, active for three; a daily harvest event active for eight hours; and a convoy every 48 hours, active for six. The goals are three new featured-room clears, three harvested crops, or three successful deliveries, respectively. Bomb/TNT/Mega rewards require an active, completed, unclaimed window and a trusted online clock. Normal play remains available outside those windows. Displayed event times use the player's timezone.

## SwiftUI, accessibility and layout choices

- Native `NavigationStack` sheets keep Done visible for events and records. Named room exits and standard buttons remain the actionable controls; decorative scenery does not receive touch input. Explicit accessibility containers preserve the event/record roots and distinct child identifiers; FinalPhone's full largest-text flow passed those checks.
- Hub pages show two rooms normally and one when text/height needs it. Large-text or very short welcome pages split the story from the restoration checkpoint. `ViewThatFits` can substitute a concise door while preserving the room mechanic and full spoken reward/life rule.
- Hub, event and record page indicators expose adjustable accessibility values. The hub also exposes named next/previous actions. Swiping is not the only way for an assistive-technology user to change pages.
- Events divide into timing, goal/reward and action/status sections at larger text or short height. Records separate each room's score/completion, then ranking explanation and action. This produces nine event pages and eleven record pages in the compact accessibility layout rather than shrinking all details into one panel.
- The activity toolbar keeps explicit 48-point exit/restart/pause targets. Compact instructions move to a paged large-text help sheet; gameplay pauses while help is open. Restart asks for confirmation and explains what remains saved.
- Pipe controls speak their connected ports and whether water is flowing. Lanterns use numbers and names alongside color, and playback issues accessibility announcements. Star tiles expose their numbers and move actions. The windmill offers guided timing while VoiceOver is running.
- The directory, game outcomes and pause transitions respect Reduce Motion. Static SceneKit miniatures cache a room/restoration key, fit the available camera aspect and release their scene on dismantling. Periodic timer updates need not reconstruct unchanged room geometry.
- Compact gameplay chrome uses some fixed-size readable fonts to keep exits and boards usable. Fitting the viewport does not prove full text-scaling quality; physical low-vision and screen-reader checks remain necessary.

The scene miniatures are decorative previews with seven distinct models: flower board, beds, delivery road, canal, lantern trail, windmill and observatory. The native door is the hit target. The new `KeeperLio` and `RallyRover` artwork is original generated raster artwork; the race is an illustrated road game, not a claim of full 3D vehicle physics.

## Trust, saving and optional ranking

`GameModel.completeActivity()` validates the current room and sequential completion, credits the connected reward once and saves it. A native UI test collects all four wins through actual controls, verifies the coin increments and unchanged lives, relaunches with the saved state, then sees Challenge 2 and four earned stars. This proves that local path for the tested opening challenges; it does not prove a live iCloud round trip.

Apple Game Center connection and private Apple saved games are optional. iCloud Drive and matching Apple accounts are required for that cloud path. Schema-3 saves include journey/event records; active game state guards prevent a cloud restore from replacing an active game. The Cloudflare event endpoint supplies public server time and does not receive the app's player saves or purchase data.

Atoll Skills combines four personal-best scores; each is bounded to 20,000 and the total to 80,000. `RoomRecordsView` requires the SHA-256 key of the current authenticated Game Center player to match the connected account and active wallet, then checks identity again after asynchronous submission. Purchases, coin balances and lives add no ranking points. These client score/account checks are for non-prize rankings and do not establish server-side anti-cheat. The page must report Apple submission errors without pretending the score was accepted.

Retention comes from a restored place, saved completed progress, varied skills and optional timed bonuses. There is no requirement here for forced continuity, hidden exits, guilt, paid event entry or notification spam. Ordinary puzzles have five regenerating lives at 30 minutes each; the other six rooms stay life-free. Prices and purchase outcomes come from Apple rather than an invented local success screen.

## Static scan evidence

The existing `evidence/build11-mobile-static-scan.txt` reports 69 files scanned, Swift/iOS, P0=0, P1=38, P2=9, P3=0. This audit reads that artifact; it does not rerun the scanner or treat its counts as an accessibility score.

The scan includes research code and multiple images already marked `accessibilityHidden(true)`, illustrating why line-based image warnings need source inspection. It also flags VoiceOver announcements and notification-center subscriptions as permission/retention signals; those are accessibility events, not a user-notification permission request. Broad safe-area warnings include intentional background layers. Actual control bounds, spoken labels, focus behavior and re-entry therefore require native evidence beyond the scan.

## Latest verification evidence and limits

The union of recorded passing cases is **107 unique cases**: 49 core, 47 native, nine phone UI and two iPad UI cases, with repeated cases counted once. This is not a claim that earlier diagnostic bundles completed without failures. The corrected seven-door, normal capture and both fresh iPad cases now pass. Signed-package, screenshot and preview-preservation details belong to the build-11 release record; confirmed Apple delivery is recorded below.

| Latest passing evidence | What it establishes |
| --- | --- |
| `build11-core-final.log`: 49 core cases, zero failures | Campaign/room/economy/save rules. The solver completes 1,020 stages and six projects in 6,578 legal swaps and 23 retries without paid items/extra moves; not human difficulty or manual play of every stage. |
| Build11-NativeRooms4: 47 native units, zero unit failures | Seven journey, fifteen account, six purchase, nine session and ten clock cases. Its three-case UI diagnostic portion had one failure, recorded below. |
| Build11-FinalPhone: seven passing UI cases of eight | Back/life accounting, board powers/shuffle, One shot, separate Farm/Rally maps, all seven doors, maximum text including nine event/eleven record pages, and actual Rally pickup/banking. The four-win case failed on a compiled stale restoration-page assertion. |
| Build11-RoomReturnFinal: four-win case passed, 103.084 seconds | Four real-input wins, reward persistence, chosen-door return without welcome replay and next-challenge progression after relaunch. Its other case failed an invalid Farm/Rally exit expectation; the corrected case subsequently passed in NormalGallery. |
| Build11-NormalGallery: strengthened seven-door case passed, 65.450 seconds | Fresh keeper story, distinct destinations, normal exits, and retained room selection after reopening from the intended Farm/Rally Island destination. Its new capture case failed only a floating-point height comparison. |
| Build11-NormalGalleryFinal: one normal read-only capture case passed, 140.331 seconds | Keeper/four door pages, three real online event pages, five records, Apple Saved Garden and six shop packs, with unchanged coin/life balances and no purchase. The targeted final bundle has zero failures. |
| Build11-iPadRoomsVerified: one seven-room case passed, 210.940 seconds | Seven-room play surfaces and controls fit portrait/landscape without changing rewards. Fresh retained bundle: zero failures. |
| Build11-iPadReleaseVerified: one release-screen case passed, 52.812 seconds | Portrait/landscape native release captures with a fresh valid retained result bundle: zero failures. |

FinalPhone's maximum-text case passed in 262.032 seconds and Rally passed in 50.879 seconds. The earlier seven-door traversal passed in 51.600 seconds; its stronger corrected rerun passed in 65.450 seconds. Those are one unique case. The normal read-only gallery adds the ninth unique phone case.

The FinalPhone four-win diagnostic completed gameplay but queried `hubRestoration` while the retained room page was selected. Its corrected assertion pages back to inspect restoration and passes in RoomReturnFinal. The first failed bundle remains failed. The invalid RoomReturnFinal seven-door assertion was corrected to follow the actual Island exit and now passes in NormalGallery; its earlier bundle remains failed. The first normal capture run measured a 44-point target as `43.99999999999994`, failing the exact numeric comparison. A test-only `1e-6` epsilon addressed that floating-point residue; app code was unchanged and the capture rerun passed. None of those failed bundles is relabeled successful.

The updated isolated Cloudflare homepage and build-11 native preview asset deployed as version `1fe5fe66-69a0-4b46-a680-70fadf7a12d7`, recorded in `build11-site-final-deploy.log`. Root confirmed five HTTPS/security-route checks and the native normal event pages accepted the real public clock. This proves the observed content/clock connection, not server-side player storage, score anti-cheat, private Apple cloud or payment operation. Those route checks are not added to the 107-case test union.

On **10 October 2026 at 16:47 India time**, Apple received review submission **83b00d39-0873-4771-8bc9-5d94d4be04b4**: eight items comprising version 1.0 build 11, six in-app purchase packs and Atoll Skills. Its status is **Waiting for Review**. Twenty matching native gallery screenshots processed successfully; build 11 is assigned to internal TestFlight QA with one existing tester. This confirms submission and tester assignment. Apple approval/public availability and actual player-service round trips require separate confirmation.

### Earlier diagnostic evidence

The completed diagnostic NativeRooms4 run in `evidence/build11-native-rooms4.log` contains:

| Completed evidence at this snapshot | What it establishes |
| --- | --- |
| 47 native unit tests, zero failures | Seven journey tests, fifteen player-account tests, six purchase tests, nine session tests and ten world-clock tests passed in this run. Their models/mocks and StoreKit test configuration are not a live account or real-purchase certification. |
| `testAllSevenDoorsHaveDistinctRoomsAndClearExits` passed, 55.939 seconds | All seven entries were found, distinct play surfaces/lobby paths appeared, exits returned correctly, and only starting/abandoning Bloom spent a life. |
| `testFourNewRoomsWinThroughRealInputSaveRewardsAndAdvanceAfterRelaunch` passed, 93.612 seconds | Pipe rotations, lantern repetition, timed charging and star-tile moves produced actual opening wins; result collection credited saved rewards and next-challenge progression survived relaunch. |
| `testMaximumAccessibilityTextKeepsSevenRoomControlsEventsAndRecordsInBounds` failed, 161.521 seconds | Room/large-text activity checks reached the later event sheet, then the expected event-page or offline controls were not discovered within the wait. The log reports the assertion at line 205. |
| Overall selected UI run: three tests, one failure | NativeRooms4 remains a failed diagnostic run despite its 47 unit passes and two completed UI paths. At that stage the grouping, help-gesture and return-context changes awaited fresh evidence; the later runs above record their subsequent checks. |

Earlier NativeRooms2/3 failures remain diagnostic evidence, not passing release evidence. They exposed the swipe/button conflict and compressed hit targets described above. The Rally test was revised to separate slow accessibility assertions from a fresh controlled drive, since assertions consume real race time; the later FinalPhone result supplies its passing evidence.

Root owns the completed native results, screenshots, broader regression report, build/signing checks and release decision. After the failure, this scoped task applied only the authorized help-gesture and event/record accessibility-container corrections, and their syntax parse passed. It starts no native build, simulator, browser, purchase, upload or commit and does not clear the user's preview save.

During iPad QA, disk pressure required scoped cleanup of regenerable duplicate attachment/export-verification folders and the redundant early NativeRooms2/3 failed result bundles. Those two original bundles are no longer available locally; their raw logs cited here remain. The interrupted `Build11-iPadFinal.xcresult` now has `Info.plist` and a readable summary: `result: unknown`, `totalTestCount: 0`, `passedTests: 0`, `failedTests: 0`. Its raw log contains a 57.216-second release-case pass line, but the bundle records no cases. It is incomplete/unknown and contributes no counted pass or final capture provenance; it is not currently unreadable/corrupt. The fresh release rerun passes in 52.812 seconds with a valid retained bundle. NativeRooms4, FinalPhone, RoomReturnFinal, NormalGallery, NormalGalleryFinal and both fresh verified iPad originals are retained. No save, source or signed package was deleted. Root confirmed native gallery export and QA simulator shutdown after the valid reruns.

Remaining checks before broad claims of quality:

- Physical/player-service follow-through and Apple's review outcome. Keep package/capture/preview provenance in the release record and count repeated phone/iPad passes once. Submission is confirmed; approval and public availability are pending.
- Physical VoiceOver speech/focus and sequence timing, guided windmill behavior, Switch Control/external input, contrast and Reduce Motion. Simulator bounds assertions do not establish these.
- Smaller phones, iPad split-screen/short windows, long strings and process interruption at help, pause, outcome and collection boundaries. The recorded full iPad portrait/landscape tour and release captures have now passed.
- Live Apple account connection, private-cloud backup/restore across devices, account switching during a ranking request, slow/offline ranking recovery and Apple sandbox purchase/restore/refund behavior.
- Low-end hardware frame pacing, SceneKit memory/battery use, sound output and input latency. Static scene caching reduces unnecessary work but is not a measured performance result.
- Player comprehension of the keeper story, room choice, first-clear rewards, unfinished-attempt loss and event expiry; difficulty/playtesting beyond the four opening skill challenges.

## Source trail

Reviewed: `OrbitBloom/Views/RootView.swift`, `IslandHubView.swift`, `IslandActivityView.swift`, `WorldEventsView.swift`, `RoomRecordsView.swift`, `OrbitBloom/GameModel.swift`, `OrbitBloom/Core/IslandJourney.swift`, `OrbitBloom/Core/IslandActivities.swift`, `OrbitBloom/WorldEventClock.swift`, `OrbitBloomUITests/SevenRoomsUITests.swift`, `docs/SEVEN_ROOMS_DESIGN.md`, NativeRooms2/3/4/static-scan artifacts and the build11 core-final, final-phone, room-return-final, normal-gallery, normal-gallery-final, site-final-deploy, ipad-rooms-verified and ipad-release-verified logs. The applied skill is `/Users/ajnasnb/.agents/skills/mobile-app-ux-auditor/SKILL.md`, with its mobile UX audit reference.
