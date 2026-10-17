# Store QA runtime check — 17 October 2026

The pinned Store QA device is currently unavailable because its **iOS 26.1 runtime is missing**. CoreSimulator lists only iOS 26.5 as installed. The Store QA device itself still exists, with `runtime profile not found`; it was not erased or replaced during this run. Available storage was approximately 678 MiB when inspected, so a runtime download was not attempted.

`scripts/test-ios.sh` now checks the available-device JSON before compiling or booting. It requires the existing Store QA UUID on iOS 26.1, an available device, and a Booted or Shutdown state. Missing, mismatched, malformed or busy inventories stop safely. The existing rejection of the personal preview UUID remains first. An already booted device is not booted again; a failed boot is no longer silently ignored. There is no automatic fallback to another device or runtime.

## Verification

- **11 runner safety cases pass**, using isolated command stubs. They cover missing/wrong runtimes, unavailable/busy devices, malformed inventory, inventory-command failure, preview rejection, healthy routing of both native suites, an already booted device and failed boot. These are runner checks, not simulator gameplay tests.
- **63 real core cases pass** with `swift test -j 2`. The campaign completes all 1,020 levels and six garden projects in 6,125 legal swaps and 24 retries, without purchases or extra moves. This proves automated reachability, not human difficulty.
- Running the actual revised iOS test script on this host returns **exit 2** with the runtime recovery message before compiling or booting. Native and UI gameplay checks are **blocked**, not passed or skipped by XCTest.
- All **88 build-22 frozen app/resource/project/test hashes** still match. No app code, assets, entitlements, privacy declarations, product metadata or bundle version changed. Build 22 remains the latest local game package; no build 23 was made.
- Personal preview preferences are byte-for-byte unchanged across the checks. Every simulator remains shut down. No install, reset, app launch or new screenshot occurred. Existing build-22 screenshots retain their original provenance.

[Machine-readable record](qa/2026-10-17-runtime-readiness.json) pins log hashes. Private raw logs remain in ignored `evidence/`. The old runner failed nine of the original ten stub cases; that expected reproduction is retained separately. An intermediate revision returned the wrong error code in two malformed-input cases; the final eleven-case run passes.

## Recovery

Free enough disk space to restore **iOS 26.1** through Xcode's simulator components, then rerun `scripts/test-ios.sh` against the existing Store QA device. Preserve both device records and the personal preview save. Do not redirect resetting tests to the available personal iOS 26.5 preview.

App Store status was not freshly authenticated during this infrastructure run. The last authenticated observation remains 13 October: internal build 19 and public build 11 Waiting for Review with manual release. Build 22 remains local. No upload, review replacement, public release, purchase, agreement, duplicate Apple inquiry or website/backend deployment occurred.
