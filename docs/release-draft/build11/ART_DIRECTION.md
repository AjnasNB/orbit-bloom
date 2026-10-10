# Build 11 original artwork

Two original raster assets were generated for Orbit Bloom using the **built-in imagegen tool**, with **transparent background mode enabled** (`transparent_background: true`). These are production character and vehicle assets, displayed inside the native game. They are not App Store screenshots or UI mockups.

## Assets and verified provenance

| Asset | Native use | PNG dimensions | Format | Fully transparent pixels | File size |
| --- | --- | --- | --- | --- | --- |
| [KeeperLio.png](../../../OrbitBloom/Resources/Assets.xcassets/KeeperLio.imageset/KeeperLio.png) | Keeper portrait in the island-room welcome | 1145 × 1374 | RGBA PNG | 605,768 / 1,573,230 (38.50%) | 2,313,585 bytes |
| [RallyRover.png](../../../OrbitBloom/Resources/Assets.xcassets/RallyRover.imageset/RallyRover.png) | Live Harvest Rally vehicle | 1144 × 1375 | RGBA PNG | 682,971 / 1,573,000 (43.42%) | 1,910,768 bytes |

The PNGs were inspected read-only with Pillow and visually reviewed. Both have an alpha range of **0–255**, confirming actual transparent pixels. Most visible pixels have alpha 253; the files also include partially transparent edges and glow. No embedded prompt or other PNG metadata was present.

The original generated files match the committed asset files byte-for-byte by SHA-256:

- **KeeperLio source:** `/Users/ajnasnb/.codex/generated_images/01a11b5b-a39f-7f50-bd8a-54736d327ef5/exec-ecbfd46a-3400-4e68-804d-898f31686569.png`
- **KeeperLio SHA-256:** `0286e02d15f00295024af4c4d1e920c4df576d0742e991be201613f0df48ffde`
- **RallyRover source:** `/Users/ajnasnb/.codex/generated_images/01a11b5b-a39f-7f50-bd8a-54736d327ef5/exec-72886789-bac6-43fb-9d2f-25a1cc08424a.png`
- **RallyRover SHA-256:** `8106c5a6668d42598b61d7fcc0e3ab24ec577be9cdea8dc69772d705a1d972e8`

Asset catalog source paths are `OrbitBloom/Resources/Assets.xcassets/KeeperLio.imageset/KeeperLio.png` and `OrbitBloom/Resources/Assets.xcassets/RallyRover.imageset/RallyRover.png`. Each has a universal image entry in its adjacent `Contents.json`.

## Visual rationale

**Lio** is a young keeper apprentice rebuilding Aurora Atoll after the Great Eclipse. The portrait combines a friendly expression, teal workwear, brass goggles, botanical tools and a glowing moonseed. The wrench explains the rebuilding work; leaves and flowers explain the garden; the moonseed connects the world to its space setting. This gives the seven rooms one recognizable person and purpose. The character is a dimensional rendered illustration, not a live animated 3D character model.

**The rally rover** uses an overhead view with the nose facing up the road. Cream bodywork, teal glass, brass trim and dark leaf-pattern tires create a readable vehicle silhouette. The wooden cargo bed holds roses and a glowing moon apple, connecting farm harvests to deliveries. Warm lamps distinguish the front and rear. It replaces the small atlas car in live play; native movement, collision feedback, shadows and coin-flight animations come from game code. The vehicle image is a rendered sprite rather than a real-time 3D mesh.

## Prompt record

The exact original tool-call prompt strings were unavailable when preparing this document. The following descriptions are **reconstructed generation intent**, based on the implementation brief and visual inspection. They are **not verbatim prompts** and must not be presented as an exact generation transcript.

### KeeperLio — reconstructed intent

Create an original, friendly keeper apprentice for a botanical space-island adventure. Show a young character with dark wavy hair, expressive warm eyes, brass goggles, teal workwear, cream shirt, leather tool straps and gardening details. Give the character a glowing moonseed in one hand and a botanical wrench in the other. Use polished dimensional game illustration, tactile fabric and metal, warm highlights and a readable silhouette. Isolate the character on a genuinely transparent background, with no lettering, UI or scenery.

### RallyRover — reconstructed intent

Create a premium overhead 3D-rendered moonseed cargo rover for a native garden racing game. Face the nose toward the top of the image. Use cream bodywork, teal glass, brass trim, four substantial dark tires and warm lamps. Fill a wooden rear cargo bed with coral roses, green leaves and a glowing moon apple. Keep the shape recognizable at a small game-sprite size. Isolate the vehicle on a genuinely transparent background, with no text, road, interface or surrounding scenery.

## Release screenshot boundary

Use simulator captures of the running native game for gameplay and release screenshots. These two transparent illustrations may appear naturally in those captures through their in-game use. This document introduces no synthetic UI screenshots and no altered gameplay evidence.
