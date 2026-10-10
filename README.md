# Orbit Bloom: Garden Arcade

A native iOS arcade with seven connected games and one saved island. Meet Lio, a keeper apprentice rebuilding Aurora Atoll after the Great Eclipse. Play Bloom Circuits, Farm Terraces, Harvest Rally, Canal Weave, Firefly Trail, Windmill Works and Moon Observatory. Build 11 is submitted for App Review; Apple approval and manual public release are pending.

[Public GitHub repository](https://github.com/AjnasNB/orbit-bloom) · [Build 11 review, screenshots and verification](docs/release-draft/build11/README.md)

## Play

Open `OrbitBloom.xcodeproj`, select the **OrbitBloom** scheme and an iPhone simulator, then Run. iOS 17+ is required. The scheme uses `OrbitBloom.storekit` for local Apple purchase testing; test purchases do not charge real money. `scripts/run-ios.sh` installs and runs on the dedicated **Orbit Bloom QA** simulator.

- **Island:** swipe through 102 ten-stop 3D scene pages. Finish a stage to unlock the next; locked pages can be explored but cannot be started. Play 1,020 stages (12 authored opening stages plus 1,008 generated stages). Swipe neighbors to match three or tap touching groups. Four in a line creates a Bomb, L/T creates TNT, a seven-piece cross creates Mega, and five in a line creates Rainbow on the board. Powers chain when blasted. Circuits use 10–20 turns. The first 12 stages fund six restorations. First 10 hints are free; permanent field tasks reward more hints, shuffles and tools.
- **Farm:** enter through Farm & craft on the island. Swipe to the tool shed. Choose roses or apples, tap an empty plot to plant, tap to water, and tap a ripe crop to harvest. Crops grow while the app is closed. Harvests provide coins, compost for crafting, and cargo. Collected puzzle water is saved before match animations, so closing during a match keeps it available for planting.
- **Race:** enter through Harvest rally on the island; swipe horizontally to steer the new illustrated rover, dodge obstacles, collect coins, pause or leave clearly, and finish a delivery. Harvested cargo adds a bonus. Traffic tightens through five tiers.
- **Four skill rooms:** rotate pipes in Canal Weave, repeat numbered lantern signals in Firefly Trail, charge inside a timing window in Windmill Works, and swipe star tiles into order in Moon Observatory. Each has up to 1,000 seeded challenges. Each sequential first clear saves one star, 25 coins and two water exactly once. Unfinished attempts in these four rooms are discarded when leaving.
- **Rooms and events:** Explore 7 rooms opens Lio’s story and distinct labeled 3D doors. Swipe pages to choose a room. Optional world events use common UTC schedules and require a recent public clock check for bonus claims. Room records show personal bests; Atoll Skills compares the combined four-room skill score through Game Center. Coins and purchases add no ranking points.
- **Lives:** five normal lives, one regenerated every 30 minutes including offline. Puzzle entry spends a life; winning returns one. Purchased extra lives are a separate reserve that does not expire. The other six rooms use no puzzle lives. Earned coins can refill normal lives.
- **Supplies:** tap the coin balance and swipe between life supplies and six Apple packs: four coin packs, extra lives, and a one-time starter bundle. Intended Indian prices are ₹99, ₹299, ₹499, and ₹999. The app displays actual Apple storefront prices when products are available. Unavailable purchases stay disabled.
- **Saved garden:** Settings → Player & saved garden offers optional Game Center sign-in and private iCloud Drive backups. Each player has a separate local wallet and each device writes a separate cloud file. Choose a device/cloud garden explicitly when they differ. Restores protect credited purchases and retain an undo checkpoint. Guest play remains available offline.

The brighter cream-and-sky interface fits its game screens without vertical scrolling or a permanent activity tab bar. The island uses actual original SceneKit meshes and twelve biome families with generated scenery variations; it is not 1,020 hand-built worlds.

Different looping music plays in each activity, with action sounds, particles, dimensional botanical sprites, a robot companion, and coins flying into the shared balance. Music, sound effects, and haptics have separate settings.

## Verify

```sh
swift test
scripts/test-ios.sh
```

`scripts/test-ios.sh` runs core and all native tests on the separate **Orbit Bloom Store QA** iOS 26.1 device. Automated resets belong on that device; the **Orbit Bloom QA** preview save should be preserved during daily updates. The iOS 26.5 runtime cannot reliably load local StoreKit products, so purchase verification uses iOS 26.1. See [test evidence](docs/TEST_REPORT.md) and the [build 11 verification and gallery](docs/release-draft/build11/README.md) for the verified result and limitations. Core tests verify all 1,020 stages are reachable with normal swaps and earned bursts, plus life boundaries, offline growth, crafting, tool areas, 60 connected campaign simulations with carried inventory, and racing. Native tests cover the atomic wallet, transaction idempotency, interrupted puzzles, and bundled media. UI tests actually swipe through the chapter, farm, race, relaunch, and shop.

## Sources and release draft

- [System list and source comparison](docs/V2_SYSTEMS_AND_SOURCES.md)
- [Screenshot draft](docs/release-draft/README.md)
- [App Store status and product catalogue](docs/APP_STORE_PREPARATION.md)
- [Security review](docs/SECURITY_REVIEW.md)
- [License audit](docs/LICENSE_AUDIT.md)
- [Audio source manifest](docs/AUDIO_PROVENANCE.json)
- [Exact generated-art prompts](docs/V2_ARTWORK_PROMPTS.json)

MIT game code is preserved in `vendor/Match3Kit`; two MIT reference projects are downloaded under `research/`. Selected audio is CC0. New rendered botanical art, Lio and rover sprites are generated for this project under the applicable OpenAI terms, not falsely labeled as upstream MIT assets. [Build 11 art direction and provenance](docs/release-draft/build11/ART_DIRECTION.md) record the original generated additions. No proprietary Gardenscapes material is included.

Gameplay works offline. Guest saves remain device-local; deleting the app can lose them. Optional cloud saves require Game Center, iCloud Drive and the same Apple accounts on both devices. Check the last successful backup before switching devices. Build 11 has 107 unique cases with passing runs: 49 core, 47 native, nine iPhone UI and two iPad UI. Its signed export has production Game Center and private iCloud entitlements. Account, corrupt/legacy save, restore, purchase and event-clock protections have test coverage. Twenty genuine matching iPhone/iPad captures are submitted to Apple. Failed diagnostic bundles remain distinguished from later passing cases. Physical Apple authentication, cloud round trips, signed sandbox purchases and live leaderboard submissions remain unverified. Client-side scores are bounded, not authoritative anti-cheat. Production work still includes currency recovery/refund policy, broader accessibility/device coverage, difficulty tuning and release review.

Marketing, privacy and support pages are live at [the Orbit Bloom site](https://orbit-bloom-game-site.ajnasnb.workers.dev/), hosted on a dedicated Cloudflare Worker. The optional custom subdomain remains unconfigured.
