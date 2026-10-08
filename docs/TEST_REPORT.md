# Orbit Bloom verification — 8 October 2026

The native game builds and runs on the dedicated **Orbit Bloom QA** iPhone 17 Pro simulator. The entire twelve-level chapter and all six restorations were completed through real UI interactions. This verifies the delivered first chapter, not production readiness or App Store approval.

## Verified results

| Run | Result | Evidence |
| --- | --- | --- |
| Pure Swift rules and economy | 12 tests passed, zero failures | `evidence/core-tests-final.log` |
| Native session persistence and interrupted victory recovery | 2 tests passed, zero failures | `evidence/FinalGameplay.xcresult` |
| Native UI campaign, pause/resume, and shop-to-free-gameplay flow | 3 tests passed, zero failures | `evidence/FinalGameplay.xcresult`, `evidence/final-gameplay.log` |
| Real drag gesture on a suggested matching pair | 1 UI test passed, zero failures | `evidence/SwipeVerification.xcresult`, `evidence/swipe-verification.log` |
| Final simulator app build, including the original app icon | Build succeeded | `evidence/final-build.log` |

Total: **18 passing tests** across the rules, native session, and UI runs. The separate swipe test dragged between the actual accessible tile centers and verified that a legal move was consumed.

The full UI campaign test took 409.45 seconds. It used actual piece taps, the public free hint control, and earned starlight bursts. It did not inject completed levels, grant stars, bypass victory checks, or unlock purchases. It won levels 1–12, spent the earned stars on six ordered projects, asserted the chapter ending, and checked that garden progress survived termination and relaunch. The separate core simulation completed the campaign in 54 legal swaps with no retries, paid items, or extra moves; that solver result is a reachability check rather than a human difficulty rating.

Rules coverage includes 100 stable initial boards, reproducible seeded boards and refills, valid swaps and cascades, invalid swaps preserving moves, frost and cross clears, loss/retry, free shuffling, session serialization, reward accounting, and restoration order. Native session tests also recreate the model from saved data and recover a victory interrupted before its animation completes without duplicating rewards.

Screenshots exported directly from the passing UI run:

- `evidence/01-garden-home.png`
- `evidence/02-playable-puzzle.png`
- `evidence/03-real-level-victory.png`
- `evidence/04-restored-greenhouse.png`
- `evidence/07-chapter-finale.png`
- `evidence/08-complete-garden.png`

The home, puzzle, frost-level, and completed-garden images were visually inspected. The branded header and individual accessible piece identifiers were corrected during testing. Earlier diagnostic logs remain in `evidence/`; the final named runs above are the passing results.

## Purchase verification remains blocked

StoreKit 2 purchase code and a local `OrbitBloom.storekit` configuration are present. The installed iOS 26.5 runtime rejects the test configuration with `SKInternalErrorDomain Code=3`; it cannot reliably return the configured product. Configuration was tried through command-line tests and an Xcode launch. No successful purchase is claimed, and the app does not simulate ownership to make a test pass.

Four native purchase tests (purchase/restore, cancellation, pending approval, and refund revocation) and one purchase UI test are excluded from the final passing run. These five tests are **unverified**, not passed. Apple describes a related iOS 26.5 command-line StoreKit configuration problem in this [Developer Forums thread](https://developer.apple.com/forums/thread/826971). A working local runtime or signed sandbox build is required to resolve verification.

The shop's absence of a connection does not block the free chapter. It shows a retryable status, and the native UI test returned from Shop and started a real puzzle successfully. Real App Store product registration, distribution signing, TestFlight, and sandbox transactions remain release work.

## Reproduce

Use the commands in `README.md`. Environment: Xcode 26.6 (17F113), Swift 6.3.3, iOS 26.5 (23F77), iPhone 17 Pro simulator. The dedicated device identifier is `64173F47-C4DC-46B4-82EC-0027675F7780`; select an available simulator identifier when running elsewhere. Dependencies are vendored, and the project uses relative source paths.

## Scope still requiring device testing

Physical-device sound and haptics, VoiceOver, accessibility text sizes, older supported iOS versions, iPad orientations, interruption/network cases, and signed purchase flows have not been fully verified. Content tuning, stronger visible construction changes, and separate biome illustrations are production milestones described in `CONCEPT_AND_ROADMAP.md`. Only Orbit Bloom is built; the other three games remain concepts.
