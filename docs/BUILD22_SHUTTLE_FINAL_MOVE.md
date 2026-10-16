# Build 22: a final seat still gets its ticket check

Sky Shuttle previously marked an attempt lost as soon as its placement counter reached the limit. Even a correct twelve-passenger plan seated on the final move could not use Depart. The old-source regression fails nine assertions across challenges 1, 20 and 1,000: the complete plan is prematurely finished, departure fails and no win is recorded. The original output is retained in `evidence/build22-last-seat-reproduction.log`.

A full, unchecked plan at zero moves now remains available for its departure check. Seat moves stop at zero in both the engine and interface. A correct plan wins; an incorrect final check ends the attempt. An incomplete plan still loses when its placement budget is used. Wrong checks are capped at the move limit, and the existing correction opportunities before zero remain available. Challenge budgets, ticket constraints, rewards and save schema are unchanged.

The zero-move counter changes to a checkered flag. Its accessibility value explains that everyone is seated and Depart checks the final plan; the departure hint explains the wrong-plan outcome. Existing short text and illustrated passengers remain.

Core coverage checks ordinary and final-move solutions across all 1,000 seeded Shuttle challenges. Separate boundaries cover wrong final plans, incomplete plans, blocked extra placements, repeated checks and terminal wins. The native case finishes a real final-move run, verifies its single shared garden reward and reopens the saved wallet. Real-input phone flows verify the final-seat win at maximum text and the existing five-game restoration loop.

[Delivery record, actual test results, original screenshots, preserved preview and Apple status](release-draft/build22/README.md) distinguish local checks from server validation. Physical Apple/iCloud synchronization, signed sandbox purchases, actual VoiceOver timing and human difficulty remain device checks.
