# Orbit Bloom build 15 — a living farm

The Farm room is now a continuous native 3D field. Actual saved apple trees and rose bushes develop shoots, leaves, blossoms and harvests among soil beds, paths, a farmhouse, stream and bridge. A new pointed, veined leaf is used in both Farm and Bloom Circuits. Numbered actions follow the native camera and stay reachable after rotation. Water and harvest feedback respect Reduce Motion. Existing timers, crop costs, harvest rewards, saves and purchases remain compatible.

Source: **`3896b3fd13c58b5ce6a6f2a60ad812f3321cb848`**. [Verification](verification.json) pins 69 app/resource/project files and twelve test files. **108 unique affected cases have passing runs: 51 core, 51 native, five phone UI and one iPad UI.** The final main phone bundle records 55 passes and one missed entrance-tap failure; that farming case passes separately after its test waits for the initial entrance/layout to settle. This is a union, not a claim that every bundle passed. The failed first 31-point control and all intermediate results remain recorded. Earlier procedural-leaf runs are not used as final-source screenshot proof.

The new natural-time farming test plants both species, waters them, retains the apple when roses are selected, closes and reopens the app, waits for both actual saved deadlines, harvests once each and verifies **245 coins** and two harvests through another relaunch. The existing harvest/craft/save test also passes. The normal and maximum-text phone layouts, current puzzle/leaf, six patch actions, separate room entrances/exits and readonly iPad portrait/landscape are exercised. [UX findings](../../FARM_FIELD_REDESIGN.md) describe the font caps and remaining hardware checks.

The ordinary build **1.0 (15)** is installed in place on the personal Orbit Bloom QA preview. Its original full container backup is retained privately. [After installation](preview-after-install.json), all six typed preferences and the entire plist match byte-for-byte. [After ordinary launch](preview-after-launch.json), the full decoded wallet, farm, inventory, receipts, settings and timers match; only StoreKit's system check time changes. The save remains **520 coins, three completed levels, six hints and five lives**. No reset, uninstall or test flag was used. The simulator relocated its data container during the upgrade; the path was re-resolved before comparison. Installed Info/executable match the ordinary product and there are no test plug-ins.

[The signed App Store package](signed-package-verification.json) passes local signature, Production private iCloud/Game Center, privacy-manifest and no-test-plug-in checks. Archive and export succeeded. **Build 15 has not uploaded:** Xcode reports `Failed to Use Accounts` both with and without provisioning refresh. Native UI control reports the Mac is locked; the user has been asked to unlock it. No Apple server validation, processing or group assignment is claimed for build 15.

Chrome confirmed on 11 October that public version 1.0 still has **build 11 Waiting for Review**, with manual release. The existing public review/gallery was not changed. It also confirmed processed builds 13 and 14 belong to **Orbit Bloom QA**, with one invite each. [Next metadata](metadata-prepared.json) and [ten screenshots per device](apple-gallery-prepared.json) are prepared locally for a later public build update, not saved to Apple. The existing payment setup is unchanged; no real purchase or agreement occurred.

Eleven original native PNGs are retained without resizing, cropping or overlays. [Manifest](manifest.json) records hashes, raw/display dimensions, orientation, device and each individual passing case. iPad landscape preserves its orientation-8 metadata. Diagnostic exports can be regenerated from the named retained xcresult bundles.

| Native capture | Flow |
| --- | --- |
| [phone-01-empty-field.png](screenshots/phone-01-empty-field.png) | Six soil beds and field actions |
| [phone-02-sprouts.png](screenshots/phone-02-sprouts.png) | Planted apple and rose shoots |
| [phone-03-growing-orchard.png](screenshots/phone-03-growing-orchard.png) | Watered crop growth, actual species retained |
| [phone-04-ripe-orchard-and-roses.png](screenshots/phone-04-ripe-orchard-and-roses.png) | Offline return with ripe apples and flowering roses |
| [phone-05-harvested-field.png](screenshots/phone-05-harvested-field.png) | Both harvests credited and beds cleared |
| [phone-06-maximum-text.png](screenshots/phone-06-maximum-text.png) | Six reachable patches, exit and shed at maximum text |
| [phone-07-living-leaf-puzzle.png](screenshots/phone-07-living-leaf-puzzle.png) | New leaf in the actual playable puzzle |
| [phone-08-tool-shed.png](screenshots/phone-08-tool-shed.png) | Connected crafting with harvested compost |
| [ipad-01-portrait.png](screenshots/ipad-01-portrait.png) | Preserved iPad QA rose and full-width field |
| [ipad-02-landscape.png](screenshots/ipad-02-landscape.png) | Same six patches, camera-aligned actions and exit |
| [preview-build15-preserved.png](screenshots/preview-build15-preserved.png) | Ordinary personal preview, saved progress intact |

[Original leaf and full prompt](../../FARM_LEAF_PROMPT.json) record generation and asset provenance. The new asset is `OrbitBloom/Resources/Assets.xcassets/LivingLeaf.imageset/image.png`; no bitmap editing was applied.

Physical Apple account/cloud/sandbox/ranking, VoiceOver speech/focus, sound/haptics, SceneKit performance, smallest phones and split view remain separate checks. Store/iPad QA are shut down; the personal preview remains running and unrelated WeightGPT/Rush Drives work is preserved. Unlocking the Mac is needed to show the preview in front and continue the Apple upload.
