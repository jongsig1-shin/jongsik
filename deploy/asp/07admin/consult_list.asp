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

			' 유입경로 표시용 — qr: 접두어는 배지 형태로 짧게, 그 외(리퍼러 URL 등)는 길이를 잘라서
			' 표 폭을 넓게 차지하지 않도록 함. 전체 값은 title 속성(마우스 오버)으로 확인 가능
			Function ShortSource(raw)
				Dim s
				s = raw & ""
				If Left(s, 3) = "qr:" Then
					ShortSource = "QR·" & Mid(s, 4)
				ElseIf Len(s) > 26 Then
					ShortSource = Left(s, 26) & "..."
				Else
					ShortSource = s
				End If
			End Function
		%>

		<style>
			.qc-wrap { font-family: "Malgun Gothic", "Apple SD Gothic Neo", sans-serif; color: #1f2430; }
			.qc-stats { display: flex; gap: 10px; margin-bottom: 16px; flex-wrap: wrap; }
			.qc-stat { background: #f6f7f9; border: 1px solid #e4e7ec; border-radius: 10px; padding: 10px 18px; font-size: 12.5px; color: #5b6472; }
			.qc-stat b { font-size: 17px; color: #17233d; display: block; margin-top: 2px; }
			.qc-stat.qc-stat-pending b { color: #c0392b; }

			.qc-toolbar { background: #fff; border: 1px solid #e4e7ec; border-radius: 12px; padding: 14px 18px; margin-bottom: 18px; display: flex; gap: 10px; align-items: center; flex-wrap: wrap; font-size: 13px; }
			.qc-toolbar input[type=date] { border: 1px solid #d7dbe3; border-radius: 6px; padding: 5px 8px; font-size: 13px; }
			.qc-toolbar .qc-quick a { color: #8a5a17; text-decoration: none; }
			.qc-toolbar .qc-quick a:hover { text-decoration: underline; }
			.qc-hint { color: #9aa1ad; }

			.qc-btn { display: inline-block; border-radius: 7px; padding: 6px 14px; font-size: 12.5px; font-weight: 700; text-decoration: none; border: 1px solid transparent; cursor: pointer; }
			.qc-btn-primary { background: #17233d; color: #fdfbf6; }
			.qc-btn-danger { background: #fff; color: #c0392b; border-color: #f0c1ba; }
			.qc-btn-save { background: #b9862f; color: #231604; }

			.qc-list { display: flex; flex-direction: column; gap: 10px; }
			.qc-card { background: #fff; border: 1px solid #e4e7ec; border-radius: 12px; padding: 16px 18px; }
			.qc-card-top { display: flex; align-items: center; justify-content: space-between; gap: 12px; flex-wrap: wrap; }
			.qc-name { font-size: 15px; font-weight: 900; color: #17233d; margin-right: 10px; }
			.qc-phone { font-size: 14px; color: #3a4152; font-variant-numeric: tabular-nums; }
			.qc-date { font-size: 12px; color: #8a92a3; margin-right: 10px; }
			.qc-status { display: inline-block; padding: 3px 10px; border-radius: 999px; font-size: 11.5px; font-weight: 800; }
			.qc-status-pending { background: #fdecea; color: #c0392b; }
			.qc-status-done { background: #e8f5e9; color: #2e7d32; }

			.qc-card-sub { display: flex; align-items: center; gap: 8px; margin-top: 10px; flex-wrap: wrap; }
			.qc-chip { background: #f1f0e9; color: #7a5c1e; font-size: 11.5px; font-weight: 700; padding: 3px 10px; border-radius: 999px; }
			.qc-source { font-size: 11px; color: #8a92a3; background: #f6f7f9; padding: 3px 9px; border-radius: 6px; max-width: 220px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; cursor: help; }

			.qc-card-actions { margin-top: 12px; display: flex; gap: 8px; }

			.qc-memo { margin-top: 14px; padding-top: 12px; border-top: 1px dashed #e4e7ec; }
			.qc-memo-label { font-size: 11.5px; font-weight: 800; color: #8a92a3; margin-bottom: 6px; }
			.qc-memo textarea { width: 100%; box-sizing: border-box; border: 1px solid #d7dbe3; border-radius: 8px; padding: 8px 10px; font-family: inherit; font-size: 13px; resize: vertical; }
			.qc-memo-actions { margin-top: 6px; text-align: right; }

			.qc-empty { text-align: center; padding: 40px 0; color: #8a92a3; font-size: 13px; }
			.qc-pagination { margin-top: 18px; text-align: center; font-size: 13px; color: #5b6472; }
			.qc-pagination a { color: #17233d; text-decoration: none; font-weight: 700; padding: 4px 10px; }
			.qc-pagination a:hover { text-decoration: underline; }
		</style>

		<div class="qc-wrap">
			<div class="qc-stats">
				<div class="qc-stat">전체<b><%=totalCount%>건</b></div>
				<div class="qc-stat qc-stat-pending">미처리<b><%=pendingCount%>건</b></div>
				<div class="qc-stat">완료<b><%=doneCount%>건</b></div>
			</div>

			<form method="get" action="consult_export.asp" class="qc-toolbar">
				<label>기간: <input type="date" name="from" id="expFrom"></label>
				<label>~ <input type="date" name="to" id="expTo"></label>
				<button type="submit" class="qc-btn qc-btn-primary">CSV 다운로드</button>
				<span class="qc-hint">(기간을 비워두면 전체 다운로드)</span>
				<span class="qc-quick">
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
			</script>

			<div class="qc-list">
				<%
					Set rsList = Server.CreateObject("ADODB.Recordset")
					rsList.Open "SELECT Id, RequestedAt, Name, Phone, UnitType, SourcePage, Status, HandledMemo FROM (" & _
						"SELECT ROW_NUMBER() OVER (ORDER BY RequestedAt DESC) AS RowNum, Id, RequestedAt, Name, Phone, UnitType, SourcePage, Status, HandledMemo " & _
						"FROM dbo.QuickConsult) AS T WHERE RowNum BETWEEN " & startRow & " AND " & endRow & " ORDER BY RowNum", db, 0, 1

					If rsList.bof Or rsList.eof Then
				%>
				<div class="qc-empty">신청 내역이 없습니다.</div>
				<%
					Else
						Do While Not rsList.eof
							Dim rowId, rowMemo, rowIsDone
							rowId = rsList("Id")
							rowIsDone = (rsList("Status") = "완료")
							If IsNull(rsList("HandledMemo")) Then
								rowMemo = ""
							Else
								rowMemo = rsList("HandledMemo")
							End If
				%>
				<div class="qc-card">
					<div class="qc-card-top">
						<div>
							<span class="qc-name"><%=Server.HTMLEncode(rsList("Name"))%></span>
							<span class="qc-phone"><%=Server.HTMLEncode(rsList("Phone"))%></span>
						</div>
						<div>
							<span class="qc-date"><%=rsList("RequestedAt")%></span>
							<% If rowIsDone Then %>
							<span class="qc-status qc-status-done">완료</span>
							<% Else %>
							<span class="qc-status qc-status-pending">미처리</span>
							<% End If %>
						</div>
					</div>
					<div class="qc-card-sub">
						<span class="qc-chip"><%=Server.HTMLEncode(rsList("UnitType"))%></span>
						<span class="qc-source" title="<%=Server.HTMLEncode(rsList("SourcePage"))%>"><%=Server.HTMLEncode(ShortSource(rsList("SourcePage")))%></span>
					</div>
					<div class="qc-card-actions">
						<% If Not rowIsDone Then %>
						<a class="qc-btn qc-btn-primary" href="consult_list.asp?ji_num=10&page=<%=pageNum%>&done=<%=rowId%>" onclick="return confirm('처리완료로 표시하시겠습니까?');">완료처리</a>
						<% Else %>
						<a class="qc-btn qc-btn-danger" href="consult_list.asp?ji_num=10&page=<%=pageNum%>&del=<%=rowId%>" onclick="return confirm('완료된 신청 건을 삭제하시겠습니까? 삭제 후 복구할 수 없습니다.');">삭제</a>
						<% End If %>
					</div>
					<% If rowIsDone Then %>
					<div class="qc-memo">
						<div class="qc-memo-label">상담메모</div>
						<form method="post" action="consult_list.asp?ji_num=10&page=<%=pageNum%>">
							<input type="hidden" name="memoId" value="<%=rowId%>">
							<textarea name="memoText" rows="2" maxlength="300" placeholder="상담 진행 내용을 남겨두세요 (최대 300자)"><%=Server.HTMLEncode(rowMemo)%></textarea>
							<div class="qc-memo-actions">
								<button type="submit" class="qc-btn qc-btn-save">저장</button>
							</div>
						</form>
					</div>
					<% End If %>
				</div>
				<%
							rsList.movenext
						Loop
					End If
					rsList.close
					Set rsList = Nothing
				%>
			</div>

			<div class="qc-pagination">
				<% If pageNum > 1 Then %>
					<a href="consult_list.asp?ji_num=10&page=<%=pageNum-1%>">« 이전</a>
				<% End If %>
				&nbsp;<%=pageNum%> / <%=totalPages%> 페이지&nbsp;
				<% If pageNum < totalPages Then %>
					<a href="consult_list.asp?ji_num=10&page=<%=pageNum+1%>">다음 »</a>
				<% End If %>
			</div>
		</div>
	</section>
</main>

<!-- #include virtual="/web/inc/bottom.asp" -->
