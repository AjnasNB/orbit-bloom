# Sky Shuttle world events — 20 October 2026

Sky Shuttle now receives a separate UTC event every six hours with a three-hour active window. Three sequential Shuttle clears during that event earn the same Bomb claim as the rotating skill workshop. Its `shuttle:` receipt IDs have a new allowlisted namespace; saved wallets advance to **schema 5** when they carry that receipt. Previous builds reject schema 5 to protect the receipt. Existing Canal, Firefly, Windmill and Observatory rotations and keys remain unchanged.

The focused event/save tests (7/7) and all 64 core tests pass. The iOS app, unit-test bundle and UI-test bundle compile for a generic Simulator destination. The iOS 26.1 Store QA runtime is still missing, so no device gameplay, screenshot, signed archive or preview update is verified. Build 23 remains development source; the App Store package/gallery remain build 22. [Structured verification](qa/2026-10-20-shuttle-events.json).

---

# QA runtime guard — 17 October 2026

`scripts/test-ios.sh` now checks the exact Store QA device/runtime before compilation, rejects unavailable or busy inventories, avoids duplicate boot attempts and stops on boot failure. Eleven isolated safety checks pass; 63 real core tests still pass. [Evidence and recovery](QA_RUNTIME_PREFLIGHT.md).

The host currently has only iOS 26.5; the pinned iOS 26.1 Store QA runtime is missing, blocking native/UI verification. No game code, artwork, save schema or package changed: all 88 build-22 hashes match. No personal preview reset, install or launch occurred; its preferences remain byte-for-byte intact. Build 22 remains the latest local game version. No new gameplay screenshots or Apple upload are claimed.

---

# Latest local delivery — build 22, 16 October 2026

A correct Shuttle plan seated on the final move can now **Depart**. Seats lock at zero; wrong final checks and incomplete plans still lose. The counter uses a checkered flag and explains the final check to accessibility users. Budgets, ticket constraints and rewards stay the same. [Change and old-source reproduction](BUILD22_SHUTTLE_FINAL_MOVE.md), [delivery record](release-draft/build22/README.md).

**132 unique affected checks pass:** 63 core, 67 native and two real-input phone flows, with no final native/UI failures or skips. All 1,000 Shuttle challenges pass ordinary and exact-budget plans. Maximum-text play verifies a final-move win, one shared garden reward and challenge 2 after relaunch; all five skill games also complete the shared restoration loop. Fourteen original native screenshots are pinned. Source **5cb0681** is pushed to public main. The ordinary preview runs **1.0 (22)** with every saved gameplay value intact, including 555 coins, both frozen patches and the active rules-2 level-4 board at nine moves. Store QA is closed.

Signed archive/export, Production private iCloud/Game Center, unchanged privacy and all 88 frozen source hashes pass. **Build 22 is local, not uploaded/submitted.** The known delivery blocker is unchanged; no repeated account/unlock request was made. Last authenticated Apple status remains dated **13 October**: internal build 19 in Orbit Bloom QA, public build 11 Waiting for Review/manual release. Local metadata/gallery preparation is aligned. No daily public release, purchase, agreement, duplicate Apple inquiry or website/backend change occurred. Physical Apple/iCloud, signed sandbox checkout and actual VoiceOver timing remain device checks.

---

# Latest local delivery — build 21, 15 October 2026

Restart decisions now pause all five skill games. Cancelling preserves the current attempt and prior Pause state; confirming starts fresh. Windmill no longer times out behind the prompt, and Firefly safely replays a covered demonstration without a mistake charge. Native modal focus keeps underlying accessibility elements stable. [Change and reproduced timeout](BUILD21_RESTART_DECISIONS.md), [delivery record](release-draft/build21/README.md).

**131 unique affected checks have passing records:** 61 core, 66 native and four real-input phone flows. Final restart, maximum-text and native runs pass; unsuccessful diagnostics and source-stage provenance remain explicit. All five games were played through real wins, shared garden restoration and relaunch; restart/cancel/help works at maximum text across all five. Twenty-five original native PNGs are pinned. No new tablet run. Source **e1ee94d** is pushed to public main. Ordinary preview **1.0 (21)** retains every saved game value, including 555 coins and the active rules-2 level-4 board with nine moves; Store QA is closed.

