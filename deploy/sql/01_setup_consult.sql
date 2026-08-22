-- 빠른상담 신청 저장용 SQL Server 계정 + 테이블 생성 스크립트
-- SSMS에서 이 파일을 열 때 "파일 - 다른 이름으로 저장 안 함" 상태(원본 그대로) UTF-8로 열려야
-- 아래 한글 주석/문자열이 깨지지 않습니다. 실행은 sa 계정으로 접속해서 하세요.
-- <새비밀번호> 는 실제 값으로 반드시 교체하세요. (DB명은 sinsung으로 고정)

USE [master];
GO

-- 1) 앱 전용 로그인 생성 (sa 대신 사용할 최소권한 계정)
CREATE LOGIN [sinsung_consult] WITH PASSWORD = N'<새비밀번호>', CHECK_POLICY = ON;
GO

-- 2) 운영 DB로 전환
USE [sinsung];
GO

CREATE USER [sinsung_consult] FOR LOGIN [sinsung_consult];
GO

-- 3) 상담 신청 저장 테이블
CREATE TABLE dbo.QuickConsult (
    Id            INT IDENTITY(1,1) PRIMARY KEY,
    RequestedAt   DATETIME       NOT NULL DEFAULT GETDATE(),
    Name          NVARCHAR(50)   NOT NULL,
    Phone         NVARCHAR(20)   NOT NULL,
    UnitType      NVARCHAR(30)   NULL,
    Message       NVARCHAR(500)  NULL,
    SourcePage    NVARCHAR(200)  NULL,
    ConsentAgreed BIT            NOT NULL DEFAULT 0,
    Status        NVARCHAR(10)   NOT NULL DEFAULT N'신규',
    HandledAt     DATETIME       NULL,
    HandledMemo   NVARCHAR(300)  NULL
);
GO

-- 4) sinsung_consult 계정은 이 테이블에만 접근 가능 (DB 전체 권한 없음)
GRANT SELECT, INSERT, UPDATE ON dbo.QuickConsult TO [sinsung_consult];
GO

-- 확인용 조회 (관리자 페이지에서 쓰는 것과 동일한 정렬)
-- SELECT * FROM dbo.QuickConsult ORDER BY RequestedAt DESC;
