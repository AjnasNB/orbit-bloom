# Orbit Bloom Cloudflare site

Live standalone marketing, privacy and support pages: **https://orbit-bloom-game-site.ajnasnb.workers.dev/**. The pages use bundled original artwork, a native game screenshot and local scripts, with no analytics or external JavaScript.

Deploy from the repository root with `wrangler deploy --config wrangler.orbitbloom.jsonc`. This creates/updates only the dedicated `orbit-bloom-game-site` Worker and its static assets. The initial deploy verified that this Worker did not already exist. A new Pages project was attempted, but the account has reached its Pages project limit, so the site uses Workers static assets instead.

Preview with `python3 -m http.server 4173 --directory site`. The live home, privacy and support routes were opened in Chrome on 9 October 2026. Canonical metadata, sitemap and robots use the verified workers.dev host. Recompute the JSON-LD SHA-256 in `_headers` when its inline text changes.

The optional custom host `orbitbloom.cognifyr.co` has not been configured. Existing projects, DNS records, apex hosts and unrelated subdomains remain unchanged. Check that a desired custom hostname is unused before adding it.

10 October 2026: the home hero uses the original native build13 cartoon puzzle screenshot `assets/game-v13.png`. Deployment `8786ad9b-5de6-47ff-a68c-064d97529ab2` passed the five-route HTTPS/security check and visual verification in Chrome. No event-clock or privacy/support logic changed.
