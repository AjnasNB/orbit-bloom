# Build 18: one visible garden across eight activities

The home screen previously offered eight unlabeled circles and a much larger puzzle action. Players had little visible evidence that rewards from the skill games fed the same garden. Build 18 gives every activity an equally sized, named button with its live progress badge. The separate campaign action is compact. Water, seeds, compost and cargo are visible together; restoration shows stars ready out of two and completed projects out of six. Five skill-game headers show the same garden stars and water.

Lio's optional story now has eight swipeable pages explaining every activity's purpose and contribution. This is help, not a mandatory directory. Each game still opens directly from home and has its existing exit. Gameplay, prices, lives, account boundaries and save schema remain unchanged.

| Flow | Shared result |
| --- | --- |
| New Bloom clear | One restoration star, 120 coins; collected water and seeds feed the farm |
| New Canal, Firefly, Windmill, Observatory or Shuttle clear | One star, 25 coins, two water, once per sequential challenge |
| Farm harvest | Crop coins, one compost, one cargo and one replacement seed |
| Craft in the shed | Compost becomes stock powers usable in Bloom |
| Successful Rally | Collected run coins; one cargo consumed for a 40-coin delivery bonus |
| Restoration | Two earned stars fund the next ordered project, visible in the island scene |
| Life refill | Farm, Rally and other earned coins can refill normal puzzle lives |

The integration test plays all five real skill engines, restores a project, grows/harvests two test crops, crafts a bomb, completes a real Rally, uses the bomb to start a puzzle, abandons it, then verifies the same saved wallet locally and through account-matched cloud encoding. Real UI tests independently play all five skill games, verify the shared supply/star counters, restore the greenhouse and retain that result after relaunch. Purchase credits never become leaderboard points.

## UX audit

| Priority | Evidence | Change |
| --- | --- | --- |
| P1 | Eight picture-only home controls obscure which game they open | Short readable names and complete VoiceOver names, purpose, progress and reward |
| P2 | Large puzzle action visually outweighs every other activity | Equal 78-point activity targets; compact separate selected-stage control |
| P2 | Skill water/coins/stars save correctly but are hard to connect to restoration | Live home supplies, garden stars/water in skill headers, two-star project progress and eight story explanations |

Static scanning is a heuristic, not a clean accessibility audit: it also flags decorative images already hidden from accessibility, parent-labeled buttons and research code excluded from the app. Actual phone/iPad bounds, exits, maximum-text controls, story swipes and reward flows are checked in native UI tests. Hardware VoiceOver timing, Apple Game Center sign-in, private iCloud synchronization and signed sandbox purchases still require physical devices.

## Hosting and review

Wrangler attached only the previously unused `orbitbloom.cognifyr.co` hostname to the existing isolated game Worker. Canonicals, structured metadata, sitemap, robots and policy/support URLs use the custom domain. Existing app builds keep their working Workers.dev clock endpoint. Neither endpoint accepts player saves, credentials or purchase payloads. No publisher player-save database was added.

Apple's current public submission was still version 1.0/build 11, Waiting for Review, when inspected. A routine App Review Status email request was sent through Apple's official support form: **case 102994340844**. No expedited circumstances, approval or public availability were claimed. The build-18 release evidence records upload/review status separately from local tests and signing.
