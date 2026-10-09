# Orbit Bloom App Store preparation — 9 October 2026

## Current release status

App **Orbit Bloom: Garden Arcade**, Apple ID **6820591529**, bundle **com.orbitbloom.game**, SKU **orbit-bloom-ios-001**, publisher **Ajnas N B**, team **4V29K5Q8S9**. Version **1.0 (7)** and all six first purchases were resubmitted on **9 October 2026 at 10:55 PM India time** with the upgraded product page. Apple confirms **Waiting for Review** for all seven items. Submission **a7ca5b7d-24f9-4b4a-8dba-9ecf44398ec9** has [Apple confirmation proof](release-draft/product-page/proof/apple-review-submission.jpg). The linked header and search creative assets also show Waiting for Review. Manual public release remains selected; the app is not publicly released. The 10:26 PM build 7 submission was cancelled by the publisher to unlock artwork/gallery edits; the earlier build 6 submission was cancelled to apply the security patch. Neither cancellation was an Apple rejection.

Optional Game Center sign-in and GameKit saved games use the player's private iCloud Drive container `iCloud.com.orbitbloom.game`. Guest play remains available. Per-player local wallets, per-device cloud files, explicit restore choices, local recovery and undo checkpoints, purchase protection and timeout/error handling are implemented. Build 7 rejects corrupt timers and excessive save values, validates legacy progress, and guards cloud results and restore choices against Apple account changes. **68 unique core/native/UI checks pass.** A live Apple cloud round trip and signed sandbox purchases on hardware remain unverified; the owner has installed build 6 through TestFlight, but no device is connected for independent testing. See [test report](TEST_REPORT.md) and [security review](SECURITY_REVIEW.md).

The matching **Orbit Bloom AppStore** profile includes Game Center and the isolated iCloud container. Release archive/export and exported package signature checks pass. The IPA has Production CloudDocuments entitlements, debugger access disabled and four supported iPad orientations. [Build 7 package verification](release-draft/build7/signed-package-verification.json) records the exact hash and source commit. Private certificates/profiles are not committed.

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

All six products have worldwide availability and English (U.S.) metadata. Six actual native purchase screenshots and reviewer notes were saved and verified. Apple submitted all six together with version 1.0 (7), and each shows **Waiting for Review**. These products are not live or evidence of real payment tests. The obsolete Aurora local test product remains only for entitlement regression coverage.

## Draft metadata and site

Review contact details supplied by the owner were saved and the missing-field errors cleared. Private contacts remain in Apple rather than the public repository. Subtitle **Swipe, farm & race among stars**, category Games, Puzzle/Simulation subcategories, content rights and the age questionnaire are saved. Most regions rate 13+, Vietnam 16+, Korea 12+. App availability is 173 regions, excluding China mainland and Vietnam because required game licenses were not supplied. Future-region auto-add is off. Mac/Vision Pro distribution is opted out, verified on the saved pricing page in Chrome. No licenses were invented.

The App Store description covers optional accounts/saves; review notes now also describe build 7's save and account-change protections. The notes were saved and verified after reloading in Chrome. The version's Game Center checkbox is checked. Sign-in is not required for guest review/play. Full draft copy is in [metadata.json](release-draft/metadata.json).

The isolated existing Cloudflare Worker serves marketing, privacy and support at https://orbit-bloom-game-site.ajnasnb.workers.dev/ . Privacy/support cover Game Center and private iCloud saves. Security headers were hardened and deployed as Worker version `7c4a36b1-1c7d-484d-abc1-2e5b9f555ee4`; five HTTPS routes, including the 404, pass the security check. Chrome displays the live site without site CSP failures. Per the owner's architecture preference, Apple remains the sole player cloud service; no additional Cloudflare player database was created. Existing projects and DNS were untouched. The optional cognifyr.co subdomain remains unconfigured and does not block these live URLs.

The privacy declaration is **Data Not Collected, published by Ajnas N B**, verified in Chrome before submission. Apple defines collection around developer/third-party access and says the publisher is not responsible for Apple's own data collection: [official definitions](https://developer.apple.com/app-store/app-privacy-details/). The declaration had already been published when the agent resumed; no new legal agreement was accepted by the agent.

