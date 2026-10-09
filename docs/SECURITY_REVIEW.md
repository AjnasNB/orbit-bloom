# Orbit Bloom security review — 9 October 2026

## Architecture and scope

The owner chose to retain Apple's private iCloud saves without a second Cloudflare player database. Game Center handles optional Apple authentication; GameKit stores saves in `iCloud.com.orbitbloom.game`. Cloudflare hosts the isolated static marketing/privacy/support site only. No player credentials, saved games, coins or transaction identifiers are sent to that site or a publisher API. Guest progress is device-local.

This is a focused source review and automated regression check, not a penetration-test certificate or a promise that software cannot be attacked. Local wallets are stored inside the iOS app sandbox using UserDefaults. They are not an authoritative server economy or an encrypted anti-cheat ledger. A compromised device or modified client is outside the guarantees of this architecture. Offline crop/life timers use device time; advancing the device clock can affect waiting periods. A competitive or transferable economy would require an authoritative server. A hash of the game-scoped Apple identifier separates profiles; hashing is not authentication.

## Corrections in build 7

- Save validation rejects non-finite/out-of-range dates, missing crop timers, oversized scores and collection counts before restoring. Calendar dates use a broad 1970–9999 range instead of requiring a correct current device clock. Life regeneration caps the missing hearts before integer conversion. Countdown conversion cannot overflow on extreme clock data.
- Older separate progress/puzzle files pass the same validation before migration. Corrupt current wallets continue to fall back to their own valid local checkpoint.
- Cloud reads and writes recheck the current Game Center player and local wallet owner after asynchronous completion. Account changes discard returned choices and prevent false successful-backup acknowledgments. A new identity check also runs at restore/keep-device time. An already-started Apple operation cannot be recalled; the checks prevent its stale result from being applied locally.
- Pausing cloud backup prevents restoring or acknowledging previously offered cloud choices. Corresponding choice buttons become disabled while paused. Resume checks the saved gardens again before writing.

The existing per-player wallets, per-device cloud filenames, explicit conflict picker, no-balance-merging rule, pre-restore undo checkpoint, purchase-receipt protection, offline fallback and 20-second Apple callback deadlines remain in place. Unknown/corrupt cloud data blocks overwriting an unseen backup.

## Payments and privacy

Purchase rewards require StoreKit's `.verified` transactions. Pending, cancelled, unverified, unknown-product and revoked transactions do not grant new pack rewards. Transaction identifiers prevent repeat grants on the same device, including Game Center profile changes. The transaction is finished after delivery; unfinished transactions are recovered. The non-consumable starter bundle has an ownership restore path; spent consumables are not represented as restorable currency.

Apple processes payment credentials. There is no card form, payment key or banking credential in the game. There are no publisher networking calls, arbitrary-transport-security exceptions, analytics/advertising SDKs, tracking domains or unrelated data permissions in the app sources reviewed. The privacy manifest declares no tracking/collected data and the UserDefaults reason CA92.1. Private signing material is ignored and is not tracked by Git. App Store privacy is published as Data Not Collected; optional Apple-managed saves are described in the live policy.

Client-side receipt deduplication is not a worldwide server ledger. Signed sandbox transaction delivery/recovery and live cross-device iCloud saves still need a physical-device TestFlight check. Simulator StoreKit tests use Apple's local test environment and memory cloud tests do not establish an Apple server round trip. Consumable refund/recovery policy remains a public-release check.

## Cloudflare site

The existing `orbit-bloom-game-site` Worker serves static assets only, without a login form, gameplay API or save database. The deployed `_headers` now includes HTTPS HSTS, `X-Frame-Options: DENY`, MIME sniffing protection, referrer/permissions controls, and a restrictive CSP. The CSP blocks frames, object embeds, form submissions and script-originated connections; scripts/styles/images stay same-origin with the existing exact JSON-LD script hash. No new DNS or other Cloudflare project was changed.

Run `node scripts/check-site-security.mjs` to verify live HTTPS/status/header behavior on the landing page, privacy, support, stylesheet and a missing route. Chrome rendering was inspected after deployment; observed extension warnings are unrelated to the site, and no site CSP failures were reported. Deployment version: `7c4a36b1-1c7d-484d-abc1-2e5b9f555ee4`.

## Verification and remaining checks

Detailed native/core/UI results, release package and Apple submission status are recorded in [TEST_REPORT.md](TEST_REPORT.md) and [APP_STORE_PREPARATION.md](APP_STORE_PREPARATION.md). The two malformed-save regression cases failed against the previous implementation before being fixed. Tests also cover extreme clock values, account changes during fetch/write, a stale restore choice, a paused backup and corrupt legacy startup data.

Before public release, the owner should use the existing TestFlight invitation to sign in with Game Center, enable iCloud Drive, back up a progressed garden, then choose that garden on another Apple device with the same accounts. Repeat offline/reconnect and sandbox purchase/cancel/pending/restore checks. Confirm the app reports an actual last successful cloud backup before deleting it or changing devices. A disconnected device never proves that unsynced progress exists remotely.

Sources: Apple's [Game Center authentication](https://developer.apple.com/documentation/gamekit/authenticating-a-player), [private iCloud saved games](https://developer.apple.com/documentation/gamekit/saving-the-player-s-game-data-to-an-icloud-account), [StoreKit verification results](https://developer.apple.com/documentation/storekit/verificationresult), and Cloudflare's [static asset headers](https://developers.cloudflare.com/workers/static-assets/headers/).
