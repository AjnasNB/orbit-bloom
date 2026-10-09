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

## Prepared content

- Native SwiftUI game, original icon and dimensional botanical artwork, bundled CC0 music/effects and license notices.
- Original SceneKit island, 102 swipeable ten-stop pages, sequential unlocks and 10–20 turn budgets across 1,020 campaign stages (12 authored + 1,008 generated), board powers, farm, crafting, swipe-steered delivery, permanent tasks, life regeneration and shared economy.
- Local StoreKit verification passes six purchase tests on iOS 26.1, including coins, lives, starter grant, idempotency, restore, cancellation, pending approval and refunded entitlement revocation. See TEST_REPORT.md for exact evidence and the distinction from signed sandbox testing.
- Description, promotional text, keywords and review notes updated in the App Store draft. Full reviewable copy is in release-draft/metadata.json.
- Nineteen native build 5 screenshots in release-draft/. Ten large-display captures (1320 × 2868) were uploaded in Chrome on 9 October and verified after reload with rendered thumbnails. The medium-display class now shows Apple’s Using Existing Assets view of those ten current captures. Old medium screenshots were archived locally and remain recoverable in Apple’s Asset Library; no stale screenshots remain assigned to that class. Other required device classes remain to be checked.
- Privacy required-reason manifest for local saved data; no account, analytics, advertisements, tracking or requested sensitive device permissions.
- Marketing, privacy and support site is live at https://orbit-bloom-game-site.ajnasnb.workers.dev/ . Dedicated Cloudflare Workers static assets are used because the Pages account has reached its project limit. Home/privacy/support were verified in Chrome. Support, marketing and privacy URLs plus build 5 description/review notes were saved in App Store Connect. No existing projects, domain records or sites were changed. The optional orbitbloom.cognifyr.co custom host remains unconfigured.

## External blockers and remaining submission work

1. **Distribution signing:** the build 5 archive attempt with existing automatic provisioning reports No Accounts / no provisioning profile (evidence/v5-signing-account-check.log). An App Store distribution profile was created, but its Chrome download was blocked. The account owner must finish Xcode Settings → Accounts sign-in. Do not bypass browser security or store credentials in Git.
2. **Optional custom hostname:** the site already serves through workers.dev. The cognifyr.co subdomain is not configured; the existing dashboard authenticator challenge need not block coding or the live fallback site.
3. Check other required screenshot device classes, complete categories, age rating and App Privacy answers matching the actual app. Do not claim a feature or accessibility capability that has not been tested.
4. The owner handles any required paid-app agreement, tax and banking submissions. No such legal or financial agreement has been accepted by this project automation.
5. Archive, validate and upload a signed build to TestFlight, then exercise physical-device and signed sandbox purchase flows. No TestFlight upload, App Review submission or public release has been completed.
6. Before production release, verify iPad layouts and screenshots, VoiceOver and larger text, older supported iOS versions, audio interruptions, low-network purchase recovery, save recovery and consumable refund policy. Saves currently remain device-local.

Daily improvement automation is ACTIVE at 10:00 Asia/Kolkata. It continues coding, testing, screenshots and reviewed commits while signing is unavailable, and can upload a tested internal TestFlight build once existing account signing works. It does not submit a public release or perform real purchases.
