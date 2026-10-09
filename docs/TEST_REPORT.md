# Orbit Bloom build 6 verification — 9 October 2026

**60 unique checks pass across the recorded runs: 28 core, 23 native, eight iPhone UI flows and one iPad layout flow.** Build 6 adds optional Game Center authentication and private iCloud saved gardens. Guest play, active puzzle/farm progression, coins, lives, tools, assistance and credited transactions remain in the local wallet. Separate player wallets and device files avoid silently combining balances. A restore that omits a purchase credited locally is rejected. Undo restores the local checkpoint and pauses cloud backup.

| Area | Unique passing cases | Evidence |
| --- | ---: | --- |
| Core gameplay, all-stage solver, economy and saved-garden schema | 28 | evidence/build6-core-tests.log |
| Native account migration, isolation, cloud choices, undo, corrupt saves, offline failures and Apple callback timeouts | 10 | evidence/Build6-AccountFinal.xcresult; evidence/Build6-RecoveryFinal.xcresult |
| Native sessions and bundled media | 7 | evidence/Build6-AccountFinal.xcresult |
| Apple local StoreKit purchase, pending, restore and refund checks | 6 | evidence/Build6-AccountFinal.xcresult |
| iPhone campaign, powers, island, farm/craft, rally, six packs, puzzle water and account/relaunch | 8 | evidence/Build6-Verification.xcresult; account contrast refreshed in evidence/Build6-AccountScreen.xcresult |
| iPad portrait/landscape controls and account page | 1 | evidence/Build6-iPadFinal.xcresult; 37.047 seconds |

The native UI campaign again wins twelve stages and restores six projects using real controls, in 290.603 seconds. Account UI testing plants a crop, opens the saved-garden screen, checks the honest guest state, returns to play and relaunches with the crop retained. Real Apple sign-in is deliberately not simulated in UI tests. Memory transport tests exercise save/restore/error behavior; they are not evidence of successful Game Center authentication or a live Apple iCloud round trip. No physical Apple device was connected. Signed sandbox purchases and cross-device cloud syncing remain owner/device checks.

Thirty native iPhone screenshots at 1320 × 2868 and nine native iPad captures are in release-draft/build6/. Seven iPad portraits are 2064 × 2752; two landscape QA images retain orientation 8 metadata and display at 2752 × 2064. Account button/footer contrast was corrected and the account capture refreshed after the UI rerun (24.223 seconds). Capture hashes and exact source attachments are recorded in build6/verification.json and build6/ipad/verification.json. No screenshots were resized or synthesized.

An initial account compilation error was repaired before passing runs. The first iPad assertions passed, but its result bundle stalled during diagnostic collection as disk space ran out; that incomplete bundle is not counted as final evidence. After removing only this project's rebuildable caches, the focused iPad test passed again with diagnostics disabled and a readable result bundle. Existing simulator saves were not erased.

The matching distribution profile was regenerated with Game Center and container iCloud.com.orbitbloom.game. Release archive and export passed. The exported 1.0 (6) IPA passes local signature/profile/bundle checks and contains Production CloudDocuments entitlements and four iPad orientations. See build6/signed-package-verification.json. **Build 6 has not been uploaded, submitted for App Review or publicly released.** Build 5 remains the previously processed TestFlight build. The Mac is locked during remaining Transporter/Chrome work.

The current App Store description/review notes and Game Center checkbox were saved. Privacy/support updates were deployed to the isolated existing Cloudflare Worker and the live privacy page was verified in Chrome. Publishing Apple's privacy declaration still requires the owner's approval of its accuracy/compliance/update agreement. During screenshot replacement, the old large-display images were moved into Apple's Asset Library and ten new native files were selected; persistence of the replacement set could not be verified before control was interrupted. Recheck or complete the upload before submitting. Six older iPad portraits remain the last verified uploaded set.

Build 6 was installed normally over Orbit Bloom QA (64173F47-C4DC-46B4-82EC-0027675F7780), without reset arguments. All preferences were exactly equal after installation. Normal launch retained the full garden wallet after normalizing only natural life-clock metadata and enum dictionary ordering. evidence/build6-preview-preservation.txt records this check. Only the user's preview simulator remains booted; the unused Store QA and iPad QA devices are stopped.

VoiceOver, larger text, smaller iPad and older iOS coverage, physical audio/haptics, human difficulty, consumable refund policy and live cloud/purchase integration remain release limitations. No real purchases or new legal/financial agreements were performed. Historical reports below apply only to their own builds.

---

# Orbit Bloom build 5 verification — 9 October 2026

**46 unique tests pass across the verified runs: 25 core checks, 13 native checks, seven existing UI flows and one new iPad release layout check.** The core suite was refreshed in this store-preparation run with 25 passes; the focused shop flow also passed again with six product screenshots. The prior combined native/UI evidence remains the source for the unchanged model and purchase flows. Build 5 introduces a bright SceneKit island, 102 horizontally swiped pages with ten sequential stops each, in-scene Farm/Rally gates, and swipe pages for crafting, field tasks, patterns and supplies. The game pages fit without vertical scrolling or a permanent activity tab bar. Native island meshes animate trees and clouds; board/farm art remains rendered bitmap sprites. The 1,020 stops have unique generated names across twelve biome families, not 1,020 individually authored 3D environments.

