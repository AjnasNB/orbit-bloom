# Orbit Bloom: Garden Arcade

A native iOS garden arcade with three connected activities: swipe-and-group bloom circuits, a persistent pocket farm, and a rover delivery race. Built for simulator testing and App Store preparation. This is the first playable chapter, not a claim of production completeness.

## Play

Open `OrbitBloom.xcodeproj`, select the **OrbitBloom** scheme and an iPhone simulator, then Run. iOS 17+ is required. The scheme uses `OrbitBloom.storekit` for local Apple purchase testing; test purchases do not charge real money. `scripts/run-ios.sh` installs and runs on the dedicated **Orbit Bloom QA** simulator.

- **World / Garden:** play 1,020 stages (12 authored opening stages plus 1,008 generated stages). Swipe neighbors to match three or tap touching groups. Four in a line creates a Bomb, L/T creates TNT, a seven-piece cross creates Mega, and five in a line creates Rainbow on the board. Powers chain when blasted. The first 12 stages fund six restorations. First 10 hints are free; permanent field tasks reward more hints, shuffles and tools.
- **Farm:** choose roses or apples, tap an empty plot to plant, tap to water, and tap a ripe crop to harvest. Crops grow while the app is closed. Harvests provide coins, compost for crafting, and cargo.
- **Race:** swipe the road to steer the rover, dodge obstacles, collect coins, and finish a delivery. Harvested cargo adds a bonus.
- **Lives:** five normal lives, one regenerated every 30 minutes including offline. Puzzle entry spends a life; winning returns one. Purchased extra lives are a separate reserve that does not expire. Farm and Race are always available. Earned coins can refill normal lives.
- **Shop:** four coin packs, extra lives, and a one-time starter bundle. Intended Indian prices are ₹99, ₹299, ₹499, and ₹999. The app displays actual Apple storefront prices when products are available. Unavailable purchases stay disabled.

Different looping music plays in each activity, with action sounds, particles, dimensional botanical sprites, a robot companion, and coins flying into the shared balance. Music, sound effects, and haptics have separate settings.

## Verify

```sh
swift test
scripts/test-ios.sh
```

`scripts/test-ios.sh` runs core and all native tests on the separate **Orbit Bloom Store QA** iOS 26.1 device. Automated resets belong on that device; the **Orbit Bloom QA** preview save should be preserved during daily updates. The iOS 26.5 runtime cannot reliably load local StoreKit products, so purchase verification uses iOS 26.1. See [test evidence](docs/TEST_REPORT.md) and the [case/screenshot manifest](docs/release-draft/verification.json) for the verified result and limitations. Core tests verify all 1,020 stages are reachable with normal swaps and earned bursts, plus life boundaries, offline growth, crafting, tool areas, 60 connected campaign simulations with carried inventory, and racing. Native tests cover the atomic wallet, transaction idempotency, interrupted puzzles, and bundled media. UI tests actually swipe through the chapter, farm, race, relaunch, and shop.

## Sources and release draft

- [System list and source comparison](docs/V2_SYSTEMS_AND_SOURCES.md)
- [Screenshot draft](docs/release-draft/README.md)
- [App Store status and product catalogue](docs/APP_STORE_PREPARATION.md)
- [License audit](docs/LICENSE_AUDIT.md)
- [Audio source manifest](docs/AUDIO_PROVENANCE.json)
- [Exact generated-art prompts](docs/V2_ARTWORK_PROMPTS.json)

MIT game code is preserved in `vendor/Match3Kit`; two MIT reference projects are downloaded under `research/`. Selected audio is CC0. New rendered botanical art is generated for this project under the applicable OpenAI terms, not falsely labeled as upstream MIT assets. No proprietary Gardenscapes material is included.

Gameplay works offline. Progress and purchased consumable balances are device-local; reinstalling can lose that save. Production work still includes physical-device and signed sandbox testing, currency recovery/refund policy, broader accessibility and device coverage, additional content, and release review.
