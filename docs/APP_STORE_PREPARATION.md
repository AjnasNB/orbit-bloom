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

All six actual purchase screens were captured by the passing focused native UI run at 1320 × 2868. [Purchase review metadata](release-draft/purchase-review/metadata.json) records exact reviewer notes and status. All six screenshots and notes are saved and verified after navigation/reload. Apple accepted all six into one iOS draft submission and shows **Ready for Review**. The draft cannot be submitted until an app version is added.

App download pricing is now **free**, with India as the base region and optional paid packs above. Availability is configured for **173 countries or regions**. China mainland and Vietnam are excluded because their required game licenses have not been supplied; automatic addition of future regions is off. Apple Silicon Mac and Vision Pro distribution were opted out for this mobile release. Apple’s [app information reference](https://developer.apple.com/help/app-store-connect/reference/app-information/app-information/) documents the regional game-license requirements. No licenses were fabricated or submitted.

The existing matching profile was found in the owner’s Documents folder and installed locally. Release build **1.0 (5)** archived and exported with the installed Apple Distribution identity. Local signature verification passed, and the IPA was delivered through the owner’s signed-in Transporter account at **15:25 Asia/Kolkata on 9 October**. Apple processed it and TestFlight shows **Ready to Submit**. [Signed package verification](release-draft/signed-package-verification.json) records its hash and evidence. The internal **Orbit Bloom QA** group exists with this build and automatic distribution enabled; it currently has zero testers. The owner invitation and release-version build attachment were interrupted when the Mac locked again.

## Prepared content

- Native SwiftUI game, original icon and dimensional botanical artwork, bundled CC0 music/effects and license notices.
- Original SceneKit island, 102 swipeable ten-stop pages, sequential unlocks and 10–20 turn budgets across 1,020 campaign stages (12 authored + 1,008 generated), board powers, farm, crafting, swipe-steered delivery, permanent tasks, life regeneration and shared economy.
- Local StoreKit verification passes six purchase tests on iOS 26.1, including coins, lives, starter grant, idempotency, restore, cancellation, pending approval and refunded entitlement revocation. See TEST_REPORT.md for exact evidence and the distinction from signed sandbox testing.
- Description, promotional text, keywords and review notes updated in the App Store draft. Full reviewable copy is in release-draft/metadata.json.
- Nineteen native iPhone build 5 screenshots in release-draft/. Ten large-display captures (1320 × 2868) were uploaded in Chrome on 9 October and verified after reload with rendered thumbnails. The medium-display class inherits those ten current captures. Old medium screenshots remain recoverable in Apple’s Asset Library. Six native iPad portrait screenshots (2064 × 2752) are uploaded and rendered in the 13-inch class; Apple’s confirmation says they cover selected smaller iPad sizes/localizations. Final iPad reload verification remains to be recorded.
- Privacy required-reason manifest for local saved data; no account, analytics, advertisements, tracking or requested sensitive device permissions.
- Marketing, privacy and support site is live at https://orbit-bloom-game-site.ajnasnb.workers.dev/ . Dedicated Cloudflare Workers static assets are used because the Pages account has reached its project limit. Home/privacy/support were verified in Chrome. Support, marketing and privacy URLs plus build 5 description/review notes were saved in App Store Connect. No existing projects, domain records or sites were changed. The optional orbitbloom.cognifyr.co custom host remains unconfigured.

## External blockers and remaining submission work

1. **Mac input:** Chrome reconnected and external saves resumed. The Mac subsequently locked during build selection. Unlocking is needed to complete the release-version build attachment and owner TestFlight invitation. A duplicate profile-download Save panel was dismissed after the existing profile had already been found; no browser security workaround was used.
2. **Privacy agreement:** publish the prepared declaration only after the owner explicitly approves Apple’s accuracy/compliance/update agreement. The current confirmation is open in Chrome and the question remains pending.
3. **Final review preparation:** attach processed build 5, record the final iPad screenshot reload check and pricing/platform preferences, and add version 1.0 to the same draft that already contains all six first purchases. App accessibility claims remain unverified and must not be advertised as supported.
4. **Internal testing and review:** add only the owner to Orbit Bloom QA, record the invitation, and exercise physical-device and signed sandbox purchase flows. **TestFlight upload is completed; App Review submission and public release are not.** Payment account setup is active; do not redo banking or tax work. Manual release remains selected.
5. **Release QA:** verify smaller iPad and older iOS layouts, VoiceOver and larger text, audio interruptions, low-network purchase recovery, save recovery and consumable refund policy. Saves currently remain device-local. The new iPad release check preserves progress and captures portrait/landscape scenes; TEST_REPORT.md records its actual result.
6. **Optional custom hostname:** the site already serves through workers.dev. The cognifyr.co subdomain remains unconfigured; it does not block the live marketing, support or privacy pages.

Daily improvement automation is ACTIVE at 10:00 Asia/Kolkata. It continues coding, testing, screenshots and reviewed commits, and can upload tested internal TestFlight builds using the available signing path. It does not submit a public release or perform real purchases.
