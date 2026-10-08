# Orbit Bloom verification — 8 October 2026

**40 unique tests passed across the verified rules, native session, local StoreKit and targeted UI runs.** The first twelve stages and all six restoration projects were completed through actual simulator interactions. All 1,020 stages were completed separately by the rules solver. This does not mean all 1,020 stages were played through the UI or that the app has passed App Review.

| Verified area | Passing unique tests | Evidence |
| --- | ---: | --- |
| Swift rules, economy and powers | 24 | evidence/v3-core-verified.log; GitHub Core game rules CI for b8a2efe |
| Native save, hint migration, atomic grants, interruption recovery, bundled media | 5 | evidence/V3SwipeFixed.xcresult; refreshed with release materials |
| Apple local purchase flows | 6 | evidence/V3ApplePurchases.xcresult; evidence/v3-apple-purchases.log |
| Actual swipe campaign and six restorations | 1 | evidence/V3SwipeFixed.xcresult, 393.208 seconds |
| Farm, harvesting, task claim, craft and relaunch | 1 | evidence/V3SwipeFixed.xcresult |
| Pause, tool use, durable puzzle and Shop-to-Farm navigation | 1 | evidence/V3SwipeFixed.xcresult |
| Swipe steering, delivery reward and return navigation | 1 | evidence/V3RaceVerified.xcresult |
| On-board power formation, animated shuffle preservation and detonation | 1 | evidence/V3BoardPower.xcresult |

These results span several focused runs. The common UI run caught a race finish-button failure; the finish card was moved outside the steering gesture and that entire race flow then passed. Earlier diagnostic runs also caught vertical drags scrolling the puzzle page. Page scrolling now locks while a tile is held, and the campaign test asserts that every hinted swipe spends exactly one turn. Diagnostic failures are not counted as passing evidence.

## Gameplay and economy

The core campaign solver completed all 1,020 stages and six projects in **6,068 legal swaps, zero retries, and no paid items or extra moves**. This is a reachability check, not a human difficulty rating. Twelve opening stages are authored; 1,008 later stages use deterministic generated goals and boards.

The native UI campaign uses public hints, real horizontal/vertical drags, supplied inventory tools and earned cross bursts. It does not inject completed stages, grant stars or bypass victory checks. It verifies early relaunch persistence, twelve victories and six ordered restoration purchases with earned stars.

Additional checks cover fixed power formations, chained blasts consuming powers once, power persistence through saves/shuffles, first ten free hints, paid assistance, one-time field rewards, 30-minute life boundaries, non-expiring reserve lives, offline crop growth, compost crafting, cargo delivery and reward idempotency.

## Purchase verification

Six tests pass on **iOS 26.1** using Apple's local StoreKit test service: verified 400-coin credits without duplicate recovery, extra-life and starter-bundle grants with durable restore, cancellation, pending Ask to Buy approval, non-consumable purchase/restore, and asynchronous refund revocation of the legacy cosmetic entitlement. They use real StoreKit APIs with local test transactions and charge no money.

The iOS 26.5 runtime cannot reliably load the local catalogue, so it is used for gameplay/UI testing while iOS 26.1 handles purchase verification. Signed sandbox/device purchases are still required before release. Production consumable recovery/refund policy remains release work; the passing legacy cosmetic refund test does not establish consumable clawback behavior.

## Visual and web checks

Native screenshots are exported from actual runs at **1206 × 2622** without fabricating device dimensions. See release-draft/README.md for the gallery and selected ten App Store screenshots. Home, puzzle, on-board power, field tasks and race completion were visually inspected. The art consists of original rendered bitmap sprites, not interactive 3D meshes.

The standalone website was inspected in Chrome at its default desktop size and 390 × 844. All three bundled images loaded, horizontal overflow was absent, and the privacy page opened through navigation. JavaScript syntax and repository whitespace checks pass. Cloudflare deployment and final browser proof are blocked by the owner's authenticator verification and Mac lock; the intended subdomain is not claimed live.

## Reproduce and limits

`swift test` runs core checks. `scripts/test-ios.sh` runs core and all native checks on the separate Orbit Bloom Store QA iOS 26.1 simulator. `scripts/run-ios.sh` builds/installs the preview without clearing its save. Xcode 26.6 (17F113), Swift 6.3.3; gameplay device: iPhone 17 Pro, iOS 26.5; StoreKit device: iPhone 17 Pro Max, iOS 26.1.

Physical-device audio/haptics, VoiceOver and larger text, iPad layouts/orientations, older iOS versions, signed purchase interruptions and production save recovery remain unverified. There is no TestFlight upload, public release or App Review approval. Distribution signing requires the owner's Xcode account sign-in. Only Orbit Bloom is built; the other portfolio games remain concepts.
