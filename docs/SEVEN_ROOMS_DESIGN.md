# Lio’s Atoll: seven connected games

Orbit Bloom is a native portrait-first garden arcade for iPhone and iPad. The player’s job is to help a keeper restore a visible island by choosing different short activities. The bright botanical palette, existing campaign map, saved garden and account options stay recognizable. The new directory makes the seven destinations explicit; it does not require account creation or a purchase before exploring.

## Findings and response

| Priority | Evidence | Player impact | Response |
| --- | --- | --- | --- |
| P1 | The island previously offered a puzzle path plus two separate activity doors, with no character or explanation of their shared purpose. | The player could understand each task but not why planting, driving and puzzles belong to the same world. | Introduce Lio, Aurora Atoll and the next actual restoration checkpoint; make earned resources visibly support that place. |
| P1 | Seven activities cannot fit as equally legible doors below the existing ten-stop campaign map. | Adding tiny gates would repeat the discovery problem fixed for Farm and Rally in build 10. | Keep the main island as the domain and add a prominent Explore 7 rooms entrance to a separate paged directory. Each room names its mechanic, rewards and entry action. |
| P2 | Scrolling menus would conflict with the game’s established horizontal island interaction. | Activities could be missed below the fold, and gameplay would resemble a web menu. | Show two rooms per horizontal page, or one at accessibility sizes and short heights. Provide a named adjustable page action for VoiceOver. |
| P2 | A generic world illustration would make different activities feel interchangeable. | The player could not recognize a destination at a glance. | Give each room an original static SceneKit miniature: flower board, farm beds, delivery road, canal, lantern trail, windmill and observatory. Clear text remains the primary explanation. |
| P1 | The initial native run showed a horizontal directory swipe changing the page and also activating the large room door beneath the finger. | Swiping could unexpectedly leave the directory and enter a game. | Page drags use a high-priority gesture so a recognized drag cancels the underlying button. Ordinary taps still enter; the same rule covers event/record action pages. Native traversal must rerun after this correction. |

Before: island → unlabeled shared story/economy → puzzle, Farm or Rally. After: island → Explore 7 rooms → Lio’s Atoll welcome and real restoration checkpoint → swipe to a named activity → play → explicit exit. The existing sequential campaign remains available directly from the island.

## Character and world

Lio is a young adult keeper apprentice: part gardener, part botanical mechanic. The Great Eclipse interrupted Aurora Atoll’s moonseed irrigation, leaving garden beds cold, lights dim and neighborhoods disconnected. Lio returns with a repaired delivery rover and the practical knowledge learned from the atoll’s keepers. He rebuilds shared gardens rather than conquering territory.

His visible domain is the island itself. Its greenhouse, moonseed beds, starlight pond, observatory, aurora grove and pollinators are the six existing ordered restoration projects. Each costs two earned stars. The welcome page uses the actual completed-project count, actual star balance and actual next project; it does not invent completed work or charge for a story scene.

Coins buy supplies, water supports crops, compost becomes tools, powers clear obstacles, and stars complete restoration projects. Each room represents a skill needed by a keeper. The story’s reward is a visible, increasingly lively place; play can be stopped without guilt or loss beyond the clearly explained puzzle-life rule.

## Seven room roles

| Room | Player action | Story purpose | Connected benefit |
| --- | --- | --- | --- |
| Bloom Circuits | Swipe botanical pieces, use formations and clear frost within the turn budget. | Warm damaged beds and recover moonseed energy. | Campaign stars, coins and farm water. |
| Farm Terraces | Plant, water and harvest six persistent plots; craft in the shed. | Reopen the greenhouse and grow supplies for the island. | Produce, compost, tools and delivery cargo. |
| Harvest Rally | Swipe between road lanes, avoid barriers and collect pickups. | Carry crops and supplies between homes. | Coins and the existing cargo delivery bonus. |
| Canal Weave | Connect a valid water route through a compact logic board. | Restore moonseed irrigation. | Earned coins and a star for a first cleared challenge. |
| Firefly Trail | Observe and reproduce a lantern sequence. | Guide pollinators and light safe paths after dusk. | Earned coins and a star for a first cleared challenge. |
| Windmill Works | Time each charge as the pointer enters a marked window; VoiceOver uses guided timing. | Bring dependable power back to the neighborhood. | Earned coins and a star for a first cleared challenge. |
| Moon Observatory | Swipe a numbered star tile toward the gap; put the spatial chart into order. | Recalibrate the moonseed network after the Eclipse. | Earned coins and a star for a first cleared challenge. |

The last four rows are implemented in the native activity views and deterministic core runs. Each new sequential challenge awards one star, 25 coins and two farm water on its first clear. Repeating or submitting an already completed challenge cannot mint another star. Each room supports 1,000 sequential challenges with increasing structure/difficulty. The directory’s enum raw values are `bloom`, `farm`, `rally`, `canal`, `fireflies`, `windmill`, and `observatory`. These remain stable if a displayed name changes. Native play and difficulty checks are recorded by the integrated release workflow rather than inferred from the directory.

This is a combination of familiar game families with a shared restoration economy and keeper story. It is not a claim that any mechanic has never existed before. Difficulty should increase through observed challenge structure, with readable goals, fair opening rounds and visible failure/retry choices. Purchases remain optional supplies with prices supplied by StoreKit; spending must not be required to understand a rule or complete the introductory activities.

## Worldwide events

The implemented schedule uses shared UTC windows with immutable event IDs, room, start/end instants, goals, tool rewards and claim receipts. `Core/IslandJourney.swift` defines three concurrent event families:

