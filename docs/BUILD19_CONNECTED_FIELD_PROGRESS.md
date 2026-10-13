# Build 19 — every adventure expands the farm

The shared wallet already awarded water, stars and coins from skill games, but field expansion checked only Bloom clears and harvests. A player could finish Canal, Firefly, Windmill, Observatory, Shuttle and Rally while the second field still showed a puzzle-only lock.

Farm expansion now derives its adventure count from saved Bloom first clears, all five skill-game first clears and successful Rally deliveries. Three adventure wins open field two; nine open field three. The existing alternative of three or nine harvests remains. Harvests and adventure wins have separate counters, rather than being added together. No new currency, purchase, save field or cloud schema was introduced.

Locked fields show both fractions and a short explanation. The accessibility label identifies which activities count. Planting help also points players to Bloom and skill games for water. Failed/abandoned attempts and repeated Bloom/skill results add no expansion progress. Rally still awards one delivery per successful run through its existing result flow.

The new native regression drives all five actual skill engines, combines their wins with a Bloom clear and three safe Rally runs, verifies the three/nine boundaries and planting guards, then reloads locally and through the saved-garden codec. Separate regressions retain old campaign-only and harvest-only unlocking. Real phone input completes Canal, Firefly and Windmill, opens field two without any campaign clear or harvest, plants an apple, checks field three's 3/9 lock and retains the crop after relaunch.

[Build-19 delivery](release-draft/build19/README.md) records 125 passing affected checks, fifteen original native screenshots, the ordinary preview save comparison, the signed package and explicit Apple upload limits. [Live support](https://orbitbloom.cognifyr.co/support/) describes these rules as development build 19. Use build 19 on all devices for the same field-access rules; older schema-4 builds preserve these crops/results but use their earlier unlock calculation.
