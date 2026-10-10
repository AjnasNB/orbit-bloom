# Orbit Bloom 1.0 (11) — verification and release gallery

**Build 11 is submitted for actual App Review and Waiting for Review.** Apple confirms [eight submitted items](https://appstoreconnect.apple.com/apps/6820591529/distribution/reviewsubmissions/details/83b00d39-0873-4771-8bc9-5d94d4be04b4): version 1.0 (11), Atoll Skills and all six purchase packs. Submitted 10 October 2026 at 16:47 India time (minute precision). [The actual Chrome confirmation](proof/apple-review-submission.jpg) shows the app/build and submission status. Public release has not occurred; manual release remains selected. Transporter Verify succeeded at 15:54 and Deliver at 16:29, Apple processing completed, and the existing one-tester Orbit Bloom QA group received build 11 with testing instructions.

**107 unique cases have a passing run.**

App source is pinned to `8b26cbdbe0827c571aca7725842a5a973d0c7dea`. All 44 source/asset/privacy hashes match the [signed package record](signed-package-verification.json), and the IPA hash/size match that record. See [verification.json](verification.json) for the evidence and independently updateable Apple status fields.

The [test report](../../TEST_REPORT.md) records **49 core + 47 native + 9 iPhone UI + 2 iPad UI cases**, counted once across reruns. Several earlier mixed bundles retain their failures; a later passing case does not relabel an entire earlier bundle successful. Native play solves all four new rooms through real inputs, saves their rewards, advances after relaunch, checks swipe/pause/exit behavior and tests the largest text pages. The core solver reaches all 1,020 campaign stages and six projects in 6,578 legal swaps with 23 retries, using no paid items or extra moves. This does not measure human difficulty or mean every stage was manually played.

## Selected native gallery

Ten iPhone images (1320 × 2868) and ten iPad images (2064 × 2752) were uploaded, processed and saved in App Store Connect. [The manifest](manifest.json) records hashes, tests, native capture dimensions and provenance. All 20 matching build 11 images are part of the submitted version; the medium iPhone gallery inherits the large iPhone assets.

| Slot | iPhone | iPad |
| --- | --- | --- |
| 01 | [Lio and Aurora Atoll](iphone/01-lio-and-aurora-atoll.png) | [Lio and Aurora Atoll](ipad/01-lio-and-aurora-atoll.png) |
| 02 | [Bloom circuits](iphone/02-bloom-circuits.png) | [Bloom circuits](ipad/02-bloom-circuits.png) |
| 03 | [Farm terraces](iphone/03-farm-terraces.png) | [Farm terraces](ipad/03-farm-terraces.png) |
| 04 | [Harvest Rally](iphone/04-harvest-rally.png) | [Harvest Rally](ipad/04-harvest-rally.png) |
| 05 | [Canal Weave](iphone/05-canal-weave.png) | [Canal Weave](ipad/05-canal-weave.png) |
| 06 | [Firefly Trail](iphone/06-firefly-trail.png) | [Firefly Trail](ipad/06-firefly-trail.png) |
| 07 | [Windmill Works](iphone/07-windmill-works.png) | [Windmill Works](ipad/07-windmill-works.png) |
| 08 | [Moon Observatory](iphone/08-moon-observatory.png) | [Moon Observatory](ipad/08-moon-observatory.png) |
| 09 | [World events](iphone/09-world-events.png) | [Field tasks and powers](ipad/09-field-tasks-and-powers.png) |
| 10 | [Seven room doors](iphone/10-seven-room-doors.png) | [Apple Saved Garden](ipad/10-player-saved-garden.png) |

Twenty separate native [proof captures](manifest.json) cover supplies and all six purchase packs, Apple save/ranking information, room records, iPad landscape play, field tasks and the [preserved preview](proof/preview-save-preserved.png). iPad slot 09 uses settled Field Tasks; the mid-transition shop frame is excluded and retained as diagnostic evidence. Original PNG bytes and orientation metadata are preserved. Original xcresults remain at workspace-relative `evidence/` paths; temporary export folders may be absent and can be regenerated from those bundles.

## Preserved save and connected services

The ordinary preview update used no reset or QA flags. [Immediately after installation](preview-after-install.json), all seven preferences and the plist bytes match exactly. [After normal launch](preview-after-launch.json), the full decoded wallet, puzzle, farm, inventory, receipts and settings match: **280 coins, one completed stage, level 2/rules 1 with 11 moves, seven hints and five lives**. Only dictionary serialization order and one newly added empty journey default were accepted; timers and gameplay fields were compared. StoreKit check metadata changed separately. Store/iPad QA are shut down, the preview is booted and unrelated Rush Drives is preserved.

The isolated [Cloudflare site](https://orbit-bloom-game-site.ajnasnb.workers.dev) and public event clock use deployed version `1fe5fe66-69a0-4b46-a680-70fadf7a12d7`. Five HTTPS/security-route checks and real native clock acceptance are separate from the 107 cases. Cloudflare stores no player saves or purchase data. [Security review](../../SECURITY_REVIEW.md), [system/source inventory](../../V2_SYSTEMS_AND_SOURCES.md), [seven-room design](../../SEVEN_ROOMS_DESIGN.md), [UX audit](../../SEVEN_ROOMS_UX_AUDIT.md), [art direction](ART_DIRECTION.md) and [metadata draft](metadata.md) document the boundaries and sources.

Physical Game Center sign-in, private iCloud round trips, signed Apple sandbox purchases and leaderboard submission remain unverified on hardware. Local StoreKit and account/clock test doubles do not prove those services. Physical VoiceOver focus/timing, performance, audio/haptics, smaller devices/split-screen and human pacing also need hardware checks. Client-bounded rankings are not authoritative anti-cheat.

The previous build 7 submission was canceled and appears Removed because build 11 replaced it. This was a developer action, not an Apple rejection. Purchase products and Indian prices (₹99–₹999) are unchanged and also Waiting for Review.
