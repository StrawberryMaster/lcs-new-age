'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter.js": "888483df48293866f9f41d3d9274a779",
"icons/lcs-64-maskable.png": "8e641e6e15d0eb0e29c414af7557a44d",
"icons/lcs-512-basic.png": "5962f4d71bf9b8bdecd9f1ead69742b6",
"icons/lcs-512-maskable.png": "a40c7559c5af8bc030ce5224b0caf9d0",
"icons/lcs-256-maskable.png": "59453f129a578c0e81efd6c9231e19ba",
"icons/lcs-128-basic.png": "8344e8afa45dfe764a56f525c8ed414f",
"icons/lcs-64-basic.png": "2316220ef28b8db51a1af09023cbda5a",
"icons/lcs-256-basic.png": "f1d80ae86af069125660a1e7e4b813af",
"icons/lcs-128-maskable.png": "428e54b1042caee7cd59dd7e0a586050",
"manifest.json": "f119e0617118de8af9f48f1c649b3da7",
"index.html": "cc1c786a0a39cc53080a9e84a307e2d3",
"/": "cc1c786a0a39cc53080a9e84a307e2d3",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin.json": "db4a992d3e200881b19f1065bfb38b71",
"assets/assets/xml/creatures.xml": "880961a35faf76aff3e30d5339b20642",
"assets/assets/xml/deptstore.xml": "4b1562455b686f279bd40f7881b1fd61",
"assets/assets/xml/armsdealer.xml": "cade7bb6236e211694cdc3a8c72a1243",
"assets/assets/xml/oubliette.xml": "2725d66349d12fced57e35d629786107",
"assets/assets/xml/pawnshop.xml": "15a1cec3aafbf14d0761dcac706860fd",
"assets/assets/xml/ammo.xml": "b1079b26e8183dd6ebf571e185f1aa11",
"assets/assets/xml/armor_upgrades.xml": "48c59be6c48fc614ae3f345eb1ae6215",
"assets/assets/xml/clothing.xml": "04731b38c1389ddd6e11f197ee4a5db3",
"assets/assets/xml/loot.xml": "d5559eae7f2a943870850f9a1ee3ce65",
"assets/assets/xml/weapons.xml": "68f9a0da64c0539f4850789ef09e395c",
"assets/assets/xml/vehicles.xml": "c289fea820c554c40257fa3f7587030f",
"assets/assets/flags/Flag_of_the_United_States.svg": "be0d3dd892b9f444330280ee044a3376",
"assets/assets/art/lacops.cmv": "a8fdbd4ba108cb03a02ef19e0b0f6445",
"assets/assets/art/3x5caps.txt": "c3dfd9f925215512073b799281cb4464",
"assets/assets/art/newstops.cpc": "646c367f78889cfe5c2f9283a0f80f49",
"assets/assets/art/newspic.cpc": "98e37b3ec80f685073bfe32a25bdabda",
"assets/assets/art/newscast.cmv": "52b2fb3c753e59f26650c7aabd0a4004",
"assets/assets/art/anchor.cmv": "8a1bbaf41d4f9bae633c7b5ad574f39a",
"assets/assets/art/abort.cmv": "48494c75c44e2094882a335f93488c28",
"assets/assets/art/5x5caps.txt": "6347ce3131a20fea87c26b4cc3aad442",
"assets/assets/art/4x5caps.txt": "dacdd30e3650252457d0f5505d2f72f5",
"assets/assets/art/3x3caps.txt": "77d6c32e83b614580478ea1b84808220",
"assets/assets/art/glamshow.cmv": "a1471c6e16cf206cc40ca7eb3b3f3a06",
"assets/assets/art/largecap.cpc": "2047ced74a7bfb9dd7a5bb1b51bc0bf6",
"assets/assets/changelog.md": "d17c4621dd6399574e2225a2c84872a5",
"assets/assets/maps/mapCSV_Bank_Specials.csv": "3d49bb440e05e49044fc1455dbce72a9",
"assets/assets/maps/mapCSV_Bank_Tiles.csv": "edf6ae2979c12b631f16da0be9b77ab5",
"assets/assets/maps/mapCSV_NuclearPlant_Tiles.csv": "e2da3eab12c62ac642ac77570e0f857a",
"assets/assets/maps/mapCSV_WhiteHouse2_Specials.csv": "a37e066b91592416f42eb16b74df08a3",
"assets/assets/maps/mapCSV_WhiteHouse_Tiles.csv": "ae2b5df3a3d20eecc12608ab43341250",
"assets/assets/maps/sitemaps.txt": "57ea87c6e088ea2d295bbb214aaddf9a",
"assets/assets/maps/mapCSV_WhiteHouse3_Tiles.csv": "cb9f94106a103a6afd308e7242f3348f",
"assets/assets/maps/mapCSV_BombShelter_Specials.csv": "fd1ee89cdc4b34e7d48e0b44dd40fd0e",
"assets/assets/maps/mapCSV_BarAndGrill_Tiles.csv": "23acf14bab733487460894c2749c49ac",
"assets/assets/maps/mapCSV_Courthouse_Tiles.csv": "1a542e5d2dbfa2191fc3e71b2945b800",
"assets/assets/maps/mapCSV_Church_Tiles.csv": "86b4b78051f06d2209ee3bed632afb8e",
"assets/assets/maps/mapCSV_BombShelter_Tiles.csv": "0ba3e854243b519ad6e7fb3cf51d032a",
"assets/assets/maps/mapCSV_Church_Specials.csv": "cf7fef4d989443284116566221c8d1ff",
"assets/assets/maps/mapCSV_BarAndGrill_Specials.csv": "63f00b948b5e3f0d07a82436b4014e59",
"assets/assets/maps/mapCSV_Courthouse_Specials.csv": "03950979257128739c48ff6c89590fa3",
"assets/assets/maps/mapCSV_Bunker_Specials.csv": "eb563e09cde9670e7831927709952d75",
"assets/assets/maps/mapCSV_NuclearPlant_Specials.csv": "21a7d5b7e3c59861950b09d803679730",
"assets/assets/maps/mapCSV_Bunker_Tiles.csv": "e9db9be966037b9e47cab81158a58b13",
"assets/assets/maps/mapCSV_WhiteHouse2_Tiles.csv": "078222b3d2ba662f6d33e2c9b363a366",
"assets/assets/maps/mapCSV_WhiteHouse3_Specials.csv": "42164c4856018f431f2ac5c49ba7365b",
"assets/assets/maps/mapCSV_WhiteHouse_Specials.csv": "ea3803956db4327bd0a72f01e5e6defb",
"assets/fonts/SourceCodePro-Regular.ttf": "4126a99d9f605a6acc9ae740b3a1ddcb",
"assets/fonts/MaterialIcons-Regular.otf": "fce3ecb1c7c14747539230bdfd11ee8e",
"assets/NOTICES": "dde13751db2c25b13da4f442ff86e971",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/FontManifest.json": "8f4791e5515ee1ab955fe8e529c2c437",
"assets/AssetManifest.bin": "7523add4af068931b3c97c41d8502eee",
"assets/AssetManifest.json": "f10ed045343a4ce7da33d544767c8a72",
"canvaskit/chromium/canvaskit.wasm": "24c77e750a7fa6d474198905249ff506",
"canvaskit/chromium/canvaskit.js": "5e27aae346eee469027c80af0751d53d",
"canvaskit/chromium/canvaskit.js.symbols": "193deaca1a1424049326d4a91ad1d88d",
"canvaskit/skwasm_heavy.wasm": "8034ad26ba2485dab2fd49bdd786837b",
"canvaskit/skwasm_heavy.js.symbols": "3c01ec03b5de6d62c34e17014d1decd3",
"canvaskit/skwasm.js": "1ef3ea3a0fec4569e5d531da25f34095",
"canvaskit/canvaskit.wasm": "07b9f5853202304d3b0749d9306573cc",
"canvaskit/skwasm_heavy.js": "413f5b2b2d9345f37de148e2544f584f",
"canvaskit/canvaskit.js": "140ccb7d34d0a55065fbd422b843add6",
"canvaskit/skwasm.wasm": "264db41426307cfc7fa44b95a7772109",
"canvaskit/canvaskit.js.symbols": "58832fbed59e00d2190aa295c4d70360",
"canvaskit/skwasm.js.symbols": "0088242d10d7e7d6d2649d1fe1bda7c1",
"favicon.png": "723c73eab748c2072d457e3416723b18",
"flutter_bootstrap.js": "3196fd43ea2ee5b5346fafd973f4f362",
"version.json": "0ab8e60862f07552ac09f7e110469527",
"main.dart.js": "777d11bcd25481aabf8e19b3e3193ce2"};
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
