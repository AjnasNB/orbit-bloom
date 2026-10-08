# Orbit Bloom App Store preparation — 8 October 2026

## Actual Apple records

App: **Orbit Bloom: Garden Arcade**, Apple ID **6820591529**, bundle **com.orbitbloom.game**, SKU **orbit-bloom-ios-001**, publisher **Ajnas N B**, team **4V29K5Q8S9**. Version 1.0 is **Prepare for Submission** with manual release selected. Workspace build number is 3.

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
- 1,020 campaign stages (12 authored + 1,008 generated), board powers, farm, crafting, swipe-steered delivery, permanent tasks, life regeneration and shared economy.
- Local StoreKit verification passes six purchase tests on iOS 26.1, including coins, lives, starter grant, idempotency, restore, cancellation, pending approval and refunded entitlement revocation. See TEST_REPORT.md for exact evidence and the distinction from signed sandbox testing.
- Description, promotional text, keywords and review notes updated in the App Store draft. Full reviewable copy is in release-draft/metadata.json.
- Native screenshots and a gallery in release-draft/. Upload confirmation and any outstanding device classes must be checked in App Store Connect.
- Privacy required-reason manifest for local saved data; no account, analytics, advertisements, tracking or requested sensitive device permissions.
- Standalone marketing, privacy and support site in ../site/. Intended fresh host: https://orbitbloom.cognifyr.co/ . **Not yet deployed:** Cloudflare is waiting for the owner's authenticator verification. No existing domain records or sites have been changed.

## External blockers and remaining submission work

1. **Distribution signing:** the archive attempt reports no signed-in Xcode account / no provisioning profile. An App Store distribution profile was created, but its Chrome download was blocked. The account owner must finish Xcode Settings → Accounts sign-in. Do not bypass browser security or store credentials in Git.
2. **Chrome access:** the Mac locked during final draft work. The owner must unlock it to resume screenshots and website publishing. Cloudflare additionally needs the owner's authenticator verification.
3. Upload the final screenshot set, fill verified support/privacy URLs after deployment, and complete categories, age rating and App Privacy answers matching the actual app. Do not claim a feature or accessibility capability that has not been tested.
4. The owner handles any required paid-app agreement, tax and banking submissions. No such legal or financial agreement has been accepted by this project automation.
5. Archive, validate and upload a signed build to TestFlight, then exercise physical-device and signed sandbox purchase flows. No TestFlight upload, App Review submission or public release has been completed.
6. Before production release, verify iPad layouts and screenshots, VoiceOver and larger text, older supported iOS versions, audio interruptions, low-network purchase recovery, save recovery and consumable refund policy. Saves currently remain device-local.

Daily improvement automation is ACTIVE at 10:00 Asia/Kolkata. It continues coding, testing, screenshots and reviewed commits while signing is unavailable, and can upload a tested internal TestFlight build once existing account signing works. It does not submit a public release or perform real purchases.
