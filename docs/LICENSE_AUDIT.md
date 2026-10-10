# Source and asset license audit

The compiled third-party game engine is MIT. Audio is CC0. Generated art and Apple platform resources have separate terms. Public availability alone is not a reuse license.

| Material | Source / revision | License | Use |
| --- | --- | --- | --- |
| Match3Kit | [alex566/Match3Kit](https://github.com/alex566/Match3Kit), `d19e1443f40ca1a5603d38c9d2ac498b3644f5a6` | MIT, Alexey Oleynik, 2020 | Compiled grid/refill/matching primitives; original connected-group logic added locally |
| MatchPuzzle | [yadorogi/MatchPuzzle](https://github.com/yadorogi/MatchPuzzle), `73c496d7b398f334964cc41b362e7032b87c8af2` | MIT, Tetsuo Kawakami, 2024 | Downloaded comparison source only |
| FarmingReference | [oiblank/godot-farming-prototype](https://github.com/oiblank/godot-farming-prototype), `58be1ed5c3df797db6eef9bbf61d809c2dc29097` | MIT, oiblank, 2016 | Downloaded comparison source; native farm implemented independently |
| Orbit Bloom code | `OrbitBloom/`, root `LICENSE` | MIT | Native UI, farming, delivery, economy, persistence, StoreKit integration |
| Botanical atlas, living garden, bloom logo | `Assets.xcassets`, prompts in `V2_ARTWORK_PROMPTS.json` | Generated with built-in OpenAI ImageGen on 8 October 2026, subject to [OpenAI terms](https://openai.com/policies/terms-of-use/) | Original dimensional sprite renders, backdrop, and icon; not actual 3D meshes |
| Current cartoon atlas, Keeper Lio and Rally Rover | `Assets.xcassets`, prompts and gutter revision in `CARTOON_ARTWORK_PROMPTS.json` | Restyled with built-in OpenAI ImageGen on 10 October 2026, subject to OpenAI terms | Original rounded cartoon renders replace the earlier detailed atlas/character/rover; no Playrix assets copied |
| Interface / impact / jingle effects | [Kenney](https://kenney.nl/assets), exact files in `AUDIO_PROVENANCE.json` | CC0; publisher licenses preserved under `research/audio/` and bundled notices | Tap, match, cascade, explosion, plant, water, harvest, craft, coin, collision, win and lose cues |
| Another August | [The Cynic Project](https://opengameart.org/node/73989), cynicmusic.com / pixelsphere.org | CC0 | Full garden/farm ambient track |
| Happy Adventure (Loop) | [TinyWorlds](https://opengameart.org/content/happy-adventure-loop) | CC0 | Full puzzle music loop |
| Rhythm Garden | [congusbongus](https://opengameart.org/content/rhythm-garden) | CC0 | Full rover race track |
| Legacy garden and tones | `MoonGarden.imageset`, `bloom*.wav`, original prompt in `ARTWORK_PROMPT.txt` | Original generated artwork / synthesized audio | Retained first-version resources; replaced in current main presentation |
| SF Symbols / SwiftUI / StoreKit / AVFoundation | Apple SDK | Apple platform terms | Native framework and symbol use |

Exact audio download URLs and selected source filenames are in `AUDIO_PROVENANCE.json`. Source MP3/OGG files were transcoded to bundled AAC/M4A without changing their license. Full upstream notices remain in their repositories and in the app's Settings > Licenses.

[Spring Festival Crush](https://github.com/banghuazhao/Spring-Festival-Crush) was rejected because of its noncommercial CC BY-NC-SA license. ISC and unverified sources were not imported as MIT. Gardenscapes is a genre reference only; no proprietary code, artwork, audio, or names were copied.