Signed archive/export, Production private iCloud/Game Center, unchanged privacy and all 88 source hashes pass. **Build 21 is local, not uploaded/submitted.** The known native delivery blocker remains; no repeated sign-in/unlock request was made. The last authenticated Apple observation remains dated **13 October**: internal build 19 in Orbit Bloom QA and public build 11 Waiting for Review/manual release. Local metadata/gallery preparation is aligned. No daily public release, purchase, agreement, duplicate Apple inquiry or website/save-backend change occurred. Physical Apple/iCloud, signed sandbox checkout and actual VoiceOver timing remain hardware checks.

---

# Latest local delivery — build 20, 14 October 2026

Rally now settles each registered finished attempt once. Duplicate, reentrant, abandoned, superseded and previous-account callbacks cannot mint coins, consume extra cargo or count false farm unlock wins. The old-source reproduction paid one route four times and persisted the wrong wallet; the failed result remains separate. [Change and rationale](BUILD20_RALLY_SETTLEMENT.md), [delivery record](release-draft/build20/README.md).

**131 unique affected checks pass:** 61 core, 66 native and four real-input phone flows, including an exact completed-route reward, field two remaining locked at 1/3, relaunch, pause/exit, maximum text and skill-to-farm progression. Fifteen original native screenshots are preserved. This run has no new tablet test; previous build-19 tablet evidence remains separate. Source **8f72c7b** is pushed to public main. The ordinary preview runs **1.0 (20)** with the full save intact: 555 coins, three completed stages and active rules-2 level 4 at nine moves. Other QA devices are closed.

Strict signed archive/export verification and all 88 frozen source hashes pass. **Build 20 is local, not uploaded or submitted.** Native control reports a locked Mac with failed automatic unlock; Chrome Apple-tab attachment times out. Unlocking the Mac is required to resume Transporter delivery. No repeated sign-in request was made. The last authenticated Apple observation remains **13 October**: internal build 19 processed in Orbit Bloom QA, public build 11 Waiting for Review with manual release. Local metadata/gallery preparation is aligned; the pending public submission and website are unchanged. No daily public release, real purchase, agreement or duplicate Apple inquiry occurred. Physical Apple/iCloud, signed sandbox checkout and VoiceOver timing remain hardware checks.

---

# Latest verified delivery — build 19, 13 October 2026

The owner-requested full retest brings build **1.0 (19)** to **138 unique passing affected checks**: 60 core, 62 native, fifteen real-input phone flows and a complete iPad portrait/landscape tour. The first expanded attempt hit host storage exhaustion during test-app installation; generated own test caches were cleared and the full rerun passes. [Final delivery record](release-draft/build19/README.md) retains both diagnostics and successful results, with 38 fresh native screenshots and twenty current-build gallery selections. Game source and the signed package are unchanged.

**Apple validated, received and processed build 19.** Transporter verification finished at 6:35 PM India time and delivery at 6:43 PM. The **Orbit Bloom QA** internal group has access (one tester/invite); What to Test was saved and verified after reload. [Apple proof](release-draft/build19/proof/apple-build19-ready.png), [status](release-draft/build19/apple-retest-status.json). Native upload control now works, resolving the previous Transporter blocker for this session. No manual upload of the older build-18 package is needed.

The ordinary preview remains build 19 with 555 coins and the active level-4 rules-2 board at nine moves; no preview reset or test arguments were used. Both QA devices are closed. The authenticated public submission remains **build 11 Waiting for Review**, with manual release. Build 19 is available for internal testing, not submitted for public review or publicly released. Physical Game Center/iCloud, signed sandbox checkout and VoiceOver timing remain hardware checks; no real purchase, agreement or duplicate Apple inquiry occurred.

---

# Initial local delivery — build 19, 13 October 2026 (before full retest)

Farm fields now expand through Bloom first clears, all five skill-game first clears and successful Rally deliveries: three wins open the second field, nine open the third. The existing three/nine-harvest alternative is preserved. Locked fields display both progress counters and accessible explanations. [Delivery record](release-draft/build19/README.md) documents **125 passing affected core/native/phone checks**, fifteen original native screenshots and full local/cloud progression regressions. Source **34b5770** is pushed to public main.

The ordinary preview runs **1.0 (19)** with the complete save intact: 555 coins, three campaign clears and the active rules-2 level-4 board with nine moves. Strict local signature/export and frozen-source checks pass. The support page on **https://orbitbloom.cognifyr.co/support/** explicitly describes development build 19; Chrome and HTTPS/security routes pass.

