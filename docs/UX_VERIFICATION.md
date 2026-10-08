# Connected arcade: mobile UX verification

## Flow map

First launch → brief animated loading screen → World automatically. Five persistent destinations are World, Garden, Farm, Race and Shop. World starts the next circuit and shows six restoration projects. Circuits earn stars and farming water; Farm produces coins, compost and cargo; crafting supplies circuit tools; Race converts a delivered cargo run into shared coins. No account or permission gate is present.

Circuit entry spends one normal life or an extra-life reserve item. Pause exposes resume, restart with an explicit life cost, and leave. A win returns one normal life. Five normal lives regenerate one every 30 minutes, with elapsed time preserved offline. Farm and Race remain playable without lives. Shop shows the life timer, a coin-funded refill, Apple coin/life packs, the one-time starter bonus, and Restore purchases.

## Findings addressed

| Issue | Change |
| --- | --- |
| Flat generic pieces lacked recognizable forms | Replaced the main piece set with dimensional roses, apples, leaves, droplets and diamonds; original logo and garden art |
| A frost cell could remain isolated after useful circuit groups disappeared | Adjacent circuits melt frost; board recovery guarantees a connected group |
| Hint controls moved when instruction text appeared | Fixed-height instruction region and stable controls above the board |
| Shop scroll position carried into Farm | Shared page scroll view gets a distinct identity for each destination |
| Puzzle scroll position carried between circuits | Puzzle scroll identity resets for each stage |
| Vertical piece drags could scroll the page | Disable page scrolling while holding a piece; assert that suggested horizontal and vertical swipes spend a turn |
| Tool activation consumed a normal turn in earlier design assumptions | Native UI asserts that a bomb leaves the turn count unchanged; tool inventory is consumed instead |
| Wallet and transaction grants could diverge during interruptions | A single durable wallet blob saves balance, transaction ledger, ecosystem and board atomically |
| No cross-activity sensory feedback | Bundled action effects, mode music, particles, coin flights, harvest and collision feedback |

## Accessibility and platform behavior

Piece accessibility labels include the recognizable kind, row, column and frozen state; matching does not depend on color alone. Tap groups avoid a drag-only requirement. Navigation, plot, tool, pause and race-road controls expose stable labels/identifiers. Controls generally provide 44-point tap regions; a seven-column board uses approximately 45-point tiles on the tested iPhone 17 Pro. Reduce Motion shortens/disables large movement. Music, sound effects and haptics have separate settings, and the audio session respects silent mode and app inactivity.

Native UI tests exercise actual taps, public hints, supplied/earned tools, plot watering/harvesting, crafting, swipe steering, pause/relaunch and returning from a long Shop page to Farm. Final results and screenshots are recorded in `TEST_REPORT.md`; diagnostic runs are not treated as passing results.

Physical-device VoiceOver, accessibility text sizes, older iOS, iPad orientations and physical audio/haptic behavior still need verification. The native screenshot review does not establish full accessibility certification. Live payment completion requires signed sandbox verification before release.
