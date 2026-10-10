# Orbit Bloom build 13 — cartoon artwork and gameplay verification

Local simulator update, source `d6780355d5350b42c2225e427a1cbcef3787ba7c`. The existing Apple build-11 submission is unchanged; build 13 is not uploaded or submitted.

109 unique passing cases: 49 core, 49 native, ten phone UI and one iPad UI. Farm/Shop gallery reruns count once. [Verification](verification.json) retains the initial crop failure and final passes. [Preview installation](preview-after-install.json) and [ordinary launch](preview-after-launch.json) prove saved-game preservation.

These 25 actual native PNGs retain their original bytes. iPad landscape uses native orientation metadata; compatible viewers show the full landscape frame. [Manifest](manifest.json) records hashes and capture provenance. Early room-fade captures were replaced by settled shots. Older attachment-name prefixes belong to reused tests; the recorded bundles run build 13.

Replacement [sprite atlas](../../../OrbitBloom/Resources/Assets.xcassets/BotanicalAtlas.imageset/image.png), [Keeper Lio](../../../OrbitBloom/Resources/Assets.xcassets/KeeperLio.imageset/KeeperLio.png) and [Rally Rover](../../../OrbitBloom/Resources/Assets.xcassets/RallyRover.imageset/RallyRover.png) were made with built-in ImageGen. [Complete prompts](../../CARTOON_ARTWORK_PROMPTS.json) and [gutter refinement](../../CARTOON_ATLAS_REFINEMENT.json) retain provenance.

- [phone-01-connected-garden.png](screenshots/phone-01-connected-garden.png)
- [phone-02-cartoon-puzzle.png](screenshots/phone-02-cartoon-puzzle.png)
- [phone-03-board-power.png](screenshots/phone-03-board-power.png)
- [phone-04-first-clear.png](screenshots/phone-04-first-clear.png)
- [phone-05-locked-island.png](screenshots/phone-05-locked-island.png)
- [phone-06-farm.png](screenshots/phone-06-farm.png)
- [phone-07-tool-shed.png](screenshots/phone-07-tool-shed.png)
- [phone-08-rally-room.png](screenshots/phone-08-rally-room.png)
- [phone-09-cartoon-rover.png](screenshots/phone-09-cartoon-rover.png)
- [phone-10-rally-complete.png](screenshots/phone-10-rally-complete.png)
- [phone-11-lives-and-shop.png](screenshots/phone-11-lives-and-shop.png)
- [phone-12-coin-pack.png](screenshots/phone-12-coin-pack.png)
- [phone-13-starter-pack.png](screenshots/phone-13-starter-pack.png)
- [phone-14-abandon.png](screenshots/phone-14-abandon.png)
- [phone-15-one-shot.png](screenshots/phone-15-one-shot.png)
- [phone-16-cartoon-keeper.png](screenshots/phone-16-cartoon-keeper.png)
- [phone-17-canal-weave.png](screenshots/phone-17-canal-weave.png)
- [phone-18-firefly-trail.png](screenshots/phone-18-firefly-trail.png)
- [phone-19-windmill-works.png](screenshots/phone-19-windmill-works.png)
- [phone-20-moon-observatory.png](screenshots/phone-20-moon-observatory.png)
- [ipad-01-garden-portrait.png](screenshots/ipad-01-garden-portrait.png)
- [ipad-02-garden-landscape.png](screenshots/ipad-02-garden-landscape.png)
- [ipad-03-puzzle-landscape.png](screenshots/ipad-03-puzzle-landscape.png)
- [ipad-04-puzzle-portrait.png](screenshots/ipad-04-puzzle-portrait.png)
- [preview-preserved-cartoon-puzzle.png](screenshots/preview-preserved-cartoon-puzzle.png)
