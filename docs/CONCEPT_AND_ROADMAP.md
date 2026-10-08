# Four mobile game concepts and first release scope

Orbit Bloom is the first playable build: a calm, native iOS match-3 adventure that connects resource gathering to restoring a botanical moon. The initial portfolio has two restoration puzzle games and two distinct shooters. Only Orbit Bloom is implemented in this workspace; the other three are product concepts.

| Game | Core play | Additional aspects | Proposed purchase | Status |
| --- | --- | --- | --- | --- |
| Orbit Bloom | Swap botanical pieces to match three | Resource goals, frozen patches, cascades, garden restoration, three campaign biomes | One-time cosmetic Aurora Nights atmosphere | Native playable 12-level chapter |
| Tidal Terraces | Water-channel and match puzzles | Restore coastal gardens, tide states, habitat choices, rescued creatures | A substantial optional island expansion | Concept; build after feedback on Orbit Bloom |
| Comet Courier | One-finger vertical space shooter | Cargo routes, rescue missions, ship equipment, distinct bosses | Permanent expansion with new routes and ships | Concept; open-source candidate requires full asset audit |
| Seedguard | Top-down auto-fire shooter | Protect botanical domes, choose defensive plants, day/night enemies, wave survival | Permanent biome pack and cosmetic ships | Concept; procedural native art preferred |

These products should have distinct mechanics and content. A recolor of one app under multiple bundle IDs would create a weak product and review risk under Apple's [guideline 4.3](https://developer.apple.com/app-store/review/guidelines/#spam). Commercial games named by the user are genre references only; their code, names, characters, music, and visual identity are not reused. The reference “Redticket” has not been conclusively identified and was not treated as a source asset.

## Orbit Bloom loop

First launch introduces the moon garden without login or permissions. The player starts a puzzle, swaps neighboring pieces, reaches resource and score goals, and earns one restoration star for the first win. Two stars restore one garden project. Six projects and twelve puzzles complete the chapter. Replays retain best scores and give a small coin reward. Hints, shuffling, retries, and the entire chapter are free.

The current restoration scene uses one original illustration. Fog, saturation, and completion markers change as projects are restored. The biomes have different level names, targets, and frost quantities but share one piece set and one garden illustration. Separate fully modeled biome environments, branching decoration choices, character story scenes, and a large campaign are later production work.

## Next content milestones

1. Evaluate the playable chapter on physical iPhones and collect feedback on swaps, readability, and puzzle difficulty.
2. Tune the free burst economy and level seeds; the automated solver verifies reachability, not human difficulty or long-term engagement.
3. Add a second illustrated environment, more substantial visible construction changes, short story beats, and a broader authored level set.
4. Complete TestFlight validation and the App Store setup described in `APP_STORE_PREPARATION.md`.
5. Start Comet Courier with one complete boss route, then develop the second puzzle game and the mechanically different Seedguard.

## Shooter research candidates

[Space Shooter by M4rdine](https://github.com/M4rdine/space-shooter-godot-game) advertises an MIT source license, five-minute runs, weapon evolutions, and bosses. Its own README separates CC0 Kenney art from audio and fonts that need item-level review. It is a candidate, not a commercially cleared bundle.

[Stellar Vortex](https://github.com/UnusualTitan711x/Stellar-Vortex) advertises MIT source and a boss encounter, but its Kenney assets and Pixabay soundtrack have separate provenance. It is a second candidate; do not ship its music without reviewing the actual asset terms. Neither candidate is downloaded into or incorporated into the first game.

A strict MIT requirement applies to copied source code. Asset terms are checked independently. Original procedural visuals and synthesized audio can avoid uncertainty; CC0 artwork is commercially reusable when its actual provenance is verified, though it is not MIT.
