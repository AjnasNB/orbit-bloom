# Orbit Bloom build 12 — connected garden and larger board

Local simulator update, source `b0fb97f5ca9091aa27668df58ab879e614af493c`. Build 11 remains in Apple review. Build 12 is not uploaded or submitted.

103 unique recorded passing cases: 49 core, 48 native, five phone UI and one iPad UI. Retries count once. [Verification](verification.json) retains failures and rerun provenance.

Eleven actual native PNGs retain their original bytes and orientation. Landscape iPad PNGs encode a portrait-sized raster with native orientation metadata; compatible viewers display the full landscape frame. Failed app-scoped crops are excluded. [Manifest](manifest.json) records hashes, dimensions, orientation and capture source.

- [ipad-01-garden-portrait.png](screenshots/ipad-01-garden-portrait.png)
- [ipad-02-garden-landscape.png](screenshots/ipad-02-garden-landscape.png)
- [ipad-03-puzzle-landscape.png](screenshots/ipad-03-puzzle-landscape.png)
- [ipad-04-puzzle-portrait.png](screenshots/ipad-04-puzzle-portrait.png)
- [phone-01-connected-garden.png](screenshots/phone-01-connected-garden.png)
- [phone-02-locked-district.png](screenshots/phone-02-locked-district.png)
- [phone-03-large-puzzle.png](screenshots/phone-03-large-puzzle.png)
- [phone-04-first-clear.png](screenshots/phone-04-first-clear.png)
- [phone-05-board-power.png](screenshots/phone-05-board-power.png)
- [phone-06-exit-confirmation.png](screenshots/phone-06-exit-confirmation.png)
- [preview-preserved-puzzle.png](screenshots/preview-preserved-puzzle.png)
