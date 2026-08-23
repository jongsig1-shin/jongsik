<%@ LANGUAGE="VBScript" CODEPAGE="65001" %>
<%
' 빠른상담 신청 처리 스크립트 (이 파일은 UTF-8로 저장 — 위 CODEPAGE 지시자와 반드시 세트로 유지)
' 배치 위치: D:\Jboard\web\inc\consult_proc.asp (main.asp와 같은 폴더)
' <서버주소>, <새비밀번호> 는 01_setup_consult.sql에서 만든 값과 동일하게 교체하세요. (DB명은 sinsung으로 반영됨)
'
' 출력은 Response.Write 대신 ADODB.Stream으로 UTF-8 바이트를 직접 써서 내보냅니다.
' (사이트/서버의 기본 코드페이지 설정과 무관하게 항상 정확한 UTF-8이 나가도록 하기 위함)

Response.Buffer = True
Response.ContentType = "application/json"
Response.CharSet = "utf-8"
Response.Expires = -1
Response.ExpiresAbsolute = Now() - 1
Response.AddHeader "Cache-Control", "no-cache, no-store, must-revalidate"
Response.AddHeader "Pragma", "no-cache"

Sub WriteUTF8(text)
    Dim stream
    Set stream = Server.CreateObject("ADODB.Stream")
    stream.Type = 2 ' adTypeText
    stream.Charset = "utf-8"
    stream.Open
    stream.WriteText text
    stream.Position = 0
    stream.Type = 1 ' adTypeBinary
    stream.Position = 3 ' UTF-8 BOM(3바이트) 건너뛰기
    Response.BinaryWrite stream.Read
    stream.Close
    Set stream = Nothing
End Sub

Dim reqName, reqPhone, reqUnit, reqMessage, reqConsent
reqName    = Trim(Request.Form("name"))
reqPhone   = Trim(Request.Form("phone"))
reqUnit    = Trim(Request.Form("unit"))
reqMessage = Trim(Request.Form("message"))
reqConsent = Trim(Request.Form("consent"))

' 서버단 필수값 검증 (프론트 검증만 믿지 않음)
If reqName = "" Or reqPhone = "" Or reqConsent <> "1" Then
    Response.Status = "400 Bad Request"
    WriteUTF8 "{""ok"":false,""error"":""필수 항목이 누락되었습니다.""}"
    Response.End
End If

' 길이 방어 (테이블 컬럼 크기와 맞춤)
If Len(reqName) > 50 Then reqName = Left(reqName, 50)
If Len(reqPhone) > 20 Then reqPhone = Left(reqPhone, 20)
If Len(reqUnit) > 30 Then reqUnit = Left(reqUnit, 30)
If Len(reqMessage) > 500 Then reqMessage = Left(reqMessage, 500)

Dim conn, cmd
On Error Resume Next

Set conn = Server.CreateObject("ADODB.Connection")
conn.Open "Provider=SQLOLEDB;Data Source=<서버주소>;Initial Catalog=sinsung;User ID=sinsung_consult;Password=<새비밀번호>;"

If Err.Number <> 0 Then
    Response.Status = "500 Internal Server Error"
    WriteUTF8 "{""ok"":false,""error"":""DB 연결 실패""}"
    Response.End
End If

Set cmd = Server.CreateObject("ADODB.Command")
cmd.ActiveConnection = conn
' 매개변수화 쿼리 사용 — SQL 인젝션 방지를 위해 문자열 연결(& 접합) 절대 금지
cmd.CommandText = "INSERT INTO dbo.QuickConsult (Name, Phone, UnitType, Message, SourcePage, ConsentAgreed) " & _
                   "VALUES (?, ?, ?, ?, ?, 1)"

cmd.Parameters.Append cmd.CreateParameter("p_name",    200, 1, 50,  reqName)
cmd.Parameters.Append cmd.CreateParameter("p_phone",   200, 1, 20,  reqPhone)
cmd.Parameters.Append cmd.CreateParameter("p_unit",    200, 1, 30,  reqUnit)
cmd.Parameters.Append cmd.CreateParameter("p_message", 200, 1, 500, reqMessage)
cmd.Parameters.Append cmd.CreateParameter("p_source",  200, 1, 200, Left(Request.ServerVariables("HTTP_REFERER"), 200))

cmd.Execute

If Err.Number <> 0 Then
    Response.Status = "500 Internal Server Error"
    WriteUTF8 "{""ok"":false,""error"":""저장 중 오류가 발생했습니다.""}"
    conn.Close
    Response.End
End If

On Error Goto 0
conn.Close

WriteUTF8 "{""ok"":true}"
%>
