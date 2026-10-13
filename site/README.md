# Orbit Bloom Cloudflare site

Live standalone marketing, privacy and support pages: **https://orbitbloom.cognifyr.co/**. The pages use bundled original artwork, a native game screenshot and local scripts, with no analytics or external JavaScript.

Deploy from the repository root with `wrangler deploy --config wrangler.orbitbloom.jsonc`. This creates/updates only the dedicated `orbit-bloom-game-site` Worker and its static assets. The initial deploy verified that this Worker did not already exist. A new Pages project was attempted, but the account has reached its Pages project limit, so the site uses Workers static assets instead.

Preview with `python3 -m http.server 4173 --directory site`. The live home, privacy and support routes were opened in Chrome on 9 October 2026. Canonical metadata, sitemap and robots use the dedicated orbitbloom.cognifyr.co custom domain. The original Workers.dev endpoint remains available for existing app event-clock requests. Recompute the JSON-LD SHA-256 in `_headers` when its inline text changes.

The exact `orbitbloom.cognifyr.co` DNS search was empty before deployment on 12 October 2026. Wrangler attached it to the isolated game Worker with `custom_domain: true`, and Cloudflare now shows one Worker DNS record for this hostname. Other DNS records, apex hosts and projects were not edited. Public resolver and certificate-verified HTTPS checks pass; local routers may cache the earlier NXDOMAIN until their negative TTL expires.

10 October 2026: the home hero uses the original native build13 cartoon puzzle screenshot `assets/game-v13.png`. Deployment `8786ad9b-5de6-47ff-a68c-064d97529ab2` passed the five-route HTTPS/security check and visual verification in Chrome. No event-clock or privacy/support logic changed.

12 October 2026: deployment `651367f7-33c3-4d47-9a9e-f4b293dcb802` presents eight development activities, three farm fields and tier-3-to-5 Rally, with an original native build-17 puzzle image. Chrome confirms the new page; all five HTTPS/security routes pass. App Store availability remains pending and is not represented as live.

13 October 2026: deployment `f4e3edfa-04d2-42ca-a714-4dd5e8478115` changes only support guidance for development build 19. Combined Bloom/skill/Rally wins now expand fields at three and nine; separate harvest thresholds remain. Chrome and five HTTPS/security route checks pass. App Store availability remains pending; no DNS or player-save backend changed.
