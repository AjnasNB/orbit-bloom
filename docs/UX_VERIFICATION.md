# Orbit Bloom mobile flow verification

Orbit Bloom targets casual iPhone and iPad players who want a short, calm puzzle and a visible restoration reward. The first native build uses a dark teal space setting, warm illustrated garden art, distinct botanical piece silhouettes, and a simple three-destination structure.

## Screen and flow map

First launch → short garden introduction → Garden → Play puzzle → real match/cascade → resource and score completion → Victory → Garden → restoration project.

Garden, Journey, and Shop remain available outside a puzzle. A puzzle has pause/help, resume, restart, and an explicitly labeled leave action. Settings contains sound, haptics, instructions, privacy, licenses, and a confirmed local reset. There is no account or permission gate. Backgrounding saves the current resolved board before its cascade animation finishes.

## Findings and fixes

| Severity | Flow | Evidence | Fix or remaining work |
| --- | --- | --- | --- |
| P1 resolved | Victory → next level | Simulator UI automation treated reward pills as separate alerts | Removed inherited modal traits, contained the result group, and hid the underlying puzzle from accessibility while the result is visible |
| P1 resolved | Selecting puzzle pieces | First simulator AX inspection showed the board's identifier on every piece | Removed the parent identifier; each piece now exposes its own stable tile identifier, shape name, row, column, and frozen state |
| P2 resolved | Home header | iPhone simulator screenshot showed the brand wrapping | Kept the brand on one line with calibrated size and a modest minimum scale factor |
| P1 remaining | Purchase verification | Installed iOS 26.5 local StoreKit service logs SKInternalErrorDomain 3 and cannot load the configured product | Live/sandbox purchase, pending approval, refund, and restore tests must run on a working runtime or signed device before release |
| P2 remaining | Large text and physical device accessibility | Native AX labels were inspected, but a full VoiceOver and accessibility-size walkthrough has not been completed | Test physical iPhone VoiceOver, large text, contrast, older supported OS versions, and iPad layout before TestFlight release |

## Interaction and platform checks

The seven-column board has distinct leaf, droplet, sun, blossom, and crystal silhouettes, so matching does not depend on color alone. Two taps provide an alternative to dragging. Puzzle pieces expose their type and position to accessibility. The observed iPhone 17 Pro layout has approximately 45-point piece targets, with larger controls for pause and tools. Phone content uses safe areas; the space backdrop alone extends behind system bars.

Hints and shuffling preserve moves and earned goals. Invalid swaps preserve the board and move count. First wins award one star; replaying a completed level cannot duplicate restoration stars. Leaving a level explicitly discards that puzzle while retaining earned garden progress. All retries are free, with no energy timer, ads, forced purchase, or subscription.

Reduce Motion disables piece collapse/position animation and button scaling. Sound and haptics can be switched off. The app centers constrained-width content on larger screens rather than stretching the phone board across the entire display.

The static scan is saved in `evidence/mobile-ux-scan.txt`. Its remaining image warnings include symbols explicitly marked `accessibilityHidden(true)` or grouped under labeled controls; these are heuristic signals, not verified missing-label defects. Background safe-area warnings apply to intentional decorative layers. No claim of complete accessibility certification is made.
