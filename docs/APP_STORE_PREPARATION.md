# Subsequent cartoon artwork revision — build 13

Build 13 is locally verified: shared cartoon fruit/powers, robot/coin, Lio and rally rover; safe sprite framing; unchanged save and purchase schemas. The [109-case test record](release-draft/build13/verification.json) and [25 native screenshots](release-draft/build13/README.md) prepare this visual revision for a later distribution update. The ordinary preview preserves its current saved game and runs 1.0 (13).

**Build 13 is not uploaded or submitted.** The existing build-11 Apple submission, binary and uploaded gallery are unchanged. Its status was not freshly rechecked here because the Chrome connection was unavailable. Local screenshots must not be presented as already uploaded product-page assets, and simulator account/purchase tests do not replace physical Apple service checks.

---

# Orbit Bloom App Store preparation — 10 October 2026

## Subsequent UI revision — build 12

Build 12 expands the connected garden and adaptive puzzle board, fixes shuffle input during movement and enlarges the Keep playing target. It has 103 unique recorded passing affected checks and [eleven native captures](release-draft/build12/README.md). The ordinary preview runs build 12 with all saved game state preserved, including the current level-2 ten-move session. [Verification](release-draft/build12/verification.json) distinguishes final evidence from failed diagnostics.

**Build 12 is local and not uploaded/submitted.** Chrome rechecked the existing build-11 submission: all eight items are Waiting for Review. Its binary, twenty screenshots and store copy remain unchanged. The build-11 details below describe that submission and its historical preview update, not the new build-12 simulator revision.


## Current release status — build 11

