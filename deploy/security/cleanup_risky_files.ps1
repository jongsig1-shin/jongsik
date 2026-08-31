# 사용법: D:\Jboard 서버에서 관리자 권한 PowerShell로 이 스크립트를 실행하세요.
#   powershell -ExecutionPolicy Bypass -File cleanup_risky_files.ps1
#
# 하는 일 (전부 "삭제"가 아니라 웹 폴더 밖 격리 폴더로 "이동"만 함 — 나중에 필요하면 복구 가능):
#   1. D:\Jboard 안의 모든 .bak 파일을 D:\Jboard_quarantine\bak_files 로 이동
#   2. Jsource\setup, Jsource\install 폴더 전체를 D:\Jboard_quarantine 로 이동
#   3. data\temp 안의 DB 백업(.bak)을 D:\Jboard_quarantine\db_backup 으로 이동
#   4. web\util, mobile\util 안의 remot.ex- 를 D:\Jboard_quarantine\suspicious 로 이동
#      (이건 자동으로 지우지 않음 — 본인이 올린 파일인지 먼저 확인 후 필요없으면 직접 삭제하세요)
#
# 실행 전: 이미 웹사이트를 쓰고 있는 IIS 프로세스가 파일을 잠그고 있으면 이동이 실패할 수 있습니다.
#          그런 경우 IIS를 잠깐 멈추고(iisreset /stop) 실행한 뒤 다시 켜주세요(iisreset /start).

$ErrorActionPreference = "Stop"

$root = "D:\Jboard"
$quarantine = "D:\Jboard_quarantine"

if (-not (Test-Path $root)) {
    Write-Host "D:\Jboard 를 찾을 수 없습니다. 경로가 다르면 이 스크립트의 `$root 값을 실제 경로로 바꿔서 실행해주세요." -ForegroundColor Red
    exit 1
}

New-Item -ItemType Directory -Force -Path $quarantine | Out-Null
New-Item -ItemType Directory -Force -Path "$quarantine\bak_files" | Out-Null
New-Item -ItemType Directory -Force -Path "$quarantine\db_backup" | Out-Null
New-Item -ItemType Directory -Force -Path "$quarantine\suspicious" | Out-Null

Write-Host "`n=== 1) .bak 파일 이동 ===" -ForegroundColor Cyan
$bakFiles = Get-ChildItem -Path $root -Filter "*.bak" -Recurse -File -ErrorAction SilentlyContinue
foreach ($f in $bakFiles) {
    $rel = $f.FullName.Substring($root.Length).TrimStart("\")
    $dest = Join-Path "$quarantine\bak_files" $rel
    New-Item -ItemType Directory -Force -Path (Split-Path $dest) | Out-Null
    Move-Item -Path $f.FullName -Destination $dest -Force
    Write-Host "이동: $rel"
}
Write-Host "총 $($bakFiles.Count)개 .bak 파일 이동 완료"

Write-Host "`n=== 2) Jsource\setup, Jsource\install 폴더 이동 ===" -ForegroundColor Cyan
foreach ($sub in @("Jsource\setup", "Jsource\install")) {
    $src = Join-Path $root $sub
    if (Test-Path $src) {
        $dest = Join-Path $quarantine $sub
        New-Item -ItemType Directory -Force -Path (Split-Path $dest) | Out-Null
        Move-Item -Path $src -Destination $dest -Force
        Write-Host "이동: $sub"
    } else {
        Write-Host "$sub 없음 (이미 정리됐거나 경로가 다름)"
    }
}

Write-Host "`n=== 3) data\temp 안의 DB 백업 파일 이동 ===" -ForegroundColor Cyan
$dbBak = Get-ChildItem -Path (Join-Path $root "data\temp") -Filter "*.bak" -File -ErrorAction SilentlyContinue
foreach ($f in $dbBak) {
    Move-Item -Path $f.FullName -Destination "$quarantine\db_backup\$($f.Name)" -Force
    Write-Host "이동: data\temp\$($f.Name)"
}

Write-Host "`n=== 4) 의심 실행파일(remot.ex-) 이동 — 자동 삭제 안 함 ===" -ForegroundColor Cyan
foreach ($sub in @("web\util\remot.ex-", "mobile\util\remot.ex-")) {
    $src = Join-Path $root $sub
    if (Test-Path $src) {
        $destName = ($sub -replace "[\\/]", "_")
        Move-Item -Path $src -Destination "$quarantine\suspicious\$destName" -Force
        Write-Host "이동: $sub  ->  격리됨 (본인이 올린 파일인지 꼭 확인해주세요)"
    }
}

Write-Host "`n완료! 격리된 파일은 D:\Jboard_quarantine 에 있습니다 (웹에서 접근 불가한 경로)." -ForegroundColor Green
Write-Host "확인 후 필요 없는 것들은 직접 지우시면 됩니다." -ForegroundColor Green
