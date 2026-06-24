const CACHE_NAME = "croche-cache-v2";
const MAX_ITEMS = 10;

self.addEventListener("install", event => {
  self.skipWaiting();
});

self.addEventListener("activate", event => {
  event.waitUntil(
    caches.open(CACHE_NAME).then(cache => {
      return cache.keys().then(keys => {
        if (keys.length > MAX_ITEMS) {
          return Promise.all(
            keys.slice(0, keys.length - MAX_ITEMS).map(key => cache.delete(key))
          );
        }
      });
    })
  );
});

self.addEventListener("fetch", event => {
  event.respondWith(
    caches.open(CACHE_NAME).then(async cache => {
      const cached = await cache.match(event.request);

      const fetchPromise = fetch(event.request).then(response => {
        if (event.request.method === "GET" && response.status === 200) {
          cache.put(event.request, response.clone());

          cache.keys().then(keys => {
            if (keys.length > MAX_ITEMS) {
              cache.delete(keys[0]);
            }
          });
        }
        return response;
      });

      return cached || fetchPromise;
    })
  );
});
