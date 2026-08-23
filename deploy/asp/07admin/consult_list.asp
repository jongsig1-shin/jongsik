<!-- 빠른상담 신청 목록 (관리자 전용)
     배치 위치: D:\Jboard\web\07admin\consult_list.asp
     같은 폴더의 top.asp/left.asp/bottom.asp 틀을 그대로 쓰고,
     list.asp/content.asp와 동일한 방식(admin/user 쿠키 → a_member_class_S → cl_class)으로
     관리자(1)·운영자(2)만 접근 가능하도록 보호합니다.
-->
<!-- #include virtual="/web/inc/top.asp" -->

<main>
	<!-- #include file="left.asp" -->

	<section>
		<h2>빠른상담 신청 목록</h2>

		<%
			' db 연결과 ad* 상수는 top.asp 체인에서 이미 로드되어 있어 다시 include하지 않음(ASP 0141 방지)
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
				Response.write "<script>alert('접근 권한이 없습니다.');window.location.href=""/"";</script>"
				Response.End
			End If

			' ---- 처리완료 토글 ----
			Dim actId
			actId = Request.QueryString("done")
			If actId <> "" And IsNumeric(actId) Then
				Set cmdUpd = Server.CreateObject("ADODB.Command")
				With cmdUpd
					.ActiveConnection = db
					.CommandText = "UPDATE dbo.QuickConsult SET Status=N'완료', HandledAt=GETDATE() WHERE Id=?"
					.Parameters.Append .CreateParameter("p_id", 3, 1, , CLng(actId))
				End With
				cmdUpd.Execute , , adCmdText + adExecuteNoRecords
				Set cmdUpd = Nothing
				Response.Redirect "consult_list.asp?ji_num=10"
			End If
		%>

		<p style="margin-bottom:12px;">
			<a href="consult_export.asp">CSV 다운로드</a>
		</p>

		<table border="1" cellpadding="6" cellspacing="0" style="width:100%; border-collapse:collapse; font-size:13px;">
			<tr style="background:#f2f2f2;">
				<th>신청일시</th><th>이름</th><th>연락처</th><th>관심평형</th><th>유입페이지</th><th>상태</th><th>처리</th>
			</tr>
			<%
				Set rsList = Server.CreateObject("ADODB.Recordset")
				rsList.Open "SELECT Id, RequestedAt, Name, Phone, UnitType, SourcePage, Status FROM dbo.QuickConsult ORDER BY RequestedAt DESC", db, 0, 1

				If rsList.bof Or rsList.eof Then
					Response.write "<tr><td colspan=""7"" style=""text-align:center;padding:20px;"">신청 내역이 없습니다.</td></tr>"
				Else
					Do While Not rsList.eof
			%>
			<tr>
				<td><%=rsList("RequestedAt")%></td>
				<td><%=Server.HTMLEncode(rsList("Name"))%></td>
				<td><%=Server.HTMLEncode(rsList("Phone"))%></td>
				<td><%=Server.HTMLEncode(rsList("UnitType"))%></td>
				<td><%=Server.HTMLEncode(rsList("SourcePage"))%></td>
				<td><%=rsList("Status")%></td>
				<td>
					<% If rsList("Status") <> "완료" Then %>
					<a href="consult_list.asp?ji_num=10&done=<%=rsList("Id")%>" onclick="return confirm('처리완료로 표시하시겠습니까?');">완료처리</a>
					<% Else %>
					-
					<% End If %>
				</td>
			</tr>
			<%
						rsList.movenext
					Loop
				End If
				rsList.close
				Set rsList = Nothing
			%>
		</table>
	</section>
</main>

<!-- #include virtual="/web/inc/bottom.asp" -->
