# Orbit Bloom build 16 — safe harvest taps

A repeated Harvest tap could become a Plant action after the first tap emptied the bed. This silently consumed one seed and two water, and the unwanted new crop entered the save. The failing native reproduction records that behavior on the previous app source; its one case has five failed assertions.

The model now protects just that harvested patch for **1.1 seconds**, while collection finishes. Its native action shows a checkmark and **Harvested**, announces the completed harvest and temporarily disables planting. Other patches can still plant, water and harvest. When the action returns to Plant, a deliberate new planting works. Invalid patch IDs are ignored safely. The protection is transient and never enters the wallet or cloud-save schema.

Source: **`3b70e9264b9b191c50e7362af958a5b3e6a4641e`**. [Verification](verification.json) pins 69 app/resource/project hashes and twelve test hashes. **109 unique affected cases passed: 51 core, 53 native, four phone UI and one iPad UI.** Both final native result bundles pass without failures or skips. The original failing reproduction remains failed; a preliminary test-comparison compile error is recorded separately and excluded from passing counts.

New native cases check unchanged water/seeds/wallet after repeated harvest, durable save/relaunch, independent other beds, invalid IDs and deliberate replanting after collection. The real phone test **double-taps Harvest** and verifies 195 coins, eight seeds, unchanged water and exactly one harvest, then deliberately plants an apple and retains it through relaunch. Actual apple/rose offline growth, both harvests, crafting, maximum phone text and readonly iPad portrait/landscape also pass. Core tests complete all 1,020 campaign stages and six projects in 6,470 legal swaps and 18 retries, without paid items or extra moves; this proves automated reachability rather than human difficulty.

The ordinary **1.0 (16)** preview is installed in place with no reset or test flags. Its private full container checkpoint is retained. [Install comparison](preview-after-install.json) confirms all six typed preferences and the whole plist byte-for-byte. [Ordinary launch comparison](preview-after-launch.json) confirms every decoded gameplay value, wallet, farm, inventory, receipts, settings and timer; only StoreKit's system check timestamp changes. The preview retains **520 coins, three completed levels, six hints and five lives**. Installed Info/executable match the ordinary build, with no test plug-ins. The relocated simulator data path was re-resolved before checking it.

The [signed package](signed-package-verification.json) passes local code signature, Production Game Center/private iCloud, privacy-manifest and no-test-plug-in checks. Archive/export succeeded. The single new upload attempt returns the existing **Failed to Use Accounts** error; **build 16 is not uploaded**, with no Apple server validation, processing or group assignment claimed. No repeated sign-in/unlock request was sent. Native foreground control could not locate a Simulator window; purpose-built native tests and captures still completed.

[Metadata/What to Test](metadata-prepared.json) and [ten-per-device gallery selections](apple-gallery-prepared.json) are prepared locally. The unchanged puzzle leaf uses an original build-15 screenshot; Farm and iPad use fresh build-16 captures. Public review and screenshots were not edited. Public build 11 was last observed Waiting for Review on **11 October**, and that status was not rechecked today. No public release, real purchase or agreement occurred.

Nine original native PNGs retain their bytes, dimensions, orientation and passing-test provenance in [the manifest](manifest.json). The collected frame is intentionally an actual animation frame, showing the newly protected action and real coin flight.

| Capture | Flow |
| --- | --- |
| [phone-01-ready-crop.png](screenshots/phone-01-ready-crop.png) | Rose ready to harvest |
| [phone-02-harvest-collected.png](screenshots/phone-02-harvest-collected.png) | Double tap: one reward, Harvested feedback, unchanged water/seeds |
| [phone-03-deliberate-replant.png](screenshots/phone-03-deliberate-replant.png) | Intentional apple planting after collection |
| [phone-04-ripe-apple-and-rose.png](screenshots/phone-04-ripe-apple-and-rose.png) | Real saved crop species after offline growth |
| [phone-05-maximum-text.png](screenshots/phone-05-maximum-text.png) | Six patch actions and shed/exit at maximum text |
| [phone-06-tool-shed.png](screenshots/phone-06-tool-shed.png) | Harvested compost used in connected crafting |
| [ipad-01-portrait.png](screenshots/ipad-01-portrait.png) | Current field and preserved iPad QA crop |
| [ipad-02-landscape.png](screenshots/ipad-02-landscape.png) | Camera-aligned actions after rotation; native orientation 8 retained |
| [preview-build16-preserved.png](screenshots/preview-build16-preserved.png) | Ordinary personal preview with its complete save |

Store/iPad QA are shut down. The personal preview stays booted; unrelated devices/work remain untouched. Only completed regenerable exports/build caches and system caches of shutdown owned QA devices were cleared for disk space; original results, signed packages and all saves remain. Physical Apple sign-in/cloud/sandbox/rankings, VoiceOver, sound/haptics/performance and smallest-device/split-view checks remain outside this focused pass.
