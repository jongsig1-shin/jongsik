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

        .jss-menurow {
            border-top: 1px solid #e7e1d2;
        }
        .jss-menu {
            list-style: none !important; display: flex !important; justify-content: center; flex-wrap: wrap;
            gap: 4px; margin: 0 auto !important; padding: 0 32px !important; max-width: 1180px;
        }
        .jss-menu li { list-style: none !important; margin: 0 !important; }
        .jss-menu a {
            display: inline-block; padding: 12px 22px; font-family: "Noto Sans KR", "Malgun Gothic", sans-serif !important;
            font-size: 14.5px !important; font-weight: 500 !important; color: #2b3346 !important;
            text-decoration: none !important; letter-spacing: 0.01em; position: relative; transition: color .15s;
        }
        .jss-menu a::after {
            content: ""; position: absolute; left: 22px; right: 22px; bottom: 5px; height: 2px;
            background: #b9862f; transform: scaleX(0); transform-origin: center; transition: transform .2s ease;
        }
        .jss-menu a:hover { color: #17233d !important; }
        .jss-menu a:hover::after { transform: scaleX(1); }

        @media (max-width: 860px) {
            .jss-utilbar { padding: 6px 16px; }
            .jss-utilbar a { font-size: 11px !important; padding: 0 8px; }
            .jss-logorow { padding: 18px 16px 12px; }
            .jss-logo-img { height: 38px; }
            .jss-logo-text { font-size: 19px !important; }
            .jss-menu { padding: 0 8px !important; gap: 0; }
            .jss-menu a { padding: 10px 12px; font-size: 13px !important; }
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
    </div>

    <nav class="jss-menurow">
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
