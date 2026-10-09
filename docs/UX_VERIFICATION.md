# Connected arcade: mobile UX verification

## Flow map

First launch → brief loading screen → 3D island automatically. There is no permanent activity tab bar or vertical game-page scrolling. The island has 102 horizontal pages with ten stops each. Completing a stage unlocks the next stop. Locked regions can be previewed but cannot start a puzzle. The island starts the selected open circuit, has physical farm/race gates, a book for the field journal, and the next restoration project. Circuits earn stars and farming water; Farm produces coins, compost and cargo; crafting supplies circuit tools; Race converts a delivered cargo run into shared coins. No account or permission gate is present.

Circuit entry spends one normal life or an extra-life reserve item. Pause exposes resume, restart with an explicit life cost, and leave. A win returns one normal life. Five normal lives regenerate one every 30 minutes, with elapsed time preserved offline. Farm and Race remain playable without lives. Shop shows the life timer, a coin-funded refill, Apple coin/life packs, the one-time starter bonus, and Restore purchases.

## Findings addressed

| Issue | Change |
| --- | --- |
| Flat generic pieces lacked recognizable forms | Replaced the main piece set with dimensional roses, apples, leaves, droplets and diamonds; original logo and garden art |
| A frost cell could remain isolated after useful circuit groups disappeared | Adjacent circuits melt frost; board recovery guarantees a connected group |
| Hint controls moved when instruction text appeared | Fixed-height instruction region and stable controls above the board |
| Website-like navigation and long shop lists | In-scene island gates, swipeable farm/tool-shed and seven supply pages |
| Stage transitions retained interaction state | Puzzle scene identity resets for each stage while durable model state stays intact |
| Vertical piece drags could scroll the page | No puzzle ScrollView; assert that suggested horizontal and vertical swipes spend one turn |
| Tool activation consumed a normal turn in earlier design assumptions | Native UI asserts that a bomb leaves the turn count unchanged; tool inventory is consumed instead |
| Wallet and transaction grants could diverge during interruptions | A single durable wallet blob saves balance, transaction ledger, ecosystem and board atomically |
| No cross-activity sensory feedback | Bundled action effects, mode music, particles, coin flights, harvest and collision feedback |

## Accessibility and platform behavior

Piece accessibility labels include the recognizable kind, row, column and frozen state; matching does not depend on color alone. Scene containers preserve independent level, gate and plot identifiers. The island exposes next/previous accessibility actions as alternatives to horizontal swipes. Hint-highlighted tiles have explicit rectangular touch areas. The race road stops intercepting touches once the finish card appears. Tap groups avoid a drag-only requirement. Navigation, plot, tool, pause and race-road controls expose stable labels/identifiers. Controls generally provide 44-point tap regions; a seven-column board uses approximately 45-point tiles on the tested iPhone 17 Pro. Reduce Motion shortens/disables large movement. Music, sound effects and haptics have separate settings, and the audio session respects silent mode and app inactivity.

Native UI tests exercise actual taps, public hints, supplied/earned tools, plot watering/harvesting, crafting, swipe steering, pause/relaunch and returning from swipeable supplies to Farm. Final results and screenshots are recorded in `TEST_REPORT.md`; diagnostic runs are not treated as passing results.

Physical-device VoiceOver, accessibility text sizes, older iOS, iPad orientations and physical audio/haptic behavior still need verification. The native screenshot review does not establish full accessibility certification. Live payment completion requires signed sandbox verification before release.
