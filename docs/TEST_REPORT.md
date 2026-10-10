# Build 13 release delivery follow-up — 10 October 2026

The same tested app source was archived for device Release, exported with the existing App Store profile, verified for code signature/Production private iCloud/Game Center/privacy reasons and no test plug-ins, then validated and delivered by Transporter. Apple processing finished according to Transporter. See [package verification](release-draft/build13/signed-package-verification.json). This does not prove a physical Apple account/cloud/sandbox round trip.

`evidence/Build13-iPadRooms.xcresult` passes `SevenRoomsUITests/testAllSevenDoorsHaveDistinctRoomsAndClearExits()` on the separate iPad QA simulator: all seven entrances/exits, retained room choice and no puzzle-life cost for the six other rooms. It is an existing phone case rerun on another device; **109 unique passing cases remains the count**. Six additional original native room PNGs extend the gallery to 31. The iPad QA device is shut down after the capture work; the owner's preview save remains intact.

Cloudflare's home screenshot now matches build13. Five public HTTPS/security-header routes pass in `evidence/build13-site-security.log`; [deploy proof](release-draft/build13/site-delivery.json) distinguishes this website update from the Apple product page. Apple gallery/review replacement waits for the expired Chrome Apple session to be signed in. The existing build11 review was not cancelled.

---

# Orbit Bloom build 13 verification — 10 October 2026

The fruit, leaf, dew, rose, diamond, powers, gardening robot, coin, Lio and rally rover now share a rounded 3D cartoon style with the existing garden. Original transparent PNGs replace the detailed realistic renders. [Style findings](CARTOON_STYLE_REFINEMENT.md) and [full prompts](CARTOON_ARTWORK_PROMPTS.json) describe the changes. Navigation, difficulty, economy, account handling and save schemas are preserved.

**109 unique cases passed: 49 core, 49 native, ten phone UI and one iPad UI.** Final relevant bundles have no failures or skips. Farm/Shop recapture reruns count once. [Verification](release-draft/build13/verification.json) pins source and records the failed initial crop check.

| Area | Evidence |
| --- | --- |
| Rules, powers, economy, save compatibility and campaign | `evidence/build13-core.log`: 49 passes in 24.549 seconds. All 1,020 stages and six projects complete in 6,427 legal swaps and ten retries, without paid items or extra moves. This is automated reachability, not human difficulty evidence. |
| Native assets, sessions, local purchases, accounts, journey and clock | `evidence/Build13-PhoneVerified.xcresult`: 49 native passes, including all twelve visible sprite crops with transparent gutters and character/rover alpha. Local StoreKit checks cover credits, duplicate protection, cancellation, pending purchases and refund behaviour. |
| Actual phone play | PhoneVerified adds eight UI passes for swipes, first clear/locks, board powers and shuffle, One shot, life accounting/abandon/restart, harvest/craft/relaunch, rally steering/completion and supply packs. |
| Seven connected rooms | `evidence/Build13-SevenRooms.xcresult`: two passes, including every entrance/exit and real wins in Canal, Firefly, Windmill and Observatory. Four first clears retain +100 coins, four stars, water and next-challenge progression after relaunch. |
| Settled capture rerun | `evidence/Build13-PhoneGallery.xcresult`: two repeated cases pass after the capture helper waits beyond the 200-ms room fade. Early blended Farm/Shop pictures are replaced; screenshots retain original bytes. |
| Adaptive iPad | `evidence/Build13-iPad.xcresult`: one pass in 50.065 seconds, checking map/board, all 49 tiles, booster rails, exits and 44-point controls through portrait/landscape. Full Screen.main PNG capture retains native orientation. |

The initial Phone bundle records 56 passes and one failed diamond crop guard. That result stays failed. The atlas gutter repair and closer diamond crop resolve the issue; PhoneVerified passes all 57 native/phone cases. Artwork iterations rejected for size/edge issues are excluded from the app. [Twenty-five native screenshots](release-draft/build13/README.md) cover map, cartoon board/powers, Farm/tool shed, Rally, story, four skill rooms, supplies, exits, One shot, both iPad orientations and the ordinary preview.

The complete preview container was backed up privately. All seven preferences and plist bytes match after in-place installation. After ordinary launch, the full decoded wallet, puzzle, farm, inventory, receipts, settings and timers still match; only the normal StoreKit system check timestamp changed. The preview preserves **280 coins, one completed stage, active level 2/rules 1, ten moves, seven free hints and five lives**. No reset or QA launch flags were used there. Its build-13 window is brought forward; Store and iPad QA are shut down, and unrelated simulator work is preserved.

Low disk space was handled by removing regenerable caches on stopped owned simulators, the completed package build cache and duplicate exported attachments. Full app-container backups, source, earlier signed packages, raw test results/logs and selected original PNGs remain. The static UX scan is retained at `evidence/build13-ux-scan.txt`; decorative-image and accessibility-notification signals are triaged in the style note. Physical Apple account/cloud/ranking/signed sandbox checks, hardware performance/audio/haptics, VoiceOver speech and smallest-device/split-view layouts remain separate verification.

Build 13 is tested locally and committed to source; **it has not been uploaded to TestFlight or submitted to Apple**. The existing build-11 submission and its product gallery were not modified. Chrome was unavailable for an incidental review recheck, so no fresh Apple server status is claimed. No real purchase or agreement occurred.

---

# Orbit Bloom build 12 verification — 10 October 2026

The garden now fills the viewport with original continuous 3D scenery, neighboring districts, a river, promenade and a route extending beyond the screen. Floating controls retain clear Farm, Rally and seven-room entrances. Puzzle pieces occupy more space on warm tiles over an azure courtyard; iPad landscape separates goals/turns and boosters into side rails. [UX findings and reference research](GARDEN_UI_REDESIGN.md).

**103 unique cases have recorded passes: 49 core, 48 native, five phone UI and one iPad UI.** Reruns count once. These are the affected checks for this revision, not all seven-room tests from build 11. [Build-12 verification](release-draft/build12/verification.json) pins source and native capture provenance. Final relevant runs have no failures or skips.

| Area | Cases | Evidence |
| --- | ---: | --- |
| Core rules, progression, economy, save compatibility, all-stage solver | 49 | `evidence/build12-core.log`: 24.016 seconds, zero failures |
| Native sessions/lives, purchase/account/journey/clock tests, including moving-shuffle input/save regression | 48 | `evidence/Build12-PhoneFinal.xcresult`: 8.301 seconds, zero unit failures |
| Full garden/board targets, real first-clear swipe and sequential locks, powers/shuffle, One shot, abandonment/restart, separate rooms and saves | 5 | PhoneFinal records all five passes. `Build12-ExitVerified.xcresult` rechecks the later enlarged Keep playing label and life accounting. |
| iPad map and board, all 49 tiles in both orientations, goal/booster rails, reachable exits and no scrolling | 1 | `evidence/Build12-iPadGallery.xcresult`: final range spacing and full-screen native captures; zero failures |

