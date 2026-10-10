# Orbit Bloom security review

## Build 11 source review — 10 October 2026

This section reviews the working Build 11 sources: the event clock/Worker, journey save format, Game Center rankings, local/Apple backups and StoreKit delivery. It is a focused source audit, not a penetration test or a claim that software cannot be attacked. Compilation, simulator evidence, exported-package checks and Apple delivery status belong to [TEST_REPORT.md](TEST_REPORT.md) and [APP_STORE_PREPARATION.md](APP_STORE_PREPARATION.md); this audit did not run those operations.

Apple remains the only player cloud-save service. Cloudflare now also provides the optional world-event clock, so the older “static site only/no publisher networking” statements below are historical. The event request contains no application-supplied player identifier, garden, score, purchase record, credentials or payment data. Cloudflare still processes the IP address and technical request information needed to deliver/protect the request, as disclosed in the updated privacy policy. Source inspection cannot independently establish every service provider's retention behavior or the correctness of final App Store privacy answers.

### Event timing and reward boundary

[WorldEventClock.swift](../OrbitBloom/WorldEventClock.swift) uses an ephemeral HTTPS session with an unchanged fixed endpoint, a 12-second request timeout and no account authorization/body. It accepts only HTTP 200 from that exact final URL, a payload smaller than 4,096 bytes, schema/schedule 1 and finite server time within the supported range. Unexpected redirects, other status codes and malformed/out-of-range payloads cannot establish or replace an anchor. The size check applies before JSON decoding, after URLSession has received the response; it is not a streaming download limit. Transport security uses Apple's normal HTTPS trust validation, without custom certificate pinning.

A successful reply records monotonic system uptime. The estimated UTC time advances only by elapsed uptime, is unavailable at exactly 900 seconds, and rejects negative/non-finite elapsed values. Editing the device wall clock does not change a running anchor. Failed retries keep only the original anchor until its original expiry; an initial offline failure never creates trusted event time. Network latency can produce a small offset from server UTC. The app follows common UTC windows, without claiming atomically synchronized clients.

The Worker accepts GET/HEAD and returns only a versioned timestamp with `no-store`; other methods return 405. It has no player-write route or player database. `GameModel` requires a fresh anchor before recording/claiming events. `IslandJourney` derives supported windows locally, checks the selected room and active interval, caps goal progress at three and rejects a second claim in the current saved branch. Expired-window metadata is pruned. This is local reward idempotency, not a global ledger across restored branches, modified clients or multiple offline devices. Ordinary rooms remain open without a clock check.

The new ten native clock tests exercise request contents, monotonic advancement, exact expiry, corrupt/oversized responses, redirects, status errors, first offline use, retry retention and concurrent-request coalescing. Their execution result must be read from the native test evidence rather than inferred from this source review.

### Save compatibility, identity and purchases

[SavedGarden.swift](../OrbitBloom/Core/SavedGarden.swift) now emits cloud schema 3 whenever the wallet contains journey data. Older cloud schemas cannot masquerade as journey-aware saves; unknown future schemas, wrong player keys, corrupt values and oversized cloud files are rejected. Old wallets without journey data decode with an empty journey while retaining puzzle/farm/receipt state. Journey validation permits only four known room keys, levels 0–1,000, scores 1–20,000 and bounded valid event/claim records.

Cloud schema 3 protects remote backups from older clients silently reinterpreting the new fields. **It does not make an older installed app understand the device-local optional fields.** Local wallets still use existing JSON/v2 preference keys; installing an older TestFlight build on the same device may discard journey data when that build saves. Keep current builds on active devices and confirm a successful current iCloud backup before downgrade/reinstallation.

New activity completion requires the next sequential level and a bounded score, and grants each first-clear reward once. A repeated callback cannot mint another star/coin reward. Completed journey/results are included in local and private Apple wallets. Unfinished new activity attempts are intentionally not persisted; leaving or closing the app discards them without spending a puzzle life. The existing puzzle snapshot remains resumable. Restore is blocked during an active new room, and the offered backup remains available after exiting.

The existing Game Center/local-owner identity checks run before and after asynchronous cloud fetch/write, and before accepting a restore. Per-player wallets, per-device filenames, explicit branch selection, no balance merging, pre-restore recovery and the receipt-subset check remain. No Apple password is requested or stored by the publisher. Hashing the player identifier separates profiles; Apple authentication supplies identity. Already-started Apple operations cannot be recalled after an account change; stale results are not applied/acknowledged locally. Local UserDefaults data relies on the iOS app sandbox, not a separately encrypted or server-authoritative economy.

