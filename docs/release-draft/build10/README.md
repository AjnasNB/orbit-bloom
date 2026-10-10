# Build 10 — separate Farm and Rally rooms

The island now has two clearly labeled room entrances. Farm opens a 3D terrace map with six numbered plots and its tool shed; Rally opens a separate garage/orchard route preview before the existing 440-metre race. Every room names its exit back to the Island. The active rally also has a prominent room exit. Original SceneKit terrain, buildings, flowers, trees, rover, road and directional shadows add depth to the established light botanical art.

Large-text entrances stack vertically. Room controls have descriptive accessibility labels, static miniatures and Reduce Motion support. The camera fits the diorama to the available width and height. This is a navigation/visual update: campaign unlocks, puzzle difficulties, life costs, planting/crafting, saved boards, purchases and Apple private iCloud architecture keep their established rules.

[Focused UX audit](../../ACTIVITY_ROOMS_UX_AUDIT.md) records the before/after flows, verified defects and implementation. [Verification manifest](verification.json) records final test summaries, native capture hashes, save-preserving installation and the signed package. The exact tested source commit is pinned there rather than inferred from the screenshot name.

**77 unique cases passed:** 34 core, 30 native, 12 iPhone UI and one iPad UI. The broad phone run records 42 passes with no failures or skips. After the final visual refinements, the room and iPad cases passed again; the expanded room case also verifies all six large-text Farm plots do not overlap. Reruns do not add unique cases. The automated solver completes all 1,020 stages and six projects in 6,556 legal swaps and 25 retries without paid items or extra moves.

| Native view | Captures |
| --- | --- |
| Labeled room entrances | [iPhone](captures/iphone-room-entrances.png), [large text](captures/iphone-large-room-entrances.png), [iPad](captures/ipad-room-entrances.png) |
| Farm terraces and plot status | [iPhone](captures/iphone-farm-room.png), [large text](captures/iphone-large-farm-room.png), [iPad](captures/ipad-farm-room.png), [landscape](captures/ipad-farm-landscape.png) |
| Garage/orchard route preview | [iPhone](captures/iphone-rally-room.png), [large text](captures/iphone-large-rally-room.png), [iPad](captures/ipad-rally-room.png), [landscape](captures/ipad-rally-landscape.png) |
| Actual road steering and room exit | [iPhone exit](captures/iphone-rally-exit.png), [iPad road](captures/ipad-rally-road.png) |
| Preserved personal preview after normal launch | [Active level 2](proof/preview-preserved.png) |

Thirteen distinct native PNGs retain their original pixels and orientation metadata, copied byte-for-byte from final test attachments. The separate preview proof uses a normal launch with no QA flags. All seven preferences match immediately after installation; the full decoded wallet and board remain equal afterward, normalizing only dictionary/enum-key ordering. The user's 280 coins, one completed stage, active level 2 with eleven moves, seven free hints and all inventory remain intact. The full original data container is backed up locally. Store and iPad QA are stopped; the personal preview is running build 10.

The new native captures and [metadata copy](metadata.json) are prepared locally for this build. The submitted build 7 and its Apple galleries/review queue were not edited by this task. Build 10 is not delivered to TestFlight: the existing Apple account authentication blocker remains, without another sign-in request or upload attempt. No public release or real purchase occurred. Physical VoiceOver, small phones, hardware performance, live Apple cloud and signed sandbox purchases retain their documented device-testing limits.
