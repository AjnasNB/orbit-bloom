# Build 21: restart decisions pause the activity

The restart confirmation used to leave skill-game timers and lantern playback running behind the sheet. A player considering a restart could lose Windmill's 24-second attempt before cancelling, or miss Firefly's demonstration while it was covered by the prompt.

The shared activity container now suspends all five skill games while a restart decision is open, through the same timer/input/playback policy used by Pause and Help. The prompt explains that play pauses. Dismissing it preserves the player's previous explicit pause state. Confirming creates a fresh attempt and resumes it. Firefly interrupts its covered demonstration safely, returning to Ready to watch so the entire signal can be replayed without a mistake charge.

The native decision sheet manages modal accessibility focus. Underlying accessibility visibility retains the existing Pause/Help policy, keeping elements stable when the popover closes. Maximum-text checks open Help after cancelling Restart in every skill game, rather than checking only the restart action.

No inventory, reward, difficulty, save schema or purchase product changed. Canal, Firefly, Windmill, Observatory and Shuttle use the same suspension condition. The existing background-app pause remains in effect.

## Reproduction

`evidence/Build21-Restart-Reproduction2.xcresult` runs the new real-input regression against the previous build-20 implementation. After starting Windmill, opening Restart and leaving the prompt open for 26 seconds, dismissing the prompt reveals the failure outcome. The case fails at the assertion that the result should still be absent. This is a reproduced player-facing timeout, not a hypothetical callback issue.

The earlier `Build21-Restart-Reproduction.xcresult` is a separate test-harness diagnostic: iOS 26.1 presented a popover with outside-tap dismissal and omitted the cancel-role button. The test was corrected to use the visible presentation. That initial failure is not counted as a second product defect.

## Verification scope

The updated real-input regression holds the prompt longer than the complete Windmill timer, cancels without losing the attempt, checks the retained time, cancels while already paused and confirms a fresh restart. A separate Firefly flow interrupts playback, dismisses Restart, replays the full demonstration and saves a win for the normal shared coins, water and star.

Existing real-input cases play and save all five skill games, restore a garden project and relaunch. Maximum-text checks open and dismiss the restart prompt in each activity, verifying that its restart action is reachable. The core and native suites retain the current campaign, wallet, cloud, farm, Rally and StoreKit regressions.

[Final results, original captures, ordinary preview preservation and Apple delivery status](release-draft/build21/README.md) are recorded separately. Physical Apple/iCloud synchronization, signed sandbox checkout, real VoiceOver timing and human difficulty remain device checks.
