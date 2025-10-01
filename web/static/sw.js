// 주님말씀AI Service Worker (PWA 지원)

const CACHE_NAME = 'bibleai-v1';
const urlsToCache = [
    '/',
    '/static/js/main.js'
    // 외부 CDN은 CORS 문제로 캐시에서 제외
];

// 설치 이벤트
self.addEventListener('install', function(event) {
    event.waitUntil(
        caches.open(CACHE_NAME)
            .then(function(cache) {
                console.log('캐시를 열었습니다');
                return cache.addAll(urlsToCache);
            })
            .catch(function(error) {
                console.warn('캐시 추가 실패:', error);
            })
    );
});

// 페치 이벤트
self.addEventListener('fetch', function(event) {
    event.respondWith(
        caches.match(event.request)
            .then(function(response) {
                // 캐시에서 응답을 찾았으면 반환
                if (response) {
                    return response;
                }
                return fetch(event.request);
            })
    );
});

// 활성화 이벤트
self.addEventListener('activate', function(event) {
    event.waitUntil(
        caches.keys().then(function(cacheNames) {
            return Promise.all(
                cacheNames.map(function(cacheName) {
                    if (cacheName !== CACHE_NAME) {
                        console.log('오래된 캐시를 삭제합니다:', cacheName);
                        return caches.delete(cacheName);
                    }
                })
            );
        })
    );
});