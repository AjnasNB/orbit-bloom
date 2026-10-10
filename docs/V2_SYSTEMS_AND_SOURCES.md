# Orbit Bloom: connected garden arcade

This revision follows the user's requested change from a single swap puzzle to a connected collection of activities. No claim is made that these mechanics have never existed elsewhere. The distinctive direction is the shared plant → harvest → craft → clear → deliver loop.

## System list and implementation specification

| System | Behavior for this build |
| --- | --- |
| World | Original SceneKit island; 102 horizontal pages × 10 sequential stops; in-scene farm/race gates and a field journal |
| Bloom circuits | Swipe real neighboring pieces or tap botanical groups; resource goals, frost, 10–20 turns, 1,020 stages (12 authored + 1,008 generated) |
| Tools | Bomb: 3×3 area; TNT: row and column; mega bomb: 5×5 area; rainbow: every piece matching the selected color |
| Farming | Six persistent plots, rose/apple selection, plant/water/grow/harvest, offline elapsed growth, produce and compost |
| Crafting | Harvest compost creates garden tools; puzzle dew refills farming water |
| Delivery race | Swipe-steered three-lane rover, obstacles, pickups, health, finish, cargo delivery and coin reward |
| Lives | Five regenerating puzzle lives; one every 1,800 seconds, including while closed; wins return the spent life; extra purchased lives never expire |
| Economy | Shared earned/purchased coins; refill with coins; consumable coin and extra-life packs; duplicate verified transactions cannot grant twice |
| Pricing draft | ₹99/₹299/₹499/₹999 coin packs, ₹99 extra-life pack, one-time ₹99 starter bundle with a transparent bonus. Live prices always come from StoreKit |
| Feedback | Dimensional alpha sprites, particles, tool blasts, coin travel into the balance, button/harvest/collision/finish sounds, looping mode music, mute settings |
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

Puzzle and farm pieces are original 3D-style renders with transparency. Build 5 adds actual original 3D meshes for the island terrain, greenhouse, pond, trees, flowers and clouds. Apple frameworks remain under Apple terms; audio is CC0, copied game code is MIT. Public availability alone is not a reuse license.

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
