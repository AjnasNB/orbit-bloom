# Orbit Bloom build 14 — Rally traffic guide

The next real barrier and coin now appear in three numbered lane tiles. The road exposes the same guidance to VoiceOver, and active crossings trigger short announcements. Pause freezes both. The existing cartoon rover and 3D route remain; the maximum-text lobby and pause controls now fit without scrolling.

Source: `c2aa27aeb753b4af1918c046beecf3fca639802b`. [Verification](verification.json) records **106 unique passing affected cases**: 50 core, 50 native, five phone UI and one iPad UI. The main phone bundle has one room-relaunch failure; that corrected case passes in its separate rerun. Diagnostic failures remain recorded.

The signed Release build **uploaded successfully through the existing Xcode account on 11 October at 11:12 AM India time**. Apple accepted it and began processing. [Exact package proof](signed-package-verification.json) distinguishes the uploaded, freshly signed IPA from the local export. Processing completion and internal TestFlight group assignment are not confirmed. The existing build-11 public review was not replaced or rechecked.

[Metadata](metadata-prepared.json) and [ten screenshots per proposed gallery](apple-gallery-prepared.json) are prepared locally, not saved to Apple. Each proposed device gallery retains nine truthful unchanged build-13 shots and uses a fresh Rally capture. The submitted build-11 galleries remain unchanged.

The ordinary preview is updated in place with its complete save preserved: **520 coins, three completed stages, six free hints and five lives**. [Install comparison](preview-after-install.json) checks every one of its six typed preferences and exact plist bytes against the immediate final-install checkpoint. [Launch comparison](preview-after-launch.json) checks the full decoded wallet, farm, inventory, receipts, settings and timers. No reset or test flags were used. Normal saving clears the unused charged flag of a completed puzzle and rotates the recovery slot to exactly the preceding primary wallet; [original-save reconciliation](preview-original-save-reconciliation.json) verifies every other gameplay field. The strict launch checker permits only that exact recovery rotation and rejects lost coins in either slot. A leftover simulator-only test plug-in was quarantined privately before the clean ordinary reinstall; the installed preview has no test plug-ins.

Ten native QA PNGs and one ordinary preview are copied without crop, resize or overlays. [Manifest](manifest.json) pins SHA-256, dimensions, orientation, passing case and original result bundle. Phone captures come from passing cases in a bundle with the separate relaunch failure; no failed capture is used.

| Original screenshot | Flow |
| --- | --- |
| [phone-01-rally-lobby.png](screenshots/phone-01-rally-lobby.png) | Rally room and Start |
| [phone-02-next-traffic.png](screenshots/phone-02-next-traffic.png) | Actual driving and next lane guide |
| [phone-03-paused-rally.png](screenshots/phone-03-paused-rally.png) | Paused route with frozen guide |
| [phone-04-delivery-result.png](screenshots/phone-04-delivery-result.png) | Real delivery result and reward |
| [phone-05-accessibility-lobby.png](screenshots/phone-05-accessibility-lobby.png) | Maximum accessibility text: room and Start |
| [phone-06-accessibility-road.png](screenshots/phone-06-accessibility-road.png) | Maximum accessibility text: pause, exit and traffic |
| [ipad-01-rally-portrait.png](screenshots/ipad-01-rally-portrait.png) | Normal portrait |
| [ipad-02-rally-landscape.png](screenshots/ipad-02-rally-landscape.png) | Normal landscape |
| [ipad-03-accessibility-portrait.png](screenshots/ipad-03-accessibility-portrait.png) | Maximum accessibility text: portrait |
| [ipad-04-accessibility-landscape.png](screenshots/ipad-04-accessibility-landscape.png) | Maximum accessibility text: landscape |
| [preview-build14-preserved.png](screenshots/preview-build14-preserved.png) | Ordinary preview launch; owner save preserved |

Hardware Apple account/cloud/sandbox/ranking, VoiceOver speech and reaction timing remain separate checks. The large-text result screen and smallest-device/split-view layouts were not exercised in this focused pass. [UX findings](../../RALLY_TRAFFIC_UX_AUDIT.md) document dense-diagram font limits and the actual changes.
