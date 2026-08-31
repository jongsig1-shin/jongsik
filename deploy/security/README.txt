보안 점검에서 발견된 문제 정리 파일들입니다. 순서대로 적용해주세요.

[1] web.config (D:\Jboard\web.config 덮어쓰기)
    - .bak, .ex-, .mdf, .config, .old 처럼 정상적인 사이트 운영에서는 절대
      다운로드될 일이 없는 확장자만 사이트 전체에서 차단합니다.
    - .zip/.exe/.sql은 일부러 안 넣었습니다 — "자료실" 게시판에서 방문자에게
      실제로 그런 파일을 내려주고 있다면 사이트 전체 차단 시 그 기능이 막히기 때문입니다.
      자료실에서 안 쓰신다면 말씀해주세요, 추가해드리겠습니다.
    - 기존에 쓰던 대용량 업로드 허용 설정은 그대로 유지했습니다.
    - 이것부터 올리면, 아래 2~4번을 아직 못 끝냈어도 즉시 웹에서 해당 파일들이
      막혀서 위험이 크게 줄어듭니다.

[2] data_folder_web.config -> D:\Jboard\data\web.config 로 이름 바꿔서 새로 추가
    - data 폴더(그 안의 DB 백업 포함)를 웹에서 통째로 접근 못하게 막습니다.
    - 원래 이 폴더엔 web.config가 없었을 텐데, 새로 만들어서 넣는 것입니다.
    - ⚠️ 적용 후 꼭 확인: 관리자 페이지의 "빠른상담 신청 목록 > CSV 다운로드" 버튼이
      DB 연결 파일을 /data/db_conn/user_dbconn.asp 경로에서 서버 내부적으로 읽어옵니다.
      이건 브라우저가 직접 요청하는 게 아니라 서버 안에서만 일어나는 일이라 이 차단의
      영향을 받지 않아야 정상인데, 혹시나 하니 적용 후 CSV 다운로드가 그대로 잘 되는지
      한 번 눌러서 확인해주세요. 안 되면 바로 말씀해주시면 조정하겠습니다.

[3] jsource_setup_web.config -> D:\Jboard\Jsource\setup\web.config 로 이름 바꿔서 추가
    jsource_install_web.config -> D:\Jboard\Jsource\install\web.config 로 이름 바꿔서 추가
    - 설치 마법사/DB 생성 스크립트 폴더를 웹에서 열 수 없게 막습니다.

[4] cleanup_risky_files.ps1 (D:\Jboard 서버에서 관리자 권한 PowerShell로 실행)
    - .bak 파일 전부, Jsource\setup, Jsource\install, data\temp의 DB 백업,
      remot.ex- 실행파일을 D:\Jboard_quarantine (웹 폴더 밖)으로 옮깁니다.
    - 삭제가 아니라 이동이라 복구 가능하니 안심하고 실행하셔도 됩니다.
    - 실행법: powershell -ExecutionPolicy Bypass -File cleanup_risky_files.ps1

[5] 꼭 확인해주세요
    - D:\Jboard_quarantine\suspicious 안의 remot.ex- 파일이 본인이 올린 게 맞는지 확인.
      맞다면 그냥 두거나 필요한 곳으로 옮기시고, 모르는 파일이면 보안 전문가에게 검사를 맡기세요.
      만약 이게 지금도 사용 중인 원격지원 프로그램이라면, 스크립트 실행 전에 4번 단계를
      건너뛰고(스크립트에서 그 부분만 주석 처리하거나 수동으로 따로 옮기지 마시고) 먼저
      확인부터 해주세요 — 옮기면 그 프로그램이 그 경로를 더 이상 못 찾을 수 있습니다.
    - consult_proc.asp.bak 등에 들어있던 실제 DB 비밀번호는 이미 파일로 노출된 이력이
      있으니, 가능하면 DB 비밀번호를 새로 교체하시는 걸 권합니다.
    - 위 조치들을 다 하신 뒤에도, 브라우저에서 직접
      https://sinsung.pe.kr/data/temp/ 같은 경로로 접근해서 진짜 막혔는지 한 번 확인해보세요.
