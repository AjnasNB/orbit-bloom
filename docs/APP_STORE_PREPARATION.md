# Orbit Bloom App Store preparation

The app currently builds and runs in the iOS simulator. Its purchase flow uses StoreKit 2 and an Xcode local test configuration. It has not been signed for distribution, uploaded, submitted, or published. The current deliverable is a playable first chapter for review before release preparation.

## Prepared in the workspace

- Native iOS 17+ application and shared Xcode scheme, with iPhone and iPad targets.
- Original 1024-pixel app icon and bundled offline artwork and sound.
- Twelve levels, a chapter ending, unlimited retries, saved progress, and interrupted puzzle recovery.
- A non-consumable Aurora Nights product with localized StoreKit pricing, verified transactions, updates, cancellation, pending approval, refunds, and restore handling.
- Local product ID `com.orbitbloom.aurora` and app bundle ID `com.orbitbloom.game`; both are working identifiers and need registration under the publisher's account.
- UserDefaults privacy reason `CA92.1` in `PrivacyInfo.xcprivacy`. This reason covers this app's own local saved data under [Apple's current required-reason documentation](https://developer.apple.com/documentation/bundleresources/app-privacy-configuration/nsprivacyaccessedapitypes/nsprivacyaccessedapitypereasons).
- In-app privacy explanation and full upstream license notices.

## Remaining release work

1. Select the user's Apple Developer team in Xcode, confirm the final title and identifiers, and register the app record in App Store Connect. No credentials belong in the repository or chat.
2. Configure the real non-consumable product and its territories and price in App Store Connect. The US$2.99 local setting is a test price. Digital unlocks use Apple's purchase mechanism as described in [guideline 3.1.1](https://developer.apple.com/app-store/review/guidelines/#in-app-purchase).
3. Complete the publisher's paid-app agreements, tax, and banking setup if needed. The account owner handles those legal and financial submissions.
4. Test a signed build on physical iPhones, including older supported iOS versions, audio interruptions, VoiceOver, large text, and poor-network StoreKit behavior. Add a TestFlight build and test sandbox purchases and restore under a real sandbox account.
5. Finish content tuning and visual restoration depth. The current three campaign regions share one illustrated environment; this is not a large commercial restoration game.
6. Add final support and privacy-policy URLs under the publisher's domain, the App Store description, screenshots for required device classes, age-rating answers, and app-privacy answers matching the shipped behavior.
7. Archive and validate a Release build, upload to App Store Connect, submit the build and in-app purchase for review, and choose the release mode.

## Draft listing

Working title: Orbit Bloom

Subtitle: A little space to grow

Description: Restore a tiny garden among the stars. Match leaves, blossoms, dewdrops, sunshine, and crystals across twelve gentle puzzles. Melt frozen patches, discover cascades, and turn your first victories into six garden projects. Play at your own pace with free hints and unlimited retries. Aurora Nights is an optional one-time cosmetic purchase.

Review notes: All twelve puzzles are available without purchase. From the garden, tap Play level 1. Tap two neighboring pieces or swipe to match three. Each first win earns one star; two stars restore the next garden project. The optional non-consumable is in Shop and includes Restore purchases. There is no login, advertising, tracking, or server-side game dependency.

A local test passing does not establish App Store approval or a live purchase configuration. The release must offer a substantive, distinct experience under [Apple's design and spam guidelines](https://developer.apple.com/app-store/review/guidelines/#spam).