The phone map is checked against 95% of viewport width and 85% of viewport height. Its board occupies at least 90% of screen width, with all tiles and tools reachable; checked targets are at least 44 points. A real first win unlocks level 2 and keeps level 3 locked. Swiping to district 2 cannot bypass progression. iPad landscape board width exceeds 600 points, and all tiles and controls remain in bounds through rotation. The solver completes all 1,020 stages and six projects in 6,439 legal swaps and 15 retries, with no paid items or extra moves; this does not establish human difficulty.

Shuffle now saves its final arrangement and one inventory debit immediately, locks input for a finite 450-ms animation plus a small settling allowance, and uses a run token to avoid reopening a replaced attempt. The native regression rejects taps, swaps and a repeated shuffle during movement, restores the saved arrangement, then verifies gameplay reopens. The real UI power test forms a board power, shuffles while keeping powers/turns and detonates the resulting power after readiness.

Diagnostics are retained separately. Phone's first run exposed accessibility identifier propagation (three failures); the next run exposed a tap during shuffle movement (one failure). PhoneFinal then passes all 53 native/phone cases. The first iPad run reported a 24.5-point Keep playing target, followed by a disk-full result-packaging error. Its next keep-progress run correctly resumed that interrupted puzzle and failed a home-only test setup; setup now returns through real abandonment rather than resetting data. iPadConfirmed passes, but its app-scoped landscape captures were cropped. Final iPadGallery uses Screen.main PNG capture, preserves native orientation, verifies the adjusted badge spacing and supplies the selected full-screen images. No failed diagnostic run is relabeled successful or counted as a pass.

[Eleven native screenshots](release-draft/build12/README.md) show phone map, locked district, board, first clear, board power, final abandonment, both iPad orientations and the ordinary preserved preview. Original bytes and orientation metadata remain intact. The selected screenshots were visually inspected; old cropped landscape exports are excluded.

The complete private preview container was backed up before installation. All seven preference values and plist bytes match after in-place installation. After ordinary launch, the full decoded wallet, puzzle, farm, tools, receipts and settings still match; no timer or gameplay value was ignored. The fresh baseline is **280 coins, one completed stage, active level 2/rules 1 with ten moves, seven free hints and five lives**. This preserves the user's current ten-move save rather than substituting the eleven-move historical build-11 snapshot. No QA launch/reset flags were used on the preview. Store and iPad QA are shut down; the preview runs build 12. Unrelated simulator work was preserved.

Disk cleanup was confined to regenerable caches on the two stopped QA devices, the completed Swift package cache and duplicate exported attachments. Original test results/logs, selected screenshots, signed packages and preview backups were retained. Smaller devices, split view, hardware performance/audio/haptics, VoiceOver speech and live Apple cloud/ranking/sandbox checks remain outside this simulator evidence. Local test doubles do not prove physical Apple service paths.

Chrome confirms **version 1.0 build 11 and its eight submitted items remain Waiting for Review**. Build 12 is installed locally and pushed to source; it is **not uploaded to TestFlight or submitted**. The submitted build-11 binary, gallery and metadata were not replaced. No public release, real purchase or agreement occurred.

---

# Orbit Bloom build 11 verification and submission — 10 October 2026

Build 11 connects seven named rooms through Lio's Aurora Atoll story, original 3D room miniatures, four new skill games, an illustrated delivery rover, shared UTC events and optional Game Center skill records. Completed skill results feed the garden with stars, coins and water. Large-text pages separate story/project, event details and records; returning from a new skill room retains its selected directory page. [Seven-room UX audit](SEVEN_ROOMS_UX_AUDIT.md).

**107 unique cases have a recorded passing run:** 49 core, 47 native, nine iPhone UI and two iPad UI cases. This is a union across runs, with reruns counted once. The corrected seven-door case, normal read-only captures and both fresh valid iPad bundles now pass. Native galleries have been exported and QA simulators shut down. Apple build 11 was submitted on **10 October 2026 at 16:47 India time** and is **Waiting for Review**; twenty matching native gallery screenshots processed successfully. Earlier diagnostic bundles below retain their recorded failures or incomplete status.

The new review submission is **83b00d39-0873-4771-8bc9-5d94d4be04b4**, containing eight items: version 1.0 build 11, all six in-app purchase packs and the Atoll Skills leaderboard. Build 11 is assigned to internal TestFlight QA with one existing tester. These are confirmed delivery/review states; Apple's approval and public availability are still pending.

| Area | Unique recorded passes | Evidence / current limit |
| --- | ---: | --- |
| Core rules, procedural rooms, journey/events, economy, save compatibility and campaign solver | 49 | `evidence/build11-core-final.log`: zero failures, 25.824 seconds |
| Native journey/account/recovery, sessions/lives, local StoreKit and trusted-clock behavior | 47 | `evidence/Build11-NativeRooms4.xcresult`: zero native unit failures; its separate UI portion failed |
| iPhone gameplay, seven-room progression, largest text, event/record pages, Rally and normal read-only gallery | 9 | Union of Build11-FinalPhone, Build11-RoomReturnFinal, Build11-NormalGallery and Build11-NormalGalleryFinal result bundles; each test name counted once |
| iPad seven-room portrait/landscape tour and release captures | 2 | `evidence/Build11-iPadRoomsVerified.xcresult` and `evidence/Build11-iPadReleaseVerified.xcresult`; both fresh valid bundles have zero failures |

The nine unique phone cases are recorded individually so the union does not conceal failed diagnostic runs:

| Phone case | Passing evidence | Duration |
| --- | --- | ---: |
| Back/cancel/abandon/restart charges exactly one life per attempt | Build11-FinalPhone | 22.636 s |
| Board power formation and animated shuffle | Build11-FinalPhone | 15.605 s |
| One shot real winning swipe and returned life | Build11-FinalPhone | 17.965 s |
| Separate Farm/Rally maps, clear exits and saved progress | Build11-FinalPhone | 60.469 s |
| All seven distinct room doors and clear exits, with retained selection after the intended exit path | Build11-NormalGallery | 65.450 s; corrected strengthened assertion passed |
| Four new rooms win through real input, save rewards and advance after relaunch | Build11-RoomReturnFinal | 103.084 s |
| Maximum accessibility text, room controls, nine event pages and eleven record pages | Build11-FinalPhone | 262.032 s |
| Rally ignores vertical steering, pauses/resumes and banks actual pickups | Build11-FinalPhone | 50.879 s |
| Normal story/room doors, online events, records, saved-garden and read-only supplies gallery | Build11-NormalGalleryFinal | 140.331 s |

Both unique iPad cases have fresh retained passing evidence:

| iPad case | Passing evidence | Duration |
| --- | --- | ---: |
| Seven-room layout fits portrait/landscape without changing rewards | Build11-iPadRoomsVerified | 210.940 s |
| Portrait/landscape release screens and native captures | Build11-iPadReleaseVerified | 52.812 s |

Core automation completes all 1,020 campaign stages and six projects in **6,578 legal swaps and 23 retries**, without paid items or extra moves. This is automated reachability and rule evidence, not manual play of every level or proof of human difficulty. The native 47-case total consists of seven journey, fifteen account, six purchase, nine session and ten world-clock cases. Local StoreKit and account/clock test doubles do not establish a live Apple account, cloud round trip, signed sandbox purchase or worldwide leaderboard submission.

