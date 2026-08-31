<!-- #include virtual="/web/inc/top.asp" -->
<!-- #include virtual="/Jsource/Jnotice/list.asp" -->

<!-- 메인 슬라이드 -->
<!--
  [사용 방법]
  기존 <div class="mainSlideWrap"> ~ </div> 부분을 이 코드로 완전히 교체해 주세요.
  기존 레이아웃이나 외부 스타일과 간섭이 전혀 없도록 전용 클래스(.modern-slide-container)로 안전하게 격리 및 설계되었습니다.
-->

<!-- 프리텐다드 웹폰트 로드 (더 트렌디한 타이포그래피) -->
<link rel="stylesheet" as="style" crossorigin href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.css" />

<div class="modern-slide-container">
    <div class="modern-slide-wrap">
        <div id="modernSlide">

            <!-- 슬라이드 0 -->
            <div class="slide active">
                <img src="../images/slide0.jpg" alt="정직한 경영" width="1600" height="900">
                <div class="caption">
                    <span class="slide-tag">MANAGEMENT PHILOSOPHY</span>
                    <h1>정직한 경영</h1>
                    <p>기본에 충실한 기업</p>
                </div>
            </div>

            <!-- 슬라이드 1 -->
            <div class="slide">
                <img src="../images/slide1.jpg" alt="안정적인 운영" width="1600" height="900">
                <div class="caption">
                    <span class="slide-tag">STABLE OPERATION</span>
                    <h1>안정적인 운영</h1>
                    <p>신뢰받는 파트너</p>
                </div>
            </div>

            <!-- 슬라이드 2 -->
            <div class="slide">
                <img src="../images/slide2.jpg" alt="함께 성장하는 기업" width="1600" height="900">
                <div class="caption">
                    <span class="slide-tag">MUTUAL GROWTH</span>
                    <h1>함께 성장하는 기업</h1>
                    <p>지속 가능한 가치 창출</p>
                </div>
            </div>

            <!-- 슬라이드 3 -->
            <div class="slide">
                <img src="../images/slide3.jpg" alt="신뢰를 바탕으로 성장하는 기업" width="1600" height="900">
                <div class="caption">
                    <span class="slide-tag">SUSTAINABLE FUTURE</span>
                    <h1>신뢰를 바탕으로 성장하는 기업</h1>
                    <p>고객과 함께 지속 가능한 미래를 만듭니다</p>
                </div>
            </div>

        </div>

        <!-- 좌우 내비게이션 화살표 -->
        <button class="slide-nav prev" onclick="moveSlide(-1)" aria-label="이전 슬라이드">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"></polyline></svg>
        </button>
        <button class="slide-nav next" onclick="moveSlide(1)" aria-label="다음 슬라이드">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"></polyline></svg>
        </button>

        <!-- 하단 페이지 인디케이터 (닷) -->
        <div class="slide-indicators">
            <span class="dot active" onclick="currentSlide(0)"></span>
            <span class="dot" onclick="currentSlide(1)"></span>
            <span class="dot" onclick="currentSlide(2)"></span>
            <span class="dot" onclick="currentSlide(3)"></span>
        </div>
    </div>
</div>

<style>
/* --- 세련된 메인 슬라이드 스타일 정의 --- */

.modern-slide-container {
    width: 100%;
    margin: 0;
    padding: 0;
    box-sizing: border-box;
    font-family: 'Pretendard', -apple-system, BlinkMacSystemFont, system-ui, sans-serif;
}

.modern-slide-container * {
    box-sizing: border-box;
}

.modern-slide-wrap {
    position: relative;
    width: 100%;
    height: 480px; /* 데스크톱 최적 화면 높이 */
    overflow: hidden;
    background-color: #111;
}

/* 어둡고 고급스러운 그라데이션 레이어 (이미지 시인성 확보) */
.modern-slide-wrap::after {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: linear-gradient(to bottom, rgba(0, 0, 0, 0.05) 0%, rgba(0, 0, 0, 0.2) 100%);
    z-index: 2;
    pointer-events: none; /* 클릭 이벤트가 하단 요소에 전달되도록 함 */
}

