<!-- #include virtual="/data/db_conn/user_dbconn.asp" --><!-- #include virtual="/Jsource/inc/adovbs.inc" --><%
	' 빠른상담 신청 목록 CSV 다운로드 (관리자 전용)
	' 배치 위치: D:\Jboard\web\07admin\consult_export.asp
	' user_dbconn.asp에 이미 @ 지시자가 있어서 이 파일엔 별도로 넣지 않음(ASP 0141 방지)
	' 스크립트 구분자 밖의 텍스트/공백은 그대로 응답에 섞여 나가므로, 이 파일은 시작부터 끝까지 전부 스크립트 블록 안에서만 작성함
	' (주의: ASP는 스크립트 구분자를 주석 안에서도 문자 그대로 찾기 때문에, 이 파일 안에서는 구분자 기호를 절대 텍스트로 쓰지 않음)

	Response.Buffer = True
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

	' ---- 기간 필터 (yyyy-mm-dd) — IsDate로 검증 후 Year/Month/Day로 재조립해서
	'      숫자/하이픈만 SQL 문자열에 들어가도록 하여 SQL 인젝션 여지를 없앰 ----
	Function SafeDateParam(s)
		SafeDateParam = ""
		If s <> "" And IsDate(s) Then
			Dim d
			d = CDate(s)
			SafeDateParam = Year(d) & "-" & Right("0" & Month(d), 2) & "-" & Right("0" & Day(d), 2)
		End If
	End Function

	Dim qFrom, qTo
	qFrom = SafeDateParam(Request.QueryString("from"))
	qTo   = SafeDateParam(Request.QueryString("to"))

	Dim sql, whereSql
	whereSql = ""
	If qFrom <> "" Then whereSql = whereSql & " AND RequestedAt >= '" & qFrom & "'"
	If qTo   <> "" Then whereSql = whereSql & " AND RequestedAt < DATEADD(day, 1, '" & qTo & "')"

	sql = "SELECT RequestedAt, Name, Phone, UnitType, VisitDate, Message, SourcePage, Status, HandledMemo FROM dbo.QuickConsult"
	If whereSql <> "" Then sql = sql & " WHERE " & Mid(whereSql, 6) ' 맨 앞의 " AND " 제거
	sql = sql & " ORDER BY RequestedAt DESC"

	' ---- CSV 생성 ----
	Response.ContentType = "text/csv"
	Dim csvFileName
	If qFrom <> "" Or qTo <> "" Then
		csvFileName = "quick_consult_" & qFrom & "_" & qTo & ".csv"
	Else
		csvFileName = "quick_consult.csv"
	End If
	Response.AddHeader "Content-Disposition", "attachment; filename=" & csvFileName

	Function CsvEsc(v)
		v = CStr(v & "")
		' 엑셀 수식 삽입(CSV Injection) 방지 — 공개 신청 폼에서 받은 이름/문의내용이 =, +, -, @로
		' 시작하면 엑셀이 이를 수식으로 해석해 실행할 수 있음. 앞에 작은따옴표를 붙여 순수 텍스트로 강제.
		If Len(v) > 0 Then
			Dim firstCh
			firstCh = Left(v, 1)
			If firstCh = "=" Or firstCh = "+" Or firstCh = "-" Or firstCh = "@" Then
				v = "'" & v
			End If
		End If
		v = Replace(v, """", """""")
		CsvEsc = """" & v & """"
	End Function

	' VisitDate는 방문예약 선택 건에만 값이 있고 그 외에는 NULL이라, CSV에는 빈 칸으로 나감
	Function CsvDate(v)
		If IsNull(v) Then
			CsvDate = ""
		Else
			CsvDate = Year(v) & "-" & Right("0" & Month(v), 2) & "-" & Right("0" & Day(v), 2)
		End If
	End Function

	Dim csvText
	csvText = "신청일시,이름,연락처,문의사항,방문희망일,문의내용,유입페이지,상태,상담메모" & vbCrLf

	Set rsExp = Server.CreateObject("ADODB.Recordset")
	rsExp.Open sql, db, 0, 1

	Do While Not rsExp.eof
		csvText = csvText & CsvEsc(rsExp("RequestedAt")) & "," & CsvEsc(rsExp("Name")) & "," &_
			CsvEsc(rsExp("Phone")) & "," & CsvEsc(rsExp("UnitType")) & "," &_
			CsvEsc(CsvDate(rsExp("VisitDate"))) & "," & CsvEsc(rsExp("Message")) & "," & CsvEsc(rsExp("SourcePage")) & "," &_
			CsvEsc(rsExp("Status")) & "," & CsvEsc(rsExp("HandledMemo")) & vbCrLf
		rsExp.movenext
	Loop
	rsExp.close
	Set rsExp = Nothing

	' UTF-8 BOM을 포함해서 내보내야 엑셀에서 한글이 정상적으로 보입니다.
	' (이 Stream 방식은 이미 정상 동작 확인됨 — 인코딩 문제 없음)
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