The four-room passing UI run solves actual pipe rotations, repeats lantern signals, times charges and moves star tiles. It explicitly saves each result, checks +25 coins per new clear, unchanged puzzle lives, return to the chosen room without replaying the welcome, next-challenge progression after relaunch and four earned stars. The maximum-text passing case verifies the keeper/project pages, room exits/controls, paged help, event details and records with their child identifiers preserved. The Rally case separates control assertions from a fresh controlled drive and checks a real pickup plus banked reward. The normal capture case records the keeper, four room-door pages, three real online event pages, five record pages, Apple Saved Garden and all six shop packs without buying anything or changing coins/lives. No fake winning-state shortcut is counted as this play evidence.

Diagnostic history remains visible:

- NativeRooms2/3 exposed swipe/button activation and compressed activity targets; NativeRooms4 retained 47 unit passes and two UI passes but failed later at maximum-text event-state discovery. Explicit accessibility containers were added to the event/record roots, and FinalPhone's maximum-text case subsequently passed.
- Build11-FinalPhone ran eight UI tests: seven passed and the four-win case failed after completing its play path because the compiled final assertion queried `hubRestoration` while the retained room page was selected. The corrected case pages back to inspect restoration and passes in RoomReturnFinal. The failed first bundle is not relabeled successful.
- Build11-RoomReturnFinal ran two UI tests: the four-win case passed, but a newly strengthened all-seven-door test incorrectly expected Farm/Rally exits to go directly to the directory. Those labeled exits intentionally return to the Island. The corrected test reopens the directory and verifies retained selection; it passes in Build11-NormalGallery at 65.450 seconds. The earlier failed bundle stays failed.
- Build11-NormalGallery's second, read-only capture case failed only on a floating-point target-height comparison: `43.99999999999994 >= 44`. A test-only `1e-6` epsilon resolves the rounding residue without changing app code or materially lowering the 44-point requirement. Build11-NormalGalleryFinal reruns that one case and passes in 140.331 seconds, with zero failures. Its first bundle is not relabeled successful.
- The interrupted `Build11-iPadFinal.xcresult` now has `Info.plist` and is readable by `xcresulttool`. Its current summary is `result: unknown`, `totalTestCount: 0`, `passedTests: 0`, `failedTests: 0`. The raw disk-full log includes an earlier release-screen pass line at 57.216 seconds, but the bundle records no cases: classify it as incomplete/unknown, with no counted passes or final screenshot provenance. It is not currently an unreadable corrupt bundle. The fresh Build11-iPadReleaseVerified rerun passes in 52.812 seconds with a valid retained bundle; the case is counted once, using the fresh evidence.

The isolated Cloudflare website and public event clock are deployed at `https://orbit-bloom-game-site.ajnasnb.workers.dev`, latest version **1fe5fe66-69a0-4b46-a680-70fadf7a12d7** (`evidence/build11-site-final-deploy.log`). The updated homepage and genuine build-11 preview asset uploaded successfully. Root confirmed five HTTPS/security-route checks and the native app accepted the real public clock for its normal event pages. These deployment checks are separate from the 107 counted test cases; no player save or purchase data is stored by this event endpoint.

Disk pressure interrupted iPad boot/test preparation. Scoped cleanup removed only regenerable build-11 duplicate attachment/export-verification folders and redundant early NativeRooms2/3 failed result bundles. Their raw diagnostic logs remain; NativeRooms4, FinalPhone, RoomReturnFinal, NormalGallery, NormalGalleryFinal and both fresh verified iPad bundles are retained. No player save, source or signed package was deleted. The fresh iPad runs now supply the two counted passes and valid native capture evidence.

Root confirmed native gallery export and QA simulator shutdown after the passing iPad reruns, followed by the matching twenty-screen Apple gallery, internal TestFlight assignment and eight-item review submission. Signed-package, capture and preview-preservation details are maintained in the build-11 release record. Physical VoiceOver/focus/timing, smaller hardware/split-screen, performance/audio/haptics, real-player Apple cloud/ranking/sandbox and human difficulty remain separate checks; publisher sign-in or an accepted review submission does not prove those player-service paths. The user's preview save must remain preserved; resetting test fixtures belong only on the isolated Store QA device.

---

# Orbit Bloom build 10 verification — 10 October 2026

Farm and Harvest Rally now have distinct labeled entrances, original 3D room maps and prominent exits naming the Island destination. Farm keeps six numbered plots and its tool shed; Rally previews the existing garage-to-orchard-to-finish course. Camera framing fits the diorama's width and height, card shadows no longer duplicate text, and plot status has stronger contrast. [Focused mobile UX audit](ACTIVITY_ROOMS_UX_AUDIT.md).

**77 unique cases passed**, with no failures or skips in final evidence:

| Area | Cases | Evidence |
| --- | ---: | --- |
| Core rules, economy, difficulty, save compatibility and all-stage solver | 34 | evidence/build10-core.log |
| Native account/recovery, sessions/lives and local StoreKit | 30 | evidence/Build10-FinalPhone.xcresult |
| Full iPhone gameplay/navigation and room entry/exit/save/accessibility | 12 | evidence/Build10-FinalPhone.xcresult; final affected room reruns below |
| iPad room/puzzle controls, both orientations and actual swipe steering | 1 | evidence/Build10-iPadFinal.xcresult |

The broad phone result records 42 passes, zero failures and zero skips; twelve UI cases take 581.842 seconds, including twelve opening-stage victories and six garden restorations. After the final camera/continuous-road refinement, the affected room and iPad cases passed again. The final expanded room case takes 71.312 seconds and additionally checks non-overlapping large-text Farm plots; the final iPad case takes 50.672 seconds and rotates both room maps. These reruns add no unique cases. [Compact summaries and capture provenance](release-draft/build10/verification.json) pin source `fac4c21`.

Core automation completes all 1,020 stages and six projects in 6,556 legal swaps and 25 retries without paid items or extra moves. The native suite rechecks optional accounts, offline/timeout/stale-account cloud behavior, local recovery, legacy saves, exactly-once life/wallet transactions and local StoreKit purchase/cancellation/approval/restore/refund behavior. Rules and cloud/payment architecture were not changed by this visual/navigation task. Solver reachability does not establish human difficulty or manual play of every stage.

The new room flow uses actual taps to plant, leave/re-enter and craft, relaunches with retained progress, performs actual road swipes and exits a paused rally. Normal and accessibility-medium entrances, room exits, Start rally and all six Farm plots are reachable; enlarged Farm plots do not overlap. There is no vertical scrolling in the checked Home/Rally pages. Thirteen selected native phone/iPad PNGs retain original pixels/orientation; a separate normal-preview proof shows the user's retained puzzle. Initial diagnostics found an accessibility wrapper hiding button traits; the wrapper was removed and final checks pass. Screenshot review drove the shadow, road and camera corrections.

