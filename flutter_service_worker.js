'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"favicon.png": "b5208c328f835aa0948d8a0221f8837a",
"assets/AssetManifest.json": "4065e40e68d90831e7f56eed7334b9a2",
"assets/assets/puzzles/elements.json": "0dae07d90a267b8b3c3aa49174dd2a73",
"assets/assets/puzzles/cars.json": "c41e834ebb5f62cf6c26c0342e895202",
"assets/assets/puzzles/moons.json": "b914ecfa92ba3bbfba4bf400dd20269d",
"assets/assets/puzzles/sea-creatures.json": "24abf7b7da5110a07234a97e31879cb5",
"assets/assets/puzzles/martialarts.json": "68c3f86b177b46d9dc5fdba042a13a97",
"assets/assets/puzzles/countries.json": "67df2ea79741f131c3157ff999afc0f8",
"assets/assets/puzzles/olympics.json": "befa4cba4e3c11525772150ca468e480",
"assets/assets/puzzles/flowers.json": "adad42d846876535805716bb9f051a9d",
"assets/assets/puzzles/languages.json": "5126887cd231728aa21d884463fcc862",
"assets/assets/puzzles/capitals.json": "75d2146b66259c1b830d7da5dba43464",
"assets/assets/puzzles/currencies.json": "596db6c4291c4cd1122bd7fa3e38baed",
"assets/assets/puzzles/desserts.json": "6456c0468ba23b478b494cc1f967fb5d",
"assets/assets/puzzles/cartoons.json": "8ce8a179f4671fe46637e28a094993b6",
"assets/assets/puzzles/birds.json": "49ecf2385fbc5fbdbfe963470ab8d5ee",
"assets/assets/puzzles/fruits.json": "98180eb3addb7154d9e01d2a29751552",
"assets/assets/puzzles/emotions.json": "0e82b776383fee1dc43f4d8e64fcde4a",
"assets/assets/puzzles/scientists.json": "442200bde6c1cae839dbfe63090eb5c0",
"assets/assets/puzzles/superheroes.json": "96a1586ec40cd2f7d6e34f16dc0995c4",
"assets/assets/puzzles/animals.json": "f24d9a3a215ff7437fd30e1ea1630fc9",
"assets/assets/puzzles/vegetables.json": "9d8b6fb120f743e31d0731e9f16d0281",
"assets/assets/audio/start.mp3": "6253d309e44915e665a1514f492c7828",
"assets/assets/audio/fail.mp3": "5fe67858eb78ccf72b5738649649929c",
"assets/assets/audio/lost.mp3": "8000d7b559ad72a125c8aafeecc2cb67",
"assets/assets/audio/mismatch.mp3": "797666bb071d553b69d2104b0ab67ca6",
"assets/assets/audio/win.mp3": "99f4eaed9f4f3d46f03c73809bfe4453",
"assets/assets/audio/match.mp3": "0bbb3c31dc32cc6cb2bff1cae5ec57a8",
"assets/assets/l10n/app_en.arb": "0dd3c3556483ecc594411c28bb2cd882",
"assets/assets/l10n/app_ur.arb": "2ffcc00a4a31bcf2c72d55877a3000ab",
"assets/assets/fonts/Lilita_One/LilitaOne-Regular.ttf": "ce83b4bfa37f53ea2a3fc97088af7181",
"assets/assets/fonts/BraahOne/BraahOne-Regular.ttf": "86528aad78a0882c9c9bc63541898a2d",
"assets/assets/metadata.json": "79dfaaed99d9adb01d6318ffff32e592",
"assets/NOTICES": "cbc22e8865a0d1349f87d05510884a26",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"assets/AssetManifest.bin.json": "34259f7b1b0765c582d44347f920963f",
"assets/fonts/MaterialIcons-Regular.otf": "27ab2ba3d234e080cb272b0db116f4c4",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "1aa9671ab9755b88e071335f6e641deb",
"assets/FontManifest.json": "2970a650803a9f805edbe243924a8106",
"index.html": "5fc87e514afea235f691c719238e3158",
"/": "5fc87e514afea235f691c719238e3158",
"manifest.json": "ed75df3432748cc0d165262743036387",
"flutter_bootstrap.js": "da666085320927baf8586cb22d4c5e55",
"main.dart.js": "86971ac30a885b4d4870a04b37c264c6",
"flutter.js": "f31737fb005cd3a3c6bd9355efd33061",
"canvaskit/skwasm.js.symbols": "262f4827a1317abb59d71d6c587a93e2",
"canvaskit/canvaskit.wasm": "1f237a213d7370cf95f443d896176460",
"canvaskit/skwasm.js": "9fa2ffe90a40d062dd2343c7b84caf01",
"canvaskit/skwasm.wasm": "9f0c0c02b82a910d12ce0543ec130e60",
"canvaskit/canvaskit.js": "5fda3f1af7d6433d53b24083e2219fa0",
"canvaskit/canvaskit.js.symbols": "48c83a2ce573d9692e8d970e288d75f7",
"canvaskit/skwasm.worker.js": "bfb704a6c714a75da9ef320991e88b03",
"canvaskit/chromium/canvaskit.wasm": "b1ac05b29c127d86df4bcfbf50dd902a",
"canvaskit/chromium/canvaskit.js": "87325e67bf77a9b483250e1fb1b54677",
"canvaskit/chromium/canvaskit.js.symbols": "a012ed99ccba193cf96bb2643003f6fc",
"version.json": "43bb129801d8595238eac217d250c67d",
"icons/Icon-maskable-512.png": "ebb6881284c9c241d7db2e16f966f33a",
"icons/Icon-maskable-192.png": "206fe2d38eb8c7b837f4006105c5b961",
"icons/Icon-192.png": "206fe2d38eb8c7b837f4006105c5b961",
"icons/Icon-512.png": "ebb6881284c9c241d7db2e16f966f33a"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
