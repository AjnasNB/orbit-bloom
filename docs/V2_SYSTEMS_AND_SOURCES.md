# Orbit Bloom: connected garden arcade

This revision follows the user's requested change from a single swap puzzle to a connected collection of activities. No claim is made that these mechanics have never existed elsewhere. The distinctive direction is the shared plant → harvest → craft → clear → deliver loop.

## System list and implementation specification

| System | Behavior for this build |
| --- | --- |
| World | Illustrated settlement hub, robot companion, navigation to all activities |
| Bloom circuits | Swipe real neighboring pieces or tap botanical groups; resource goals, frost, 1,020 stages (12 authored + 1,008 generated) |
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
| [Kenney Nature Kit](https://kenney.nl/assets/nature-kit) | Publisher labels CC0 | Future true 3D scene option; this build uses original rendered sprites to keep the current native app fast |
| [Racing game](https://github.com/chukfinley/racing-game) | README says MIT but a license file still needs confirmation | Candidate only; write a small native delivery race, no source/assets imported |

Full-length CC0 background tracks: [Another August](https://opengameart.org/node/73989) by The Cynic Project, [Happy Adventure](https://opengameart.org/content/happy-adventure-loop) by TinyWorlds, and [Rhythm Garden](https://opengameart.org/content/rhythm-garden) by congusbongus. Garden/farm share a track; puzzles and racing have distinct tracks. Exact source, destination and license records are in `AUDIO_PROVENANCE.json`.

The generated pieces are original 3D-style renders with transparency, not manipulable 3D meshes. Apple frameworks remain under Apple terms; audio is CC0, copied game code is MIT. Public availability alone is not a reuse license.

## Apple payment boundary

Apple supports consumable products for currency and custom territorial price schedules: [purchase overview](https://developer.apple.com/in-app-purchase/), [pricing setup](https://developer.apple.com/help/app-store-connect/manage-in-app-purchases/set-a-price-for-an-in-app-purchase). The listed rupee amounts are intended configuration, not a live storefront promise. Product registration, agreements, and signed sandbox verification are required before release. No fake payment success is used in the app.

## Version 3 interaction update

On-board powers follow piece identity through swaps and gravity. Formations create powers; blasts recursively trigger adjacent powers once. Shuffles animate and preserve power counts. The first ten hints and three shuffles are free; additional assistance uses earned coins or permanent task rewards. Startup shows a brief loading screen and opens Home automatically. Garden regions page in groups of twenty stages. These are implementation features; final native test status is recorded separately in TEST_REPORT.md.