Before installing build 10, the full personal preview container was backed up. All seven preferences match exactly immediately after installation. After normal launch, the complete decoded wallet, board and legacy progress still match, normalizing only JSON dictionary/enum-key ordering: 280 coins, one completed stage, active level 2 with eleven moves, seven free hints and all inventory. No timer/gameplay value was ignored. Only Store QA receives reset fixtures; iPad uses keep-progress. Store/iPad QA are stopped and the personal preview runs build 10. Completed compilation caches and duplicate extracted captures were removed to relieve temporary disk pressure; source, saves, signed archives/IPAs and original result bundles were retained. Unrelated simulators were untouched.

Final Release archive/export and exact exported signature checks pass. [Signed package record](release-draft/build10/signed-package-verification.json) pins source and IPA hash, Production Game Center/private iCloud entitlements, disabled debugger access, all four iPad orientations and absence of the Debug stage-selection fixture. Build 10 is prepared locally, **not uploaded to TestFlight**. Existing Apple account authentication remains the known blocker; no repeated sign-in request or upload attempt occurred. Build 7's submitted review/galleries were not changed or freshly rechecked. [Local build 10 metadata draft](release-draft/build10/metadata.json) accurately describes the new rooms and One shot rules, without replacing the submitted build-7 copy.

Physical VoiceOver speech, extreme text sizes/smaller phones, hardware performance/audio/haptics, live Apple cloud round trips, signed sandbox purchases and human difficulty remain outside simulator verification. No public release, real purchase or agreement occurred.

---

# Orbit Bloom build 9 verification — 10 October 2026

Build 9 adds visible puzzle Back navigation with separate abandon/restart confirmations, labeled difficulty and a campaign that tightens across later bands. Twenty One shot stages begin at 30 and recur every 50 stages: one move, hints available and a free winning swipe. Existing active sessions retain their exact previous goals and turn budgets. [Rules and focused mobile UX review](DIFFICULTY_AND_EXIT.md).

**76 unique cases passed today**, with no failures in the final runs:

| Area | Cases | Final evidence |
| --- | ---: | --- |
| Core rules, all-stage solver, difficulty variants, legacy/future saves and economy | 34 | evidence/build9-core-final.log |
| Native account/recovery, session/life accounting, blocked assistance and local StoreKit | 30 | evidence/Build9-FinalPhone.xcresult |
| All iPhone flows, including real One shot swipe and cancel/abandon/restart/relaunch | 11 | evidence/Build9-FinalPhone.xcresult |
| iPad portrait/landscape bounds, 49 tiles, road steering and abandon confirmation | 1 | evidence/Build9-iPad.xcresult |

The complete phone result bundle records 41 passed and zero skipped/failed tests; its eleven UI cases take 554.064 seconds, including twelve actual opening-stage victories and six earned garden restorations. The One shot case was rerun after correcting “1 turns” to “1 turn”; its final native captures use that rerun, without double-counting it. [Compact result summaries and capture provenance](release-draft/build9/verification.json).

Core checks complete all 1,020 stages and six projects in 6,421 legal swaps, 15 retries and no paid tools or extra moves. All twenty One shot combinations (five colors × four rotations) pass at three seeds each, with no initial matches, a free winning swipe and unchanged inventory under blocked assistance. An invalid swap preserves the move; a legal wrong move can lose. Difficulty checks compare the same stage rhythm across later bands. These establish automated reachability and rule behavior, not human difficulty or manual play of every stage.

The exit tests verify start spends exactly one life, cancel/pause keeps the same board and balance, abandon clears the session without another debit, and relaunch retains the world. Restart only spends the next life after confirmation. One shot wins return the spent life, unlock the next Simple stage and preserve unavailable tools. The stage-30 UI setup uses a Debug-only progression fixture; it does not claim to have played the preceding 29 stages. The signed Release executable was checked to exclude this fixture.

Save checks preserve older snapshots with their legacy budgets, reject unknown rule versions and reject a schema-1 cloud envelope falsely containing new rules. Active version-2 puzzles use cloud schema 2 so older clients cannot reinterpret them. Existing Apple account isolation, purchase protections, timeout, offline and paused-restore tests pass. GameKit/private iCloud remains the sole cloud service.

An initial One shot UI run solved the puzzle but its life-balance assertion matched both the result and underlying HUD. It now checks the balance after returning to the island; the final full run and affected rerun pass. That failed diagnostic run is excluded from final evidence. Seven selected native iPhone/iPad PNGs and a separate preview proof were visually checked and retain exact original pixels/orientation. They are prepared for build 9 and were not substituted into build 7's submitted Apple galleries.

The user's preview data container was backed up before installation. All seven preferences were exactly equal immediately afterward; after normal launch the full wallet and active board remain equal: 280 coins, one completed stage and level 2. Only absent legacy rules markers become version 1; dictionary/enum-key ordering is normalized without dropping any gameplay value or timer. The preview was temporarily stopped to reduce disk pressure, then reopened with build 9. Only finished project compilation caches and duplicate extracted verification folders were removed; signed archives/IPAs, sources, saves and result bundles were retained. Store/iPad QA are stopped and unrelated simulators were not changed by this task.

Release archive/export and exact exported signature checks pass; [package verification](release-draft/build9/signed-package-verification.json) pins source `fe8a7d9` and the IPA hash. Production Game Center/iCloud entitlements, disabled debugger access and four iPad orientations were verified. Build 9 has **not been uploaded to TestFlight**; the existing Apple account blocker was not repeatedly prompted or retried. Build 7's submitted review and product-page metadata were not changed or freshly rechecked. Live Apple cloud, signed sandbox purchases, physical audio/haptics, broader accessibility/smaller devices and human difficulty retain their existing verification limits. No real purchase, agreement or public release occurred.

---

# Orbit Bloom build 8 verification — 10 October 2026

The field journal now adapts its horizontal pages to available height and larger text. Full instructions and reward/power descriptions wrap, claim actions stay reachable, and a named adjustable page counter supports accessibility. The clipped build 7 iPad help sentence is replaced by complete copy in the native capture. See [focused mobile audit](MOBILE_JOURNAL_AUDIT.md).

**63 unique cases passed today**, with no failing assertions in the final runs:

| Area | Cases | Final evidence |
| --- | ---: | --- |
| Core rules, all-stage solver, saved schema and economy | 31 | evidence/build8-core-tests.log |
| Native player accounts, recovery, sessions/media and local StoreKit | 28 | evidence/Build8-ConnectedNative.xcresult |
| Every journal reward and power at the first accessibility text size | 1 | evidence/Build8-JournalInitial.xcresult; 47.512 seconds |
| Actual harvest → claim → craft → relaunch and island/puzzle/power navigation | 2 | evidence/Build8-ConnectedNative.xcresult |
| iPad portrait/landscape bounds, swipes, wrapped journal help and power pages | 1 | evidence/Build8-iPadCaptured.xcresult; 39.425 seconds |

Six unaffected iPhone flows recorded for build 7 remain applicable and were not rerun today. Together these provide **69 recorded unique cases**, rather than 69 cases run anew for build 8. The current core solver completes all 1,020 stages and six projects in 6,057 legal swaps with one retry and no paid items/extra moves; this is automated reachability evidence, not human difficulty testing or manual play of every stage.

