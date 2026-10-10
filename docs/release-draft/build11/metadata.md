# Orbit Bloom — version 1.0, build 11 metadata draft

**Status:** version 1.0, build 11 was submitted for actual App Review on 10 October 2026 at 16:47 India time. [Submission 83b00d39-0873-4771-8bc9-5d94d4be04b4](https://appstoreconnect.apple.com/apps/6820591529/distribution/reviewsubmissions/details/83b00d39-0873-4771-8bc9-5d94d4be04b4) contains the app, all six established purchase products and Atoll Skills; all eight are Waiting for Review. The saved subtitle, promotional text, description, keywords and review notes below are submitted with ten processed iPhone and ten processed iPad screenshots. Public release remains manual and has not occurred. Signed build 11 is assigned to the existing internal TestFlight QA group.

## Product page fields

**Name:** Orbit Bloom: Garden Arcade

**Subtitle:** Seven games. One living island

**Promotional text:**

Meet Lio and rebuild Aurora Atoll. Swipe puzzles, grow crops, race a new rover and explore four skill rooms. Optional world events, Apple saves and rankings.

**Keywords:**

puzzle,farm,racing,flowers,space,offline,craft,rover,harvest,tnt,memory,logic,stars,garden,casual

**Support URL:** https://orbit-bloom-game-site.ajnasnb.workers.dev/support/

**Privacy URL:** https://orbit-bloom-game-site.ajnasnb.workers.dev/privacy/

**Marketing URL:** https://orbit-bloom-game-site.ajnasnb.workers.dev/

**Category:** retain the established Games / Puzzle / Simulation configuration.

**Description:**

Seven games. One island to bring back to life.

Meet Lio, a keeper apprentice rebuilding Aurora Atoll after the Great Eclipse. Restore its gardens, reconnect its waterways and bring light back to the homes. Choose a room, learn a skill and help your little world grow.

BLOOM CIRCUITS
Swipe neighboring flowers, leaves, apples, dewdrops and diamonds to match three, or tap touching groups. Grow Bomb, TNT, Mega Bomb and Rainbow powers from formations and trigger chains on the board. Clear frost across 1,020 sequential campaign stages. Normal puzzles have 10–20 turns, with Simple, Hard and Super hard challenges. Twenty One shot stages give you one winning move to find.

FARM TERRACES
Plant roses and apples in six saved plots. Water, harvest and craft tools in the shed. Crops grow while you are away. Your harvest produces coins, compost and cargo for the other rooms.

HARVEST RALLY
Drive a new illustrated delivery rover through three lanes. Swipe left or right, dodge striped barriers and collect coins. Finish a 22-second, 440-metre route with your shield intact. Traffic tightens through five tiers as successful deliveries accumulate, and farm cargo adds a delivery bonus.

FOUR MORE WAYS TO HELP
Canal Weave: rotate pipes to carry water to the terraces.
Firefly Trail: watch numbered lanterns and repeat their signals.
Windmill Works: time each charge to power Lio’s workshop.
Moon Observatory: swipe numbered star tiles into an ordered chart.

Each of these four rooms offers up to 1,000 procedural challenges. A first clear earns one star, 25 coins and two farm water. Their completed results and personal bests stay with your garden. Unfinished attempts in these four rooms are discarded when you leave or close the app.

A WORLD THAT GROWS
Explore 102 horizontally swipeable island pages, with ten ordered campaign stops on each. Spend earned stars on six restoration projects. Labeled doors and a seven-room directory help you choose an activity and find your way back. Enjoy original 3D scenery, dimensional botanical artwork, Lio’s portrait, animated coin collections, music and action sounds.

OPTIONAL WORLD EVENTS
Shared UTC schedules automatically feature skill workshops, harvest fairs and delivery convoys. Complete the featured goal and collect a tool before its window ends. Event bonuses need a recent online clock check; normal rooms remain available offline.

PLAY AT YOUR PACE
Your first ten hints and three shuffles are free. Earn more through permanent field tasks or spend game coins. Five normal puzzle lives regenerate one every 30 minutes. Starting a puzzle spends a life; abandoning keeps it spent, and winning returns one. The other six rooms use no puzzle lives.

Optional Apple in-app purchases provide coins, non-expiring extra lives and a one-time First Bloom bundle. Prices come from Apple. Coins, lives and purchases add no leaderboard points.

Play as a guest or connect Game Center in Settings > Player & saved garden. Optional private iCloud backup includes completed activity progress, puzzle saves, farm, coins, lives and tools. Use the same Game Center and iCloud accounts with iCloud Drive enabled, and check your latest backup before changing devices. When saves differ, choose which garden to continue. Guest saves stay on your device and can be lost if the app is deleted.

Room records show your four skill-room personal bests. Connected players can compare the combined Atoll Skills score through Game Center. Music, effects and haptics can be adjusted separately. No ads or analytics.

## App Review notes

No login is required for guest play or Apple purchases. Startup opens the island after a short loading screen. Build 11 connects seven activities through one garden economy.

From the island, tap Explore 7 rooms, read Lio’s Atoll and tap Choose a room. Swipe to the room doors. Large text separates the story and restoration checkpoint: Your project, then Rooms. All rooms have a visible exit. Direct Farm/Rally doors, the field-task book, World events globe and Room records trophy remain on the island.

Bloom Circuits: tap the campaign action and swipe neighboring pieces to match three, or tap touching groups. Four in a line creates Bomb; L/T creates TNT; a seven-piece cross creates Mega Bomb; five in a line creates Rainbow. Tap powers to detonate and chain nearby blasts. The campaign has 1,020 sequential stages on 102 swipe pages. Normal budgets are 10–20 turns; twenty One shot stages start at level 30 and recur every 50 through 980. One shot has a free winning swipe, allows hints and blocks tools, shuffles, bursts and extra moves.

Starting a puzzle spends one life. Back/Pause offers an abandon confirmation; abandoning keeps that life spent without charging a second. Cancel keeps the board. Restart explains its new attempt cost. Winning returns a normal life. Five normal lives regenerate one every 30 minutes. Purchased reserve lives do not expire. Farm, Rally and the four skill rooms have no life cost.

Farm: plant, water and harvest six plots; swipe or tap into the tool shed. Harvest supplies coins, compost and cargo. Rally: swipe horizontally on the road to steer; vertical swipes do not steer. Finish 440 metres in 22 seconds with shield remaining. Every three successful deliveries advances traffic, capped at tier 5. Pickups animate toward the run coin counter; the completed run credits the wallet, with a cargo bonus when produce is available.

Canal Weave rotates pipes from the west inlet at top-left to the east outlet at bottom-right. Firefly Trail demonstrates numbered lantern signals before accepting the same sequence. Windmill Works starts a timer, then accepts charges inside the marked wedge; VoiceOver offers guided timing. Moon Observatory moves adjacent numbered star tiles into the gap to order the chart. Each supports up to 1,000 seeded procedural challenges. Save result & return credits each new sequential win once: one star, 25 coins and two water. Unfinished attempts in these four rooms are not persisted; exit/closing instructions explain this. Two earned stars fund each ordered restoration project.

World events use public HTTPS server time from our isolated Cloudflare /api/events endpoint. Skills rotate every 6 hours with 3 active hours; harvest runs daily for 8 hours; Rally runs every 48 hours for 6 hours. Three new featured skill clears, three harvests or three successful deliveries earn the stated tool. Collect during the active window; duplicate claims are blocked. A trusted clock check lasts at most 15 minutes. Normal activities work offline. This endpoint accepts no player saves, credentials or purchase data from the app.

Settings > Player & saved garden offers optional Game Center authentication and private GameKit/iCloud Drive backup, with explicit saved-garden choices. Use your own Game Center/iCloud accounts and enable iCloud Drive; no developer credentials are needed. Completed skill progression, records and current event receipts are in schema-3 saves alongside the existing wallet. Account matching and receipts protect restores; active games block restore. Room records submits four personal bests for the authenticated wallet; purchases add no points. These non-prize client scores have no server anti-cheat.

The six existing StoreKit products remain: four consumable coin packs, one consumable 5-life pack, and one non-consumable starter bundle. Transactions credit durably and idempotently. Restore checks non-consumable ownership. No ads, analytics or publisher player-save database.

## Screenshots and release verification

Use genuine captures from the matching verified build, covering Lio/rooms, Bloom gameplay and powers, Farm, Rally with the new rover, all four new skill games, event/record pages, supplies and saved-garden settings. Select up to ten distinct captures per supported iPhone/iPad gallery; additional proof can remain in the release evidence. Artwork is separate from gameplay screenshots. Do not claim a completed live Apple save, purchase or leaderboard check based only on simulator captures.

Final source/package identity, 107 unique passing core/native/UI cases, 20 matching gallery screenshots, Cloudflare public clock acceptance, Apple leaderboard configuration and App Review submission are recorded in verification.json. Physical Apple authentication, iCloud round trips, signed sandbox payments and live leaderboard submissions remain unverified and are explicitly separate from simulator evidence.