StoreKit boundaries remain unchanged: rewards enter through verified, known-product, non-revoked transactions, with per-device/per-wallet receipt deduplication and unfinished-transaction recovery. Pending/cancelled/unverified purchases do not grant a new pack. Apple handles billing credentials; no publisher card form or payment secret exists. Already-spent consumables are not restored as fresh balances. Receipt deduplication is local and not a global server ledger; revocation does not make a spent consumable balance a server-reconciled account.

### Rankings and remaining release checks

[RoomRecordsView.swift](../OrbitBloom/Views/RoomRecordsView.swift) requires an authenticated Game Center player whose hashed ID matches both the connected player and local wallet owner before submitting. Each of the four personal bests is checked within 0–20,000; the combined score is bounded to 80,000. Coins, purchased lives and pack rewards are excluded. Identity is rechecked after asynchronous submission before opening/reporting the leaderboard result. No fake worldwide standings are supplied when Apple is unavailable.

**These are client-computed casual rankings, not authoritative anti-cheat.** A modified client or edited valid local wallet can forge a plausible bounded score. The publisher does not verify a play transcript on a server. Guided accessible timing is included in the activity scores. Do not describe the board as tamper-proof or as proving identical competitive conditions. An already-started Apple submission cannot be recalled on a later identity change, and a bounded authenticated submission does not prove Apple has configured or accepted the leaderboard.

| Check | Current source finding / required evidence |
| --- | --- |
| Required-reason privacy manifest | Fixed during Build 11 preparation: the root agent confirmed Apple's current [required-reason guidance](https://developer.apple.com/documentation/bundleresources/app-privacy-configuration/nsprivacyaccessedapitypes/nsprivacyaccessedapitypereasons) in Chrome and added SystemBootTime/35F9.1 alongside UserDefaults/CA92.1. `systemUptime` measures elapsed time between receipt of a server anchor and later in-app clock/event checks; uptime and derived elapsed-time values are not sent off device. Verify these declarations are present in the exact exported package. |
| Apple leaderboard setup | Confirm `com.orbitbloom.atollskills` exists in App Store Connect, is associated with this version and works in a signed Game Center session. Source code alone does not prove availability. |
| Real Apple backups | Use a signed device with Game Center and iCloud Drive, save a progressed schema-3 garden, and choose it on another device with the same accounts; repeat offline/reconnect and account changes. Memory transports/simulator results do not prove an Apple cloud round trip. |
| Signed purchases | Check cancellation, pending approval, verified delivery, interrupted recovery and eligible ownership restore in signed sandbox/TestFlight. Local StoreKit simulation does not demonstrate live billing delivery or real payment success. |
| Privacy and release package | Align the final store answers/policy with event-clock requests and optional Apple rankings, and verify entitlements/debugger access in the exact exported package. This source audit does not establish App Review approval or distribution delivery. |

No new credential exposure or StoreKit verification bypass was identified in the reviewed sources. The local-client, downgrade, remote-service and physical-device limitations above remain material; they are not claims of a completed adversarial security assessment.

## Historical build 7 review — 9 October 2026

The following is the original Build 7 snapshot. Its static-only Cloudflare architecture and “no publisher networking” wording applied on 9 October and do not describe the Build 11 event-clock feature. Historical test/deployment statements are retained as records of that build.

### Architecture and scope

The owner chose to retain Apple's private iCloud saves without a second Cloudflare player database. Game Center handles optional Apple authentication; GameKit stores saves in `iCloud.com.orbitbloom.game`. Cloudflare hosts the isolated static marketing/privacy/support site only. No player credentials, saved games, coins or transaction identifiers are sent to that site or a publisher API. Guest progress is device-local.

This is a focused source review and automated regression check, not a penetration-test certificate or a promise that software cannot be attacked. Local wallets are stored inside the iOS app sandbox using UserDefaults. They are not an authoritative server economy or an encrypted anti-cheat ledger. A compromised device or modified client is outside the guarantees of this architecture. Offline crop/life timers use device time; advancing the device clock can affect waiting periods. A competitive or transferable economy would require an authoritative server. A hash of the game-scoped Apple identifier separates profiles; hashing is not authentication.

### Corrections in build 7

