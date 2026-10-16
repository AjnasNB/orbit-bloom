# Build 22 — 16 October 2026

A correct Sky Shuttle plan seated on its final placement can now use **Depart**. Seats lock at zero moves; a wrong final check or incomplete plan still loses. The counter changes to a checkered flag and its accessibility value explains the final check. Budgets, ticket rules, rewards and save schema are unchanged. [Change and reproduced boundary failure](../../BUILD22_SHUTTLE_FINAL_MOVE.md).

Source **5cb068161e36abf5cfd65c0fd9070b1edc989213** is pushed to public GitHub **main**. **132 unique affected checks pass:** 63 core, 67 native and two real-input phone flows, with no final native/UI failures or skips. Both ordinary and exact-budget plans pass for all 1,000 seeded Shuttle challenges. The core campaign completes 1,020 stages and six projects in 6,125 legal swaps and 24 retries without purchases or extra moves. The old-source reproduction remains separate: one failed case/nine assertions across challenges 1, 20 and 1,000. [Verification](verification.json).

The maximum-text phone flow seats all twelve travellers on the final move, verifies locked seats and enabled Depart at zero, wins, banks one star/25 coins/two water and opens challenge 2 after relaunch. The second flow plays all five skill games, restores one shared garden project and relaunches. Native coverage verifies one saved reward without spending a puzzle life.

The ordinary preview runs **1.0 (22)** with **555 coins, three completed stages, six hints, five lives and the active rules-2 level-4 board at nine moves**. A complete private container backup preceded installation. All seven typed preferences remain byte-for-byte identical immediately after install; all decoded gameplay values remain intact after normal launch. The comparison accounts for the declared frost `Set<Int>` having the same two unique members in a different JSON order, alongside known enum-map ordering, exact recovery-slot rotation and StoreKit system check time. No grid ordering, identity, farm deadline, inventory or receipt was excluded. No preview reset, uninstall, test argument or restoration was used. Store QA is shut down; only the personal preview is booted. [Preservation proof](preview-preservation.json).

Signed archive: `build/OrbitBloom-Build22-AppStore.xcarchive`. Export: `build/AppStoreExport22/OrbitBloom.ipa`, SHA-256 **a1aa57fb6c6d1871dadbe3277f9f0685d8fb4cc0e9bd1cc58083d39f45d5faf8**. Strict signature, Production private iCloud/Game Center, disabled debugger, unchanged privacy, absent test plug-ins and all 88 frozen source hashes pass. [Package proof](signed-package-verification.json), [source hashes](source-hashes.json).

**Build 22 remains local, not uploaded, Apple-server-validated or submitted.** The known locked-Mac native delivery blocker remains unchanged; no repeated sign-in/unlock request or upload attempt was made. The last authenticated Apple observation remains **13 October**: internal build 19 in Orbit Bloom QA, public build 11 Waiting for Review/manual release. No fresh authenticated Apple status is claimed. [Observation record](apple-status.json).

[Prepared metadata and What to Test](metadata-prepared.json) pass text limits. [Ten-per-device gallery plan](apple-gallery-prepared.json) uses a fresh Shuttle view and explicitly identifies retained build-21 Firefly, build-20 Rally and build-19 originals. These remain local preparations. No daily public release, real purchase, new agreement, duplicate Apple inquiry or website/save-backend change occurred.

## Original screenshots

[Manifest](manifest.json) pins **14 original native PNGs** from the final source with dimensions, hashes and case/device provenance. Legacy attachment names can refer to earlier builds; the actual executable is 22. No crop, resize, overlay or fabricated gameplay. No new tablet run this time.

- [All tickets seated at zero moves, Depart available](captures/last-move-build22-shuttle-zero-moves-valid-plan.png)
- [Final-move victory](captures/last-move-build22-shuttle-final-move-victory.png)
- [Shared garden reward](captures/last-move-build22-shuttle-last-move-shared-garden.png)
- [Challenge 2 retained after relaunch](captures/last-move-build22-shuttle-final-move-progress-after-relaunch.png)
- [Preserved ordinary preview](captures/preview-preserved.png)

Physical Apple/iCloud synchronization, signed sandbox purchases, actual VoiceOver timing and human difficulty remain device checks. Local tests do not establish server anti-cheat or Apple approval.