**Build 19 remains local, not uploaded/submitted.** The previously established Apple account/control blocker has no new sign-in signal, so this daily run did not repeat a sign-in request or replace the pending build-18 Transporter package. The public review's last authenticated observation remains 12 October; today's Chrome Apple tab is at login. Local metadata/gallery preparation is updated, with unchanged build-18 gallery provenance explicit. No public release, purchase, agreement or duplicate Apple inquiry occurred.

---

# Latest delivery — build 18, 12 October 2026

Build **1.0 (18)** makes all eight home activities equally prominent, adds named progress badges, shared garden supplies/restoration counters and eight swipeable Lio story pages. [Delivery record](release-draft/build18/README.md) covers **135 unique passing core/native/phone/iPad cases**, a final successful 61-case polish rerun, 36 original native images and the complete preserved preview save. Source **eef0460** is on public main; the normal owner preview runs 18 with 555 coins and its active level-4 board intact.

The website is live on **https://orbitbloom.cognifyr.co/** through the isolated Cloudflare Worker. Support/marketing URLs were saved and reloaded in Apple. Canonical/SEO, privacy/support and public clock/security routes pass; no other DNS/project or player-save backend changed.

**Public release is still pending.** The existing build-11 submission remains Waiting for Review. Apple received the routine status inquiry as **case 102994340844**. Build 18 is locally signed/exported and its final package is loaded in Transporter, but Xcode reports **Failed to Use Accounts** and native delivery control is unavailable. The owner was asked to click DELIVER on Orbit Bloom 1.0 (18). New copy and ten-per-device galleries remain prepared locally until successful delivery and processing. The older review submission was not cancelled; no approval, real purchase, legal acceptance or public release is claimed.

---

# Build 17 extension — 12 October 2026

The eight direct icons, rules-3 layered hard campaign, capped win kit, three independently saved fields and original two-deck seating activity are documented in [gameplay/UX](BUILD17_GAMEPLAY_AND_UX.md). [Original apple provenance](BUILD17_ARTWORK_PROMPT.md) records the unchanged tool-generated asset; hazards, sickle, blockers and shaded travellers are native drawings. The previous world-event clock and Apple payment/cloud architecture remain. [Build-17 delivery](release-draft/build17/README.md) records tested saves, screenshots and actual external release limitations.

---

# Orbit Bloom: connected garden arcade

Build 16 protects a harvested patch for 1.1 seconds so a double tap cannot silently replant it and spend seeds/water. The action shows Harvested while collection completes; other beds remain usable, and normal planting returns afterward. Protection is transient, with no save schema change. [Build-16 evidence](release-draft/build16/README.md) records the old failing reproduction, 109 passing affected cases, native captures and the preserved ordinary preview. Signed export passes; the existing Xcode account-access error still blocks upload. Public review remains unchanged and was not rechecked today.

Build 15 makes Farm a continuous native SceneKit field with saved apple-tree and rose-bush growth, actual ripening/harvests, camera-aligned patch controls and a new botanical leaf shared with the puzzle. The six existing plot deadlines, costs, rewards, offline growth, crafting and save schema remain compatible. [Farm redesign](FARM_FIELD_REDESIGN.md) and [delivery evidence](release-draft/build15/README.md) record 108 unique affected passing cases, eleven native captures and the personal preview update with complete save checks. Signed archive/export passed; upload is blocked by Xcode `Failed to Use Accounts` while the Mac is locked. Chrome confirms build 11 still Waiting for Review and builds 13/14 in the internal group; public review is unchanged.

Build 14 adds a numbered next-barrier/coin guide using the actual Rally crossing, VoiceOver road summaries and active announcements, and readable large-text lobby/pause controls. All five traffic tiers and the real reward/save path have regressions. [Build-14 evidence](release-draft/build14/README.md) records 106 unique affected passing cases and the successful Apple upload; processing/group assignment are pending verification. The existing build-11 public review is unchanged.

Build 13 is a locally verified cartoon-art update. The shared fruit, leaf, dew, rose, diamond, powers, robot and coin atlas now matches the playful 3D garden; Lio and the rally rover use the same smooth illustrated material style. Sprite indices and save schemas are preserved. [Style refinement](CARTOON_STYLE_REFINEMENT.md) and [the test report](TEST_REPORT.md) record the artwork, crop guard and real gameplay checks. The existing build-11 Apple submission was not replaced by this local update.

