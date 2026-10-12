# Orbit Bloom — build 17 gameplay and UX

The island offers eight direct illustrated activity buttons. The main play screens use pictures, numbers and familiar controls; the optional story, rules and accessibility labels retain the explanations. The loading screen still opens the saved game automatically. The former room directory is no longer a required navigation step.

New campaign attempts use rules version 3: Hard or Super hard, 10–16 moves, with twenty one-move challenges retained. Adjacent matches reveal one-hit mud diamonds, weaken two-hit ice and rope, and open three-hit seed sacks and water tubes. A cascade damages each obstacle at most once per action. Formation powers and chains remain on the board. Matching dims the courtyard, with a gentler reduced-motion treatment. Coin flights target the actual coin counter; harvests originate at the selected patch. Newly earned stars fly to the star counter.

The pre-level selector allows at most three starting powers. Confirming spends a life and consumes selected stock in the same saved checkpoint; cancelling consumes neither. First clears grow a free Bomb, TNT, Rainbow kit, capped at three. A failure or confirmed abandonment resets that streak. Replays do not grow it. Pip costs 200 earned or purchased game coins, once, and supplies one extra hint per new campaign level, once per level. One-shot stages keep stock and streak powers out of their one-move boards.

The native farm has three independently saved fields, six patches each. The second opens after three harvests or completed campaign levels; the third after nine. Horizontal swipes change fields; the shed has its own button. Apples and roses grow from saved deadlines while away, remain their planted species when watered, and harvest with a sickle animation. Rapid repeat harvest taps cannot silently replant. The existing six patches retain their IDs and data; additional patches are optional until first used.

Rally fills the play surface with a rover, logs, cones and rocks, three graphical lane cues and compact shield/time/coin controls. It starts at tier 3, tightens after three and six successful deliveries, and caps at tier 5. Later rows can block two lanes while preserving a coin lane. Pause freezes the route; vertical swipes do not steer.

Sky Shuttle adds 1,000 seeded seating challenges. Twelve illustrated travellers need the correct upper/lower deck, window/front seats and adjacent companions. Tickets define the rules; there is always a valid plan. Placement and incorrect departure checks have finite move budgets. A first sequential win pays one star, 25 coins and two water, once. Its record saves with the garden; the existing Apple leaderboard continues to use the four original skill activities. The new activity has no puzzle-life charge.

Firefly answers visibly light the tapped lantern and fill progress dots. Canal budgets, Windmill timing and Observatory move limits are tighter. Help, pause, restart, exit, VoiceOver names and a reduced-motion path remain available.

## Save and payment compatibility

Active rules-1 and rules-2 puzzles keep their original board IDs, goals and turn budgets. Schema-4 private Apple saves hold new obstacles, momentum, fields and shuttle progress. Older clients reject that format instead of dropping new progress; use the same updated build on devices sharing a garden. Local and cloud validation rejects malformed slots, hit counts, dates, foreign accounts and missing credited purchase receipts. No publisher player-save database was introduced.

The six Apple products and their price configuration are unchanged. Simulator StoreKit checks cover credits, cancellation, pending approval, refunds and duplicate recovery. These tests do not establish physical Game Center, iCloud or signed sandbox behavior. No real purchase was made. Apple review approval is an external outcome; a submitted build is not an approved or publicly released app.

## Verification policy

Resetting tests are restricted to Store QA `6D8263A8-F049-48C0-AC3D-5FCBCFD3A3C7`. The iPad tour retains its save. The personal preview `64173F47-C4DC-46B4-82EC-0027675F7780` receives an ordinary update and a complete wallet comparison, preserving concurrent play. Unit and UI runs are separate so current Xcode retains usable reports and screenshots. Release evidence and exact source/package hashes live in `release-draft/build17`.
