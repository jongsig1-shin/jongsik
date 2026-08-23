<%@ LANGUAGE="VBScript" CODEPAGE="65001" %>
<%
' 빠른상담 신청 목록 CSV 다운로드 (관리자 전용)
' 배치 위치: D:\Jboard\web\07admin\consult_export.asp
' 이 파일은 UTF-8로 저장 — 위 CODEPAGE 지시자와 반드시 세트로 유지
%>
<!-- #include virtual="/data/db_conn/user_dbconn.asp" -->
<!-- #include virtual="/Jsource/inc/adovbs.inc" -->
<%
	' ---- 권한 체크: 관리자(1)·운영자(2)만 접근 가능 ----
	Dim cookies_adID, cookies_meID
	cookies_adID = request.cookies("admin")("ad_id")
	cookies_meID = request.cookies("user")("me_id")
	If cookies_adID <> "" Then cookies_meID = cookies_adID

	Dim cl_class
	Set objCmdAuth = Server.CreateObject("ADODB.Command")
	With objCmdAuth
		.ActiveConnection = db
		.CommandText = "a_member_class_S"
		.CommandType = adCmdStoredProc
		.Parameters.Append .CreateParameter("@me_id", advarWchar, adParamInput, 12)
		.Parameters("@me_id") = cookies_meID
	End With
	Set rsAuth = Server.CreateObject("ADODB.Recordset")
	rsAuth.Open objCmdAuth, , adOpenForwardOnly, adLockReadOnly
	Set objCmdAuth = Nothing
	If rsAuth.bof Or rsAuth.eof Then
		cl_class = 254
	Else
		cl_class = rsAuth("cl_class")
	End If
	rsAuth.close
	Set rsAuth = Nothing

	If cl_class <> 1 And cl_class <> 2 Then
		Response.Status = "403 Forbidden"
		Response.Write "접근 권한이 없습니다."
		Response.End
	End If

	' ---- CSV 생성 ----
	Response.Buffer = True
	Response.ContentType = "text/csv"
	Response.AddHeader "Content-Disposition", "attachment; filename=quick_consult.csv"

	Function CsvEsc(v)
		v = CStr(v & "")
		v = Replace(v, """", """""")
		CsvEsc = """" & v & """"
	End Function

	Dim csvText
	csvText = "신청일시,이름,연락처,관심평형,문의내용,유입페이지,상태" & vbCrLf

	Set rsExp = Server.CreateObject("ADODB.Recordset")
	rsExp.Open "SELECT RequestedAt, Name, Phone, UnitType, Message, SourcePage, Status FROM dbo.QuickConsult ORDER BY RequestedAt DESC", db, 0, 1

	Do While Not rsExp.eof
		csvText = csvText & CsvEsc(rsExp("RequestedAt")) & "," & CsvEsc(rsExp("Name")) & "," &_
			CsvEsc(rsExp("Phone")) & "," & CsvEsc(rsExp("UnitType")) & "," &_
			CsvEsc(rsExp("Message")) & "," & CsvEsc(rsExp("SourcePage")) & "," &_
			CsvEsc(rsExp("Status")) & vbCrLf
		rsExp.movenext
	Loop
	rsExp.close
	Set rsExp = Nothing

	' UTF-8 BOM을 포함해서 내보내야 엑셀에서 한글이 정상적으로 보입니다.
	Dim stream
	Set stream = Server.CreateObject("ADODB.Stream")
	stream.Type = 2
	stream.Charset = "utf-8"
	stream.Open
	stream.WriteText csvText
	stream.Position = 0
	stream.Type = 1
	Response.BinaryWrite stream.Read
	stream.Close
	Set stream = Nothing
%>
