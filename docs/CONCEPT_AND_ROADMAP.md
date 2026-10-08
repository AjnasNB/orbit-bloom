# Orbit Bloom and the four-game portfolio

## Delivered first: Orbit Bloom: Garden Arcade

One native iOS app connects three playable activities through a shared economy: bloom circuits, a six-plot farm and a rover delivery race. Five destinations—World, Garden, Farm, Race and Shop—make those activities easy to find. This is an original small connected arcade, not a claim of a wholly unprecedented genre.

Swipe neighboring botanical pieces to match three, or tap adjacent groups. Fixed formations create Bomb, TNT, Mega Bomb and Rainbow powers on the board, with chained blasts. The campaign has 1,020 stages: twelve authored opening stages and 1,008 generated stages; the opening funds six restoration projects. Six permanent field tasks reward tools, hints and shuffles. Frost melts when an adjacent circuit blooms. Farm roses or apples, water them, harvest produce and compost, craft more tools, then deliver cargo in a three-lane rover run. Puzzle dew supplies farming water; all activities contribute to the same wallet.

Five ordinary puzzle lives regenerate one every 30 minutes, including while closed. A win returns the life spent on entry. Purchased extra lives form a separate durable reserve. Farm and Race remain available when ordinary lives run out. Coins can be earned or bought; 100 earned coins refill normal lives. There is no forced subscription or advertising.

The art uses original dimensional botanical renders, a new orbit-and-leaf logo, an illustrated space garden and a floating robot companion. Coin flights, particles, harvest feedback, collisions, tool blasts, action sounds and looping music provide feedback. These are rendered sprites, not a fully modeled 3D world. The six restorations share one environment with completion treatments; a broader commercial campaign and distinct environments remain future work.

## Portfolio

| Game | Distinct direction | Status |
| --- | --- | --- |
| Orbit Bloom: Garden Arcade | Connected botanical circuits, farming, crafting and delivery racing | Implemented; native simulator testing and App Store draft |
| Tidal Terraces | Route water through coastal gardens, balance tides and restore habitats | Concept |
| Comet Courier | One-finger space shooter with rescue cargo, ship upgrades and bosses | Concept |
| Seedguard | Top-down botanical defense shooter with plant defenses and night waves | Concept |

The first delivery is one connected app. The other three games are not claimed to be built. Commercial titles mentioned by the user are genre references; their code, assets, names and music are not reused. “Redticket” remains unidentified.

## Source comparison and next milestones

See `V2_SYSTEMS_AND_SOURCES.md` for the full mechanic/source list and `LICENSE_AUDIT.md` for copied source and asset provenance. Match3Kit supplies MIT grid/refill primitives; the connected-group mode, native farming and delivery race are local implementations. Imported sound and music are CC0. Generated artwork is separately documented and is not described as MIT.

1. Collect hands-on feedback on circuit readability, farming pace and steering.
2. Validate signed sandbox purchases, cancellation, pending approval and restore on a device/TestFlight build.
3. Test VoiceOver, large accessibility text, physical-device audio/haptics, older iOS and iPad layouts.
4. Add distinct garden environments, stronger construction changes, more authored levels and story scenes.
5. Prototype Comet Courier with one complete boss route, then Tidal Terraces and Seedguard.

Shooter candidates previously researched include [M4rdine/space-shooter-godot-game](https://github.com/M4rdine/space-shooter-godot-game) and [UnusualTitan711x/Stellar-Vortex](https://github.com/UnusualTitan711x/Stellar-Vortex). These are candidates only: code and every asset need an item-level license audit before import. Neither is bundled in this app.
