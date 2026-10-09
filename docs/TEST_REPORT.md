# Orbit Bloom build 5 verification — 9 October 2026

**45 unique tests pass: 25 core checks and a final combined run of 13 native plus 7 UI tests, with zero failures.** Build 5 introduces a bright SceneKit island, 102 horizontally swiped pages with ten sequential stops each, in-scene Farm/Rally gates, and swipe pages for crafting, field tasks, patterns and supplies. The game pages fit without vertical scrolling or a permanent activity tab bar. Native island meshes animate trees and clouds; board/farm art remains rendered bitmap sprites. The 1,020 stops have unique generated names across twelve biome families, not 1,020 individually authored 3D environments.

| Area | Passing cases | Evidence |
| --- | ---: | --- |
| Core rules, power patterns, economy, sequential unlocks and turn budgets | 25 | evidence/v4-map-core-pass.log |
| Native persistence, locked-stage rejection and media | 7 | evidence/V5-FinalNative.xcresult |
| Apple local StoreKit purchase, approval, restore and refund flows | 6 | evidence/V5-FinalNative.xcresult |
| Real UI campaign, island pages, powers, journal, farm/craft, race, all six packs and water recovery | 7 | evidence/V5-FinalNative.xcresult; evidence/v5-final-native.log |

The core solver completes all 1,020 levels and six garden projects in **6,033 legal swaps, zero retries, and no paid items or extra moves**. Sixty additional seeded opening simulations cover five boards for each of the first twelve stages. The actual UI campaign wins the first twelve stages and restores all six projects using real hints, swipes, inventory tools and earned bursts, in 310.039 seconds. This is reachability and regression evidence, not a claim that 1,020 levels were manually played or that human difficulty is calibrated. Turns are now 10–20; the generated later stages use 16–20.

Diagnostic runs found and reproduced three interaction failures. The map's empty terrain initially did not receive swipes; its full content area now does. A stale transparent blast layer remained over the next level after a victory and blocked its hinted tile; blast state now expires independently with an identity guard and clears when entering/leaving a stage. The race road intercepted the finish button; it now stops receiving input after finishing. All affected flows pass in the final combined run. Atlas crop bounds also exclude neighboring art fragments, and light appearance plus grouped shadows keep status text and labels readable.

Tests reset only the separate Store QA simulator (6D8263A8-F049-48C0-AC3D-5FCBCFD3A3C7, iOS 26.1). Build 5 was installed over Orbit Bloom QA (64173F47-C4DC-46B4-82EC-0027675F7780, iOS 26.5) without clearing data. Preferences were identical immediately after installation; progress, balances, crops, tools, assistance and saved session were preserved after normal launch. Only natural life-clock refresh and enum dictionary ordering were normalized. See evidence/v5-preview-preservation.txt.

Nineteen actual build 5 screenshots were exported at native 1320 × 2868, with hashes and source attachments in release-draft/verification.json. The previous ten native medium-display captures were archived separately. Ten large-display screenshots persisted after upload/reload in Chrome; the medium class inherits those current images through Apple’s Using Existing Assets view. Current device-class status is in release-draft/app-store-screenshots.json. The website is hosted on the new isolated Cloudflare Worker at https://orbit-bloom-game-site.ajnasnb.workers.dev/; existing sites and DNS are untouched.

The build 5 archive attempt with existing automatic provisioning still reports No Accounts and no profile (evidence/v5-signing-account-check.log); no signed archive or TestFlight upload was produced. No real purchases, agreements, App Review submission or public app release were performed. Physical devices, signed sandbox transactions, VoiceOver, larger text, iPad and older iOS layouts, audio/haptics on hardware, human difficulty and production purchase recovery remain release checks. Historical reports below describe their own builds and must not be read as current screenshot or hosting status.

---

# Orbit Bloom verification — 9 October 2026

**Build 4: 42 unique cases passed across the full run and focused reruns.** Puzzle water now commits with the resolved board before match animations. The regression reproduced a saved balance of 12 rather than 16 before the fix. With the fix, model recreation during animation retains all four dewdrops, animation completion does not duplicate them, and the real UI can reopen Farm at 16 water and plant a rose to reach 14.

| Area | Passing unique cases | Current evidence |
| --- | ---: | --- |
| Core rules, 1,020-stage reachability, economy and power patterns | 24 | evidence/daily-20261009-verified.log |
| Native sessions, interrupted rewards, water durability, bundled media | 6 | evidence/Daily-20261009-PurchasesVerified.xcresult |
| Local Apple StoreKit transactions, approvals, restore and refunds | 6 | evidence/Daily-20261009-PurchasesVerified.xcresult |
| Actual UI: power formation/shuffle, farm/craft, race, tools/shop, water/reopen/plant | 5 | evidence/Native-20261009-100310.xcresult |
| Twelve-stage swipe campaign and six ordered world restorations | 1 | evidence/Daily-20261009-CampaignVerified.xcresult; 429.620 seconds |

The initial combined native run had three failures: two purchase assertions read asynchronous entitlements too early, and the campaign had a Hint press that did not produce its instruction. Purchase tests now wait up to five seconds for the expected entitlement and all twelve native cases pass. The unchanged campaign passed in isolation without other UI automation running. This is passing coverage across multiple runs, not a claim that the first combined run was wholly green. Failed diagnostics remain local and are excluded from the passing manifest.

All resetting UI tests ran on the separate Orbit Bloom Store QA device (6D8263A8-F049-48C0-AC3D-5FCBCFD3A3C7, iOS 26.1). Build 4 was installed over the user's Orbit Bloom QA preview (64173F47-C4DC-46B4-82EC-0027675F7780, iOS 26.5). Its preferences were backed up and progress, session, assistance, crops, resources and tools were verified preserved; enum-key tool dictionaries were compared without depending on serialization order.

The new farm meters have grouped resource labels for accessibility. The release gallery adds the actual build 4 water-to-farm capture at 1320 × 2868, without resizing. Existing sixteen build 3 screenshots remain valid visual references. Ten selected native iPhone medium-display screenshots were uploaded to the App Store draft through Chrome, retained after reload, and displayed rendered thumbnails. Build 4 review notes also persisted after reload. No review or public-release action was performed.

The distribution archive attempt still reports no signed-in Xcode account and no provisioning profile for com.orbitbloom.game. No signed archive, validation or TestFlight upload was produced. Cloudflare's existing authenticator challenge remains unresolved. No purchases or legal agreements were accepted.

Physical-device testing, signed sandbox transactions, VoiceOver, larger text, iPad layout, older iOS versions and production save recovery remain release work. The all-stage solver checks reachability; it does not establish human difficulty or mean that all 1,020 stages were played in the UI.

---

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
