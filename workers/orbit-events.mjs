// No player identifiers, saves, request bodies, credentials or purchase data.
export function eventClock(now = Date.now()) {
  return { schema: 1, schedule: 1, serverNow: Math.floor(now / 1000) };
}
export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    if (url.pathname !== '/api/events') return env.ASSETS.fetch(request);
    const headers = {
      'Content-Type': 'application/json; charset=utf-8',
      'Cache-Control': 'no-store',
      'Strict-Transport-Security': 'max-age=31536000; includeSubDomains',
      'X-Content-Type-Options': 'nosniff',
      'Referrer-Policy': 'no-referrer',
      'Content-Security-Policy': "default-src 'none'; frame-ancestors 'none'"
    };
    if (request.method !== 'GET' && request.method !== 'HEAD') {
      return new Response('{"error":"method_not_allowed"}', {status:405, headers:{...headers, Allow:'GET, HEAD'}});
    }
    return new Response(request.method === 'HEAD' ? null : JSON.stringify(eventClock()), {headers});
  }
};