The new large-text UI check performs actual horizontal swipes through all six rewards and four powers. It checks full wrapping, card bounds, non-overlap, hittable controls, both page boundaries, zero scrolling and return to gameplay. Existing farm checks still claim the earned reward, craft a tool and retain the garden on relaunch. The iPad run checks real race steering, 49 puzzle controls in both orientations and the journal's full portrait sentence/landscape formations. VoiceOver speech and its adjustment gesture, extreme text sizes and smaller devices remain unverified.

The first iPad run passed all assertions (50.830 seconds), but Xcode could not persist its result summaries/attachments because disk space was exhausted. It is diagnostic evidence only. After deleting this project's rebuildable caches and stopping the finished Store QA device, the repeated iPad run passed and saved all attachments. No sources, saves, archives, release assets or other projects were deleted. Six selected native journal PNGs were copied byte-for-byte and visually checked; [manifest with hashes and provenance](release-draft/build8/verification.json) distinguishes them from the existing build 7 App Store gallery.

Build 8 was installed over the user's iOS 26.5 preview without a reset. All seven preferences were exactly equal immediately after installation. After normal launch, the full active wallet and session still matched: 280 coins, one completed stage and the stage 2 puzzle. The initial raw session-byte comparison detected JSON key ordering; comparing decoded contents resolved it without ignoring any gameplay value or timer. Enum-key tool dictionaries are compared by key. The full original data container is backed up locally; evidence/build8-preview-preservation.txt records the result. Store QA alone receives resetting tests. iPad uses --keep-progress. Both test devices are stopped; the user's preview and unrelated Rush Drives simulator remain booted.

The signed Release archive/export passed, and the exact IPA signature, identity, four iPad orientations, Production cloud container and disabled debugger access were verified. [Signed package record](release-draft/build8/signed-package-verification.json) pins source a8b1ba9 and its hash. **No TestFlight delivery occurred**: upload export failed to use Apple accounts, and locked-Mac Transporter UI could not be used. Chrome's current review request redirected to sign-in. The submitted build 7 and its public metadata were not changed; their last confirmed Waiting for Review status is recorded below. Live Game Center/iCloud and signed sandbox purchase checks retain the existing hardware limitations. No real purchase, new agreement or public release occurred.

---

# Product-page verification — 9 October 2026, 10:55 PM India time

The refreshed Apple product page contains ten native iPhone and ten native iPad screenshots, plus separate original header/search brand illustrations. All twenty uploads completed and persisted in Chrome, in the intended puzzle/farm/rally-first order. Apple previews show the botanical header and readable “SWIPE. FARM. RACE.” search artwork. Both creative assets are included with the app version and are Waiting for Review. [Manifest, exact hashes and test summaries](release-draft/product-page/manifest.json), [art provenance](release-draft/product-page/IMAGE_PROMPTS.md) and [preview proof](release-draft/product-page/README.md) distinguish real app captures from illustrations.

Two existing affected UI flows passed again: `testFarmHarvestCraftAndSave` on Store QA (evidence/ProductPage-iPhone.xcresult) checks harvested field rewards, crafting and relaunch; `testIPadPortraitAndLandscapeLayout` on iPad QA (final evidence/ProductPage-iPad-Frozen.xcresult) additionally asserts actual road swipe steering into lane 1 of 3, pause, journal bounds, activity navigation and both orientations. Intermediate iPad capture runs also passed; they are reruns, not additional unique cases. The phone journal image was captured before claiming its reward. The iPad road image is a genuine paused race view, while the phone gallery shows active race play. Native source PNGs match their recorded originals byte-for-byte; no screenshot resizing or invented UI was used.

The **68 unique passing checks** recorded for build 7 remain the applicable core/native/UI evidence. Only UI-test capture/coverage, marketing artwork and release metadata changed in this product-page update; shipping app code and the signed IPA are unchanged. Store QA and iPad QA were stopped after captures, and the user's preview save was untouched. Apple confirmed a new seven-item submission at **10:55 PM**, ID `a7ca5b7d-24f9-4b4a-8dba-9ecf44398ec9`, with **Waiting for Review** for version 1.0 (7) and all six packs. [Current Apple proof](release-draft/product-page/proof/apple-review-submission.jpg). The 10:26 PM submission was cancelled by the publisher to unlock the edits. Live Apple syncing and signed sandbox purchases remain the hardware checks already noted below; no new legal agreement or real purchase occurred.

---

# Orbit Bloom build 7 verification — 9 October 2026

**68 unique checks pass across the recorded core/native/UI runs: 31 core, 28 native, eight iPhone flows and one iPad layout flow.** The security patch rejects malformed timers and excessive save values, validates legacy progress before migration, and rechecks the current Apple player after cloud requests and before restore. Paused cloud choices cannot restore or acknowledge another garden. Apple remains the sole player cloud service; Cloudflare hosts the static website only. See [security review](SECURITY_REVIEW.md) for scope and limitations.

| Area | Unique passing cases | Evidence |
| --- | ---: | --- |
| Core rules, 1,020-stage reachability, wallet schema and extreme clocks | 31 | evidence/build7-core-tests.log; evidence/build7-ios-tests.log |
| Native account isolation, recovery, stale requests, paused restores and corrupt legacy startup | 15 | evidence/Build7-FinalRecovery.xcresult; focused stale-fetch evidence/Build7-StaleFetch.xcresult |
| Native sessions, interrupted rewards and bundled media | 7 | evidence/Build7-FinalRecovery.xcresult |
| Apple local StoreKit purchase, approval, cancellation, restore and refund checks | 6 | evidence/Build7-FinalRecovery.xcresult |
| iPhone campaign, powers, island, farm/craft, rally, shop, water and saved-garden/relaunch | 8 | evidence/Native-20261009-220205.xcresult; three affected flows refreshed in evidence/Build7-FinalRecovery.xcresult |
| iPad portrait/landscape controls and saved-garden page | 1 | evidence/Build7-iPad.xcresult; 29.699 seconds |

The full iPhone run passed 35 cases and skipped only the iPad-specific case. After the final legacy validation/button change, all 28 native tests and three affected relaunch flows passed again (31 checks, no failures). The account-change fetch case was strengthened to return an actual 777-coin remote garden, ensuring a stale nonempty result is rejected rather than merely reaching the existing pre-upload check. No test counts are doubled for reruns.

The core solver completes all 1,020 levels and six projects in 6,083 legal swaps, zero retries and no paid items or extra moves. The native UI completes twelve stages and restores six projects in 303.546 seconds. This does not establish human difficulty or mean that 1,020 stages were manually played. Two save-validation regression cases failed against the earlier implementation before the correction; an initial extreme-clock assertion exposed floating-point boundary rounding and was corrected before the final passing run. Failed diagnostic logs are not counted as passing evidence.

