// 주님말씀AI 웹앱 - 메인 JavaScript

// SPA 탭 네비게이션 함수 (전역에서 사용 가능하도록 먼저 정의)
function showTab(tabName) {
    console.log('showTab 호출됨:', tabName);

    // 모든 탭 콘텐츠 숨기기
    document.querySelectorAll('.tab-content').forEach(content => {
        content.classList.remove('active');
        content.classList.add('hidden');
        // 직접 스타일 적용 (CSS 대체)
        content.style.display = 'none';
    });

    // 선택된 탭 콘텐츠 보이기
    const targetTab = document.getElementById(tabName + '-section');
    if (targetTab) {
        targetTab.classList.remove('hidden');
        targetTab.classList.add('active');
        // 직접 스타일 적용 (CSS 대체)
        targetTab.style.display = 'block';
        console.log('탭 전환 완료:', tabName);
    } else {
        console.error('탭을 찾을 수 없습니다:', tabName + '-section');
    }

    // 네비게이션 버튼 활성화 상태 업데이트
    updateNavigation(tabName);
}

// 네비게이션 색상 테마 설정
const NAV_THEMES = {
    'home': { text: 'text-orange-600', bg: 'bg-orange-50' },
    'bible-search': { text: 'text-blue-600', bg: 'bg-blue-50' },
    'hymns': { text: 'text-purple-600', bg: 'bg-purple-50' },
    'prayers': { text: 'text-green-600', bg: 'bg-green-50' },
    'bible-analysis': { text: 'text-orange-600', bg: 'bg-orange-50' }
};

// 경로별 탭 매핑
const PATH_TO_TAB = {
    '/': 'home',
    '/bible/search': 'bible-search',
    '/prayers': 'prayers',
    '/hymns': 'hymns',
    '/bible/analysis': 'bible-analysis'
};

// 네비게이션 버튼 스타일 클래스들
const NAV_STYLE_CLASSES = [
    'text-blue-600', 'text-blue-700', 'bg-blue-50', 'bg-blue-100',
    'text-green-600', 'text-green-700', 'bg-green-50', 'bg-green-100',
    'text-purple-600', 'text-purple-700', 'bg-purple-50', 'bg-purple-100',
    'text-orange-600', 'text-orange-700', 'bg-orange-50', 'bg-orange-100',
    'text-gray-600', 'bg-gray-50'
];

// 네비게이션 버튼 초기화
function resetNavButton(btn) {
    btn.classList.remove(...NAV_STYLE_CLASSES);
    btn.classList.add('text-gray-600', 'bg-gray-50');
}

// 네비게이션 버튼 활성화
function activateNavButton(btn, tabName) {
    const theme = NAV_THEMES[tabName];
    if (theme) {
        btn.classList.remove('text-gray-600', 'bg-gray-50');
        btn.classList.add(theme.text, theme.bg);
    }
}

// 통합된 네비게이션 업데이트 함수
function updateNavigation(activeTab) {
    console.log('updateNavigation 호출됨:', activeTab);

    document.querySelectorAll('.nav-btn').forEach(btn => {
        resetNavButton(btn);

        // SPA 모드에서는 data-tab 속성 사용
        const btnTab = btn.dataset.tab;
        if (btnTab === activeTab) {
            activateNavButton(btn, activeTab);
        }
    });
}

// 현재 페이지에 따른 네비게이션 활성화
function setActiveNavigation() {
    const currentPath = window.location.pathname;
    const activeTab = PATH_TO_TAB[currentPath];

    document.querySelectorAll('.nav-btn').forEach(btn => {
        resetNavButton(btn);

        const href = btn.getAttribute('href');
        if (href === currentPath || (currentPath === '/' && href === '/')) {
            activateNavButton(btn, activeTab);
        }
    });
}

// 전역에서 사용할 수 있도록 window 객체에 등록
window.showTab = showTab;
window.updateNavigation = updateNavigation;
window.setActiveNavigation = setActiveNavigation;

document.addEventListener('DOMContentLoaded', function() {
    console.log('주님말씀AI 웹앱이 로드되었습니다.');

    // 현재 페이지에 따른 네비게이션 활성화
    setActiveNavigation();

    // 서비스 워커 등록 (PWA 지원 준비)
    if ('serviceWorker' in navigator) {
        window.addEventListener('load', function() {
            navigator.serviceWorker.register('/static/sw.js')
                .then(function(registration) {
                    console.log('ServiceWorker 등록 성공:', registration.scope);
                }, function(err) {
                    console.log('ServiceWorker 등록 실패:', err);
                });
        });
    }

    // 모바일 터치 향상
    addTouchSupport();

    // 네트워크 상태 체크
    checkNetworkStatus();

    // 전역 에러 핸들링
    setupErrorHandling();
});

// 터치 지원 추가
function addTouchSupport() {
    // 터치 이벤트에 대한 기본 동작 개선
    document.addEventListener('touchstart', function(e) {
        // 터치 시작 시 기본 동작
    }, { passive: true });

    document.addEventListener('touchmove', function(e) {
        // 스크롤 시 기본 동작 유지
    }, { passive: true });
}

