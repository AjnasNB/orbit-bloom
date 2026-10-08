# Orbit Bloom source and asset license audit

The distributed third-party game code in Orbit Bloom is Match3Kit under MIT. Existing commercial game artwork and noncommercial source code are excluded. Asset and Apple platform terms are recorded separately; this project does not claim that every platform resource is MIT.

| Material | Source and revision | License or provenance | Use |
| --- | --- | --- | --- |
| Match3Kit | [alex566/Match3Kit](https://github.com/alex566/Match3Kit), commit `d19e1443f40ca1a5603d38c9d2ac498b3644f5a6` | [MIT](https://github.com/alex566/Match3Kit/blob/master/LICENSE), copyright 2020 Alexey Oleynik | Vendored source compiled into the app; grid, matching, swaps, refill, possible moves |
| MatchPuzzle | [yadorogi/MatchPuzzle](https://github.com/yadorogi/MatchPuzzle), commit `73c496d7b398f334964cc41b362e7032b87c8af2` | [MIT](https://github.com/yadorogi/MatchPuzzle/blob/main/LICENSE), copyright 2024 Tetsuo Kawakami | Downloaded reference in `research/`; no code or assets compiled into Orbit Bloom |
| Orbit Bloom code | `OrbitBloom/` | MIT, see root `LICENSE` | Original campaign, progression, UI, engine adapter, persistence, purchase integration |
| Gem illustrations | `Views/GemView.swift` | Original procedural vector artwork, included with MIT source | Five visually distinct pieces |
| App icon | `scripts/generate_icon.swift` | Original procedural AppKit artwork, included with MIT source | Native iOS app icon |
| Sound effects | `Resources/bloom0.wav` through `bloom4.wav` | Original synthesized sine/harmonic tones, included with MIT project contributions | Cascade feedback; no sampled music |
| Moon garden illustration | `Resources/Assets.xcassets/MoonGarden.imageset/garden.png` | Created for this project with built-in OpenAI ImageGen, 8 October 2026, subject to applicable [OpenAI terms](https://openai.com/policies/terms-of-use/) | Original generated background; exact prompt saved in `ARTWORK_PROMPT.txt` |
| SF Symbols and native frameworks | Installed Apple SDK | Apple platform terms | Native symbols, text rendering, StoreKit, audio, haptics, and UI; not third-party MIT assets |

The full upstream MIT notice is preserved in `vendor/Match3Kit/LICENSE` and bundled as `Resources/ThirdPartyNotices.txt`, accessible in Settings. The research reference retains its own license.

## Rejected sources

[Spring Festival Crush](https://github.com/banghuazhao/Spring-Festival-Crush) looks more complete but uses [CC BY-NC-SA 4.0](https://github.com/banghuazhao/Spring-Festival-Crush/blob/main/LICENSE.md). Its noncommercial restriction does not fit the requested paid App Store game, so none of its source or assets were downloaded for use.

[Sanyabeast's match3](https://github.com/sanyabeast/match3) declares ISC rather than MIT. It was not selected because the user requested MIT code.

Gardenscapes remains a genre reference, with no downloaded or copied proprietary materials. Project and product names are working titles and need availability checks before release.