Ten new native QA captures (one iPhone account page and nine iPad views) are recorded in [build7/verification.json](release-draft/build7/verification.json). Portraits remain 1320 × 2868 on iPhone and 2064 × 2752 on iPad. The two iPad landscapes retain native orientation metadata and display at 2752 × 2064. No resizing or synthetic UI images were used. The original 19-image gallery depicted the same interface and remained applicable; it was subsequently refreshed to twenty screenshots in the product-page update recorded above.

The isolated Cloudflare deployment passes HTTPS/status/header checks on five routes, including the 404. Chrome displays the site with no site CSP failures; observed browser-extension warnings are unrelated. No gameplay database, publisher account API or new DNS was added. Signed release archive/export and exact package signature/Production cloud-entitlement checks pass; [build7 package verification](release-draft/build7/signed-package-verification.json) records the IPA hash.

Only the Store QA simulator receives resetting tests. iPad checks use --keep-progress. The user's preview preferences were exactly equal immediately after installation, and its full garden survived normal launch (280 coins, one completed stage and the active stage 2 puzzle). No reset was used; evidence/build7-preview-preservation.txt records the comparison. Store/iPad QA are stopped, while the user's preview remains ready for testing.

Transporter delivered build 7 at 10:18 PM India time and Apple processed it into the internal Orbit Bloom QA group. **Version 1.0 (7) and all six purchases were submitted at 10:26 PM; all seven items show Waiting for Review.** Submission `9b8a89b7-74a5-4b1c-9275-e0680e6bb9ad` has [Apple confirmation](release-draft/build7/apple-review-submission.jpg). The earlier build 6 submission was cancelled by the publisher to replace it with this tested patch. The owner tester now shows Installed 1.0 (6) on hardware; live syncing and purchase verification are still pending. Manual public release remains selected. [APP_STORE_PREPARATION.md](APP_STORE_PREPARATION.md) records the current release details.

Live Game Center authentication, an Apple iCloud round trip and signed sandbox purchases remain physical-device TestFlight checks. Memory cloud and local StoreKit tests do not prove those live integrations. Broader accessibility, device coverage, physical audio/haptics, human difficulty and consumable refund/recovery policy remain public-release checks. No real purchases or new legal/financial agreements were performed. Historical reports below apply to their own builds.

---

# Orbit Bloom build 6 verification — 9 October 2026

**60 unique checks pass across the recorded runs: 28 core, 23 native, eight iPhone UI flows and one iPad layout flow.** Build 6 adds optional Game Center authentication and private iCloud saved gardens. Guest play, active puzzle/farm progression, coins, lives, tools, assistance and credited transactions remain in the local wallet. Separate player wallets and device files avoid silently combining balances. A restore that omits a purchase credited locally is rejected. Undo restores the local checkpoint and pauses cloud backup.

| Area | Unique passing cases | Evidence |
| --- | ---: | --- |
| Core gameplay, all-stage solver, economy and saved-garden schema | 28 | evidence/build6-core-tests.log |
| Native account migration, isolation, cloud choices, undo, corrupt saves, offline failures and Apple callback timeouts | 10 | evidence/Build6-AccountFinal.xcresult; evidence/Build6-RecoveryFinal.xcresult |
| Native sessions and bundled media | 7 | evidence/Build6-AccountFinal.xcresult |
| Apple local StoreKit purchase, pending, restore and refund checks | 6 | evidence/Build6-AccountFinal.xcresult |
| iPhone campaign, powers, island, farm/craft, rally, six packs, puzzle water and account/relaunch | 8 | evidence/Build6-Verification.xcresult; account contrast refreshed in evidence/Build6-AccountScreen.xcresult |
| iPad portrait/landscape controls and account page | 1 | evidence/Build6-iPadFinal.xcresult; 37.047 seconds |

The native UI campaign again wins twelve stages and restores six projects using real controls, in 290.603 seconds. Account UI testing plants a crop, opens the saved-garden screen, checks the honest guest state, returns to play and relaunches with the crop retained. Real Apple sign-in is deliberately not simulated in UI tests. Memory transport tests exercise save/restore/error behavior; they are not evidence of successful Game Center authentication or a live Apple iCloud round trip. No physical Apple device was connected. Signed sandbox purchases and cross-device cloud syncing remain owner/device checks.

Thirty native iPhone screenshots at 1320 × 2868 and nine native iPad captures are in release-draft/build6/. Seven iPad portraits are 2064 × 2752; two landscape QA images retain orientation 8 metadata and display at 2752 × 2064. Account button/footer contrast was corrected and the account capture refreshed after the UI rerun (24.223 seconds). Capture hashes and exact source attachments are recorded in build6/verification.json and build6/ipad/verification.json. No screenshots were resized or synthesized.

An initial account compilation error was repaired before passing runs. The first iPad assertions passed, but its result bundle stalled during diagnostic collection as disk space ran out; that incomplete bundle is not counted as final evidence. After removing only this project's rebuildable caches, the focused iPad test passed again with diagnostics disabled and a readable result bundle. Existing simulator saves were not erased.

The matching distribution profile was regenerated with Game Center and container iCloud.com.orbitbloom.game. Release archive and export passed. The exported 1.0 (6) IPA passes local signature/profile/bundle checks and contains Production CloudDocuments entitlements and four iPad orientations. Transporter delivered it at 8:29 PM India time on 9 October 2026 and Apple finished processing. Build 6 is in the internal Orbit Bloom QA group with one invited owner tester. **The app and six purchase products were submitted at 8:42 PM; all seven items show Waiting for Review.** Submission ID: d585e8f9-f825-4020-9661-6421068d7038. [Apple confirmation](release-draft/build6/apple-review-submission.jpg) and [package verification](release-draft/build6/signed-package-verification.json) record the evidence. Manual public release remains selected; no public release occurred.

The current App Store description/review notes and Game Center checkbox were saved. Privacy/support updates were deployed to the isolated existing Cloudflare Worker and the live privacy page was verified in Chrome. Apple's privacy declaration was already published by Ajnas N B when work resumed. Ten iPhone and nine iPad screenshots are now uploaded and included in the submission. The first Apple validation found eight interrupted iPhone uploads; replacing the set from original files and allowing uploads to finish cleared the error. Native iPad landscape orientation was checked inside Apple's image preview. Mac and Vision Pro distribution opt-outs were verified on the saved pricing page. No new code changed after the 60 passing checks, so the submission run did not duplicate those tests.

Build 6 was installed normally over Orbit Bloom QA (64173F47-C4DC-46B4-82EC-0027675F7780), without reset arguments. All preferences were exactly equal after installation. Normal launch retained the full garden wallet after normalizing only natural life-clock metadata and enum dictionary ordering. evidence/build6-preview-preservation.txt records this check. Only the user's preview simulator remains booted; the unused Store QA and iPad QA devices are stopped.

VoiceOver, larger text, smaller iPad and older iOS coverage, physical audio/haptics, human difficulty, consumable refund policy and live cloud/purchase integration remain release limitations. No real purchases or new legal/financial agreements were performed. Historical reports below apply only to their own builds.

---

# Orbit Bloom build 5 verification — 9 October 2026

