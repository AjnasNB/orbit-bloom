# Orbit Bloom cartoon style refinement — build 13

The intended visual register is a playful family garden adventure: original rounded 3D scenery, chunky colourful objects and expressive cartoon characters. Detailed photographic botanical textures competed with that miniature garden world. This update changes artwork and sprite framing while preserving existing routes, game rules, resource names and saved progress.

| Severity | Screen / flow | Evidence and impact | Implemented fix |
| --- | --- | --- | --- |
| P2 | Puzzle, crop selection and crafting | The old atlas used fine leaf veins, realistic apple skin, layered rose petals and weathered metal. These textures looked inconsistent beside the soft SceneKit map and became busy at tile size. | Shared cartoon atlas uses simple broad highlights, plump silhouettes and distinct green leaf / blue dew / red apple / coral rose / violet diamond shapes. Bomb, TNT, Mega and Rainbow remain visibly different. |
| P2 | Keeper and Harvest Rally | Lio's skin/fabric detail and the rover's realistic metal/flowers used a different material language from the garden. | Original characters and story cues are preserved in smooth cartoon renders. The rally rover still faces upward, with four readable wheels and rear produce. |
| P2 | Sprite import | The initial generated diamond touched a crop edge. An overly small repair also needed a closer native crop to match the other pieces. | Selected transparent gutter repair, four-column/three-row extraction and a closer diamond crop. The native asset regression checks all twelve sprites for visibility, resolution and transparent edges; it also checks character/rover transparency. |

No navigation or onboarding steps were added. Existing accessibility labels describe the objects and tools independently of decorative images. Native buttons, targets, gesture handling, motion preferences, audio, life accounting and save schemas are retained. The new PNGs are cached through the same shared sprite loader, so farm, tool shed, wallet, puzzle and supplies receive the same style.

The mobile UX static scan is retained at `evidence/build13-ux-scan.txt`. Its decorative-image warnings need context: SpriteView and GemView are accessibility-hidden artwork inside separately labeled native controls. Accessibility announcements and VoiceOver status observers are not push-notification requests. The scan is not evidence of a new platform failure or a completed hardware VoiceOver audit.

Built-in ImageGen produced the three replacement PNG assets. [Complete prompts](CARTOON_ARTWORK_PROMPTS.json) and [selected gutter repair](CARTOON_ATLAS_REFINEMENT.json) record provenance. Native SceneKit map/rooms and code-drawn activity surfaces remain original. No Gardenscapes artwork, character or interface image was imported.

Actual test and capture results are recorded in [the test report](TEST_REPORT.md) and the build-13 release evidence. Local simulator tests do not establish physical-device Apple cloud, ranking or signed sandbox service behaviour.