- Save validation rejects non-finite/out-of-range dates, missing crop timers, oversized scores and collection counts before restoring. Calendar dates use a broad 1970–9999 range instead of requiring a correct current device clock. Life regeneration caps the missing hearts before integer conversion. Countdown conversion cannot overflow on extreme clock data.
- Older separate progress/puzzle files pass the same validation before migration. Corrupt current wallets continue to fall back to their own valid local checkpoint.
- Cloud reads and writes recheck the current Game Center player and local wallet owner after asynchronous completion. Account changes discard returned choices and prevent false successful-backup acknowledgments. A new identity check also runs at restore/keep-device time. An already-started Apple operation cannot be recalled; the checks prevent its stale result from being applied locally.
- Pausing cloud backup prevents restoring or acknowledging previously offered cloud choices. Corresponding choice buttons become disabled while paused. Resume checks the saved gardens again before writing.

The existing per-player wallets, per-device cloud filenames, explicit conflict picker, no-balance-merging rule, pre-restore undo checkpoint, purchase-receipt protection, offline fallback and 20-second Apple callback deadlines remain in place. Unknown/corrupt cloud data blocks overwriting an unseen backup.

### Payments and privacy

Purchase rewards require StoreKit's `.verified` transactions. Pending, cancelled, unverified, unknown-product and revoked transactions do not grant new pack rewards. Transaction identifiers prevent repeat grants on the same device, including Game Center profile changes. The transaction is finished after delivery; unfinished transactions are recovered. The non-consumable starter bundle has an ownership restore path; spent consumables are not represented as restorable currency.

Apple processes payment credentials. There is no card form, payment key or banking credential in the game. There are no publisher networking calls, arbitrary-transport-security exceptions, analytics/advertising SDKs, tracking domains or unrelated data permissions in the app sources reviewed. The privacy manifest declares no tracking/collected data and the UserDefaults reason CA92.1. Private signing material is ignored and is not tracked by Git. App Store privacy is published as Data Not Collected; optional Apple-managed saves are described in the live policy.

Client-side receipt deduplication is not a worldwide server ledger. Signed sandbox transaction delivery/recovery and live cross-device iCloud saves still need a physical-device TestFlight check. Simulator StoreKit tests use Apple's local test environment and memory cloud tests do not establish an Apple server round trip. Consumable refund/recovery policy remains a public-release check.

### Cloudflare site

The existing `orbit-bloom-game-site` Worker serves static assets only, without a login form, gameplay API or save database. The deployed `_headers` now includes HTTPS HSTS, `X-Frame-Options: DENY`, MIME sniffing protection, referrer/permissions controls, and a restrictive CSP. The CSP blocks frames, object embeds, form submissions and script-originated connections; scripts/styles/images stay same-origin with the existing exact JSON-LD script hash. No new DNS or other Cloudflare project was changed.

Run `node scripts/check-site-security.mjs` to verify live HTTPS/status/header behavior on the landing page, privacy, support, stylesheet and a missing route. Chrome rendering was inspected after deployment; observed extension warnings are unrelated to the site, and no site CSP failures were reported. Deployment version: `7c4a36b1-1c7d-484d-abc1-2e5b9f555ee4`.

### Verification and remaining checks

Detailed native/core/UI results, release package and Apple submission status are recorded in [TEST_REPORT.md](TEST_REPORT.md) and [APP_STORE_PREPARATION.md](APP_STORE_PREPARATION.md). The two malformed-save regression cases failed against the previous implementation before being fixed. Tests also cover extreme clock values, account changes during fetch/write, a stale restore choice, a paused backup and corrupt legacy startup data.

Before public release, the owner should use the existing TestFlight invitation to sign in with Game Center, enable iCloud Drive, back up a progressed garden, then choose that garden on another Apple device with the same accounts. Repeat offline/reconnect and sandbox purchase/cancel/pending/restore checks. Confirm the app reports an actual last successful cloud backup before deleting it or changing devices. A disconnected device never proves that unsynced progress exists remotely.

Sources: Apple's [Game Center authentication](https://developer.apple.com/documentation/gamekit/authenticating-a-player), [private iCloud saved games](https://developer.apple.com/documentation/gamekit/saving-the-player-s-game-data-to-an-icloud-account), [StoreKit verification results](https://developer.apple.com/documentation/storekit/verificationresult), and Cloudflare's [static asset headers](https://developers.cloudflare.com/workers/static-assets/headers/).