Build 11 connects seven playable rooms through Lio, a keeper apprentice restoring Aurora Atoll after the Great Eclipse. The existing island remains his visible garden domain; Explore 7 rooms opens a separate swipe directory with labeled destinations, distinct original 3D miniatures and clear exits. Four new skill activities join Bloom Circuits, Farm Terraces and Harvest Rally. Public server time anchors optional events on shared UTC schedules, while Apple remains the sole player cloud-save service. [The seven-room design](SEVEN_ROOMS_DESIGN.md) records the story, interaction choices and verification limits. [Build 11 metadata](release-draft/build11/metadata.md) is a local App Store draft, not evidence of submission.

This revision follows the user's requested change from a single swap puzzle to a connected collection of activities. No claim is made that these mechanics have never existed elsewhere. The shared plant → harvest → craft → clear → deliver loop now also includes irrigation logic, memory signals, power timing and spatial charts that earn restoration resources.

## System list and implementation specification

| System | Behavior for this build |
| --- | --- |
| World and character | Lio restores Aurora Atoll; original SceneKit island, 102 horizontal pages × 10 sequential campaign stops, six ordered restoration projects, labeled Farm/Rally doors, seven-room directory and field journal |
| Bloom circuits | Swipe real neighboring pieces or tap botanical groups; resource goals and frost, 10–20 turns on normal stages plus twenty one-move challenges; 1,020 stages (12 opening + 1,008 generated) |
| Tools | Bomb: 3×3 area; TNT: row and column; mega bomb: 5×5 area; rainbow: every piece matching the selected color |
| Farming | Native 3D orchard/rose field, six persistent soil beds, camera-aligned actions, species-specific shoots/leaves/blossoms/ripe crop, plant/water/offline grow/harvest, produce and compost |
| Crafting | Harvest compost creates garden tools; puzzle dew refills farming water |
| Delivery race | Illustrated rover, horizontal swipe steering, three lanes, visible shield/time/distance, animated pickups, 22-second/440-metre route and cargo bonus; five traffic tiers increase every three successful deliveries; numbered next-barrier/coin guide and VoiceOver cues; pause freezes guidance |
| Canal Weave | Turn pipe ports clockwise to connect the west inlet at top-left to the east outlet at bottom-right within a move budget |
| Firefly Trail | Observe numbered lanterns and repeat their sequence across rounds; mistakes end the attempt, with no life cost |
| Windmill Works | Charge inside a visible timing wedge before the timer/miss budget ends; VoiceOver guided timing supports accessible play |
| Moon Observatory | Swipe an adjacent numbered star into the empty space to order a spatial chart within the move budget; tap offers an accessible alternative |
| New room progression | Four deterministic procedural room campaigns support up to 1,000 sequential challenges each. Each new first clear awards one star, 25 coins and two water once; completed levels and personal bests persist. Unfinished attempts in these four rooms do not persist across exit or app closure |
| World events | Shared UTC skill cycle every 6 hours/3 active hours, daily harvest/8 active hours, 48-hour convoy/6 active hours. Three qualifying actions earn Bomb/TNT/Mega respectively; claim during the active window. A recent HTTPS server clock is required for bonuses, while normal rooms work offline |
| Room records | Four local personal bests combine into the optional Apple Atoll Skills leaderboard score. Purchases, coins and lives contribute no ranking points; authenticated wallet/player identity is checked before and after submission |
| Lives | Five regenerating puzzle lives; one every 1,800 seconds, including while closed; start spends one, abandon keeps it spent without another charge, wins return it; purchased extra lives never expire. The other six rooms use no puzzle lives |
| Economy | Shared earned/purchased coins; refill with coins; consumable coin and extra-life packs; duplicate verified transactions cannot grant twice |
| Pricing draft | ₹99/₹299/₹499/₹999 coin packs, ₹99 extra-life pack, one-time ₹99 starter bundle with a transparent bonus. Live prices always come from StoreKit |
| Feedback | New original transparent Lio/rover artwork alongside dimensional botanical sprites and original SceneKit room geometry; particles, power blasts, pickup travel toward the counter, wallet reward animation, action sounds, looping mode music and mute settings |
| Saves | Local guest/player wallets and optional Apple Game Center/private iCloud Drive backup. Schema-3 adds completed new-room progression, records and current event receipts; old clients reject the new envelope. Cloudflare does not store player saves |
| Release draft | Current screenshots, product IDs, pricing intentions, reproducible test evidence, outstanding signing and purchase verification |
| Source control | Multiple meaningful commits on main; public repository follows the user's final explicit public instruction |

