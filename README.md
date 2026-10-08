# Orbit Bloom

A native iPhone/iPad match-3 garden adventure. Built and run locally on 8 October 2026 using SwiftUI and the MIT-licensed Match3Kit engine. This is a playable first chapter, not an App Store release.

## Play

Open `OrbitBloom.xcodeproj` in Xcode, select the **OrbitBloom** scheme and an iPhone simulator, and press **Run**. The scheme enables local StoreKit testing with `OrbitBloom.storekit`; test purchases do not charge money. For gameplay without purchase testing, run `./scripts/run-ios.sh` after booting the **Orbit Bloom QA** simulator.

Match three adjacent pieces by tapping two neighbors or swiping. Meet the resource targets, clear any frozen patches, and reach the score target before moves run out. Hints and shuffling are free. Matching four or more pieces at once earns a cross-clearing starlight burst. There are unlimited retries and no timers or lives.

Every first level win awards one star and 120 coins. Replays award 30 coins, with no duplicate stars. Spend two stars on each of six ordered garden restorations; restoration lifts fog, warms the scene, and adds completed markers. Spend 80 earned coins on a booster. Complete 12 levels across Moonseed Meadow, Coral Observatory, and Aurora Grove to finish the chapter, then revisit any level.

**Aurora Nights** is an optional, non-consumable cosmetic purchase. The local configuration uses US$2.99; real storefront pricing will come from App Store Connect. Purchases use StoreKit 2 verification, entitlement updates, cancellation/pending states, refunds, and restore. No real App Store product has been registered or published.

## Verify

```sh
swift test
xcodebuild -project OrbitBloom.xcodeproj -scheme OrbitBloom \
  -destination 'platform=iOS Simulator,id=64173F47-C4DC-46B4-82EC-0027675F7780' \
  -derivedDataPath build/DerivedData -parallel-testing-enabled NO \
  -skip-testing:OrbitBloomTests/PurchaseTests \
  -skip-testing:OrbitBloomUITests/GameplayUITests/testShopPurchaseAndRestoreUI \
  test CODE_SIGNING_ALLOWED=NO
```

The two exclusions above apply to the installed iOS 26.5 runtime: its StoreKit test service rejects local configuration with `SKInternalErrorDomain Code=3`. Purchase tests remain in the project, but are not reported as passed. Remove the exclusions on a working StoreKit runtime or signed sandbox device. See `docs/TEST_REPORT.md`.

Pure rules and economy tests live in `OrbitBloomTests/Core`. Native StoreKit and interrupted-session tests live in `OrbitBloomTests/iOS`. The passing UI run uses real tile taps, hints, and earned bursts to complete all 12 levels and six restorations, relaunch, and verify pause/resume and free gameplay from the shop. Separate purchase UI tests are present but unverified on this runtime. Evidence and screenshots are under `evidence/`.

## Project

- `OrbitBloom/Core`: deterministic match-3 adapter, campaign, economy, and persistence models.
- `OrbitBloom/Views`: native garden, puzzle, journey, shop, settings, and accessible piece artwork.
- `OrbitBloom/GameModel.swift`: interaction, cascades, saving/resuming, synthesized sound, and haptics.
- `OrbitBloom/PurchaseStore.swift`: StoreKit 2 integration.
- `vendor/Match3Kit`: pinned MIT engine source, preserved notices.
- `research/MatchPuzzle`: downloaded MIT reference game, not compiled into Orbit Bloom.
- `docs/CONCEPT_AND_ROADMAP.md`: four-game product ideas and release scope.
- `docs/LICENSE_AUDIT.md`: source and asset provenance.
- `docs/APP_STORE_PREPARATION.md`: concrete remaining release work.
- `docs/ARTWORK_PROMPT.txt`: exact prompt for the generated garden illustration.

The generated Xcode project is included as an artifact. `ruby scripts/generate_project.rb` can recreate it using the installed `xcodeproj` Ruby gem; end users do not need this step to open or build it. No network or third-party SDK is needed for gameplay. iOS 17 or later is required.
