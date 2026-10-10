# Difficulty and puzzle exit — build 9

The puzzle header has a visible Back arrow beside Pause. Both lead to a confirmation before abandoning. Keep playing returns to the same board and move count; pausing or closing the app preserves the active attempt. Restart has a separate confirmation because it starts another paid-in-lives attempt.

One life is spent when a puzzle starts. Abandon keeps that life spent and clears the active puzzle; it does not charge a second life. Victory returns it. Restart spends one more life only after confirmation. Completed stages, farm state, coins, tools and credited purchases stay in the wallet. The exit target is at least 44 points, with a descriptive accessibility label and hint. The confirmation wraps the whole explanation and uses the existing light botanical palette.

| Priority | Previous behavior | Player impact | Build 9 change |
| --- | --- | --- | --- |
| P2 | Leaving was only inside Pause and happened immediately. | The route back and its already-spent life were unclear. | Visible Back, separate abandon/restart explanations and a cancel action. |
| P2 | Later generated stages repeated similar budgets with no challenge labels. | Difficulty progression and recovery stages were difficult to understand. | Named Simple, Hard, Super hard and One shot badges on the island and puzzle, with tighter later bands. |

## Campaign rules

There are still 1,020 sequential stages on 102 swipeable island pages. The opening twelve keep their established goals and 10–20 move budgets: stages 1–6 are Simple, 7–8 Hard and 9–12 Super hard. These labels describe relative challenge; they are not measured human difficulty ratings.

From stage 13, every ten-stop page mixes five Simple, three Hard and two Super hard stages. Generated normal budgets range from 10 to 20 moves. The same rhythm tightens in 200-stage bands: moves decrease while resource goals, score target and frost increase. Easier recovery stops remain between challenges rather than making every successive stage harder than the previous one.

One shot replaces stage 30 and then every 50th stage after it, through 980: twenty ultra-super-hard challenges. Each gives one move, one five-piece resource goal, eight frozen patches and a 150-point target. Five goal colors and four board rotations make twenty combinations. The board has no initial matches or powers and includes a valid winning swipe without any paid assistance. Invalid swaps do not spend the move. A legal wrong move can lose the attempt.

Hints remain available under the usual first-ten-free/earned-coin rules. Tools, charged bursts, shuffles and extra moves cannot bypass the one-move challenge; attempting those actions preserves inventory and currency. This is the assumed interpretation of the user's “one shot” request. Human playtesting should determine whether its cadence and challenge are enjoyable.

## Existing saves

New active snapshots record rules version 2. Snapshots from older builds, which have no rules marker, load the exact legacy goals, frost and move budgets and then explicitly record version 1. Updating cannot reinterpret an in-progress old stage 30 or 80 as a new one-move puzzle. Unknown rule versions are rejected rather than guessed.

Cloud saves containing an active version-2 puzzle use envelope schema 2. Current clients accept legacy schema 1 and schema 2; an older client that supports only schema 1 rejects the new active puzzle rather than loading it with legacy rules. A schema-1 envelope falsely containing version-2 rules is rejected. Apple GameKit/private iCloud remains the cloud service, and existing player isolation and purchase-receipt protections still apply.

## Verification scope

Core checks cover the difficulty rhythm, every one-shot variant at three seeds, real winning swaps, invalid swaps, a losing move, blocked assistance and legacy/future save rules. The all-stage solver checks reachability without paid tools or extra moves. Native tests check abandon/relaunch/restart life accounting and unchanged one-shot inventory. Real UI swipes cover the one-shot win, difficulty labels and return to the island; touch checks cover cancel, abandon and restart. The stage-30 UI test uses a Debug-only stage-selection fixture to set up its prior progression. It does not pretend to have played the preceding 29 stages. Production builds exclude that fixture.

Exact final counts, device results, preview-save comparison and native capture provenance are recorded in [TEST_REPORT.md](TEST_REPORT.md) and [build 9 verification](release-draft/build9/verification.json). Live Apple cloud/signed sandbox purchases, VoiceOver speech, extreme text sizes, smaller devices and human difficulty remain outside these simulator checks.

The focused mobile skill scan examined 56 files and reported P0=0, P1=21, P2=7 and P3=0 (`evidence/build9-mobile-static-scan.txt`). These are heuristic signals, including research code and images already explicitly hidden from accessibility. The new confirmation's heart is decorative and hidden; only its background ignores the safe area. This targeted change does not establish app-wide accessibility conformance.
