const CACHE_NAME = 'kellen-croche-v1';
const assets = [
  './',
  './index.html',
  './manifest.json',
  'https://images.unsplash.com/photo-1621419350937-be418043685f?q=80&w=800'
];

self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME).then(cache => {
      return cache.addAll(assets);
    })
  );
});

self.addEventListener('fetch', event => {
  event.respondWith(
    caches.match(event.request).then(response => {
      return response || fetch(event.request);
    })
  );
});
