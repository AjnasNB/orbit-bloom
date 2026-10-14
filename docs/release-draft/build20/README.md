# Build 20 — 14 October 2026

Rally now banks each registered finished attempt exactly once. Duplicate, reentrant, abandoned, superseded and previous-account callbacks cannot mint coins, consume more cargo or open farm fields with false wins. Leaving an unfinished route pays nothing. Existing crash salvage and valid subsequent wins still work. [Defect, implementation and verification](../../BUILD20_RALLY_SETTLEMENT.md).

Source **8f72c7bf7f660b21e8643e9ab755bb562cb4b17b** is pushed to public GitHub **main**. **131 unique affected checks pass:** 61 core, 66 native and four real-input phone flows. No final native/UI failures or skips. The complete campaign remains reachable through 6,125 legal swaps and 24 retries across 1,020 stages and six projects without purchases or extra moves. The old failing reproduction is retained separately. [Verification](verification.json).

The ordinary personal preview runs **1.0 (20)** with **555 coins, three completed stages and its active rules-2 level-4 board with nine moves**. Complete private container backups and typed preference comparisons verify preservation. Only normal Codable ordering, prior-primary backup rotation and StoreKit's advancing check timestamp differ after launch. There was no preview reset, uninstall or test argument. Store QA and other test simulators are shut down; only the personal preview is booted. [Preservation](preview-preservation.json).

The signed archive is `build/OrbitBloom-Build20-AppStore.xcarchive`; exported package is `build/AppStoreExport20/OrbitBloom.ipa`, SHA-256 **cdcf525fa6602e3687e58fe92dc28d05a6269baedbdf8c20335fc304a03874f5**. Strict code-sign verification, Production private iCloud/Game Center, disabled debugger, unchanged privacy manifest and absent test plug-ins pass. All 88 frozen source-file hashes match. [Signed package](signed-package-verification.json), [source hashes](source-hashes.json).

**Build 20 is prepared locally, not uploaded, Apple-server-validated or submitted.** Native control reports that the Mac is locked and automatic unlock failed. Chrome attachment to the existing Apple tab also times out; this run did not freshly verify the public submission or internal beta state. Unlocking the Mac is required to resume Transporter delivery. No repeated Xcode sign-in request, replacement of the existing Transporter queue or duplicate Apple inquiry was made.

The last authenticated Apple observation is **13 October**: build 19 processed and assigned to **Orbit Bloom QA**, with one tester/invite and saved What to Test notes; the public build-11 submission was Waiting for Review with manual release selected. These are dated observations, not a new server check. No daily public review/release, real purchase or legal agreement occurred. [Current observation record](apple-status.json).

[Metadata and What to Test](metadata-prepared.json) pass their text limits and remain local preparation. [Ten-per-device gallery plan](apple-gallery-prepared.json) uses a fresh build-20 Rally phone capture while identifying retained build-19 images explicitly. No public gallery or review metadata was changed. The isolated website at **https://orbitbloom.cognifyr.co/** remains unchanged; this settlement fix needs no new Cloudflare infrastructure or player-save database.

## Original screenshots

[Manifest](manifest.json) pins **15 unchanged native PNGs** with dimensions, hashes and test/device provenance. Fourteen were captured in the current build-20 UI run; legacy attachment names can contain earlier build numbers, which the manifest distinguishes from the actual executable. The final image comes from the ordinary personal preview. No crop, resize, overlay or fabricated gameplay was used. This run has no new tablet layout test; the prior build-19 tablet evidence remains separate.

- [One real delivery leaves field two locked at 1/3](captures/build20-one-delivery-one-farm-win.png)
- [One reward and Rally badge remain after relaunch](captures/build20-rally-single-reward-after-relaunch.png)
- [Driving the complete route](captures/build17-rally-real-delivery.png)
- [Ordinary preview with the owner's save](captures/preview-preserved.png)

Physical Game Center/private iCloud synchronization, signed sandbox checkout, VoiceOver timing and human difficulty remain device checks. Local callback/signature checks do not establish server anti-cheat or guarantee that a modified client cannot cheat.