**46 unique tests pass across the verified runs: 25 core checks, 13 native checks, seven existing UI flows and one new iPad release layout check.** The core suite was refreshed in this store-preparation run with 25 passes; the focused shop flow also passed again with six product screenshots. The prior combined native/UI evidence remains the source for the unchanged model and purchase flows. Build 5 introduces a bright SceneKit island, 102 horizontally swiped pages with ten sequential stops each, in-scene Farm/Rally gates, and swipe pages for crafting, field tasks, patterns and supplies. The game pages fit without vertical scrolling or a permanent activity tab bar. Native island meshes animate trees and clouds; board/farm art remains rendered bitmap sprites. The 1,020 stops have unique generated names across twelve biome families, not 1,020 individually authored 3D environments.

| Area | Passing cases | Evidence |
| --- | ---: | --- |
| Core rules, power patterns, economy, sequential unlocks and turn budgets | 25 | evidence/appstore-core-verification.log; evidence/v4-map-core-pass.log |
| Native persistence, locked-stage rejection and media | 7 | evidence/V5-FinalNative.xcresult |
| Apple local StoreKit purchase, approval, restore and refund flows | 6 | evidence/V5-FinalNative.xcresult |
| Real UI campaign, island pages, powers, journal, farm/craft, race, all six packs and water recovery | 7 | evidence/V5-FinalNative.xcresult; evidence/AppStore-PurchaseReviewRetry.xcresult |
| iPad portrait/landscape layout, navigation, all 49 tiles, tools and six farm plots | 1 | evidence/AppStore-IPadFullScreen.xcresult; 39.289 seconds |

The core solver completes all 1,020 levels and six garden projects in **6,033 legal swaps, zero retries, and no paid items or extra moves**. Sixty additional seeded opening simulations cover five boards for each of the first twelve stages. The actual UI campaign wins the first twelve stages and restores all six projects using real hints, swipes, inventory tools and earned bursts, in 310.039 seconds. This is reachability and regression evidence, not a claim that 1,020 levels were manually played or that human difficulty is calibrated. Turns are now 10–20; the generated later stages use 16–20.

Diagnostic runs found and reproduced three interaction failures. The map's empty terrain initially did not receive swipes; its full content area now does. A stale transparent blast layer remained over the next level after a victory and blocked its hinted tile; blast state now expires independently with an identity guard and clears when entering/leaving a stage. The race road intercepted the finish button; it now stops receiving input after finishing. All affected flows pass in the final combined run. Atlas crop bounds also exclude neighboring art fragments, and light appearance plus grouped shadows keep status text and labels readable.

Tests reset only the separate Store QA simulator (6D8263A8-F049-48C0-AC3D-5FCBCFD3A3C7, iOS 26.1). Build 5 was installed over Orbit Bloom QA (64173F47-C4DC-46B4-82EC-0027675F7780, iOS 26.5) without clearing data. Preferences were identical immediately after installation; progress, balances, crops, tools, assistance and saved session were preserved after normal launch. Only natural life-clock refresh and enum dictionary ordering were normalized. See evidence/v5-preview-preservation.txt. The App Store orientation update was subsequently installed over the same preview: all preferences were identical immediately after installation, and normal launch retained the saved game (160 coins), allowing only natural life-clock metadata and enum dictionary ordering. See evidence/appstore-preview-preservation.txt.

Nineteen actual build 5 screenshots were exported at native 1320 × 2868, with hashes and source attachments in release-draft/verification.json. The previous ten native medium-display captures were archived separately. Ten large-display screenshots persisted after upload/reload in Chrome; the medium class inherits those current images through Apple’s Using Existing Assets view. Current device-class status is in release-draft/app-store-screenshots.json. The website is hosted on the new isolated Cloudflare Worker at https://orbit-bloom-game-site.ajnasnb.workers.dev/; existing sites and DNS are untouched.

The App Store preparation adds the missing upside-down portrait declaration for iPad, both in the checked-in project and its generator. The corrected Release archive compiles without the previous all-orientations warning. The matching App Store distribution profile was subsequently found in Documents and installed. Manual signing, Release archive and IPA export succeeded (evidence/appstore-signed-archive.log and evidence/appstore-signed-export.log). The package signature, bundle/version/build and four iPad orientations passed local checks. Transporter delivered build 1.0 (5) at 15:25 Asia/Kolkata; Apple processed it and TestFlight reports Ready to Submit. This is upload evidence, not App Review approval or a signed sandbox purchase test. See release-draft/signed-package-verification.json.

The iPad Pro 13-inch (iOS 26.1) release test launches with --keep-progress, avoiding save resets, and asserts real rotation, visible bounds and hittability for all 49 board tiles, pause/tools, all six farm plots and home/farm/craft/rally/shop navigation. Six native portrait captures at 2064 × 2752 are ready for Apple. Two full-screen landscape QA captures retain native orientation 8 metadata and render at 2752 × 2064; they are not falsely described as differently encoded pixels. The initial app-region landscape screenshots had a cropped frame/orientation mismatch; replacing that capture with XCUIScreen.main and repeating the affected test produced correct full-screen images. This checks the large iPad layout, not every iPad model or actual landscape puzzle wins.

The first purchase screenshot attempt failed during accessibility bootstrap before executing assertions. After recovering the dedicated test device, the same targeted shop flow passed (44.282 seconds) and captured all six actual packs. A temporary Apple upload error for the 3,000-coin screenshot was retried successfully. After Chrome reconnected, all six purchase review screenshots and notes were saved and verified, and Apple added them to one draft as Ready for Review. Six native portrait iPad screenshots uploaded and rendered; final reload verification is pending. Free app pricing and 173-region availability were configured, excluding China mainland and Vietnam without their required game licenses. Categories, subtitle, content rights, age rating and saved privacy answers are complete; privacy publication awaits the owner’s agreement confirmation. Payment agreements, bank/tax setup and trader compliance show Active and were unchanged.

Orbit Bloom QA now exists as an internal TestFlight group with build 5. No testers have yet been added. The Mac locked again during release-version build selection before the owner invitation could be sent. Two unused booted simulators were shut down without erasing their data; the user’s Orbit Bloom preview and the simulator used by another active game chat were preserved. No gameplay code changed during this signing/upload continuation, so the existing 46-case verification remains the applicable test evidence.

No real purchases, new agreements, App Review submission or public app release were performed. Physical devices, signed sandbox transactions, VoiceOver, larger text, smaller iPad and older iOS layouts, audio/haptics on hardware, human difficulty and production purchase recovery remain release checks. Historical reports below describe their own builds and must not be read as current screenshot or hosting status.

---

# Orbit Bloom verification — 9 October 2026

**Build 4: 42 unique cases passed across the full run and focused reruns.** Puzzle water now commits with the resolved board before match animations. The regression reproduced a saved balance of 12 rather than 16 before the fix. With the fix, model recreation during animation retains all four dewdrops, animation completion does not duplicate them, and the real UI can reopen Farm at 16 water and plant a rose to reach 14.

