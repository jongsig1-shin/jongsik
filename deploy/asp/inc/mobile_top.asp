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
    <link rel="stylesheet" href="/Jsource/css/style.css?v=20260512">

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Serif+KR:wght@600;700&family=Noto+Sans+KR:wght@400;500;700&display=swap" rel="stylesheet">

    <script src="/Jsource/js/common.imp.js"></script>

    <title><%=webTitle%></title>

    <style>
        /* ---- 모바일 전용 헤더 ----
           이 파일은 mobile/ 폴더 전용(모바일 기기만 default.asp가 여기로 리다이렉트)이라
           PC 대응 분기(미디어쿼리)가 필요 없음 — 처음부터 좁은 화면 기준으로만 작성.
           web/inc/top.asp와 같은 톤(남색+골드, 세리프 로고)을 쓰되 여백/글자 크기는
           360~430px대 화면에 맞춰 처음부터 다시 잡음. */
        header, .jss-header {
            height: auto !important; min-height: 0 !important; max-height: none !important;
            overflow: visible !important;
        }
        .jss-header { background: #fdfbf6 !important; border-bottom: 1px solid #e7e1d2; }

        .jss-utilbar {
            display: flex !important; align-items: center; justify-content: flex-end;
            gap: 0; padding: 6px 14px; background: #17233d !important;
            font-family: "Noto Sans KR", "Malgun Gothic", sans-serif;
        }
        .jss-utilbar a { color: #cdd4e4 !important; text-decoration: none !important; font-size: 11px !important; padding: 0 7px; }
        .jss-utilbar .jss-div { color: #445070; font-size: 10px; }

        .jss-logorow { position: relative; display: flex !important; justify-content: center; align-items: center; padding: 15px 52px 12px; }
        .jss-logo {
            font-family: "Noto Serif KR", serif !important; font-weight: 700 !important;
            color: #17233d !important; text-decoration: none !important; letter-spacing: -0.01em;
            display: flex; flex-direction: column; align-items: center; gap: 2px; text-align: center;
        }
        .jss-logo-img { height: 32px; width: auto; display: block; }
        .jss-logo-text { font-size: 17px !important; display: flex; align-items: center; gap: 6px; }
        .jss-logo-text::before, .jss-logo-text::after { content: ""; width: 5px; height: 5px; border-radius: 50%; background: #b9862f; flex-shrink: 0; }

        /* 햄버거 버튼 — 여긴 항상 모바일이라 화면폭 조건 없이 그냥 항상 보임 */
        .jss-burger {
            display: flex !important; align-items: center; justify-content: center;
            position: absolute; right: 12px; top: 50%; transform: translateY(-50%);
            width: 34px; height: 34px; border: 1px solid #d9c9a0; border-radius: 8px;
            background: #fff; cursor: pointer; padding: 0;
        }
        .jss-burger svg { width: 18px; height: 18px; color: #17233d; }
        .jss-burger .jss-icon-close { display: none; }
        .jss-burger.jss-open .jss-icon-menu { display: none; }
        .jss-burger.jss-open .jss-icon-close { display: block; }

        /* 메뉴 — 기본은 접혀 있고 햄버거 눌러야 펼쳐짐(항상) */
        .jss-menurow {
            max-height: 0 !important; overflow: hidden !important; border-top: 0 !important;
            transition: max-height .25s ease;
        }
        .jss-menurow.jss-open {
            max-height: 420px !important; overflow: visible !important; border-top: 1px solid #e7e1d2 !important;
        }
        .jss-menu {
            list-style: none !important; display: flex !important; flex-direction: column !important;
            align-items: stretch !important; gap: 0 !important; margin: 0 !important;
            padding: 4px 18px 10px !important;
        }
        .jss-menu li { list-style: none !important; margin: 0 !important; }
        .jss-menu h2 { display: block !important; margin: 0 !important; font-size: inherit !important; font-weight: inherit !important; }
        .jss-menu a {
            display: block !important; text-align: center; padding: 13px 8px;
            font-family: "Noto Sans KR", "Malgun Gothic", sans-serif !important;
            font-size: 14px !important; font-weight: 500 !important; color: #2b3346 !important;
            text-decoration: none !important; border-bottom: 1px solid #f1ece0;
        }
        .jss-menu li:last-child a { border-bottom: 0; }
        .jss-menu a:active { color: #b9862f !important; }
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

    menuRow.addEventListener('click', function (e) {
        if (e.target.tagName === 'A') setOpen(false);
    });
})();
</script>
