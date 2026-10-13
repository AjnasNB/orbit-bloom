# Build 19 — 13 October 2026

Farm expansion now counts Bloom first clears, all five skill-game first clears and successful Rally deliveries together. Three wins open field two; nine open field three. The original three/nine-harvest alternative remains. Locked fields display both progress fractions and explain the two routes, including an accessibility description. [Change and verification rationale](../../BUILD19_CONNECTED_FIELD_PROGRESS.md).

Source **34b57700b9576ac3ca73b78fc256fbc14ca3a9bb** is pushed to public GitHub **main**. **125 unique affected checks pass:** 60 core, 62 native and three real-input phone UI flows, with no failures/skips. The complete campaign remains reachable through 6,125 legal swaps and 24 retries across 1,020 stages and six projects, without paid items or extra moves. [Verification](verification.json). There is no fresh build-19 tablet run; previous tablet evidence is separate.

The normal personal preview runs **1.0 (19)**. Full private container backups and every typed preference were compared before/after the in-place install. Ordinary launch preserves every saved gameplay value, board identity, timer, inventory and receipt; only enum dictionary serialization order and StoreKit's advancing system check timestamp differ. The save retains **555 coins, three completed stages and the active rules-2 level-4 board with nine moves**. No preview reset, uninstall or test arguments were used. [Preservation proof](preview-preservation.json). Only the personal preview is booted; Store QA is shut down.

The signed package is **build/AppStoreExport19/OrbitBloom.ipa**, SHA-256 **adb87383aa1a2f57ff555b44d48ba671dc708a642730bb5e3361c32056d49b3f**. Strict signature verification, Production private iCloud/Game Center, disabled debugger, unchanged privacy manifest, absent test plug-ins and frozen source hashes pass. [Package proof](signed-package-verification.json), [source hashes](source-hashes.json).

**Build 19 is not uploaded, server-validated or submitted.** The previously established Xcode account-access/opaque Transporter control blocker has no new sign-in signal; Chrome's App Store tab is at login. No duplicate sign-in request or upload retry was made, and the pending final build-18 Transporter package was not replaced. The last verified public submission observation is 12 October: build 11 Waiting for Review, with six purchase products and a leaderboard. Today's run did not recheck authenticated Apple review state, cancel that submission, send another inquiry, accept an agreement, buy anything or publish a release. The existing Apple inquiry case remains **102994340844**.

[Store metadata](metadata-prepared.json) updates only the local next-build draft and passes text limits. [Gallery plan](apple-gallery-prepared.json) retains ten images per device, replacing the phone farm view with a fresh build-19 capture and identifying the unchanged build-18 views explicitly. These galleries are not already uploaded or saved to Apple.

The isolated Cloudflare support page is deployed at **https://orbitbloom.cognifyr.co/support/** and labels the new rules as development build 19. Chrome verifies the actual guidance; HTTPS, CSP, HSTS, frame denial, nosniff, four successful routes and the missing-route 404 pass. Worker deployment **f4e3edfa-04d2-42ca-a714-4dd5e8478115** changes only this support asset. No DNS, account, payment or player-save backend change was needed. [Site verification](site-verification.json), [Chrome proof](proof/live-support-rules.png).

Physical Game Center sign-in, private iCloud synchronization, signed sandbox purchases and real VoiceOver timing remain hardware checks. Local tests/signature checks do not prove Apple's servers or human difficulty.

## Original screenshots

[Manifest](manifest.json) pins fifteen unchanged native PNGs with dimensions, SHA-256 and case/device provenance. Legacy attachment names say build17; the result bundle and executable are build 19. The personal preview image comes from the ordinary install, without test arguments. No pixels were resized, painted or recreated.

- [Field two before wins](captures/phone-field2-before-wins.png)
- [Field two opened by three real skill games](captures/phone-field2-opened-by-skill-wins.png)
- [Field three at 3/9](captures/phone-field3-progress.png)
- [Unlocked field and saved apple after relaunch](captures/phone-field2-after-relaunch.png)
- [Preserved personal preview](captures/preview-preserved.png)
