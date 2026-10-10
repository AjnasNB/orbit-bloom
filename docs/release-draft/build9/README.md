# Build 9 — confirmed exit and campaign difficulty

Tap the puzzle's Back arrow, or Pause → Back to island, then confirm Abandon. The attempt already spent one life when it started: leaving keeps it spent without charging another. Keep playing cancels the exit; restarting explains and spends the next life. The user's existing world and active puzzle are preserved through this update.

The campaign mixes Simple, Hard and Super hard stages, with tighter moves and larger goals in later bands. Twenty One shot puzzles begin at level 30 and recur every 50 levels. They allow one move and hints, and have a free winning swipe. Tools, bursts, shuffles and extra moves cannot bypass them. [Full rules, save compatibility and focused UX review](../../DIFFICULTY_AND_EXIT.md).

**76 unique tests passed:** 34 core, 30 native, 11 iPhone UI and one iPad UI. The one-shot flow was rerun after correcting singular turn labels; this is not an additional unique case. The solver completes all 1,020 stages without paid items or extra moves. Solver reachability does not establish human difficulty or mean every stage was manually played.

| Native view | Capture |
| --- | --- |
| iPhone exit explanation and cancel | [Abandon confirmation](captures/iphone-abandon-confirmation.png) |
| Stage 30 in the island | [One shot island](captures/iphone-one-shot-island.png) |
| One-move board, frost and assistance rules | [One shot puzzle](captures/iphone-one-shot-puzzle.png) |
| Victory and returned life | [One shot victory](captures/iphone-one-shot-victory.png) |
| iPad puzzle and difficulty badge | [Portrait](captures/ipad-puzzle-portrait.png) and [landscape](captures/ipad-puzzle-landscape.png) |
| iPad confirmation in landscape | [Abandon confirmation](captures/ipad-abandon-confirmation.png) |
| Preserved personal preview after normal launch | [Active level 2](proof/preview-preserved.png) |

These are actual native PNGs copied byte-for-byte. Original dimensions and orientation metadata are retained. Stage-30 captures use a Debug-only setup fixture to seed preceding completion; the test then performs an actual hinted swipe and victory. The signed Release binary excludes that fixture. iPad uses `--keep-progress`; only Store QA receives resetting tests. The user's preview is normally launched with no QA flags.

[Verification manifest](verification.json) records exact hashes, source attachments, devices, test summaries, diagnostics and the save comparison. After installation all seven preferences match exactly. After normal launch the full wallet/board still matches, with only missing legacy rules markers becoming version 1 and dictionary ordering normalized: 280 coins, one completed stage, active level 2, retained tools and hints. The full original data container remains in a local ignored backup. Store and iPad QA are stopped; the preview is running build 9.

[Signed package verification](signed-package-verification.json) pins source `fe8a7d9`, the exact exported IPA and its signature/Production cloud entitlements. Build 9 is prepared locally and **has not been delivered to TestFlight**. The existing Apple account blocker from build 8 was not re-prompted or retried. No App Review queue, Apple product-page gallery, privacy disclosure, real purchase, agreement or public release was changed. Build 7 remains the submitted release record; its review status was not freshly rechecked in this task. Live Game Center/iCloud and signed sandbox payments retain the existing physical-device checks.
