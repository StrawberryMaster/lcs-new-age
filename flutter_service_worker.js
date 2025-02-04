'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter.js": "c71a09214cb6f5f8996a531350400a9a",
"icons/lcs-64-maskable.png": "8e641e6e15d0eb0e29c414af7557a44d",
"icons/lcs-128-maskable.png": "428e54b1042caee7cd59dd7e0a586050",
"icons/lcs-256-basic.png": "f1d80ae86af069125660a1e7e4b813af",
"icons/lcs-512-basic.png": "5962f4d71bf9b8bdecd9f1ead69742b6",
"icons/lcs-512-maskable.png": "a40c7559c5af8bc030ce5224b0caf9d0",
"icons/lcs-64-basic.png": "2316220ef28b8db51a1af09023cbda5a",
"icons/lcs-128-basic.png": "8344e8afa45dfe764a56f525c8ed414f",
"icons/lcs-256-maskable.png": "59453f129a578c0e81efd6c9231e19ba",
"version.json": "0ab8e60862f07552ac09f7e110469527",
"manifest.json": "f119e0617118de8af9f48f1c649b3da7",
"main.dart.js": "83c7d7ed4f8ddeb9fba2dc4ee32dca87",
"index.html": "c3afc55af64576db3606591039955a64",
"/": "c3afc55af64576db3606591039955a64",
"assets/AssetManifest.json": "93b04e573b611d7a113fe9c4df6a3a50",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/fonts/MaterialIcons-Regular.otf": "0db35ae7a415370b89e807027510caf0",
"assets/fonts/SourceCodePro-Regular.ttf": "4126a99d9f605a6acc9ae740b3a1ddcb",
"assets/AssetManifest.bin": "7a9ef8c3a014ee565a9284c3faf3816e",
"assets/FontManifest.json": "a32d9287c92ba417fe1342cfb38ae964",
"assets/AssetManifest.bin.json": "ca179093a3ed03a9b2957799a5b0c999",
"assets/NOTICES": "09f0f4098838c019422c7571fe6f4e73",
"assets/assets/maps/mapCSV_Bunker_Tiles.csv": "e9db9be966037b9e47cab81158a58b13",
"assets/assets/maps/mapCSV_WhiteHouse3_Specials.csv": "42164c4856018f431f2ac5c49ba7365b",
"assets/assets/maps/mapCSV_Church_Specials.csv": "cf7fef4d989443284116566221c8d1ff",
"assets/assets/maps/mapCSV_NuclearPlant_Specials.csv": "21a7d5b7e3c59861950b09d803679730",
"assets/assets/maps/mapCSV_Courthouse_Tiles.csv": "1a542e5d2dbfa2191fc3e71b2945b800",
"assets/assets/maps/mapCSV_WhiteHouse2_Tiles.csv": "078222b3d2ba662f6d33e2c9b363a366",
"assets/assets/maps/mapCSV_WhiteHouse_Tiles.csv": "ae2b5df3a3d20eecc12608ab43341250",
"assets/assets/maps/mapCSV_NuclearPlant_Tiles.csv": "e2da3eab12c62ac642ac77570e0f857a",
"assets/assets/maps/mapCSV_Bank_Specials.csv": "3d49bb440e05e49044fc1455dbce72a9",
"assets/assets/maps/mapCSV_BombShelter_Tiles.csv": "0ba3e854243b519ad6e7fb3cf51d032a",
"assets/assets/maps/mapCSV_WhiteHouse_Specials.csv": "ea3803956db4327bd0a72f01e5e6defb",
"assets/assets/maps/mapCSV_BombShelter_Specials.csv": "fd1ee89cdc4b34e7d48e0b44dd40fd0e",
"assets/assets/maps/mapCSV_Bunker_Specials.csv": "eb563e09cde9670e7831927709952d75",
"assets/assets/maps/sitemaps.txt": "57ea87c6e088ea2d295bbb214aaddf9a",
"assets/assets/maps/mapCSV_Bank_Tiles.csv": "edf6ae2979c12b631f16da0be9b77ab5",
"assets/assets/maps/mapCSV_WhiteHouse2_Specials.csv": "a37e066b91592416f42eb16b74df08a3",
"assets/assets/maps/mapCSV_BarAndGrill_Tiles.csv": "23acf14bab733487460894c2749c49ac",
"assets/assets/maps/mapCSV_BarAndGrill_Specials.csv": "63f00b948b5e3f0d07a82436b4014e59",
"assets/assets/maps/mapCSV_Church_Tiles.csv": "86b4b78051f06d2209ee3bed632afb8e",
"assets/assets/maps/mapCSV_WhiteHouse3_Tiles.csv": "cb9f94106a103a6afd308e7242f3348f",
"assets/assets/maps/mapCSV_Courthouse_Specials.csv": "03950979257128739c48ff6c89590fa3",
"assets/assets/flags/Flag_of_the_United_States.svg": "be0d3dd892b9f444330280ee044a3376",
"assets/assets/xml/vehicles.xml": "c289fea820c554c40257fa3f7587030f",
"assets/assets/xml/clips.xml": "200b514ca9499406fd7ceedca9b67b90",
"assets/assets/xml/creatures.xml": "4d1a2f11491a81ab913ce0b35ab06e8a",
"assets/assets/xml/oubliette.xml": "3d9f857ba270d4c2a0442a9876d53418",
"assets/assets/xml/masks.xml": "22625ac2113744b59f2db21e9853f32e",
"assets/assets/xml/armsdealer.xml": "04bf12ff1624d4e1a1abbfa55a544be2",
"assets/assets/xml/loot.xml": "d5559eae7f2a943870850f9a1ee3ce65",
"assets/assets/xml/armors.xml": "011ef107f50d90e737a9b27e73b6ee73",
"assets/assets/xml/pawnshop.xml": "3dfa9460e4e69c5c6f7868e55f82bd0e",
"assets/assets/xml/weapons.xml": "9bf31c45bfa3fef78f79d149c5bcab04",
"assets/assets/xml/deptstore.xml": "1d3ae5f7df754d909edb6be5c7b22ee2",
"assets/assets/art/largecap.cpc": "2047ced74a7bfb9dd7a5bb1b51bc0bf6",
"assets/assets/art/glamshow.cmv": "a1471c6e16cf206cc40ca7eb3b3f3a06",
"assets/assets/art/anchor.cmv": "8a1bbaf41d4f9bae633c7b5ad574f39a",
"assets/assets/art/newspic.cpc": "98e37b3ec80f685073bfe32a25bdabda",
"assets/assets/art/abort.cmv": "48494c75c44e2094882a335f93488c28",
"assets/assets/art/lacops.cmv": "a8fdbd4ba108cb03a02ef19e0b0f6445",
"assets/assets/art/newstops.cpc": "646c367f78889cfe5c2f9283a0f80f49",
"assets/assets/art/newscast.cmv": "52b2fb3c753e59f26650c7aabd0a4004",
"canvaskit/canvaskit.wasm": "3d2a2d663e8c5111ac61a46367f751ac",
"canvaskit/skwasm.worker.js": "bfb704a6c714a75da9ef320991e88b03",
"canvaskit/skwasm.wasm": "e42815763c5d05bba43f9d0337fa7d84",
"canvaskit/chromium/canvaskit.wasm": "f5934e694f12929ed56a671617acd254",
"canvaskit/chromium/canvaskit.js": "43787ac5098c648979c27c13c6f804c3",
"canvaskit/chromium/canvaskit.js.symbols": "4525682ef039faeb11f24f37436dca06",
"canvaskit/canvaskit.js": "c86fbd9e7b17accae76e5ad116583dc4",
"canvaskit/canvaskit.js.symbols": "38cba9233b92472a36ff011dc21c2c9f",
"canvaskit/skwasm.js": "445e9e400085faead4493be2224d95aa",
"canvaskit/skwasm.js.symbols": "741d50ffba71f89345996b0aa8426af8",
"favicon.png": "723c73eab748c2072d457e3416723b18"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
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