#modernSlide {
    width: 100%;
    height: 100%;
    position: relative;
}

/* 크로스페이드 트랜지션 효과 */
#modernSlide .slide {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    opacity: 0;
    visibility: hidden;
    transition: opacity 1.2s cubic-bezier(0.25, 1, 0.5, 1), visibility 1.2s;
    z-index: 1;
}

#modernSlide .slide.active {
    opacity: 1;
    visibility: visible;
    z-index: 2;
}

#modernSlide .slide img {
    display: block;
    width: 100%;
    height: 100%;
    object-fit: cover;
    filter: brightness(95%); /* 95% 수준으로 원본에 가깝게 밝힘 */
    transform: scale(1.03); /* 부드러운 시작 느낌 — scale은 filter가 아니라 transform 속성 값임 */
    transition: transform 6s ease-out; /* 서서히 확대되는 줌 애니메이션 효과 */
}

#modernSlide .slide.active img {
    transform: scale(1); /* 활성화될 때 차분히 안착 */
}

/* 캡션 텍스트 애니메이션 (위로 떠오르며 나타남) */
#modernSlide .caption {
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -30%); /* 아래에서 부드럽게 상승 */
    text-align: center;
    color: #ffffff;
    width: 90%;
    max-width: 1200px;
    z-index: 3;
    opacity: 0;
    transition: transform 1.2s cubic-bezier(0.25, 1, 0.5, 1) 0.2s,
                opacity 1.2s cubic-bezier(0.25, 1, 0.5, 1) 0.2s;
}

#modernSlide .slide.active .caption {
    opacity: 1;
    transform: translate(-50%, -50%); /* 정확히 정중앙에 고정 */
}

/* 카테고리 태그 (상단 서브 타이틀) */
.modern-slide-wrap .slide-tag {
    display: inline-block;
    font-size: 11px;
    font-weight: 700;
    color: #3b82f6; /* 현대적인 블루 포인트 컬러 */
    letter-spacing: 2px;
    margin-bottom: 12px;
    text-transform: uppercase;
}

.modern-slide-wrap .caption h1 {
    font-size: 44px;
    font-weight: 800;
    margin: 0 0 15px 0;
    letter-spacing: -1.5px;
    word-break: keep-all;
    text-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
}

.modern-slide-wrap .caption p {
    font-size: 18px;
    font-weight: 300;
    color: #e2e8f0;
    margin: 0;
    letter-spacing: -0.5px;
    word-break: keep-all;
    text-shadow: 0 1px 5px rgba(0, 0, 0, 0.3);
}

/* 좌우 화살표 버튼 (유리 기판 스타일 효과) */
.modern-slide-wrap .slide-nav {
    position: absolute;
    top: 50%;
    transform: translateY(-50%);
    background: rgba(255, 255, 255, 0.08);
    backdrop-filter: blur(8px);
    -webkit-backdrop-filter: blur(8px);
    border: 1px solid rgba(255, 255, 255, 0.15);
    color: #fff;
    width: 48px;
    height: 48px;
    border-radius: 50%;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 4;
    transition: all 0.3s cubic-bezier(0.25, 1, 0.5, 1);
}

.modern-slide-wrap .slide-nav:hover {
    background: rgba(255, 255, 255, 0.25);
    transform: translateY(-50%) scale(1.08);
}

.modern-slide-wrap .slide-nav.prev {
    left: 30px;
}

.modern-slide-wrap .slide-nav.next {
    right: 30px;
}

/* 하단 페이지네이션 닷 */
.modern-slide-wrap .slide-indicators {
    position: absolute;
    bottom: 30px;
    left: 50%;
    transform: translateX(-50%);
    display: flex;
    gap: 8px;
    z-index: 4;
}

.modern-slide-wrap .dot {
    width: 8px;
    height: 8px;
    border-radius: 50%;
    background-color: rgba(255, 255, 255, 0.35);
    cursor: pointer;
    transition: all 0.4s cubic-bezier(0.25, 1, 0.5, 1);
}

.modern-slide-wrap .dot.active {
    width: 28px; /* 활성화 시 가로가 길어지는 알약 모형 바 */
    border-radius: 4px;
    background-color: #3b82f6; /* 포인트 컬러 일치 */
}

