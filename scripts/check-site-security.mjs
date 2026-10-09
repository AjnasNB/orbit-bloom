import assert from 'node:assert/strict';

// Public static-site checks only; no player identifiers or credentials are sent.
const origin = 'https://orbit-bloom-game-site.ajnasnb.workers.dev';
for (const path of ['/', '/privacy/', '/support/', '/style.css', '/missing-security-check/']) {
  const response = await fetch(origin + path);
  assert.equal(response.status, path.startsWith('/missing') ? 404 : 200, path);
  assert.equal(new URL(response.url).protocol, 'https:');
  assert.equal(response.headers.get('x-content-type-options'), 'nosniff');
  assert.equal(response.headers.get('x-frame-options'), 'DENY');
  assert.match(response.headers.get('strict-transport-security') ?? '', /max-age=31536000/);
  const csp = response.headers.get('content-security-policy') ?? '';
  for (const rule of ["default-src 'self'", "frame-ancestors 'none'", "object-src 'none'",
                       "form-action 'none'", "connect-src 'none'", 'upgrade-insecure-requests']) {
    assert.ok(csp.includes(rule), `${path}: missing ${rule}`);
  }
  console.log(`${response.status} ${path}: HTTPS and security headers pass`);
}