| Area | Passing unique cases | Current evidence |
| --- | ---: | --- |
| Core rules, 1,020-stage reachability, economy and power patterns | 24 | evidence/daily-20261009-verified.log |
| Native sessions, interrupted rewards, water durability, bundled media | 6 | evidence/Daily-20261009-PurchasesVerified.xcresult |
| Local Apple StoreKit transactions, approvals, restore and refunds | 6 | evidence/Daily-20261009-PurchasesVerified.xcresult |
| Actual UI: power formation/shuffle, farm/craft, race, tools/shop, water/reopen/plant | 5 | evidence/Native-20261009-100310.xcresult |
| Twelve-stage swipe campaign and six ordered world restorations | 1 | evidence/Daily-20261009-CampaignVerified.xcresult; 429.620 seconds |

The initial combined native run had three failures: two purchase assertions read asynchronous entitlements too early, and the campaign had a Hint press that did not produce its instruction. Purchase tests now wait up to five seconds for the expected entitlement and all twelve native cases pass. The unchanged campaign passed in isolation without other UI automation running. This is passing coverage across multiple runs, not a claim that the first combined run was wholly green. Failed diagnostics remain local and are excluded from the passing manifest.

All resetting UI tests ran on the separate Orbit Bloom Store QA device (6D8263A8-F049-48C0-AC3D-5FCBCFD3A3C7, iOS 26.1). Build 4 was installed over the user's Orbit Bloom QA preview (64173F47-C4DC-46B4-82EC-0027675F7780, iOS 26.5). Its preferences were backed up and progress, session, assistance, crops, resources and tools were verified preserved; enum-key tool dictionaries were compared without depending on serialization order.

The new farm meters have grouped resource labels for accessibility. The release gallery adds the actual build 4 water-to-farm capture at 1320 × 2868, without resizing. Existing sixteen build 3 screenshots remain valid visual references. Ten selected native iPhone medium-display screenshots were uploaded to the App Store draft through Chrome, retained after reload, and displayed rendered thumbnails. Build 4 review notes also persisted after reload. No review or public-release action was performed.

The distribution archive attempt still reports no signed-in Xcode account and no provisioning profile for com.orbitbloom.game. No signed archive, validation or TestFlight upload was produced. Cloudflare's existing authenticator challenge remains unresolved. No purchases or legal agreements were accepted.

Physical-device testing, signed sandbox transactions, VoiceOver, larger text, iPad layout, older iOS versions and production save recovery remain release work. The all-stage solver checks reachability; it does not establish human difficulty or mean that all 1,020 stages were played in the UI.

---

# Orbit Bloom verification — 8 October 2026

**40 unique tests passed across the verified rules, native session, local StoreKit and targeted UI runs.** The first twelve stages and all six restoration projects were completed through actual simulator interactions. All 1,020 stages were completed separately by the rules solver. This does not mean all 1,020 stages were played through the UI or that the app has passed App Review.

| Verified area | Passing unique tests | Evidence |
| --- | ---: | --- |
| Swift rules, economy and powers | 24 | evidence/v3-core-verified.log; GitHub Core game rules CI for b8a2efe |
| Native save, hint migration, atomic grants, interruption recovery, bundled media | 5 | evidence/V3SwipeFixed.xcresult; refreshed with release materials |
| Apple local purchase flows | 6 | evidence/V3ApplePurchases.xcresult; evidence/v3-apple-purchases.log |
| Actual swipe campaign and six restorations | 1 | evidence/V3SwipeFixed.xcresult, 393.208 seconds |
| Farm, harvesting, task claim, craft and relaunch | 1 | evidence/V3SwipeFixed.xcresult |
| Pause, tool use, durable puzzle and Shop-to-Farm navigation | 1 | evidence/V3SwipeFixed.xcresult |
| Swipe steering, delivery reward and return navigation | 1 | evidence/V3RaceVerified.xcresult |
| On-board power formation, animated shuffle preservation and detonation | 1 | evidence/V3BoardPower.xcresult |

These results span several focused runs. The common UI run caught a race finish-button failure; the finish card was moved outside the steering gesture and that entire race flow then passed. Earlier diagnostic runs also caught vertical drags scrolling the puzzle page. Page scrolling now locks while a tile is held, and the campaign test asserts that every hinted swipe spends exactly one turn. Diagnostic failures are not counted as passing evidence.

## Gameplay and economy

The core campaign solver completed all 1,020 stages and six projects in **6,068 legal swaps, zero retries, and no paid items or extra moves**. This is a reachability check, not a human difficulty rating. Twelve opening stages are authored; 1,008 later stages use deterministic generated goals and boards.

The native UI campaign uses public hints, real horizontal/vertical drags, supplied inventory tools and earned cross bursts. It does not inject completed stages, grant stars or bypass victory checks. It verifies early relaunch persistence, twelve victories and six ordered restoration purchases with earned stars.

Additional checks cover fixed power formations, chained blasts consuming powers once, power persistence through saves/shuffles, first ten free hints, paid assistance, one-time field rewards, 30-minute life boundaries, non-expiring reserve lives, offline crop growth, compost crafting, cargo delivery and reward idempotency.

## Purchase verification

Six tests pass on **iOS 26.1** using Apple's local StoreKit test service: verified 400-coin credits without duplicate recovery, extra-life and starter-bundle grants with durable restore, cancellation, pending Ask to Buy approval, non-consumable purchase/restore, and asynchronous refund revocation of the legacy cosmetic entitlement. They use real StoreKit APIs with local test transactions and charge no money.

The iOS 26.5 runtime cannot reliably load the local catalogue, so it is used for gameplay/UI testing while iOS 26.1 handles purchase verification. Signed sandbox/device purchases are still required before release. Production consumable recovery/refund policy remains release work; the passing legacy cosmetic refund test does not establish consumable clawback behavior.

## Visual and web checks

Native screenshots are exported from actual runs at **1206 × 2622** without fabricating device dimensions. See release-draft/README.md for the gallery and selected ten App Store screenshots. Home, puzzle, on-board power, field tasks and race completion were visually inspected. The art consists of original rendered bitmap sprites, not interactive 3D meshes.

The standalone website was inspected in Chrome at its default desktop size and 390 × 844. All three bundled images loaded, horizontal overflow was absent, and the privacy page opened through navigation. JavaScript syntax and repository whitespace checks pass. Cloudflare deployment and final browser proof are blocked by the owner's authenticator verification and Mac lock; the intended subdomain is not claimed live.

## Reproduce and limits

`swift test` runs core checks. `scripts/test-ios.sh` runs core and all native checks on the separate Orbit Bloom Store QA iOS 26.1 simulator. `scripts/run-ios.sh` builds/installs the preview without clearing its save. Xcode 26.6 (17F113), Swift 6.3.3; gameplay device: iPhone 17 Pro, iOS 26.5; StoreKit device: iPhone 17 Pro Max, iOS 26.1.

Physical-device audio/haptics, VoiceOver and larger text, iPad layouts/orientations, older iOS versions, signed purchase interruptions and production save recovery remain unverified. There is no TestFlight upload, public release or App Review approval. Distribution signing requires the owner's Xcode account sign-in. Only Orbit Bloom is built; the other portfolio games remain concepts.