// 네트워크 상태 확인
function checkNetworkStatus() {
    function updateNetworkStatus() {
        if (navigator.onLine) {
            console.log('온라인 상태입니다.');
            hideOfflineMessage();
        } else {
            console.log('오프라인 상태입니다.');
            showOfflineMessage();
        }
    }

    window.addEventListener('online', updateNetworkStatus);
    window.addEventListener('offline', updateNetworkStatus);
    
    // 초기 상태 확인
    updateNetworkStatus();
}

// 오프라인 메시지 표시
function showOfflineMessage() {
    let offlineDiv = document.getElementById('offline-message');
    
    if (!offlineDiv) {
        offlineDiv = document.createElement('div');
        offlineDiv.id = 'offline-message';
        offlineDiv.className = 'fixed top-0 left-0 right-0 bg-yellow-500 text-white text-center py-2 px-4 text-sm z-[9996]';
        offlineDiv.innerHTML = `
            <div class="flex items-center justify-center space-x-2">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L4.082 16.5c-.77.833.192 2.5 1.732 2.5z"/>
                </svg>
                <span>인터넷 연결이 없습니다. 일부 기능이 제한될 수 있습니다.</span>
            </div>
        `;
        document.body.prepend(offlineDiv);
    }
    
    offlineDiv.classList.remove('hidden');
}

// 오프라인 메시지 숨기기
function hideOfflineMessage() {
    const offlineDiv = document.getElementById('offline-message');
    if (offlineDiv) {
        offlineDiv.classList.add('hidden');
    }
}

// 전역 에러 핸들링
function setupErrorHandling() {
    window.addEventListener('error', function(event) {
        console.error('JavaScript 에러:', event.error);
        // 사용자에게 알림 없이 조용히 로그만 남김
    });

    window.addEventListener('unhandledrejection', function(event) {
        console.error('처리되지 않은 Promise 거부:', event.reason);
    });
}

// 유틸리티 함수들
const BibleAI = {
    // 로딩 스피너 표시
    showLoading: function(elementId) {
        const element = document.getElementById(elementId);
        if (element) {
            element.classList.remove('hidden');
        }
    },

    // 로딩 스피너 숨기기
    hideLoading: function(elementId) {
        const element = document.getElementById(elementId);
        if (element) {
            element.classList.add('hidden');
        }
    },

    // 알림 표시
    showNotification: function(message, type = 'info') {
        const notification = document.createElement('div');
        const colors = {
            info: 'bg-blue-500',
            success: 'bg-green-500',
            warning: 'bg-yellow-500',
            error: 'bg-red-500'
        };

        notification.className = `fixed top-20 right-4 ${colors[type]} text-white px-4 py-2 rounded-lg shadow-lg z-[9997] transform translate-x-full transition-transform duration-300`;
        notification.textContent = message;
        
        document.body.appendChild(notification);
        
        // 애니메이션으로 표시
        setTimeout(() => {
            notification.classList.remove('translate-x-full');
        }, 10);
        
        // 3초 후 자동 제거
        setTimeout(() => {
            notification.classList.add('translate-x-full');
            setTimeout(() => {
                document.body.removeChild(notification);
            }, 300);
        }, 3000);
    },

    // API 호출 헬퍼
    api: {
        get: async function(url) {
            try {
                const response = await fetch(url);
                if (!response.ok) {
                    throw new Error(`HTTP ${response.status}: ${response.statusText}`);
                }
                return await response.json();
            } catch (error) {
                console.error('API GET 요청 실패:', error);
                throw error;
            }
        },

        post: async function(url, data) {
            try {
                const response = await fetch(url, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify(data)
                });
                
                if (!response.ok) {
                    throw new Error(`HTTP ${response.status}: ${response.statusText}`);
                }
                
                return await response.json();
            } catch (error) {
                console.error('API POST 요청 실패:', error);
                throw error;
            }
        }
    },

    // 로컬 스토리지 헬퍼
    storage: {
        set: function(key, value) {
            try {
                localStorage.setItem(key, JSON.stringify(value));
            } catch (error) {
                console.error('로컬 스토리지 저장 실패:', error);
            }
        },

        get: function(key) {
            try {
                const item = localStorage.getItem(key);
                return item ? JSON.parse(item) : null;
            } catch (error) {
                console.error('로컬 스토리지 읽기 실패:', error);
                return null;
            }
        },

        remove: function(key) {
            try {
                localStorage.removeItem(key);
            } catch (error) {
                console.error('로컬 스토리지 삭제 실패:', error);
            }
        }
    },

    // 날짜 포맷 헬퍼
    formatDate: function(date) {
        const options = { 
            year: 'numeric', 
            month: 'long', 
            day: 'numeric',
            weekday: 'long'
        };
        return new Date(date).toLocaleDateString('ko-KR', options);
    },

    // 문자열 단축
    truncate: function(str, length = 100) {
        return str.length > length ? str.substring(0, length) + '...' : str;
    }
};

// 전역에서 사용할 수 있도록 window 객체에 추가
window.BibleAI = BibleAI;