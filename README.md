# Orbit Bloom: Garden Arcade

A native iOS garden arcade with three connected activities: tap-group bloom circuits, a persistent pocket farm, and a rover delivery race. Built for simulator testing and App Store preparation. This is the first playable chapter, not a claim of production completeness.

## Play

Open `OrbitBloom.xcodeproj`, select the **OrbitBloom** scheme and an iPhone simulator, then Run. iOS 17+ is required. The scheme uses `OrbitBloom.storekit` for local Apple purchase testing; test purchases do not charge real money. `scripts/run-ios.sh` installs and runs on the dedicated **Orbit Bloom QA** simulator.

- **World / Garden:** finish 12 resource puzzles and spend earned stars on six restorations. Tap two or more touching pieces. Groups of 4/6/8/10 craft Bomb/TNT/Mega/Rainbow tools. Blooming groups melt neighboring frost. Free hints and shuffle help recovery.
- **Farm:** choose roses or apples, tap an empty plot to plant, tap to water, and tap a ripe crop to harvest. Crops grow while the app is closed. Harvests provide coins, compost for crafting, and cargo.
- **Race:** tap a lane to steer the rover, dodge obstacles, collect coins, and finish a delivery. Harvested cargo adds a bonus.
- **Lives:** five normal lives, one regenerated every 30 minutes including offline. Puzzle entry spends a life; winning returns one. Purchased extra lives are a separate reserve that does not expire. Farm and Race are always available. Earned coins can refill normal lives.
- **Shop:** four coin packs, extra lives, and a one-time starter bundle. Intended Indian prices are ₹99, ₹299, ₹499, and ₹999. The app displays actual Apple storefront prices when products are available. Unavailable purchases stay disabled.

Different looping music plays in each activity, with action sounds, particles, dimensional botanical sprites, a robot companion, and coins flying into the shared balance. Music, sound effects, and haptics have separate settings.

## Verify

```sh
swift test
xcodebuild -project OrbitBloom.xcodeproj -scheme OrbitBloom \
  -destination 'platform=iOS Simulator,name=Orbit Bloom QA' \
  -derivedDataPath build/DerivedData -parallel-testing-enabled NO \
  -collect-test-diagnostics never -skip-testing:OrbitBloomTests/PurchaseTests \
  test CODE_SIGNING_ALLOWED=NO
```

Purchase tests are separate because the local StoreKit service must load products successfully. See [test evidence](docs/TEST_REPORT.md) for the verified result and limitations. Core tests cover life boundaries, offline growth, crafting, tool areas, 60 connected campaign simulations with carried inventory, and racing. Native tests cover the atomic wallet, transaction idempotency, interrupted puzzles, and bundled media. UI tests actually tap through the chapter, farm, race, relaunch, and shop.

## Sources and release draft

- [System list and source comparison](docs/V2_SYSTEMS_AND_SOURCES.md)
- [Screenshot draft](docs/release-draft/README.md)
- [App Store status and product catalogue](docs/APP_STORE_PREPARATION.md)
- [License audit](docs/LICENSE_AUDIT.md)
- [Audio source manifest](docs/AUDIO_PROVENANCE.json)
- [Exact generated-art prompts](docs/V2_ARTWORK_PROMPTS.json)

MIT game code is preserved in `vendor/Match3Kit`; two MIT reference projects are downloaded under `research/`. Selected audio is CC0. New rendered botanical art is generated for this project under the applicable OpenAI terms, not falsely labeled as upstream MIT assets. No proprietary Gardenscapes material is included.

Gameplay works offline. Progress and purchased consumable balances are device-local; reinstalling can lose that save. Production work still includes physical-device and signed sandbox testing, currency recovery/refund policy, broader accessibility and device coverage, additional content, and release review.