| Family | Recurrence | Active window | Goal | Tool reward |
| --- | --- | --- | --- | --- |
| Skills workshop | Every 6 hours; rotates Canal, Fireflies, Windmill and Observatory | First 3 hours, followed by a 3-hour gap | Clear 3 new challenges in the featured room | Bomb |
| Atoll harvest fair | Every UTC day | First 8 hours, followed by a 16-hour gap | Harvest 3 crops | TNT |
| Moonseed convoy | Every 48 hours from the UTC epoch | First 6 hours, followed by a 42-hour gap | Finish 3 successful deliveries | Mega bomb |

The isolated Cloudflare endpoint `/api/events` returns a schema/schedule version and HTTPS server time. A recent server anchor plus monotonic device uptime supplies event timing; editing the wall clock does not move the active window in the running session. The anchor expires after 15 minutes; the app refreshes on foregrounding and regularly while open. Event bonuses need a recent check, while normal rooms remain playable offline. No player save, player identifier or purchase data is sent to this endpoint by the application.

Windows rotate automatically, including exact start/end boundaries; expired bonuses cannot be collected. The normal room levels remain saved when an event ends. Progress is capped at three and claims are idempotent within a window. Journey progress and current event receipts travel in schema-3 Apple-managed private saves; older clients reject that envelope rather than erasing the new fields. Tests must verify rollover, duplicate claims, corrupted saves and interruption/offline behavior. This scheduling system is not server-side anti-cheat for client-generated scores.

Events are optional reasons to revisit a skill, not forced continuity. All seven rooms remain discoverable outside a featured window. No paid entry, deceptive countdown, loss of purchased supplies at expiry, or mandatory notification is part of this design. Leaderboards use authenticated Apple players and an explicitly named score; unsupported or offline states should leave local play available.

## SwiftUI implementation

`IslandHubView.swift` contains the directory and its original decorative SceneKit scenery. Its initializer is:

```swift
IslandHubView(
    stars: progress.stars,
    completedProjects: progress.restored.count,
    activityLevels: roomLevels,
    onChoose: { room in /* route to the real activity */ },
    onExit: { /* return to the island */ }
)
```

The hub does not mutate a wallet or start an activity itself. Root routing supplies actual room levels and handles entry. The existing campaign map stays the authoritative sequential-level view. Farm and Rally keep their established entry identifiers and save flows outside the directory.

The welcome uses the generated transparent `KeeperLio` asset; all seven room miniatures use original procedural geometry. Miniatures are static, not interactive maps: their native door button is the hit target. SceneKit views hide decorative geometry from accessibility, ignore touch input, cache their scene key, fit the available width/height and release the scene on dismantling. Periodic game/clock updates do not rebuild a scene whose room/restoration key is unchanged. The hub’s crossfade and pressed states respect Reduce Motion.

Interactive identifiers are `chooseIslandRoom`, `hubRoom_<rawValue>`, `hubPages`, and `exitIslandHub`. The containing view is `islandHub`; story and checkpoint are `keeperStory` and `hubRestoration`. Every door has a descriptive accessibility label, reward/life explanation and native button traits. The page status exposes next/previous named actions and an adjustable value so swiping is not the sole way to traverse the directory. At accessibility sizes the welcome splits into a story page (`keeperNextProject`) and an actual project page, rather than squeezing both into a single panel. Extra-large type/short windows show one room at a time. `ViewThatFits` can substitute a concise native door when its illustrated detail card cannot fit, keeping the mechanic visible and the complete reward/life terms in its spoken label.

`WorldEventsView.swift` shows a complete event on ordinary tall screens. Large type or short windows divide each event into timing, goal/reward, and action/status pages. The one-second timer is read by the body so start/end rollover and clock expiry do not depend on gameplay changes. Claim actions appear only for an active, completed, unclaimed bonus, and upcoming entries explain that early play does not count toward the event.

`RoomRecordsView.swift` separates the four personal records from ranking information. Large type/short windows split score and completion sections, then show the ranking explanation and Apple action on separate pages. Both sheets retain native Done buttons and adjustable page values without a vertical scroll. Before submitting the combined Atoll Skills score, the SHA-256 key of the current authenticated Apple player must match both the connected account and active wallet. Individual scores are bounded to 20,000, the total to 80,000, duplicate pending submissions are disabled, and the account identity is checked again after Apple returns. Coins and purchases add no ranking points. These are client score/account checks for non-prize rankings, not a claim of server-verified anti-cheat.

## Evidence and verification limits

The mobile-app-ux-auditor static scan before the new file inspected 56 files: P0=0, P1=21, P2=7, P3=0. These are triage signals, including research code and decorative images already hidden from accessibility, not confirmed defects or an accessibility score. The current routing, Theme, existing Farm/Rally views and save rules informed this change.

The three new directory/event/record Swift sources passed a syntax-only `swiftc -frontend -parse` check, and the integrated build compiled them natively. The first maximum-text run traversed the keeper story/project and all seven hub doors with exits in bounds, then exposed a separate activity-toolbar bounds failure. The initial normal traversal exposed the swipe/button conflict recorded above. Those failed diagnostic runs are not a passing release result; corrected-source native reruns determine final evidence.

Actual directory traversal, all seven room entry/exit flows, large text, iPad rotation, scene visibility, event rollover, reward idempotency and old-save preservation remain integration checks for the main implementation. No simulator, build, screenshots, distribution upload or purchase was started by this scoped design change. Physical VoiceOver speech, maximum Dynamic Type in very short windows, live Apple account/save/leaderboard behavior and delayed network submissions require their own evidence before release. Layout adaptation is implemented; syntax/static inspection does not prove that every viewport is free of overlap.
