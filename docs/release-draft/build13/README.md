# Orbit Bloom build 13 — cartoon artwork and gameplay verification

Signed release update, source `d6780355d5350b42c2225e427a1cbcef3787ba7c`. **Transporter verified and delivered 1.0 (13), then confirmed processing finished on 10 October 2026.** [Signed package verification](signed-package-verification.json) pins the exact tested source, IPA hash and production Game Center/iCloud entitlements.

**Build 13 is uploaded but not yet attached, assigned to internal TestFlight or submitted for App Review.** Chrome restarted and the Apple session expired during delivery. The sign-in tab is kept open; the existing build-11 submission was Waiting for Review at the authenticated check before restart and has not been cancelled. [Prepared copy](metadata-prepared.json) and [ten-per-device gallery selection](apple-gallery-prepared.json) await sign-in. Transporter screenshots include private sign-in information and remain in ignored evidence only.

109 unique passing cases: 49 core, 49 native, ten phone UI and one iPad UI. Farm/Shop gallery reruns count once. The same all-seven-doors case also passed on iPad in this delivery run; it adds device coverage, not another unique case. [Verification](verification.json) retains the initial crop failure and final passes. [Preview installation](preview-after-install.json) and [ordinary launch](preview-after-launch.json) prove saved-game preservation.

These 31 actual native PNGs retain their original bytes. iPad landscape uses native orientation metadata; compatible viewers show the full landscape frame. [Manifest](manifest.json) records hashes and capture provenance. Early room-fade captures were replaced by settled shots. Older attachment-name prefixes belong to reused tests; the recorded bundles run build 13.

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

## Delivery additions

The [live Cloudflare site](https://orbit-bloom-game-site.ajnasnb.workers.dev/) shows the actual build-13 cartoon puzzle. [Deploy and five-route security record](site-delivery.json) and [Chrome proof](proof/live-cartoon-site.jpg) confirm the isolated Worker update. Privacy, support and the public event clock keep their established configuration. No player database, DNS change, purchase or agreement was added.

Additional original native iPad room screenshots:

- [ipad-05-farm.png](screenshots/ipad-05-farm.png)
- [ipad-06-rally.png](screenshots/ipad-06-rally.png)
- [ipad-07-canal.png](screenshots/ipad-07-canal.png)
- [ipad-08-fireflies.png](screenshots/ipad-08-fireflies.png)
- [ipad-09-windmill.png](screenshots/ipad-09-windmill.png)
- [ipad-10-observatory.png](screenshots/ipad-10-observatory.png)