## Screenshots and testing access

The upgraded product page has **20 distinct native screenshots: ten iPhone and ten iPad**, the maximum per gallery. Puzzle, farm and rally lead both sets, followed by island exploration, crafting, field rewards, optional supplies and saved-garden settings. Phone views also explain power formations and garden restoration; iPad includes native puzzle/world landscapes. The medium iPhone class inherits the large-display set. All twenty uploads processed, persisted and passed Apple's review submission validation. Older placements were removed while retaining the originals in Apple's Asset Library.

[Product-page manifest](release-draft/product-page/manifest.json) records exact source builds, source files and hashes. Native portraits are 1320 × 2868 on iPhone and 2064 × 2752 on iPad; two landscapes retain original orientation metadata and display at 2752 × 2064. Screenshot PNGs are copied byte-for-byte, without resizing or synthetic UI. Phone gameplay views from build 6 remain accurate for build 7; new build 7 task/account captures and iPad views complete the sets. The iPad race road capture shows the real paused race; the phone race image shows active gameplay.

Original dimensional botanical **header** (3840 × 1646) and **search results artwork** (1920 × 1280) were generated using the built-in imagegen tool and exported as opaque PNGs. They are brand illustrations, separate from gameplay screenshots. Header asset `08c00019-689f-87a9-803c-67de0c1e9279` and search asset `f7800019-689f-87a9-802c-11f4d5819599` are attached to the default English (U.S.) product page and included with app-version review. Both Apple's [header preview](release-draft/product-page/proof/header-preview.jpg) and [search preview](release-draft/product-page/proof/search-preview.jpg) were visually checked. [Apple's creative asset guidance](https://developer.apple.com/help/app-store-connect/manage-app-information/manage-your-app-store-assets/) limits these placements to iOS/iPadOS 27 and later; the real screenshot galleries remain available on earlier store versions. [Prompts and export provenance](release-draft/product-page/IMAGE_PROMPTS.md) are recorded. Promotional text (159/170 characters) and keywords (99/100) were saved and verified after reload in Chrome.

The affected phone farm/harvest/craft/relaunch flow and iPad layout/swipe flow passed again for the new captures. This reruns two existing cases and does not increase the **68 unique passing tests**. Shipping app code and the signed build 7 IPA are unchanged; no new binary upload was needed. See [product-page bundle](release-draft/product-page/README.md), [test report](TEST_REPORT.md) and [screenshot status](release-draft/app-store-screenshots.json).

Transporter delivered build 7 at **10:18 PM India time**; Apple processed it and TestFlight shows **Ready to Submit**. TestFlight build **1c228e3d-b614-4ffd-b3fd-52970c1a8a07** is assigned to the internal **Orbit Bloom QA** group. Automatic distribution is enabled, with three builds (5, 6 and 7) and one owner tester. The owner's individual tester row now shows **Installed 1.0 (6)** on an iPhone 17 Pro running iOS 26.6.1. No invitation was sent again. Update to build 7 in TestFlight for the live Game Center/iCloud and signed sandbox purchase checks; installation alone does not verify those flows.

Build 7 is installed over the user's preview simulator without clearing its save. Preferences matched exactly immediately after installation and the complete garden wallet survived normal launch: 280 coins, one completed stage and the active stage 2 puzzle. Orbit Bloom's unused Store/iPad QA simulators are stopped; its preview remains booted. The Rush Drives simulator used by another active chat was left untouched.

## Remaining public release checks

1. Wait for Apple's review outcome for the seven submitted items.
2. Update the owner's installed TestFlight app to build 7 and verify live Game Center sign-in, iCloud backup/restore across devices and signed sandbox purchases. Do not perform real purchases for QA.
3. Check physical audio/haptics, broader accessibility, older/smaller devices and human difficulty before manually releasing publicly.

Broader accessibility, smaller/older device coverage, audio on hardware, consumable refund policy and human difficulty remain release checks. Daily improvement automation remains ACTIVE at 10:00 Asia/Kolkata for coding, tests, screenshots and internal build uploads. It does not accept agreements, perform real purchases or submit public releases.
