# Orbit Bloom Cloudflare site

Static standalone game marketing, privacy and support pages. No build framework, analytics or remote scripts. Original app artwork and a reduced-size actual native screenshot are bundled under assets/.

Preview: `python3 -m http.server 4173 --directory site` from the repository root. Desktop and 390×844 layouts were visually checked in Chrome; bundled images loaded and no horizontal overflow was observed. The privacy route was opened through the actual navigation.

Deploy the contents of this directory as a **new Cloudflare Pages project** using Direct Upload. `build/orbit-bloom-site.zip` is a ready upload archive generated from these files. Connect the new `orbitbloom.cognifyr.co` subdomain only after checking that it is unused, then verify HTTPS, support/privacy routes, sitemap and security headers. Do not modify existing projects, apex records or unrelated subdomains.

Publishing is currently waiting for the owner's Cloudflare authenticator verification and Mac unlock. URLs in canonical metadata/sitemap are intended deployment addresses, not a claim that hosting is already live. The CSP JSON-LD hash in _headers must be recomputed if the inline structured-data text changes.
