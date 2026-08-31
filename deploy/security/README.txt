보안 점검에서 발견된 문제 정리 파일들입니다. 순서대로 적용해주세요.

[1] web.config (D:\Jboard\web.config 덮어쓰기)
    - .bak, .ex-, .mdf, .sql 같은 위험한 확장자를 사이트 전체에서 차단합니다.
    - 기존에 쓰던 대용량 업로드 허용 설정은 그대로 유지했습니다.
    - 이것부터 올리면, 아래 2~4번을 아직 못 끝냈어도 즉시 웹에서 해당 파일들이
      막혀서 위험이 크게 줄어듭니다.

[2] data_folder_web.config -> D:\Jboard\data\web.config 로 이름 바꿔서 새로 추가
    - data 폴더(그 안의 DB 백업 포함)를 웹에서 통째로 접근 못하게 막습니다.
    - 원래 이 폴더엔 web.config가 없었을 텐데, 새로 만들어서 넣는 것입니다.

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
    - consult_proc.asp.bak 등에 들어있던 실제 DB 비밀번호는 이미 파일로 노출된 이력이
      있으니, 가능하면 DB 비밀번호를 새로 교체하시는 걸 권합니다.
    - 위 조치들을 다 하신 뒤에도, 브라우저에서 직접
      https://sinsung.pe.kr/data/temp/ 같은 경로로 접근해서 진짜 막혔는지 한 번 확인해보세요.
