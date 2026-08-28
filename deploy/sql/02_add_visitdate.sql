-- 빠른상담 "문의사항" 기능 추가용 컬럼 — 방문예약 선택 시 희망 방문일을 저장합니다.
-- 기존 QuickConsult 테이블에 컬럼만 추가하는 것이라 데이터 손실 없이 안전하게 실행됩니다.
-- SSMS에서 이 파일을 열 때 "다른 이름으로 저장 안 함"(원본 그대로) UTF-8로 열려야
-- 아래 한글 주석이 깨지지 않습니다. 실행은 sa 계정으로 접속해서 하세요.

USE [sinsung];
GO

ALTER TABLE dbo.QuickConsult ADD VisitDate DATE NULL;
GO

-- sinsung_consult 계정은 이미 이 테이블 전체(SELECT/INSERT/UPDATE)에 권한이 있어서
-- 새로 추가된 이 컬럼에 대해 별도로 GRANT를 다시 내릴 필요가 없습니다.