## Reusable sources compared

| Source | Verified licensing / fit | Decision |
| --- | --- | --- |
| [Match3Kit](https://github.com/alex566/Match3Kit) | Pinned MIT engine already bundled; useful grid/refill primitives | Keep engine; write connected-group and power-area logic locally |
| [MatchPuzzle](https://github.com/yadorogi/MatchPuzzle) | MIT SwiftUI reference already downloaded | Reference only; no artwork copied |
| [Godot farming prototype](https://github.com/oiblank/godot-farming-prototype) | Repository declares MIT; older Godot tile-state/harvest design | Download source for comparison; implement native timestamp-based plots rather than embed another runtime |
| [Ťuk Farm](https://github.com/SevcikMichal/tuk-farm) | MIT source with separately credited animal recordings/font | Research reference; do not copy mixed assets |
| [Kenney Interface Sounds](https://kenney.nl/assets/interface-sounds) | Publisher labels CC0, 100 sounds | Import selected taps, confirmation and coin feedback with notice |
| [Kenney Impact Sounds](https://kenney.nl/assets/impact-sounds) | Publisher labels CC0, 130 sounds | Import selected soft impacts, harvest and collision sounds with notice |
| [Kenney Music Jingles](https://kenney.nl/assets/music-jingles) | Publisher labels CC0, 85 clips | Import finish/reward cues; full background tracks are listed below |
| [Kenney Nature Kit](https://kenney.nl/assets/nature-kit) | Publisher labels CC0 | Reference for future scenery expansion; current 3D island uses original procedural SceneKit geometry, without imported meshes |
| [Racing game](https://github.com/chukfinley/racing-game) | README says MIT but a license file still needs confirmation | Candidate only; write a small native delivery race, no source/assets imported |

Full-length CC0 background tracks: [Another August](https://opengameart.org/node/73989) by The Cynic Project, [Happy Adventure](https://opengameart.org/content/happy-adventure-loop) by TinyWorlds, and [Rhythm Garden](https://opengameart.org/content/rhythm-garden) by congusbongus. Garden/farm share a track; puzzles and racing have distinct tracks. Exact source, destination and license records are in `AUDIO_PROVENANCE.json`.

Puzzle and farm pieces are original 3D-style renders with transparency. Build 5 adds actual original 3D meshes for the island terrain, greenhouse, pond, trees, flowers and clouds. Build 11 adds original transparent raster art for `KeeperLio` and `RallyRover` using the built-in imagegen tool, plus original procedural SceneKit miniatures for all seven room doors. These are separate from the cited open-source/audio imports; the rover is an illustrated sprite during driving rather than a fully simulated 3D vehicle. Apple frameworks remain under Apple terms; audio is CC0, copied game code is MIT. Public availability alone is not a reuse license.

## Apple payment boundary

Apple supports consumable products for currency and custom territorial price schedules: [purchase overview](https://developer.apple.com/in-app-purchase/), [pricing setup](https://developer.apple.com/help/app-store-connect/manage-in-app-purchases/set-a-price-for-an-in-app-purchase). The listed rupee amounts are intended configuration, not a live storefront promise. Product registration, agreements, and signed sandbox verification are required before release. No fake payment success is used in the app.

## Version 3 interaction update

On-board powers follow piece identity through swaps and gravity. Formations create powers; blasts recursively trigger adjacent powers once. Shuffles animate and preserve power counts. The first ten hints and three shuffles are free; additional assistance uses earned coins or permanent task rewards. Startup shows a brief loading screen and opens Home automatically. Build 3 garden regions paged in groups of twenty stages; build 5 replaces that interface with ten-stop scene pages. These are implementation features; final native test status is recorded separately in TEST_REPORT.md.

## Build 4 save correction — 9 October 2026

Puzzle water is credited in the same wallet save as the resolved board, before its animation starts. Interrupting the animation therefore keeps the farm supply; completing or replaying the animation does not credit it twice. Farm resource meters now expose their names and balances together to accessibility. The native interruption regression and the real puzzle → reopen → plant flow are recorded in TEST_REPORT.md.

## Build 5 island and turn update — 9 October 2026

The world has 102 horizontally swipeable pages and 1,020 sequential stops, using twelve repeated biome families and ten landmark types. These are generated scene variants and named stage locations, not 1,020 independently modeled worlds. Farm, tool shed, journal and supply views fit in pages without vertical scrolling; farm/race entry points are inside the island. Settings and license text retain standard platform scrolling where needed.

Starting a locked stage is rejected before spending a life or replacing a saved session. Unlocking checks the first missing stage, so an out-of-order completion cannot skip a gap. Opening goals and frost have been retuned for 10–20 turns; generated stages use 16–20 turns. Group hints now value neighboring frost that the actual warmth rule clears. Reachability and native UI evidence are recorded in TEST_REPORT.md; solver completion does not establish human difficulty.

The island respects Reduce Motion, uses a fixed camera, and renders at 30 fps. Trees and clouds have subtle ambient movement. Level buttons, region ranges and scene gates remain accessible independent elements.

## Build 6 player accounts and saved gardens — 9 October 2026

Optional Game Center authentication identifies the player. GameKit saved games use the private CloudDocuments container `iCloud.com.orbitbloom.game`; iCloud Drive is required. No publisher game backend or credentials form was added. Guest play remains available. Per-player local wallets, per-device cloud files, explicit conflict choices, paid receipt protection and an undo checkpoint keep gardens separate. Unknown or corrupt cloud data blocks uploads; offline failures retain local progress. Apple callbacks have a 20-second deadline and ignore duplicate/late completion. Account switching and relaunch can recover only that player's local backup.

Apple's official [authentication guide](https://developer.apple.com/documentation/gamekit/authenticating-a-player) and [saved-game guide](https://developer.apple.com/documentation/gamekit/saving-the-player-s-game-data-to-an-icloud-account) informed the integration. The saved-game transport is injected for native failure/restore tests; these passing tests do not establish a live iCloud server round trip. The regenerated signed distribution profile includes Game Center and the isolated container.

The privacy policy and support site were updated and deployed only to the existing Orbit Bloom Worker. Based on Apple's [privacy definitions](https://developer.apple.com/app-store/app-privacy-details/), private Apple-managed saves and on-device account handling do not give the publisher access to collected gameplay data. The owner published the Data Not Collected declaration, verified before the build 6 App Review submission. No new agreement was accepted by the agent.


## Build 7 security corrections — 9 October 2026

Private Apple saves remain the sole cloud save system, as requested by the owner. No Cloudflare player database was added. Saved timers, scores and legacy files receive stricter validation; life-clock conversion cannot overflow. Cloud operations recheck the current Apple player after completion and before a restore, and paused backups cannot apply stale choices. The isolated Cloudflare site has additional HTTPS/CSP headers. Scope, evidence and physical-device limitations are in [SECURITY_REVIEW.md](SECURITY_REVIEW.md).

## Build 8 journal adaptation — 10 October 2026

The field journal now wraps its complete help, reward and power descriptions. Available height and Dynamic Type determine one to three rewards or one to four formations per horizontal page. Accessibility sizes move the claim action below its description. The selected entry is retained when page capacity changes; “Journal pages” exposes a named adjustable action and page value. Page updates respect Reduce Motion. Assistance prices, claim rules, saved progress and in-world entry points are unchanged. Actual large-text traversal and iPad portrait/landscape evidence are in [the focused audit](MOBILE_JOURNAL_AUDIT.md) and [test report](TEST_REPORT.md).

## Build 9 exit and difficulty — 10 October 2026

A visible Back arrow and Pause both offer a confirmation before abandoning; cancel preserves the board. Restart explains that it spends another life. Abandon clears only the current puzzle and keeps its initial life spent, without a second debit. World, farm, currency and purchases remain saved.

Simple, Hard and Super hard stages are visibly labeled and mixed across each later ten-stop page. Normal generated budgets tighten in 200-stage bands, remaining within 10–20 moves while goals and frost increase. Twenty One shot stages begin at 30 and recur every 50 stages: one move, hints allowed, no tools/bursts/shuffles, with a guaranteed free winning swipe across five colors and four rotations. Legacy active sessions retain their exact previous rules. New active rules use a versioned snapshot and schema-2 cloud envelope so old clients cannot reinterpret them. [Rules and focused UX audit](DIFFICULTY_AND_EXIT.md) describe the behavior and verification limits.

## Build 10 separate activity rooms — 10 October 2026

Build 10 separated Farm and Harvest Rally into clearly labeled rooms with original SceneKit maps and visible Island exits. Farm's six interactive plots, shed, harvesting and cargo remained connected to the existing puzzle/rally economy. Rally gained a garage/orchard preview of its existing 440-metre course. The two room doors explained purpose and no-life-cost entry, stacking for accessibility text. [The focused audit](ACTIVITY_ROOMS_UX_AUDIT.md) records that build's evidence and limits. Existing sequential campaign unlocks and life-aware puzzle exit rules remained in force.

## Build 11 seven rooms and public event clock — 10 October 2026

The new four rooms are native SwiftUI activities backed by deterministic core runs. Canal boards grow and allow fewer spare turns, lantern signals lengthen, windmill timing tightens, and observatory charts increase from 3×3 to 4×4. Difficulty reaches practical caps; 1,000 seeded challenges per room is not a claim of 4,000 independently handcrafted places. The original puzzle campaign remains 1,020 stages across 102 map pages and twelve repeating biome families. Lio's six existing ordered projects each cost two stars, and new skill-room first clears fund the same garden.

Harvest Rally now displays route tiers 1–5, derived from completed deliveries in groups of three. It increases traffic from 10 to 18 crossing obstacles and changes lane patterns while retaining the 22-second route, three shield points, earned pickup rewards and cargo connection. A new original rover sprite, legible road/barriers, a pause/resume flow and pickup travel improve the driving surface. This is a lane-delivery game, not a full 3D racing simulation.

The isolated `/api/events` Worker returns only the public schedule version and server time. The app validates HTTPS response origin, schema, size and time bounds, then advances the anchor with monotonic uptime. The anchor expires after 900 seconds and refreshes on foregrounding and regularly while open. Shared epoch-based UTC windows automatically switch to the next event after a window ends. Qualifying progress caps at three, claims are once per window, and expired bonuses cannot be claimed. The application sends no player identifier, credentials, purchase data or private save to this endpoint. These event bonuses are optional and require a recent clock check; normal room play remains available offline.

Completed new-room levels, personal records and current event receipts join the existing validated wallet in schema-3 private Apple saves. Guest/player isolation, explicit cloud restore choices and purchase-receipt protection remain. New activities save successful results when collected; their current unfinished attempts restart after exiting or closing the app. The saved Bloom puzzle and persistent Farm remain separate from that rule. Atoll Skills sums the four skill personal bests, bounded to 20,000 per room/80,000 total, only for the matching authenticated Apple wallet. Rankings have no prizes and no purchase contribution; client score/account checks are not server anti-cheat.

The hub, event, records and help flows use horizontal pages with accessible adjustable actions and native exits; large text/short windows show fewer details per page. Decorative SceneKit miniatures cache their room/restoration key and do not rebuild on periodic clock updates. Recognized page drags cancel underlying action buttons so swiping cannot also enter a room. Release evidence must verify the corrected flows rather than treat source inspection or successful compilation as proof of the complete UI. Final test counts, matching captures, signed package, live Apple checks and submission state belong to the release record; this design document does not certify an upload or public release.
# Farm model safety — 28 October 2026

`Ecosystem.plot` and farm mutations validate both the requested plot ID and the stored slot identity/bounds. This prevents malformed in-memory or decoded farm arrays from trapping during lookup or consuming seeds/water before a failed write. Regression coverage exercises truncated base and expanded fields. The 64-case core suite and generic iOS Simulator test-bundle compilation pass. Native simulator execution is blocked by the absent pinned iOS 26.1 runtime; see [test report](TEST_REPORT.md). Build 24 is development source only.
# Farm action UI guard — 29 October 2026

Farm actions now tolerate a missing plot returned by the validated ecosystem model instead of force-unwrapping it in the view. All 64 core tests pass and the app/unit/UI targets compile for Simulator. The pinned iOS 26.1 native runtime remains unavailable; see `TEST_REPORT.md`. Build 25 is development source, not an App Store candidate.