App **Orbit Bloom: Garden Arcade**, Apple ID **6820591529**, bundle **com.orbitbloom.game**, SKU **orbit-bloom-ios-001**, publisher **Ajnas N B**, team **4V29K5Q8S9**. Version **1.0 (11)** was submitted on **10 October 2026 at 4:47 PM India time (+05:30; minute precision)**. Apple confirms **Waiting for Review for all eight items**: the app version, **Atoll Skills** leaderboard and all six existing purchase packs. [Submission 83b00d39-0873-4771-8bc9-5d94d4be04b4](https://appstoreconnect.apple.com/apps/6820591529/distribution/reviewsubmissions/details/83b00d39-0873-4771-8bc9-5d94d4be04b4) is the current review record. [Actual Apple confirmation](release-draft/build11/proof/apple-review-submission.jpg) shows the submitted build and status. **Manual public release remains selected; the app is not live.** The publisher removed build 7's submission `a7ca5b7d-24f9-4b4a-8dba-9ecf44398ec9` to replace it with tested build 11. This was not an Apple rejection.

Transporter **Verify succeeded at 3:54 PM** and **Deliver succeeded at 4:29 PM India time**. Apple processing is **complete**, and the version has build **eefcb52c-0e76-4c8e-bed5-0d19a2d9f157** attached. The signed package retains Production Game Center/private iCloud entitlements, disabled debugger access, all four iPad orientations and the required UserDefaults/SystemBootTime privacy reasons. [Package verification](release-draft/build11/signed-package-verification.json) pins app source `8b26cbdbe0827c571aca7725842a5a973d0c7dea` and the same **44 source/asset/privacy hashes**. Private certificates/profiles are not committed.

**107 unique cases have a recorded passing run: 49 core, 47 native, nine iPhone UI and two iPad UI cases.** This is a union across runs, not a claim that every diagnostic bundle passed. [Build 11 verification](release-draft/build11/verification.json), [test report](TEST_REPORT.md) and [security review](SECURITY_REVIEW.md) retain the test evidence and limits. The four new skill rooms join Bloom, Farm and Harvest Rally through Lio's Aurora Atoll story, separate room maps, shared stars/coins/water, UTC events and skill records.

Optional Game Center sign-in and GameKit private iCloud saves remain the player cloud service; guest play is available. Per-player local wallets, per-device cloud files, explicit restore choices, recovery/undo checkpoints, purchase receipt protection and account-change guards remain in place. A simple public Cloudflare event clock does not store player saves or purchase data. **Physical Game Center authentication, private iCloud backup/restore, signed Apple sandbox purchases and leaderboard submission remain unverified on hardware.** Local StoreKit and account/clock doubles are not Apple sandbox-server tests.

The ordinary preview update used no reset or QA launch flags. [After installation](release-draft/build11/preview-after-install.json), all seven preferences and the plist bytes match exactly. [After normal launch](release-draft/build11/preview-after-launch.json), the full wallet, puzzle, farm, inventory, receipts and settings are preserved: **280 coins, one completed stage, active level 2/rules 1 with eleven moves, seven hints and five lives**. Only dictionary serialization order and one newly added empty journey default were accepted; timers/gameplay values were compared. StoreKit check metadata changed separately. Store/iPad QA are shut down, the user's preview is booted and unrelated Rush Drives is preserved.

## Current screenshots and testing access

All **20 actual native build-11 screenshots — ten iPhone and ten iPad — processed, uploaded and saved** with the submitted app version. [Gallery manifest](release-draft/build11/manifest.json) records hashes, tests and provenance; [gallery index](release-draft/build11/README.md) links every selection. Native portrait PNGs remain 1320 × 2868 on iPhone and 2064 × 2752 on iPad. The twenty separate proof images cover supplies/packs, records, Apple save/ranking information, native iPad landscape views and the preserved preview. These are separate from the twenty-image Apple gallery.

The iPad gallery's ninth image is settled Field Tasks and powers; the mid-transition shop frame is excluded and retained as diagnostic evidence. Original bytes and orientation metadata are preserved, without resizing or synthetic UI. Original xcresults remain at workspace-relative evidence paths; removed temporary exports can be regenerated from the named result bundle.

TestFlight build **1.0 (11)** is processed and assigned to internal **Orbit Bloom QA**, group **20c17cf7-ef9b-43be-9a6a-55530abb5a3f**, with **one tester**. **What to Test is saved.** Assignment does not prove the owner installed build 11 or tested Apple services. The last recorded hardware installation was build 6 on 9 October; update to build 11 for the physical checks below.

Atoll Skills, identifier **com.orbitbloom.atollskills**, leaderboard UUID **1645f43b-b600-4b0c-b695-33750851e1ad**, is included in the same submission and shows **Waiting for Review**. Its score combines the four new rooms' bounded personal bests; coins, lives and purchases do not contribute. Client score bounds are not authoritative anti-cheat.

## Purchases and account

The account's Free Apps/Paid Apps agreements, bank, tax and trader compliance already show **Active**; none were changed. App download pricing is **free**, with India as base region. Optional packs display Apple's localized prices.

| Product | Apple ID | Type | India price | Grant |
| --- | --- | --- | --- | --- |
| com.orbitbloom.coins400 | 6820593641 | Consumable | ₹99 | 400 coins |
| com.orbitbloom.coins1500 | 6820595004 | Consumable | ₹299 | 1,500 coins |
| com.orbitbloom.coins3000 | 6820595079 | Consumable | ₹499 | 3,000 coins |
| com.orbitbloom.coins7000 | 6820594918 | Consumable | ₹999 | 7,000 coins |
| com.orbitbloom.lives5 | 6820595083 | Consumable | ₹99 | 5 non-expiring extra lives |
| com.orbitbloom.starter | 6820594801 | Non-consumable | ₹99 | One-time 600 coins + 3 extra lives |

All six products have worldwide availability and English (U.S.) metadata. Six actual native purchase screenshots and reviewer notes were saved and verified. All six were included with version 1.0 (11) and Atoll Skills in the eight-item submission on 10 October 2026; each shows **Waiting for Review**. Their configured India prices remain unchanged at ₹99–999. These products are not live or evidence of real payment tests. The obsolete Aurora local test product remains only for entitlement regression coverage.

## Current metadata and site

Review contact details supplied by the owner were saved and the missing-field errors cleared. Private contacts remain in Apple rather than the public repository. Subtitle **Seven games. One living island**, category Games, Puzzle/Simulation subcategories, content rights and the age questionnaire are saved. Most regions rate 13+, Vietnam 16+, Korea 12+. App availability is 173 regions, excluding China mainland and Vietnam because required game licenses were not supplied. Future-region auto-add is off. Mac/Vision Pro distribution is opted out, verified on the saved pricing page in Chrome. No licenses were invented.

The current description/review notes and Game Center selection accompany build 11's seven rooms, shared progression, events and optional Apple saves/ranking. Guest sign-in is not required for review/play. [Current metadata](release-draft/metadata.json), [build-11 draft copy](release-draft/build11/metadata.md) and [App Store status](release-draft/app-store-status.json) record the prepared configuration. Historical build-7 copy and creative assets remain below and in their original bundles.

The isolated Cloudflare Worker serves the game site, privacy/support pages and public event clock at https://orbit-bloom-game-site.ajnasnb.workers.dev/ . The deployed version is **1fe5fe66-69a0-4b46-a680-70fadf7a12d7**. Five HTTPS/security-route checks and actual native public-clock acceptance are separate from the 107 test cases. No player save or purchase database was added; Apple remains the sole player cloud service. Existing projects and DNS were untouched. The optional cognifyr.co subdomain remains unconfigured and does not block these live URLs.

The privacy declaration is **Data Not Collected, published by Ajnas N B**, verified in Chrome before submission. Apple defines collection around developer/third-party access and says the publisher is not responsible for Apple's own data collection: [official definitions](https://developer.apple.com/app-store/app-privacy-details/). The declaration had already been published when the agent resumed; no new legal agreement was accepted by the agent.

## Historical build 7 release snapshot — 9 October 2026

The paragraphs in this section preserve the earlier build-7 record, including its then-current screenshots, TestFlight installation and review status. They do not describe the current build-11 queue. That submission was later removed by the publisher on 10 October to replace it with build 11, not rejected by Apple.

App **Orbit Bloom: Garden Arcade**, Apple ID **6820591529**, bundle **com.orbitbloom.game**, SKU **orbit-bloom-ios-001**, publisher **Ajnas N B**, team **4V29K5Q8S9**. Version **1.0 (7)** and all six first purchases were resubmitted on **9 October 2026 at 10:55 PM India time** with the upgraded product page. Apple confirms **Waiting for Review** for all seven items. Submission **a7ca5b7d-24f9-4b4a-8dba-9ecf44398ec9** has [Apple confirmation proof](release-draft/product-page/proof/apple-review-submission.jpg). The linked header and search creative assets also show Waiting for Review. Manual public release remains selected; the app is not publicly released. The 10:26 PM build 7 submission was cancelled by the publisher to unlock artwork/gallery edits; the earlier build 6 submission was cancelled to apply the security patch. Neither cancellation was an Apple rejection.

Optional Game Center sign-in and GameKit saved games use the player's private iCloud Drive container `iCloud.com.orbitbloom.game`. Guest play remains available. Per-player local wallets, per-device cloud files, explicit restore choices, local recovery and undo checkpoints, purchase protection and timeout/error handling are implemented. Build 7 rejects corrupt timers and excessive save values, validates legacy progress, and guards cloud results and restore choices against Apple account changes. **68 unique core/native/UI checks pass.** A live Apple cloud round trip and signed sandbox purchases on hardware remain unverified; the owner has installed build 6 through TestFlight, but no device is connected for independent testing. See [test report](TEST_REPORT.md) and [security review](SECURITY_REVIEW.md).

The matching **Orbit Bloom AppStore** profile includes Game Center and the isolated iCloud container. Release archive/export and exported package signature checks pass. The IPA has Production CloudDocuments entitlements, debugger access disabled and four supported iPad orientations. [Build 7 package verification](release-draft/build7/signed-package-verification.json) records the exact hash and source commit. Private certificates/profiles are not committed.

The App Store description covers optional accounts/saves; review notes now also describe build 7's save and account-change protections. The notes were saved and verified after reloading in Chrome. The version's Game Center checkbox is checked. Sign-in is not required for guest review/play. Full draft copy is in [metadata.json](release-draft/metadata.json).

The isolated existing Cloudflare Worker serves marketing, privacy and support at https://orbit-bloom-game-site.ajnasnb.workers.dev/ . Privacy/support cover Game Center and private iCloud saves. Security headers were hardened and deployed as Worker version `7c4a36b1-1c7d-484d-abc1-2e5b9f555ee4`; five HTTPS routes, including the 404, pass the security check. Chrome displays the live site without site CSP failures. Per the owner's architecture preference, Apple remains the sole player cloud service; no additional Cloudflare player database was created. Existing projects and DNS were untouched. The optional cognifyr.co subdomain remains unconfigured and does not block these live URLs.

The upgraded product page has **20 distinct native screenshots: ten iPhone and ten iPad**, the maximum per gallery. Puzzle, farm and rally lead both sets, followed by island exploration, crafting, field rewards, optional supplies and saved-garden settings. Phone views also explain power formations and garden restoration; iPad includes native puzzle/world landscapes. The medium iPhone class inherits the large-display set. All twenty uploads processed, persisted and passed Apple's review submission validation. Older placements were removed while retaining the originals in Apple's Asset Library.

[Product-page manifest](release-draft/product-page/manifest.json) records exact source builds, source files and hashes. Native portraits are 1320 × 2868 on iPhone and 2064 × 2752 on iPad; two landscapes retain original orientation metadata and display at 2752 × 2064. Screenshot PNGs are copied byte-for-byte, without resizing or synthetic UI. Phone gameplay views from build 6 remain accurate for build 7; new build 7 task/account captures and iPad views complete the sets. The iPad race road capture shows the real paused race; the phone race image shows active gameplay.

Original dimensional botanical **header** (3840 × 1646) and **search results artwork** (1920 × 1280) were generated using the built-in imagegen tool and exported as opaque PNGs. They are brand illustrations, separate from gameplay screenshots. Header asset `08c00019-689f-87a9-803c-67de0c1e9279` and search asset `f7800019-689f-87a9-802c-11f4d5819599` are attached to the default English (U.S.) product page and included with app-version review. Both Apple's [header preview](release-draft/product-page/proof/header-preview.jpg) and [search preview](release-draft/product-page/proof/search-preview.jpg) were visually checked. [Apple's creative asset guidance](https://developer.apple.com/help/app-store-connect/manage-app-information/manage-your-app-store-assets/) limits these placements to iOS/iPadOS 27 and later; the real screenshot galleries remain available on earlier store versions. [Prompts and export provenance](release-draft/product-page/IMAGE_PROMPTS.md) are recorded. Promotional text (159/170 characters) and keywords (99/100) were saved and verified after reload in Chrome.

The affected phone farm/harvest/craft/relaunch flow and iPad layout/swipe flow passed again for the new captures. This reruns two existing cases and does not increase the **68 unique passing tests**. Shipping app code and the signed build 7 IPA are unchanged; no new binary upload was needed. See [product-page bundle](release-draft/product-page/README.md), [test report](TEST_REPORT.md) and [screenshot status](release-draft/app-store-screenshots.json).

Transporter delivered build 7 at **10:18 PM India time**; Apple processed it and TestFlight shows **Ready to Submit**. TestFlight build **1c228e3d-b614-4ffd-b3fd-52970c1a8a07** is assigned to the internal **Orbit Bloom QA** group. Automatic distribution is enabled, with three builds (5, 6 and 7) and one owner tester. The owner's individual tester row now shows **Installed 1.0 (6)** on an iPhone 17 Pro running iOS 26.6.1. No invitation was sent again. Update to build 7 in TestFlight for the live Game Center/iCloud and signed sandbox purchase checks; installation alone does not verify those flows.

Build 7 is installed over the user's preview simulator without clearing its save. Preferences matched exactly immediately after installation and the complete garden wallet survived normal launch: 280 coins, one completed stage and the active stage 2 puzzle. Orbit Bloom's unused Store/iPad QA simulators are stopped; its preview remains booted. The Rush Drives simulator used by another active chat was left untouched.

## Historical daily internal build 8 — 10 October 2026

This is the build-8 run's historical snapshot; its account blocker and unchanged build-7 queue were true for that run, before the later build-11 upload/submission.

Build **1.0 (8)** fixes field-journal clipping with adaptive swipe pages, complete wrapping and accessible page adjustment. **63 cases passed in this run: 31 core, 28 native, three affected iPhone flows and one iPad flow.** Including six unchanged iPhone flows recorded for build 7, the applicable recorded coverage totals 69 unique cases; those six were not rerun today. Six actual journal captures, the source commit and save-preserving preview installation are in [build 8 verification](release-draft/build8/verification.json). The user's preview still has 280 coins, one completed stage and the active level 2 puzzle.

Release archive/export and exported signature/Production entitlement checks passed. The [exact build 8 IPA](release-draft/build8/signed-package-verification.json) is ready locally, but **it has not been uploaded to TestFlight**: Xcode's upload export failed to use Apple accounts; Transporter UI was unavailable while the Mac was locked. Chrome redirected the review page to sign-in, so the current review status was not independently rechecked today. No repeated sign-in request, account workaround or new agreement was attempted.

The submitted build 7, its product-page galleries and its last-verified review status above remain the release record. Build 8 screenshots are prepared for its later release metadata; the daily run did not cancel, replace or resubmit the public review.

## Historical gameplay build 9 — 10 October 2026

This is the build-9 run's historical snapshot, before the later build-11 upload/submission.

Build **1.0 (9)** adds confirmed abandon/restart navigation, visible Simple/Hard/Super hard labels, tighter later campaign bands and twenty one-move One shot challenges. Active legacy puzzles retain their original rules; new active rules use a schema-2 cloud envelope. **76 unique core/native/iPhone/iPad tests passed in this task**, with an affected One shot rerun after a singular-copy correction. [Build 9 verification](release-draft/build9/verification.json) records seven native release captures, a separate preview proof and compact result summaries. The preview is installed without reset and still has the full 280-coin garden and active level 2 puzzle.

Signed Release archive/export, exact package signature and Production cloud entitlement checks passed. [Build 9 package record](release-draft/build9/signed-package-verification.json) pins source `fe8a7d9`. Build 9 is prepared locally, **not delivered to TestFlight**. The existing Apple account authentication blocker was not re-prompted or retried. This gameplay task did not access or change the submitted build 7, its twenty-image Apple galleries or review queue, and did not freshly recheck its review status. No privacy/payment architecture or product price changed; no public release, new agreement or real purchase occurred.

## Historical activity-room build 10 — 10 October 2026

This is the build-10 run's historical snapshot, before the later build-11 upload/submission.

Build **1.0 (10)** separates Farm and Harvest Rally into labeled entrances with original 3D room maps, clear Island exits and a width-fitting camera. **77 unique cases passed**: 34 core, 30 native, twelve iPhone UI and one iPad UI. Final targeted reruns cover camera/road refinements, both iPad orientations and non-overlapping large-text Farm plots. [Build 10 verification](release-draft/build10/verification.json) pins source `fac4c21`, thirteen native captures, compact result summaries and the full save comparison. The personal preview is installed without reset: 280 coins, completed level 1, active level 2 with eleven moves and seven free hints remain intact.

The final signed Release archive/export and exact package signature/Production cloud checks passed. [Package record](release-draft/build10/signed-package-verification.json) identifies the matching IPA. Build 10 is prepared locally, **not delivered to TestFlight**; the existing Apple account authentication blocker remains without a repeat sign-in request or upload attempt. This task did not modify build 7's submitted Apple galleries or review queue, and did not freshly recheck its review status. Purchases, privacy architecture and product pricing keep their established configuration.

## Remaining public release checks

1. Wait for Apple's review outcome for the **eight** submitted items. Public release remains manual.
2. Install TestFlight **build 11** on the owner's device; verify Game Center sign-in, private iCloud backup/restore across devices, signed Apple sandbox purchases and Atoll Skills leaderboard submission. Do not perform real purchases for QA.
3. Check physical VoiceOver focus/timing, performance/audio/haptics, broader accessibility, smaller/older devices, split-screen and human pacing before public release.

Daily improvement automation remains ACTIVE at 10:00 Asia/Kolkata for coding, tests, screenshots and internal build uploads. It does not accept agreements, perform real purchases or submit public releases. The current eight-item submission is this explicitly authorized release task, separate from unattended daily work.
