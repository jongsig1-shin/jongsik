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

    <!-- 헤더 로고/메뉴에 쓰는 폰트 — 로고는 세리프로 무게감을, 메뉴는 산세리프로 가독성을 살림 -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Serif+KR:wght@600;700&family=Noto+Sans+KR:wght@400;500;700&display=swap" rel="stylesheet">

    <script src="/Jsource/js/common.imp.js"></script>

    <title><%=webTitle%></title>

    <style>
        /* ---- 헤더/메인메뉴 — 사이트 공용 style.css의 기존 header/nav 규칙을 덮어써야 할 수 있어
           .jss- 접두어로 스코프를 주고 시각 속성은 !important로 확실히 적용함 ---- */
        .jss-header { background: #fdfbf6 !important; border-bottom: 1px solid #e7e1d2; }

        .jss-utilbar {
            display: flex !important; align-items: center; justify-content: flex-end;
            gap: 0; padding: 7px 32px; background: #17233d !important;
            font-family: "Noto Sans KR", "Malgun Gothic", sans-serif;
        }
        .jss-utilbar a { color: #cdd4e4 !important; text-decoration: none !important; font-size: 12px !important; padding: 0 12px; transition: color .15s; }
        .jss-utilbar a:hover { color: #f4e6c8 !important; }
        .jss-utilbar .jss-div { color: #445070; font-size: 11px; }

        .jss-mainrow {
            display: flex !important; align-items: center; justify-content: space-between;
            max-width: 1180px; margin: 0 auto; padding: 18px 32px; flex-wrap: wrap; gap: 12px;
        }
        .jss-logo {
            font-family: "Noto Serif KR", serif !important; font-size: 22px !important; font-weight: 700 !important;
            color: #17233d !important; text-decoration: none !important; letter-spacing: -0.01em;
            display: flex; align-items: center; gap: 8px;
        }
        .jss-logo::before { content: ""; width: 7px; height: 7px; border-radius: 50%; background: #b9862f; flex-shrink: 0; }

        .jss-menu { list-style: none !important; display: flex !important; flex-wrap: wrap; gap: 2px; margin: 0 !important; padding: 0 !important; }
        .jss-menu li { list-style: none !important; margin: 0 !important; }
        .jss-menu a {
            display: inline-block; padding: 8px 18px; font-family: "Noto Sans KR", "Malgun Gothic", sans-serif !important;
            font-size: 14.5px !important; font-weight: 500 !important; color: #2b3346 !important;
            text-decoration: none !important; letter-spacing: 0.01em; position: relative; transition: color .15s;
        }
        .jss-menu a::after {
            content: ""; position: absolute; left: 18px; right: 18px; bottom: 3px; height: 2px;
            background: #b9862f; transform: scaleX(0); transform-origin: left; transition: transform .2s ease;
        }
        .jss-menu a:hover { color: #17233d !important; }
        .jss-menu a:hover::after { transform: scaleX(1); }

        @media (max-width: 860px) {
            .jss-utilbar { padding: 6px 16px; }
            .jss-utilbar a { font-size: 11px !important; padding: 0 8px; }
            .jss-mainrow { padding: 14px 16px; }
            .jss-menu a { padding: 6px 12px; font-size: 13.5px !important; }
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

    <nav class="jss-mainrow">
        <a href="../inc/main.asp" class="jss-logo topLogo"><%=site_name%></a>

        <ul class="jss-menu">
            <li><h2><a href="../01about/about01.asp">회사소개</a></h2></li>
            <li><h2><a href="../02business/business01.asp">사업안내</a></h2></li>
            <li><h2><a href="../04gallery/list.asp?ji_num=2">갤러리</a></h2></li>
            <li><h2><a href="../05support/list.asp?ji_num=1">고객센터</a></h2></li>
            <li><h2><a href="../06ftp/list.asp?ji_num=7">자료실</a></h2></li>
            <li><h2><a href="../07admin/list.asp?ji_num=8">관리자 페이지</a></h2></li>
        </ul>
    </nav>
</header>
