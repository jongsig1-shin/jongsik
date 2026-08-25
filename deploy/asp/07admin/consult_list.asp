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

			' ---- 페이지 번호 (15건씩) ----
			Const PAGE_SIZE = 15
			Dim pageNum
			pageNum = Request.QueryString("page")
			If Not IsNumeric(pageNum) Or CLng(pageNum) < 1 Then
				pageNum = 1
			Else
				pageNum = CLng(pageNum)
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
				Response.Redirect "consult_list.asp?ji_num=10&page=" & pageNum
			End If

			' ---- 삭제 (완료된 건만 허용 — 서버단에서도 Status=완료 조건을 같이 검사) ----
			Dim delId
			delId = Request.QueryString("del")
			If delId <> "" And IsNumeric(delId) Then
				Set cmdDel = Server.CreateObject("ADODB.Command")
				With cmdDel
					.ActiveConnection = db
					.CommandText = "DELETE FROM dbo.QuickConsult WHERE Id=? AND Status=N'완료'"
					.Parameters.Append .CreateParameter("p_id", 3, 1, , CLng(delId))
				End With
				cmdDel.Execute , , adCmdText + adExecuteNoRecords
				Set cmdDel = Nothing
				Response.Redirect "consult_list.asp?ji_num=10&page=" & pageNum
			End If

			' ---- 상담메모 저장 (완료된 건에 한해, 답글 형태로 상담 내용 기록) ----
			Dim postMemoId
			postMemoId = Request.Form("memoId")
			If postMemoId <> "" And IsNumeric(postMemoId) Then
				Dim postMemoText
				postMemoText = Trim(Request.Form("memoText"))
				If Len(postMemoText) > 300 Then postMemoText = Left(postMemoText, 300)
				Set cmdMemo = Server.CreateObject("ADODB.Command")
				With cmdMemo
					.ActiveConnection = db
					.CommandText = "UPDATE dbo.QuickConsult SET HandledMemo=? WHERE Id=? AND Status=N'완료'"
					.Parameters.Append .CreateParameter("p_memo", 200, 1, 300, postMemoText)
					.Parameters.Append .CreateParameter("p_id", 3, 1, , CLng(postMemoId))
				End With
				cmdMemo.Execute , , adCmdText + adExecuteNoRecords
				Set cmdMemo = Nothing
				Response.Redirect "consult_list.asp?ji_num=10&page=" & pageNum
			End If

			' ---- 전체/미처리/완료 건수 ----
			Dim totalCount, doneCount, pendingCount
			Set rsCount = Server.CreateObject("ADODB.Recordset")
			rsCount.Open "SELECT COUNT(*) AS cnt, SUM(CASE WHEN Status=N'완료' THEN 1 ELSE 0 END) AS doneCnt FROM dbo.QuickConsult", db, 0, 1
			totalCount = rsCount("cnt")
			If IsNull(rsCount("doneCnt")) Then
				doneCount = 0
			Else
				doneCount = rsCount("doneCnt")
			End If
			pendingCount = totalCount - doneCount
			rsCount.close
			Set rsCount = Nothing

			Dim totalPages
			If totalCount = 0 Then
				totalPages = 1
			Else
				totalPages = Int((totalCount - 1) / PAGE_SIZE) + 1
			End If
			If pageNum > totalPages Then pageNum = totalPages

			Dim startRow, endRow
			startRow = (pageNum - 1) * PAGE_SIZE + 1
			endRow = pageNum * PAGE_SIZE
		%>

		<p style="margin-bottom:10px; color:#555;">
			전체 <b><%=totalCount%></b>건 · 미처리 <b style="color:#c0392b;"><%=pendingCount%></b>건 · 완료 <b><%=doneCount%></b>건
		</p>

		<form method="get" action="consult_export.asp" style="margin-bottom:16px; display:flex; gap:8px; align-items:center; flex-wrap:wrap; font-size:13px;">
			<label>기간: <input type="date" name="from" id="expFrom"></label>
			<label>~ <input type="date" name="to" id="expTo"></label>
			<button type="submit">CSV 다운로드</button>
			<span style="color:#888;">(기간을 비워두면 전체 다운로드)</span>
			<span style="margin-left:8px;">
				<a href="javascript:void(0)" onclick="setRange(0)">오늘</a> ·
				<a href="javascript:void(0)" onclick="setRange(6)">최근 7일</a> ·
				<a href="javascript:void(0)" onclick="setRange(29)">최근 30일</a>
			</span>
		</form>
		<script>
		function pad2(n) { return (n < 10 ? '0' : '') + n; }
		function toDateStr(d) { return d.getFullYear() + '-' + pad2(d.getMonth() + 1) + '-' + pad2(d.getDate()); }
		function setRange(daysBack) {
			var to = new Date();
			var from = new Date();
			from.setDate(to.getDate() - daysBack);
			document.getElementById('expFrom').value = toDateStr(from);
			document.getElementById('expTo').value = toDateStr(to);
		}
		function toggleMemo(id) {
			var row = document.getElementById('memoRow_' + id);
			if (!row) return;
			row.style.display = (row.style.display === 'none' || row.style.display === '') ? 'table-row' : 'none';
		}
		</script>

		<table border="1" cellpadding="6" cellspacing="0" style="width:100%; border-collapse:collapse; font-size:13px;">
			<tr style="background:#f2f2f2;">
				<th>신청일시</th><th>이름</th><th>연락처</th><th>관심평형</th><th>유입페이지</th><th>상태</th><th>상담메모</th><th>처리</th>
			</tr>
			<%
				Set rsList = Server.CreateObject("ADODB.Recordset")
				rsList.Open "SELECT Id, RequestedAt, Name, Phone, UnitType, SourcePage, Status, HandledMemo FROM (" & _
					"SELECT ROW_NUMBER() OVER (ORDER BY RequestedAt DESC) AS RowNum, Id, RequestedAt, Name, Phone, UnitType, SourcePage, Status, HandledMemo " & _
					"FROM dbo.QuickConsult) AS T WHERE RowNum BETWEEN " & startRow & " AND " & endRow & " ORDER BY RowNum", db, 0, 1

				If rsList.bof Or rsList.eof Then
					Response.write "<tr><td colspan=""8"" style=""text-align:center;padding:20px;"">신청 내역이 없습니다.</td></tr>"
				Else
					Do While Not rsList.eof
						Dim rowId, rowMemo, rowMemoPreview
						rowId = rsList("Id")
						If IsNull(rsList("HandledMemo")) Then
							rowMemo = ""
						Else
							rowMemo = rsList("HandledMemo")
						End If
						If rowMemo = "" Then
							rowMemoPreview = "-"
						ElseIf Len(rowMemo) > 20 Then
							rowMemoPreview = Server.HTMLEncode(Left(rowMemo, 20)) & "..."
						Else
							rowMemoPreview = Server.HTMLEncode(rowMemo)
						End If
			%>
			<tr>
				<td><%=rsList("RequestedAt")%></td>
				<td><%=Server.HTMLEncode(rsList("Name"))%></td>
				<td><%=Server.HTMLEncode(rsList("Phone"))%></td>
				<td><%=Server.HTMLEncode(rsList("UnitType"))%></td>
				<td><%=Server.HTMLEncode(rsList("SourcePage"))%></td>
				<td><%=rsList("Status")%></td>
				<td><%=rowMemoPreview%></td>
				<td>
					<% If rsList("Status") <> "완료" Then %>
					<a href="consult_list.asp?ji_num=10&page=<%=pageNum%>&done=<%=rowId%>" onclick="return confirm('처리완료로 표시하시겠습니까?');">완료처리</a>
					<% Else %>
					<a href="javascript:void(0)" onclick="toggleMemo(<%=rowId%>)">메모입력</a>
					&nbsp;|&nbsp;
					<a href="consult_list.asp?ji_num=10&page=<%=pageNum%>&del=<%=rowId%>" onclick="return confirm('완료된 신청 건을 삭제하시겠습니까? 삭제 후 복구할 수 없습니다.');" style="color:#c0392b;">삭제</a>
					<% End If %>
				</td>
			</tr>
			<% If rsList("Status") = "완료" Then %>
			<tr id="memoRow_<%=rowId%>" style="display:none;">
				<td colspan="8" style="background:#fafafa;">
					<form method="post" action="consult_list.asp?ji_num=10&page=<%=pageNum%>">
						<input type="hidden" name="memoId" value="<%=rowId%>">
						<textarea name="memoText" rows="3" maxlength="300" style="width:100%; box-sizing:border-box; font-family:inherit; font-size:13px;" placeholder="상담 진행 내용을 답글 형태로 남겨두세요 (최대 300자)"><%=Server.HTMLEncode(rowMemo)%></textarea>
						<button type="submit" style="margin-top:6px;">저장</button>
					</form>
				</td>
			</tr>
			<% End If %>
			<%
						rsList.movenext
					Loop
				End If
				rsList.close
				Set rsList = Nothing
			%>
		</table>

		<p style="margin-top:14px; font-size:13px;">
			<% If pageNum > 1 Then %>
				<a href="consult_list.asp?ji_num=10&page=<%=pageNum-1%>">« 이전</a>
			<% End If %>
			&nbsp;<%=pageNum%> / <%=totalPages%> 페이지&nbsp;
			<% If pageNum < totalPages Then %>
				<a href="consult_list.asp?ji_num=10&page=<%=pageNum+1%>">다음 »</a>
			<% End If %>
		</p>
	</section>
</main>

<!-- #include virtual="/web/inc/bottom.asp" -->