/* 화면 크기에 맞춰 동적으로 크기 조정 (반응형 최적화) */
@media (max-width: 768px) {
    .modern-slide-wrap {
        height: 320px; /* 모바일에서 지나치게 길지 않게 축소 */
    }
    .modern-slide-wrap .caption h1 {
        font-size: 26px;
        margin-bottom: 8px;
    }
    .modern-slide-wrap .caption p {
        font-size: 14px;
    }
    .modern-slide-wrap .slide-tag {
        font-size: 9px;
        margin-bottom: 6px;
    }
    .modern-slide-wrap .slide-nav {
        width: 38px;
        height: 38px;
    }
    .modern-slide-wrap .slide-nav.prev { left: 15px; }
    .modern-slide-wrap .slide-nav.next { right: 15px; }
    .modern-slide-wrap .slide-indicators { bottom: 20px; }
}
</style>

<script>
// 슬라이더 전역 제어 스크립트 (외부 변수와의 충돌을 막기 위해 캡슐화)
(function() {
    var container = document.querySelector(".modern-slide-container");
    if (!container) return;

    var slides = container.querySelectorAll("#modernSlide .slide");
    var dots = container.querySelectorAll(".slide-indicators .dot");
    var current = 0;
    var timer = null;

    // 슬라이드 활성화 적용 함수
    function showSlide(index) {
        // 인덱스 범위 확인 및 보정
        if (index >= slides.length) index = 0;
        if (index < 0) index = slides.length - 1;

        // 기존 active 제거
        slides[current].classList.remove("active");
        dots[current].classList.remove("active");

        // 새로운 active 지정
        slides[index].classList.add("active");
        dots[index].classList.add("active");

        current = index;
    }

    // 자동 전환 타이머 재부팅 함수
    function resetAutoPlay() {
        clearInterval(timer);
        timer = setInterval(function () {
            showSlide(current + 1);
        }, 4500); // 4.5초 간격 전환
    }

    // 좌우 화살표 버튼 작동 인터랙션
    window.moveSlide = function(direction) {
        showSlide(current + direction);
        resetAutoPlay();
    };

    // 하단 인디케이터 (닷) 직접 클릭 인터랙션
    window.currentSlide = function(index) {
        showSlide(index);
        resetAutoPlay();
    };

    // 슬라이더 초기 작동 시작
    resetAutoPlay();
})();
</script>

<div id="mainArea">
    <main>
        <ol>
            <li>
			<%=Notice("1","공지사항","default_notice","list","%","15","25","72","","","m","/web/05support/","")%>
               <!-- <%=Notice("1","공지사항","default_notice","list","","5","22","72","","","","/web/05support/","")%> -->
            </li>
            <li>
			<%=Notice("2","갤러리","default_notice","gallery","%","5","10","1032","136 91 0 0 ","","m","/web/04gallery/","")%>
                <!--<%=Notice("2","갤러리","default_notice","gallery","","5","10","1032","136 91 0 0","","","/web/04gallery/","")%> -->
            </li>
        </ol>
    </main>
</div>

<!-- #include virtual="/web/inc/bottom.asp" -->

<script>
(function () {
  var KEY = 'qcPopupHideUntil';
  var hideUntil = localStorage.getItem(KEY);
  if (hideUntil && Date.now() < parseInt(hideUntil, 10)) return;

  var frame = document.createElement('iframe');
  frame.src = '/web/inc/quick_consult_popup.html';
  frame.style.cssText = 'position:fixed;inset:0;width:100%;height:100%;border:0;z-index:99999;background:rgba(10,13,22,.55)';
  document.body.appendChild(frame);

  window.addEventListener('message', function (e) {
    if (e.data === 'qc-popup-close') {
      frame.parentNode.removeChild(frame);
    } else if (e.data === 'qc-popup-hide-today') {
      var until = Date.now() + 24 * 60 * 60 * 1000;
      localStorage.setItem(KEY, String(until));
      frame.parentNode.removeChild(frame);
    }
  });
})();
</script>
