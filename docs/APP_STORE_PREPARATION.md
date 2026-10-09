# Orbit Bloom App Store preparation — 9 October 2026

## Actual Apple records

App: **Orbit Bloom: Garden Arcade**, Apple ID **6820591529**, bundle **com.orbitbloom.game**, SKU **orbit-bloom-ios-001**, publisher **Ajnas N B**, team **4V29K5Q8S9**. Version 1.0 is **Prepare for Submission** with manual release selected. Workspace build number is 5.

App Review contact information supplied by the owner was saved on 8 October and verified after reload. The missing-contact errors are cleared. Private review contact details remain in App Store Connect rather than the public repository.

The app record and the six products below exist in App Store Connect. Each product has worldwide availability, India as the base region, the listed draft price, and English (U.S.) display information saved. These are draft configurations, not live products or proof of paid agreement activation.

| Product | Apple ID | Type | India price | Grant |
| --- | --- | --- | --- | --- |
| com.orbitbloom.coins400 | 6820593641 | Consumable | ₹99 | 400 coins |
| com.orbitbloom.coins1500 | 6820595004 | Consumable | ₹299 | 1,500 coins |
| com.orbitbloom.coins3000 | 6820595079 | Consumable | ₹499 | 3,000 coins |
| com.orbitbloom.coins7000 | 6820594918 | Consumable | ₹999 | 7,000 coins |
| com.orbitbloom.lives5 | 6820595083 | Consumable | ₹99 | 5 non-expiring extra lives |
| com.orbitbloom.starter | 6820594801 | Non-consumable | ₹99 | One-time 600 coins + 3 extra lives |

The obsolete Aurora test product remains in the local test configuration for entitlement regression tests; it is not the main shop catalogue. The app displays Apple's localized storefront prices rather than hard-coded charge amounts. First purchase submission must accompany a new app version.

## Saved store details

On 9 October, the subtitle was saved as **Swipe, farm & race among stars**. The primary category is **Games**, with **Puzzle** and **Simulation** subcategories. Content rights identify licensed third-party content (MIT library and CC0 audio) alongside original artwork. The completed age questionnaire assigns **13+** in most regions, **16+** in Vietnam and **12+** in Korea. The recurring Bomb/TNT imagery was included under Apple’s broad weapons/objects definition; no gambling, loot boxes, advertising, social features or mature content were declared.

The App Privacy answers are saved as **Data Not Collected**, with the live policy URL. They remain an **unpublished draft** because Apple’s Publish confirmation includes an agreement that the answers are accurate and will be kept updated. The owner’s action-time confirmation has been requested.

The account’s Free Apps and Paid Apps agreements, bank account, tax forms and Digital Services Act compliance already show **Active**. No banking details, tax submissions or legal agreements were changed.

All six actual purchase screens were captured by the passing focused native UI run at 1320 × 2868. [Purchase review metadata](release-draft/purchase-review/metadata.json) records exact reviewer notes and per-product upload status. The four coin pack screenshots rendered in Apple; the 400-coin record was verified after reload. Final reload checks for the other three and the lives/starter review uploads remain pending after Chrome disconnected. These products are still Prepare for Submission.

## Prepared content

- Native SwiftUI game, original icon and dimensional botanical artwork, bundled CC0 music/effects and license notices.
- Original SceneKit island, 102 swipeable ten-stop pages, sequential unlocks and 10–20 turn budgets across 1,020 campaign stages (12 authored + 1,008 generated), board powers, farm, crafting, swipe-steered delivery, permanent tasks, life regeneration and shared economy.
- Local StoreKit verification passes six purchase tests on iOS 26.1, including coins, lives, starter grant, idempotency, restore, cancellation, pending approval and refunded entitlement revocation. See TEST_REPORT.md for exact evidence and the distinction from signed sandbox testing.
- Description, promotional text, keywords and review notes updated in the App Store draft. Full reviewable copy is in release-draft/metadata.json.
- Nineteen native build 5 screenshots in release-draft/. Ten large-display captures (1320 × 2868) were uploaded in Chrome on 9 October and verified after reload with rendered thumbnails. The medium-display class now shows Apple’s Using Existing Assets view of those ten current captures. Old medium screenshots were archived locally and remain recoverable in Apple’s Asset Library; no stale screenshots remain assigned to that class. Other required device classes remain to be checked.
- Privacy required-reason manifest for local saved data; no account, analytics, advertisements, tracking or requested sensitive device permissions.
- Marketing, privacy and support site is live at https://orbit-bloom-game-site.ajnasnb.workers.dev/ . Dedicated Cloudflare Workers static assets are used because the Pages account has reached its project limit. Home/privacy/support were verified in Chrome. Support, marketing and privacy URLs plus build 5 description/review notes were saved in App Store Connect. No existing projects, domain records or sites were changed. The optional orbitbloom.cognifyr.co custom host remains unconfigured.

## External blockers and remaining submission work

1. **Signing and upload:** the corrected build 5 Release archive compiles successfully at build/OrbitBloom-Release-Prepared.xcarchive, but is unsigned and cannot be uploaded. An active **Orbit Bloom AppStore** distribution profile exists in the Apple portal for com.orbitbloom.game; its automated download did not create a local file. The owner has been asked to download that existing profile at https://developer.apple.com/account/resources/profiles/review/554SHJ3J75 . No matching profile is currently installed. Existing Xcode account sign-in was unavailable; manual signing can proceed once the correct profile is installed, followed by authenticated validation/upload. Do not bypass browser security or place signing credentials in Git.
2. **Chrome connection:** the browser automation connection disconnected during purchase review preparation. The owner has been asked to reconnect the Chrome extension and unlock the Mac. No alternative browser or security workaround was used. Remaining external saves and native Xcode controls await that state change.
3. **Store completion:** publish the prepared privacy declaration only after the requested confirmation, finish the two remaining purchase review uploads and reload checks, upload the six verified native portrait iPad screenshots, check app pricing/availability and any region-specific game-license requirements, and attach the signed build plus all six first purchases to version 1.0. App accessibility claims remain unverified and must not be advertised as supported.
4. **Internal testing and review:** archive, validate and upload a signed build to TestFlight, then exercise physical-device and signed sandbox purchase flows. No TestFlight upload, App Review submission or public release has been completed. Payment account setup is already active; do not ask the owner to redo completed banking or tax work.
5. **Release QA:** verify smaller iPad and older iOS layouts, VoiceOver and larger text, audio interruptions, low-network purchase recovery, save recovery and consumable refund policy. Saves currently remain device-local. The new iPad release check preserves progress and captures portrait/landscape scenes; TEST_REPORT.md records its actual result.
6. **Optional custom hostname:** the site already serves through workers.dev. The cognifyr.co subdomain remains unconfigured; it does not block the live marketing, support or privacy pages.

Daily improvement automation is ACTIVE at 10:00 Asia/Kolkata. It continues coding, testing, screenshots and reviewed commits while signing is unavailable, and can upload a tested internal TestFlight build once existing account signing works. It does not submit a public release or perform real purchases.