| Area | Passing cases | Evidence |
| --- | ---: | --- |
| Core rules, power patterns, economy, sequential unlocks and turn budgets | 25 | evidence/appstore-core-verification.log; evidence/v4-map-core-pass.log |
| Native persistence, locked-stage rejection and media | 7 | evidence/V5-FinalNative.xcresult |
| Apple local StoreKit purchase, approval, restore and refund flows | 6 | evidence/V5-FinalNative.xcresult |
| Real UI campaign, island pages, powers, journal, farm/craft, race, all six packs and water recovery | 7 | evidence/V5-FinalNative.xcresult; evidence/AppStore-PurchaseReviewRetry.xcresult |
| iPad portrait/landscape layout, navigation, all 49 tiles, tools and six farm plots | 1 | evidence/AppStore-IPadFullScreen.xcresult; 39.289 seconds |

The core solver completes all 1,020 levels and six garden projects in **6,033 legal swaps, zero retries, and no paid items or extra moves**. Sixty additional seeded opening simulations cover five boards for each of the first twelve stages. The actual UI campaign wins the first twelve stages and restores all six projects using real hints, swipes, inventory tools and earned bursts, in 310.039 seconds. This is reachability and regression evidence, not a claim that 1,020 levels were manually played or that human difficulty is calibrated. Turns are now 10–20; the generated later stages use 16–20.

Diagnostic runs found and reproduced three interaction failures. The map's empty terrain initially did not receive swipes; its full content area now does. A stale transparent blast layer remained over the next level after a victory and blocked its hinted tile; blast state now expires independently with an identity guard and clears when entering/leaving a stage. The race road intercepted the finish button; it now stops receiving input after finishing. All affected flows pass in the final combined run. Atlas crop bounds also exclude neighboring art fragments, and light appearance plus grouped shadows keep status text and labels readable.

Tests reset only the separate Store QA simulator (6D8263A8-F049-48C0-AC3D-5FCBCFD3A3C7, iOS 26.1). Build 5 was installed over Orbit Bloom QA (64173F47-C4DC-46B4-82EC-0027675F7780, iOS 26.5) without clearing data. Preferences were identical immediately after installation; progress, balances, crops, tools, assistance and saved session were preserved after normal launch. Only natural life-clock refresh and enum dictionary ordering were normalized. See evidence/v5-preview-preservation.txt. The App Store orientation update was subsequently installed over the same preview: all preferences were identical immediately after installation, and normal launch retained the saved game (160 coins), allowing only natural life-clock metadata and enum dictionary ordering. See evidence/appstore-preview-preservation.txt.

Nineteen actual build 5 screenshots were exported at native 1320 × 2868, with hashes and source attachments in release-draft/verification.json. The previous ten native medium-display captures were archived separately. Ten large-display screenshots persisted after upload/reload in Chrome; the medium class inherits those current images through Apple’s Using Existing Assets view. Current device-class status is in release-draft/app-store-screenshots.json. The website is hosted on the new isolated Cloudflare Worker at https://orbit-bloom-game-site.ajnasnb.workers.dev/; existing sites and DNS are untouched.

The App Store preparation adds the missing upside-down portrait declaration for iPad, both in the checked-in project and its generator. The corrected Release archive compiles without the previous all-orientations warning. The matching App Store distribution profile was subsequently found in Documents and installed. Manual signing, Release archive and IPA export succeeded (evidence/appstore-signed-archive.log and evidence/appstore-signed-export.log). The package signature, bundle/version/build and four iPad orientations passed local checks. Transporter delivered build 1.0 (5) at 15:25 Asia/Kolkata; Apple processed it and TestFlight reports Ready to Submit. This is upload evidence, not App Review approval or a signed sandbox purchase test. See release-draft/signed-package-verification.json.

The iPad Pro 13-inch (iOS 26.1) release test launches with --keep-progress, avoiding save resets, and asserts real rotation, visible bounds and hittability for all 49 board tiles, pause/tools, all six farm plots and home/farm/craft/rally/shop navigation. Six native portrait captures at 2064 × 2752 are ready for Apple. Two full-screen landscape QA captures retain native orientation 8 metadata and render at 2752 × 2064; they are not falsely described as differently encoded pixels. The initial app-region landscape screenshots had a cropped frame/orientation mismatch; replacing that capture with XCUIScreen.main and repeating the affected test produced correct full-screen images. This checks the large iPad layout, not every iPad model or actual landscape puzzle wins.

The first purchase screenshot attempt failed during accessibility bootstrap before executing assertions. After recovering the dedicated test device, the same targeted shop flow passed (44.282 seconds) and captured all six actual packs. A temporary Apple upload error for the 3,000-coin screenshot was retried successfully. After Chrome reconnected, all six purchase review screenshots and notes were saved and verified, and Apple added them to one draft as Ready for Review. Six native portrait iPad screenshots uploaded and rendered; final reload verification is pending. Free app pricing and 173-region availability were configured, excluding China mainland and Vietnam without their required game licenses. Categories, subtitle, content rights, age rating and saved privacy answers are complete; privacy publication awaits the owner’s agreement confirmation. Payment agreements, bank/tax setup and trader compliance show Active and were unchanged.

Orbit Bloom QA now exists as an internal TestFlight group with build 5. No testers have yet been added. The Mac locked again during release-version build selection before the owner invitation could be sent. Two unused booted simulators were shut down without erasing their data; the user’s Orbit Bloom preview and the simulator used by another active game chat were preserved. No gameplay code changed during this signing/upload continuation, so the existing 46-case verification remains the applicable test evidence.

No real purchases, new agreements, App Review submission or public app release were performed. Physical devices, signed sandbox transactions, VoiceOver, larger text, smaller iPad and older iOS layouts, audio/haptics on hardware, human difficulty and production purchase recovery remain release checks. Historical reports below describe their own builds and must not be read as current screenshot or hosting status.

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
