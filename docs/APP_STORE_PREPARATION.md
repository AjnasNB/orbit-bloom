# Orbit Bloom App Store preparation — 9 October 2026

## Current release status

App **Orbit Bloom: Garden Arcade**, Apple ID **6820591529**, bundle **com.orbitbloom.game**, SKU **orbit-bloom-ios-001**, publisher **Ajnas N B**, team **4V29K5Q8S9**. Version **1.0 (6)** and all six first purchases were submitted on **9 October 2026 at 8:42 PM India time**. Apple confirms **Waiting for Review** for all seven items. Submission **d585e8f9-f825-4020-9661-6421068d7038** has [Apple confirmation proof](release-draft/build6/apple-review-submission.jpg). Manual public release remains selected; the app is not publicly released.

Build 6 adds optional Game Center sign-in and GameKit saved games in the player's private iCloud Drive container `iCloud.com.orbitbloom.game`. Guest play remains available. Per-player local wallets, per-device cloud files, explicit restore choices, local recovery and undo checkpoints, purchase protection and timeout/error handling are implemented. Sixty unique core/native/UI checks pass. A live Apple cloud round trip and signed sandbox purchases on hardware remain unverified; no physical Apple device is connected. See [test report](TEST_REPORT.md).

The matching **Orbit Bloom AppStore** profile was regenerated with Game Center and the isolated iCloud container. Release archive/export and exported package signature checks pass. The IPA has Production CloudDocuments entitlements and four supported iPad orientations. [Build 6 package verification](release-draft/build6/signed-package-verification.json) records the exact hash and source commit. Private certificates/profiles are not committed.

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

All six products have worldwide availability and English (U.S.) metadata. Six actual native purchase screenshots and reviewer notes were saved and verified. Apple submitted all six together with version 1.0 (6), and each shows **Waiting for Review**. These products are not live or evidence of real payment tests. The obsolete Aurora local test product remains only for entitlement regression coverage.

## Draft metadata and site

Review contact details supplied by the owner were saved and the missing-field errors cleared. Private contacts remain in Apple rather than the public repository. Subtitle **Swipe, farm & race among stars**, category Games, Puzzle/Simulation subcategories, content rights and the age questionnaire are saved. Most regions rate 13+, Vietnam 16+, Korea 12+. App availability is 173 regions, excluding China mainland and Vietnam because required game licenses were not supplied. Future-region auto-add is off. Mac/Vision Pro distribution is opted out, verified on the saved pricing page in Chrome. No licenses were invented.

The App Store description and review notes were updated for build 6's optional accounts/saves and saved. The version's Game Center checkbox is checked. Sign-in is not required for guest review/play. Full draft copy is in [metadata.json](release-draft/metadata.json).

The isolated existing Cloudflare Worker serves marketing, privacy and support at https://orbit-bloom-game-site.ajnasnb.workers.dev/ . Privacy/support were updated for Game Center and private iCloud saves and deployed; the live privacy page was verified in Chrome. Existing projects, DNS and sites were untouched. The optional cognifyr.co subdomain remains unconfigured and does not block these live URLs.

The privacy declaration is **Data Not Collected, published by Ajnas N B**, verified in Chrome before submission. Apple defines collection around developer/third-party access and says the publisher is not responsible for Apple's own data collection: [official definitions](https://developer.apple.com/app-store/app-privacy-details/). The declaration had already been published when the agent resumed; no new legal agreement was accepted by the agent.

## Screenshots and testing access

Thirty build 6 iPhone captures at native 1320 × 2868 and nine iPad captures are prepared with hashes/source attachments in [build6/verification.json](release-draft/build6/verification.json) and [iPad verification](release-draft/build6/ipad/verification.json). Seven iPad portraits are 2064 × 2752; two landscape QA images retain native orientation 8 metadata. No resizing or synthetic UI screenshots were used.

The final store package contains **19 distinct native screenshots: ten iPhone and nine iPad**, including the account page on both devices and two iPad landscapes. The medium iPhone class inherits the large-display set. Apple's first submission check detected eight interrupted iPhone uploads; the set was replaced from the local originals, uploads finished, and review validation passed. The old set remains recoverable in Apple's Asset Library. The iPad landscape orientation was visually checked inside Apple's image preview. [Screenshot status](release-draft/app-store-screenshots.json) records the final files and evidence.

Transporter delivered build 6 at **8:29 PM India time** and confirmed processing finished. TestFlight build **858d66b4-ee72-4e6c-838a-65aa2450225b** is assigned to the internal **Orbit Bloom QA** group. Automatic distribution is enabled, with two builds and one owner tester. The owner's invitation already showed **Invited** when inspected; it was not sent again. No installs or live-device cloud/purchase tests were recorded. Accept the existing TestFlight invitation on an Apple device to run those checks.

Build 6 is installed over the user's preview simulator without clearing its save. Preferences matched exactly immediately after installation and the complete garden wallet survived normal launch. Only the preview remains booted; unused Store/iPad QA simulators are stopped.

## Remaining public release checks

1. Wait for Apple's review outcome for the seven submitted items.
2. Use the existing owner TestFlight invitation to verify live Game Center sign-in, iCloud backup/restore across devices and signed sandbox purchases. Do not perform real purchases for QA.
3. Check physical audio/haptics, broader accessibility, older/smaller devices and human difficulty before manually releasing publicly.

Broader accessibility, smaller/older device coverage, audio on hardware, consumable refund policy and human difficulty remain release checks. Daily improvement automation remains ACTIVE at 10:00 Asia/Kolkata for coding, tests, screenshots and internal build uploads. It does not accept agreements, perform real purchases or submit public releases.
