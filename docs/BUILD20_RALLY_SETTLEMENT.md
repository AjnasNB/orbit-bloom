# Build 20: one Rally result, one saved reward

The previous model accepted any finished Rally result every time its completion method was called. Repeating one winning route could mint coins, spend cargo repeatedly and count enough false adventure wins to open another farm field. The race screen's existing `rewarded` flag protected its normal timer path, but the shared wallet boundary itself was unprotected.

## Reproduction and change

An old-source native reproduction completed the same winning route four times. Its balance became **1,080 instead of 400 coins**, cargo fell from three to zero instead of two, and deliveries became four instead of one. Field two opened incorrectly. Those incorrect values survived model relaunch. The original failed result remains at `evidence/Build20-Rally-Reproduction.xcresult`: one failed case and seven failed assertions. This demonstrates the model defect, not a reproduced double-payment gesture or a compromised-client exploit.

Each new `DeliveryRun` has a stable UUID. The model prepares and registers the current attempt; completion must match that registration and be finished. The model retires the attempt **before** updating coins, cargo, world-event participation or delivery progression. Repeated and reentrant callbacks are ignored. A new valid attempt can still earn its normal reward.

Leaving Rally and installing another account's wallet invalidate the registration. A superseded attempt cannot pay. Registration is transient: unfinished Rally attempts already do not survive app closure, so no save schema or persistent field changed. Existing schema-4 gardens and older active puzzle rules remain compatible.

Settlement makes one checkpoint through the existing coin-award path after cargo and progression change. The redundant second save was removed. A failed route retains its existing collected-coin salvage reward once; it spends no cargo and adds no successful delivery. Leaving an unfinished route pays nothing. No reward amounts, traffic tiers, purchase products or farm unlock thresholds changed.

## Verification

- **61 core cases:** distinct run IDs and stable IDs through value copies, plus the full campaign and existing game rules.
- **66 native cases:** duplicate and reentrant completion, one checkpoint, cargo conservation, locked fields, relaunch, abandoned/superseded/account-switched results, valid subsequent wins and crash salvage. Existing wallet, cloud and connected-game cases remain passing.
- **Four real-input phone flows:** a complete Rally route through visible guidance; exact reward/cargo checks; field two at one of three wins; preserved balance and Rally badge after relaunch; pause/guide/exit; maximum text; and three skill wins opening the farm with a planted crop retained after relaunch.

All **131 unique affected cases pass**, with no final native/UI failures or skips. The full campaign completes 1,020 stages and six restoration projects in 6,125 legal swaps and 24 retries without paid items or extra moves. [Result inventory and limits](release-draft/build20/verification.json), [original native captures](release-draft/build20/manifest.json).

Automated resets stayed on Store QA (`6D8263A8-F049-48C0-AC3D-5FCBCFD3A3C7`). The ordinary personal preview was installed in place with complete private backups and comparisons: 555 coins, three completed stages and the active rules-2 level-4 board at nine moves remain intact. There was no reset, uninstall or test argument on that device. [Preservation record](release-draft/build20/preview-preservation.json).

No new tablet layout run was needed for this model and lifecycle change; build-19 tablet evidence remains separate. Physical Apple account/iCloud synchronization, signed sandbox purchases, VoiceOver timing and human difficulty remain device checks. This callback guard is not server anti-cheat or a guarantee against a modified client.

[Delivery and Apple status](release-draft/build20/README.md) records the signed package and external limitation separately from passing local checks.
