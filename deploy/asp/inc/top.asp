<!-- #include virtual="/Jsource/inc/include_common.asp" -->

<!doctype html>
<html lang="ko">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="format-detection" content="telephone=no">

    <meta name="description" content="">
    <meta property="og:title" content="<%=site_name%>">
    <meta property="og:url" content="<%=site_url%>">
    <meta property="og:description" content="">
    <meta property="og:image" content="">

    <link rel="canonical" href="<%=site_url%>">
    <link rel="shortcut icon" type="image/x-icon" href="">

    <!-- ✅ CSS는 여기서 단 한 번만 -->
    <link rel="stylesheet" href="/Jsource/css/style.css?v=20260901">

    <!-- 헤더 로고/메뉴에 쓰는 폰트 — 로고는 세리프로 무게감을, 메뉴는 산세리프로 가독성을 살림 -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Serif+KR:wght@600;700&family=Noto+Sans+KR:wght@400;500;700&display=swap" rel="stylesheet">

    <script src="/Jsource/js/common.imp.js"></script>

    <title><%=webTitle%></title>

    <style>
        /* ---- 헤더/메인메뉴 — 사이트 공용 style.css의 기존 header/nav 규칙을 덮어써야 할 수 있어
           .jss- 접두어로 스코프를 주고 시각 속성은 !important로 확실히 적용함 ---- */
        /* 기존 헤더는 한 줄짜리라 공용 CSS가 header 태그에 고정 높이 + overflow:hidden을
           걸어뒀을 가능성이 높음 — 로고+메뉴 2단으로 늘리면서 메뉴 부분이 그 높이를 넘어
           통째로 잘려 안 보이는 증상과 정확히 일치해서, header 자체의 높이 제한을 강제로 풀어줌 */
        header, .jss-header {
            height: auto !important; min-height: 0 !important; max-height: none !important;
            overflow: visible !important;
        }
        .jss-header { background: #fdfbf6 !important; border-bottom: 1px solid #e7e1d2; }

        .jss-utilbar {
            display: flex !important; align-items: center; justify-content: flex-end;
            gap: 0; padding: 7px 32px; background: #17233d !important;
            font-family: "Noto Sans KR", "Malgun Gothic", sans-serif;
        }
        .jss-utilbar a { color: #cdd4e4 !important; text-decoration: none !important; font-size: 12px !important; padding: 0 12px; transition: color .15s; }
        .jss-utilbar a:hover { color: #f4e6c8 !important; }
        .jss-utilbar .jss-div { color: #445070; font-size: 11px; }

        /* 로고를 위에, 메뉴를 아래에 각각 중앙 정렬하는 2단 구조 —
           로고/메뉴를 좌우 끝으로 벌리는 방식(space-between)은 화면이 넓을수록
           양쪽이 따로 떨어져 노는 느낌이 들어서, 중앙 정렬로 바꿔 안정적인 균형을 줌 */
        .jss-logorow {
            display: flex !important; justify-content: center; align-items: center;
            max-width: 1180px; margin: 0 auto !important; padding: 22px 32px 16px;
        }
        .jss-logo {
            font-family: "Noto Serif KR", serif !important; font-weight: 700 !important;
            color: #17233d !important; text-decoration: none !important; letter-spacing: -0.01em;
            display: flex; flex-direction: column; align-items: center; gap: 2px; text-align: center;
        }
        .jss-logo-img { height: 46px; width: auto; display: block; }
        .jss-logo-text { font-size: 23px !important; display: flex; align-items: center; gap: 8px; }
        .jss-logo-text::before, .jss-logo-text::after { content: ""; width: 6px; height: 6px; border-radius: 50%; background: #b9862f; flex-shrink: 0; }

        /* 공용 CSS/JS가 모바일 메뉴 등을 위해 nav/ul을 기본적으로 안 보이게 해뒀을 가능성이 있어
           display 외에도 visibility/height/opacity까지 명시적으로 강제해서 확실히 보이게 함 */
        .jss-menurow {
            display: block !important; visibility: visible !important; opacity: 1 !important;
            height: auto !important; max-height: none !important; overflow: visible !important;
            border-top: 1px solid #e7e1d2;
        }
        .jss-menu {
            list-style: none !important; display: flex !important; visibility: visible !important;
            opacity: 1 !important; height: auto !important; max-height: none !important; overflow: visible !important;
            justify-content: center; flex-wrap: wrap;
            gap: 4px; margin: 0 auto !important; padding: 0 32px !important; max-width: 1180px;
        }
        .jss-menu li { list-style: none !important; margin: 0 !important; display: list-item !important; visibility: visible !important; }
        .jss-menu h2 { display: inline-block !important; margin: 0 !important; font-size: inherit !important; font-weight: inherit !important; visibility: visible !important; }
        .jss-menu a {
            display: inline-block !important; visibility: visible !important; opacity: 1 !important;
            padding: 12px 22px; font-family: "Noto Sans KR", "Malgun Gothic", sans-serif !important;
            font-size: 14.5px !important; font-weight: 500 !important; color: #2b3346 !important;
            text-decoration: none !important; letter-spacing: 0.01em; position: relative; transition: color .15s;
        }
        .jss-menu a::after {
            content: ""; position: absolute; left: 22px; right: 22px; bottom: 5px; height: 2px;
            background: #b9862f; transform: scaleX(0); transform-origin: center; transition: transform .2s ease;
        }
        .jss-menu a:hover { color: #17233d !important; }
        .jss-menu a:hover::after { transform: scaleX(1); }

        /* ---- 햄버거 버튼: PC에서는 완전히 숨기고, 모바일 폭에서만 나타남 ---- */
        .jss-burger {
            display: none; align-items: center; justify-content: center;
            position: absolute; right: 14px; top: 50%; transform: translateY(-50%);
            width: 36px; height: 36px; border: 1px solid #d9c9a0; border-radius: 8px;
            background: #fff; cursor: pointer; padding: 0;
        }
        .jss-burger svg { width: 19px; height: 19px; color: #17233d; }
        .jss-burger .jss-icon-close { display: none; }
        .jss-burger.jss-open .jss-icon-menu { display: none; }
        .jss-burger.jss-open .jss-icon-close { display: block; }

        @media (max-width: 760px) {
            .jss-utilbar { padding: 6px 16px; }
            .jss-utilbar a { font-size: 11px !important; padding: 0 8px; }

            .jss-logorow { position: relative; padding: 16px 56px 14px; }
            .jss-logo-img { height: 34px; }
            .jss-logo-text { font-size: 17px !important; }
            .jss-burger { display: flex; }

            /* 접힌/펼친 상태를 max-height로 전환 — display:none을 쓰면 이번에 겪은 것과
               비슷하게 "안 보이는" 상태로 고정될 위험이 있어, 전환 애니메이션이 되는
               max-height 방식으로 처리하고 펼쳐졌을 때만 보더를 그림 */
            .jss-menurow {
                max-height: 0 !important; overflow: hidden !important; border-top: 0 !important;
                transition: max-height .25s ease;
            }
            .jss-menurow.jss-open {
                max-height: 400px !important; overflow: visible !important; border-top: 1px solid #e7e1d2 !important;
            }
            .jss-menu {
                flex-direction: column !important; align-items: stretch !important;
                gap: 0 !important; padding: 4px 20px 12px !important;
            }
            .jss-menu a {
                display: block !important; text-align: center; padding: 13px 10px;
                border-bottom: 1px solid #f1ece0;
            }
            .jss-menu a::after { display: none; }
            .jss-menu li:last-child a { border-bottom: 0; }
        }
    </style>
</head>

<body>

<header class="jss-header">
    <div class="jss-utilbar">
        <a href="http://imail.sinsung.pe.kr" target="_blank">이메일</a>
        <span class="jss-div">|</span>
        <a href="../inc/main.asp">홈</a>
        <span class="jss-div">|</span>
        <% If cookies_meID = "" Then %>
            <a href="javascript:loginCheck('<%=page_path%>');">로그인</a>
            <span class="jss-div">|</span>
            <a href="../member/member_join.asp">회원가입</a>
        <% Else %>
            <a href="javascript:logout('<%=page_path%>');">로그아웃</a>
            <span class="jss-div">|</span>
            <a href="../member/member_join.asp?mode=modify">정보수정</a>
        <% End If %>
    </div>

    <div class="jss-logorow">
        <%' 로고 이미지(D:\Jboard\web\images\sinsung_ci.png)가 혹시 없거나 경로가 바뀌어도
          ' 빈 화면이 되지 않도록 onerror로 텍스트 로고에 자동으로 대체됨 %>
        <a href="../inc/main.asp" class="jss-logo topLogo">
            <img src="/images/sinsung_ci.png" alt="<%=site_name%>" class="jss-logo-img" onerror="this.style.display='none';this.nextElementSibling.style.display='flex';">
            <span class="jss-logo-text" style="display:none;"><%=site_name%></span>
        </a>

        <button type="button" class="jss-burger" id="jssBurger" aria-label="메뉴 열기" aria-expanded="false" aria-controls="jssMenuRow">
            <svg class="jss-icon-menu" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><line x1="4" y1="7" x2="20" y2="7"></line><line x1="4" y1="12" x2="20" y2="12"></line><line x1="4" y1="17" x2="20" y2="17"></line></svg>
            <svg class="jss-icon-close" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><line x1="5" y1="5" x2="19" y2="19"></line><line x1="19" y1="5" x2="5" y2="19"></line></svg>
        </button>
    </div>

    <%' 사이트 공용 CSS/JS가 <nav> 태그를 모바일 메뉴용으로 기본 숨김 처리해두고 있을 수 있어
      ' (버튼으로 열기 전까진 안 보이는 방식) 실제로 메뉴가 사라지는 문제가 있었음 —
      ' 원래 페이지에서 멀쩡히 보이던 것과 같은 태그(div)로 감싸서 그 규칙을 피함 %>
    <div class="jss-menurow" id="jssMenuRow">
        <ul class="jss-menu">
            <li><h2><a href="../01about/about01.asp">회사소개</a></h2></li>
            <li><h2><a href="../02business/business01.asp">사업안내</a></h2></li>
            <li><h2><a href="../04gallery/list.asp?ji_num=2">갤러리</a></h2></li>
            <li><h2><a href="../05support/list.asp?ji_num=1">고객센터</a></h2></li>
            <li><h2><a href="../06ftp/list.asp?ji_num=7">자료실</a></h2></li>
            <li><h2><a href="../07admin/list.asp?ji_num=8">관리자 페이지</a></h2></li>
        </ul>
    </div>
</header>

<script>
(function () {
    var burger = document.getElementById('jssBurger');
    var menuRow = document.getElementById('jssMenuRow');
    if (!burger || !menuRow) return;

    function setOpen(open) {
        burger.classList.toggle('jss-open', open);
        menuRow.classList.toggle('jss-open', open);
        burger.setAttribute('aria-expanded', open ? 'true' : 'false');
        burger.setAttribute('aria-label', open ? '메뉴 닫기' : '메뉴 열기');
    }

    burger.addEventListener('click', function () {
        setOpen(!menuRow.classList.contains('jss-open'));
    });

    /* 메뉴 링크를 누르면 자동으로 닫힘 (같은 페이지 내 앵커 등으로 남아있는 것 방지) */
    menuRow.addEventListener('click', function (e) {
        if (e.target.tagName === 'A') setOpen(false);
    });

    /* PC 폭으로 창을 넓히면 모바일 전용 열림 상태가 어색하게 남지 않도록 정리 */
    window.addEventListener('resize', function () {
        if (window.innerWidth > 760) setOpen(false);
    });
})();
</script>
