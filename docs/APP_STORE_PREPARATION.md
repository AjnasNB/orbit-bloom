# Orbit Bloom App Store preparation — 9 October 2026

## Current release status

App **Orbit Bloom: Garden Arcade**, Apple ID **6820591529**, bundle **com.orbitbloom.game**, SKU **orbit-bloom-ios-001**, publisher **Ajnas N B**, team **4V29K5Q8S9**. Version 1.0 remains **Prepare for Submission**, with manual release selected. Workspace **build 6** is tested, signed and exported, but **not uploaded or submitted**. Previously uploaded build 5 is processed in TestFlight. Do not submit build 5 as the new account/cloud release.

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

All six products have worldwide availability and English (U.S.) metadata. Six actual native purchase screenshots and reviewer notes were saved and verified. Apple added all six to one iOS draft and shows **Ready for Review**. The app version still needs to join this draft before they can be submitted together. These products are not live or evidence of real payment tests. The obsolete Aurora local test product remains only for entitlement regression coverage.

## Draft metadata and site

Review contact details supplied by the owner were saved and the missing-field errors cleared. Private contacts remain in Apple rather than the public repository. Subtitle **Swipe, farm & race among stars**, category Games, Puzzle/Simulation subcategories, content rights and the age questionnaire are saved. Most regions rate 13+, Vietnam 16+, Korea 12+. App availability is 173 regions, excluding China mainland and Vietnam because required game licenses were not supplied. Future-region auto-add is off. Mac/Vision Pro distribution was opted out; final reload verification remains pending. No licenses were invented.

The App Store description and review notes were updated for build 6's optional accounts/saves and saved. The version's Game Center checkbox is checked. Sign-in is not required for guest review/play. Full draft copy is in [metadata.json](release-draft/metadata.json).

The isolated existing Cloudflare Worker serves marketing, privacy and support at https://orbit-bloom-game-site.ajnasnb.workers.dev/ . Privacy/support were updated for Game Center and private iCloud saves and deployed; the live privacy page was verified in Chrome. Existing projects, DNS and sites were untouched. The optional cognifyr.co subdomain remains unconfigured and does not block these live URLs.

The privacy answers remain **Data Not Collected, unpublished**. Apple defines collection around developer/third-party access and says the publisher is not responsible for Apple's own data collection: [official definitions](https://developer.apple.com/app-store/app-privacy-details/). Publishing the prepared declaration accepts Apple's accuracy/compliance/update agreement. The owner's explicit action-time approval is pending; the final confirmation was not accepted.

## Screenshots and testing access

Thirty build 6 iPhone captures at native 1320 × 2868 and nine iPad captures are prepared with hashes/source attachments in [build6/verification.json](release-draft/build6/verification.json) and [iPad verification](release-draft/build6/ipad/verification.json). Seven iPad portraits are 2064 × 2752; two landscape QA images retain native orientation 8 metadata. No resizing or synthetic UI screenshots were used.

During replacement of the ten iPhone screenshots, the prior set was removed from the draft and retained in Apple's Asset Library. Ten new files, including the account page, were selected. Chrome control stopped before persistence could be verified. **Recheck or complete this replacement before submitting.** Six build 5 iPad portraits are the last verified uploaded set; add/refresh the build 6 iPad captures. [Screenshot status](release-draft/app-store-screenshots.json) records the incomplete external step honestly.

The internal **Orbit Bloom QA** TestFlight group has automatic distribution enabled, one previously processed build and zero testers at the last check. Add only the owner, upload build 6 and verify its distribution. No owner invitation has been confirmed.

Build 6 is installed over the user's preview simulator without clearing its save. Preferences matched exactly immediately after installation and the complete garden wallet survived normal launch. Only the preview remains booted; unused Store/iPad QA simulators are stopped.

## Remaining review work

1. Unlock the Mac: native automation explicitly reports it is locked. Transporter upload and Chrome draft actions cannot continue until unlocked.
2. Verify/finish iPhone replacement uploads, refresh iPad screenshots and confirm rendered images.
3. Upload build 6 through the already signed-in Transporter, wait for processing, attach it to version 1.0 and add that version to the six-product iOS draft.
4. Publish privacy only after the owner's explicit agreement approval.
5. Invite only the owner to internal QA and verify live Apple sign-in/cloud backups and signed sandbox purchases on an Apple device.
6. Resolve actual Apple validation errors and submit app + first purchases together for App Review. Keep manual release selected. **No App Review submission or public release has occurred.**

Broader accessibility, smaller/older device coverage, audio on hardware, consumable refund policy and human difficulty remain release checks. Daily improvement automation remains ACTIVE at 10:00 Asia/Kolkata for coding, tests, screenshots and internal build uploads. It does not accept agreements, perform real purchases or submit public releases.
