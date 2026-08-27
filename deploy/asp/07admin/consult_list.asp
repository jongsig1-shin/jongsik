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
			' ---- PC에서 새로고침해도 브라우저에 남아있던 예전 화면이 아니라 항상 서버의 최신 내용을 받도록 캐시 방지 ----
			' (top.asp가 이미 실행됐지만 IIS 기본 버퍼링 덕분에 아직 실제로 전송되지는 않은 시점이라 헤더 추가 가능 —
			'  이 파일의 Response.Redirect들이 top.asp 이후에도 정상 동작하는 것과 같은 원리)
			Response.CacheControl = "no-cache"
			Response.AddHeader "Pragma", "no-cache"
			Response.Expires = -1
			Response.ExpiresAbsolute = Now() - 1

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

			' ---- 페이지 번호 (한 줄 표기로 바뀌어 카드 방식보다 훨씬 짧아졌으므로 15건씩) ----
			Const PAGE_SIZE = 15
			Dim pageNum
			pageNum = Request.QueryString("page")
			If Not IsNumeric(pageNum) Or CLng(pageNum) < 1 Then
				pageNum = 1
			Else
				pageNum = CLng(pageNum)
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

			' ---- 상담처리(완료 표시) + 상담메모 저장을 하나의 팝업창에서 한 번에 처리 ----
			' markDone=1 이면 미처리 건을 완료로 바꾸면서 메모도 같이 저장,
			' markDone=0 이면(이미 완료된 건의 "상담내용보기") 메모만 수정 저장
			Dim postMemoId
			postMemoId = Request.Form("memoId")
			If postMemoId <> "" And IsNumeric(postMemoId) Then
				Dim postMemoText, postMarkDone
				postMemoText = Trim(Request.Form("memoText"))
				If Len(postMemoText) > 300 Then postMemoText = Left(postMemoText, 300)
				postMarkDone = Request.Form("markDone")

				Set cmdMemo = Server.CreateObject("ADODB.Command")
				With cmdMemo
					.ActiveConnection = db
					If postMarkDone = "1" Then
						.CommandText = "UPDATE dbo.QuickConsult SET Status=N'완료', HandledAt=GETDATE(), HandledMemo=? WHERE Id=?"
					Else
						.CommandText = "UPDATE dbo.QuickConsult SET HandledMemo=? WHERE Id=? AND Status=N'완료'"
					End If
					.Parameters.Append .CreateParameter("p_memo", 200, 1, 300, postMemoText)
					.Parameters.Append .CreateParameter("p_id", 3, 1, , CLng(postMemoId))
				End With
				cmdMemo.Execute , , adCmdText + adExecuteNoRecords
				Set cmdMemo = Nothing
				Response.Redirect "consult_list.asp?ji_num=10&page=" & pageNum
			End If

			' ---- 전화상담 수동 등록 (전화로 직접 문의받은 건을 유입경로 '전화상담'으로 리스트에 추가) ----
			If Request.Form("addPhone") = "1" Then
				Dim apName, apPhone, apUnit, apMemo, apDone
				apName = Trim(Request.Form("apName"))
				apPhone = Trim(Request.Form("apPhone"))
				apUnit = Trim(Request.Form("apUnit"))
				apMemo = Trim(Request.Form("apMemo"))
				apDone = Request.Form("apDone")

				If Len(apName) > 50 Then apName = Left(apName, 50)
				apPhone = FormatPhone(apPhone)
				If Len(apPhone) > 20 Then apPhone = Left(apPhone, 20)
				If Len(apUnit) > 30 Then apUnit = Left(apUnit, 30)
				If Len(apMemo) > 300 Then apMemo = Left(apMemo, 300)

				If apName <> "" And apPhone <> "" Then
					Set cmdAdd = Server.CreateObject("ADODB.Command")
					With cmdAdd
						.ActiveConnection = db
						If apDone = "1" Then
							.CommandText = "INSERT INTO dbo.QuickConsult (Name, Phone, UnitType, SourcePage, ConsentAgreed, Status, HandledAt, HandledMemo) " & _
								"VALUES (?, ?, ?, N'전화상담', 1, N'완료', GETDATE(), ?)"
						Else
							.CommandText = "INSERT INTO dbo.QuickConsult (Name, Phone, UnitType, SourcePage, ConsentAgreed, HandledMemo) " & _
								"VALUES (?, ?, ?, N'전화상담', 1, ?)"
						End If
						.Parameters.Append .CreateParameter("p_name", 200, 1, 50, apName)
						.Parameters.Append .CreateParameter("p_phone", 200, 1, 20, apPhone)
						.Parameters.Append .CreateParameter("p_unit", 200, 1, 30, apUnit)
						.Parameters.Append .CreateParameter("p_memo", 200, 1, 300, apMemo)
					End With
					cmdAdd.Execute , , adCmdText + adExecuteNoRecords
					Set cmdAdd = Nothing
				End If
				Response.Redirect "consult_list.asp?ji_num=10&page=1"
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
				ElseIf Len(s) > 18 Then
					ShortSource = Left(s, 18) & "..."
				Else
					ShortSource = s
				End If
			End Function

			' 신청일시를 서버 지역설정과 무관하게 항상 같은 짧은 형식(yyyy-mm-dd hh:mm)으로 표시
			' — rsList("RequestedAt")를 그대로 출력하면 서버 설정에 따라 길이가 달라져서
			'    "신청일시" 칸 폭을 예측할 수 없고, 옆의 "이름" 칸과 겹쳐 보일 수 있음
			Function FormatCompactDate(dt)
				FormatCompactDate = Year(dt) & "-" & Right("0" & Month(dt), 2) & "-" & Right("0" & Day(dt), 2) & _
					" " & Right("0" & Hour(dt), 2) & ":" & Right("0" & Minute(dt), 2)
			End Function

			' 연락처를 숫자만 추려서 010-1234-5678 형식으로 재구성 (consult_proc.asp의 동명 함수와 동일 규칙 —
			' QR로 들어온 신청과 전화상담 수동 등록 건의 연락처 표기를 통일하기 위함)
			Function FormatPhone(raw)
				Dim i, ch, digits
				digits = ""
				For i = 1 To Len(raw)
					ch = Mid(raw, i, 1)
					If ch >= "0" And ch <= "9" Then digits = digits & ch
				Next

				Select Case Len(digits)
					Case 11
						FormatPhone = Left(digits, 3) & "-" & Mid(digits, 4, 4) & "-" & Mid(digits, 8, 4)
					Case 10
						If Left(digits, 2) = "02" Then
							FormatPhone = Left(digits, 2) & "-" & Mid(digits, 3, 4) & "-" & Mid(digits, 7, 4)
						Else
							FormatPhone = Left(digits, 3) & "-" & Mid(digits, 4, 3) & "-" & Mid(digits, 7, 4)
						End If
					Case 9
						FormatPhone = Left(digits, 2) & "-" & Mid(digits, 3, 3) & "-" & Mid(digits, 6, 4)
					Case Else
						FormatPhone = raw
				End Select
			End Function
		%>

		<style>
			.qc-wrap { font-family: "Malgun Gothic", "Apple SD Gothic Neo", sans-serif; color: #1f2430; }
			.qc-stats { display: flex; gap: 10px; margin-bottom: 16px; flex-wrap: wrap; }
			.qc-stat { background: #f6f7f9; border: 1px solid #e4e7ec; border-radius: 10px; padding: 10px 18px; font-size: 12.5px; color: #5b6472; }
			.qc-stat b { font-size: 17px; color: #17233d; display: block; margin-top: 2px; }
			.qc-stat.qc-stat-pending b { color: #c0392b; }

			.qc-toolbar { background: #fff; border: 1px solid #e4e7ec; border-radius: 12px; padding: 14px 18px; margin-bottom: 12px; display: flex; gap: 10px; align-items: center; flex-wrap: wrap; font-size: 13px; }
			.qc-toolbar input[type=date] { border: 1px solid #d7dbe3; border-radius: 6px; padding: 5px 8px; font-size: 13px; }
			.qc-toolbar .qc-quick a { color: #8a5a17; text-decoration: none; }
			.qc-toolbar .qc-quick a:hover { text-decoration: underline; }
			.qc-hint { color: #9aa1ad; }

			.qc-search { margin-bottom: 14px; display: flex; gap: 8px; align-items: center; flex-wrap: wrap; }
			.qc-search input {
				flex: 1 1 auto; width: 100%; max-width: 320px; box-sizing: border-box;
				border: 1px solid #d7dbe3; border-radius: 8px; padding: 8px 12px; font-size: 13px; font-family: inherit;
			}

			.qc-btn, a.qc-btn:link, a.qc-btn:visited { display: inline-block; border-radius: 7px; padding: 6px 14px; font-size: 12.5px; font-weight: 700; text-decoration: none; border: 1px solid transparent; cursor: pointer; white-space: nowrap; }
			.qc-btn-primary, a.qc-btn-primary:link, a.qc-btn-primary:visited, a.qc-btn-primary:hover { background: #17233d !important; color: #fdfbf6 !important; }
			.qc-btn-ghost, a.qc-btn-ghost:link, a.qc-btn-ghost:visited, a.qc-btn-ghost:hover { background: #fff !important; color: #17233d !important; border-color: #c7ccd6; }
			.qc-btn-danger, a.qc-btn-danger:link, a.qc-btn-danger:visited, a.qc-btn-danger:hover { background: #fff !important; color: #c0392b !important; border-color: #f0c1ba; }
			.qc-btn-save { background: #b9862f !important; color: #231604 !important; }

			/* ---- 한 줄 표기 목록 (CSS Grid) ---- */
			.qc-table-wrap { border: 1px solid #e4e7ec; border-radius: 12px; background: #fff; overflow-x: auto; }
			.qc-table { display: grid; grid-template-columns: 150px 66px 118px 92px minmax(90px,1fr) 60px auto; min-width: 820px; }
			.qc-row { display: contents; }
			.qc-thead, .qc-row-cell { padding: 10px 12px; display: flex; align-items: center; border-bottom: 1px solid #eef0f3; font-size: 12.5px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
			.qc-thead { background: #f6f7f9; font-size: 11px; font-weight: 800; color: #8a92a3; }
			.qc-row-cell { color: #1f2430; }

			.qc-r-name { font-weight: 900; color: #17233d; overflow: hidden; text-overflow: ellipsis; }
			.qc-r-date { color: #8a92a3; font-size: 11.5px; }
			.qc-r-phone { font-variant-numeric: tabular-nums; }
			.qc-chip { background: #f1f0e9; color: #7a5c1e; font-size: 11px; font-weight: 700; padding: 2px 9px; border-radius: 999px; white-space: nowrap; }
			.qc-source { font-size: 10.5px; color: #8a92a3; background: #f6f7f9; padding: 2px 8px; border-radius: 6px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; cursor: help; max-width: 100%; }
			.qc-status { display: inline-block; padding: 2px 9px; border-radius: 999px; font-size: 10.5px; font-weight: 800; }
			.qc-status-pending { background: #fdecea; color: #c0392b; }
			.qc-status-done { background: #e8f5e9; color: #2e7d32; }
			.qc-r-actions { gap: 6px; }
			.qc-memo-flag { color: #b9862f; font-size: 13px; margin-left: 2px; }

			.qc-empty { text-align: center; padding: 40px 0; color: #8a92a3; font-size: 13px; }
			.qc-pagination { margin-top: 18px; text-align: center; font-size: 13px; color: #5b6472; }
			.qc-pagination a { color: #17233d; text-decoration: none; font-weight: 700; padding: 4px 10px; }
			.qc-pagination a:hover { text-decoration: underline; }

			/* ---- 상담메모 입력/보기 모달 ---- */
			.qc-modal-overlay {
				display: none; position: fixed; inset: 0; z-index: 999;
				background: rgba(15,20,30,0.5);
				align-items: center; justify-content: center; padding: 16px;
			}
			.qc-modal-overlay.show { display: flex; }
			.qc-modal { background: #fff; border-radius: 14px; width: 100%; max-width: 460px; padding: 22px 24px; box-shadow: 0 30px 60px -20px rgba(0,0,0,0.4); }
			.qc-modal h3 { margin: 0 0 4px; font-size: 16px; color: #17233d; }
			.qc-modal .qc-modal-sub { margin: 0 0 14px; font-size: 12px; color: #8a92a3; }
			.qc-modal textarea { width: 100%; box-sizing: border-box; border: 1px solid #d7dbe3; border-radius: 8px; padding: 10px 12px; font-family: inherit; font-size: 13.5px; resize: vertical; }
			.qc-modal-field { margin-bottom: 12px; }
			.qc-modal-field label { display: block; font-size: 12px; font-weight: 700; color: #5b6472; margin-bottom: 5px; }
			.qc-modal-field input, .qc-modal-field select { width: 100% !important; max-width: none !important; box-sizing: border-box; border: 1px solid #d7dbe3; border-radius: 8px; padding: 9px 30px 9px 12px; font-family: inherit; font-size: 13.5px; line-height: normal; }
			.qc-modal-field select { min-width: 0; height: 40px !important; padding-top: 0 !important; padding-bottom: 0 !important; }
			.qc-modal-check { display: flex; align-items: center; gap: 8px; font-size: 12.5px; color: #5b6472; margin-top: 4px; }
			.qc-modal-actions { margin-top: 14px; display: flex; justify-content: flex-end; gap: 8px; }

			/* ---- 모바일 화면 대응 ---- */
			@media (max-width: 640px) {
				.qc-stats { gap: 8px; }
				.qc-stat { flex: 1 1 auto; padding: 8px 10px; text-align: center; }
				.qc-toolbar { padding: 12px; }
				.qc-toolbar label { flex: 1 1 auto; }
				.qc-toolbar input[type=date] { width: 100%; }
				.qc-toolbar .qc-quick { width: 100%; }
				.qc-search input { max-width: none; }
			}
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

			<div class="qc-search">
				<input type="text" id="qcFilter" placeholder="이름 또는 연락처로 이 페이지 안에서 찾기" oninput="filterRows(this.value)">
				<button type="button" class="qc-btn qc-btn-ghost" onclick="openAddPhoneModal()">📞 전화상담 등록</button>
			</div>

			<div class="qc-table-wrap">
				<div class="qc-table" id="qcTable">
					<div class="qc-thead">신청일시</div>
					<div class="qc-thead">이름</div>
					<div class="qc-thead">연락처</div>
					<div class="qc-thead">관심평형</div>
					<div class="qc-thead">유입경로</div>
					<div class="qc-thead">상태</div>
					<div class="qc-thead">처리</div>
					<%
						Set rsList = Server.CreateObject("ADODB.Recordset")
						rsList.Open "SELECT Id, RequestedAt, Name, Phone, UnitType, SourcePage, Status, HandledMemo FROM (" & _
							"SELECT ROW_NUMBER() OVER (ORDER BY RequestedAt DESC) AS RowNum, Id, RequestedAt, Name, Phone, UnitType, SourcePage, Status, HandledMemo " & _
							"FROM dbo.QuickConsult) AS T WHERE RowNum BETWEEN " & startRow & " AND " & endRow & " ORDER BY RowNum", db, 0, 1

						If rsList.bof Or rsList.eof Then
					%>
					<div class="qc-empty" style="grid-column: 1 / -1;">신청 내역이 없습니다.</div>
					<%
						Else
							Do While Not rsList.eof
								Dim rowId, rowMemo, rowIsDone, rowNameEnc, rowPhoneEnc
								rowId = rsList("Id")
								rowIsDone = (rsList("Status") = "완료")
								rowNameEnc = Server.HTMLEncode(rsList("Name"))
								rowPhoneEnc = Server.HTMLEncode(rsList("Phone"))
								If IsNull(rsList("HandledMemo")) Then
									rowMemo = ""
								Else
									rowMemo = rsList("HandledMemo")
								End If
					%>
					<div class="qc-row" data-key="<%=LCase(rowNameEnc)%> <%=LCase(rowPhoneEnc)%>">
						<div class="qc-row-cell qc-r-date"><%=FormatCompactDate(rsList("RequestedAt"))%></div>
						<div class="qc-row-cell qc-r-name"><%=rowNameEnc%></div>
						<div class="qc-row-cell qc-r-phone"><%=rowPhoneEnc%></div>
						<div class="qc-row-cell"><% If rsList("UnitType") <> "" Then %><span class="qc-chip"><%=Server.HTMLEncode(rsList("UnitType"))%></span><% End If %></div>
						<div class="qc-row-cell"><span class="qc-source" title="<%=Server.HTMLEncode(rsList("SourcePage"))%>"><%=Server.HTMLEncode(ShortSource(rsList("SourcePage")))%></span></div>
						<div class="qc-row-cell">
							<% If rowIsDone Then %>
							<span class="qc-status qc-status-done">완료</span>
							<% Else %>
							<span class="qc-status qc-status-pending">미처리</span>
							<% End If %>
						</div>
						<div class="qc-row-cell qc-r-actions">
							<% If Not rowIsDone Then %>
							<a class="qc-btn qc-btn-primary" href="javascript:void(0)" data-id="<%=rowId%>" data-memo="" data-done="1" onclick="openMemoModal(this)">상담처리</a>
							<% Else %>
							<a class="qc-btn qc-btn-ghost" href="javascript:void(0)" data-id="<%=rowId%>" data-memo="<%=Server.HTMLEncode(rowMemo)%>" data-done="0" onclick="openMemoModal(this)">상담내용보기<% If rowMemo <> "" Then %><span class="qc-memo-flag">●</span><% End If %></a>
							<a class="qc-btn qc-btn-danger" href="consult_list.asp?ji_num=10&page=<%=pageNum%>&del=<%=rowId%>" onclick="return confirm('완료된 신청 건을 삭제하시겠습니까? 삭제 후 복구할 수 없습니다.');">삭제</a>
							<% End If %>
						</div>
					</div>
					<%
								rsList.movenext
							Loop
						End If
						rsList.close
						Set rsList = Nothing
					%>
				</div>
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

		<!-- 상담처리 / 상담내용보기 공용 모달 -->
		<div class="qc-modal-overlay" id="qcModalOverlay" onclick="if(event.target===this) closeMemoModal();">
			<div class="qc-modal">
				<h3 id="qcModalTitle">상담처리</h3>
				<p class="qc-modal-sub" id="qcModalSub">상담 진행 내용을 남겨두시면 다음에 보기 편합니다.</p>
				<form method="post" action="consult_list.asp?ji_num=10&page=<%=pageNum%>">
					<input type="hidden" name="memoId" id="qcModalId" value="">
					<input type="hidden" name="markDone" id="qcModalMarkDone" value="0">
					<textarea name="memoText" id="qcModalText" rows="5" maxlength="300" placeholder="예) 2차 방문상담 예약, 8/30 오후 2시 방문 예정"></textarea>
					<div class="qc-modal-actions">
						<button type="button" class="qc-btn qc-btn-ghost" onclick="closeMemoModal()">취소</button>
						<button type="submit" class="qc-btn qc-btn-save">저장</button>
					</div>
				</form>
			</div>
		</div>

		<!-- 전화상담 수동 등록 모달 -->
		<div class="qc-modal-overlay" id="qcAddPhoneOverlay" onclick="if(event.target===this) closeAddPhoneModal();">
			<div class="qc-modal">
				<h3>전화상담 등록</h3>
				<p class="qc-modal-sub">전화로 직접 받은 문의를 유입경로 "전화상담"으로 목록에 추가합니다.</p>
				<form method="post" action="consult_list.asp?ji_num=10&page=1">
					<input type="hidden" name="addPhone" value="1">
					<div class="qc-modal-field">
						<label for="apName">이름</label>
						<input type="text" name="apName" id="apName" maxlength="50" required>
					</div>
					<div class="qc-modal-field">
						<label for="apPhone">연락처</label>
						<input type="tel" name="apPhone" id="apPhone" maxlength="20" placeholder="010-0000-0000" required>
					</div>
					<div class="qc-modal-field">
						<label for="apUnit">관심 평형 (선택)</label>
						<select name="apUnit" id="apUnit">
							<option value="">선택 안 함</option>
							<option value="전용 84㎡">전용 84㎡</option>
							<option value="85㎡초과">85㎡초과</option>
						</select>
					</div>
					<div class="qc-modal-field">
						<label for="apMemo">상담메모 (선택)</label>
						<textarea name="apMemo" id="apMemo" rows="3" maxlength="300" placeholder="통화 내용을 남겨두세요"></textarea>
					</div>
					<label class="qc-modal-check">
						<input type="checkbox" name="apDone" value="1" checked>
						<span>바로 완료 처리 (체크 해제 시 미처리로 등록)</span>
					</label>
					<div class="qc-modal-actions">
						<button type="button" class="qc-btn qc-btn-ghost" onclick="closeAddPhoneModal()">취소</button>
						<button type="submit" class="qc-btn qc-btn-save">등록</button>
					</div>
				</form>
			</div>
		</div>

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

		function openMemoModal(el) {
			var id = el.getAttribute('data-id');
			var memo = el.getAttribute('data-memo');
			var markDone = el.getAttribute('data-done') === '1';
			document.getElementById('qcModalId').value = id;
			document.getElementById('qcModalText').value = memo;
			document.getElementById('qcModalMarkDone').value = markDone ? '1' : '0';
			document.getElementById('qcModalTitle').textContent = markDone ? '상담처리' : '상담내용 보기/수정';
			document.getElementById('qcModalSub').textContent = markDone
				? '완료 처리되며, 입력한 내용은 상담메모로 저장됩니다.'
				: '저장된 상담메모를 확인하고 수정할 수 있습니다.';
			document.getElementById('qcModalOverlay').classList.add('show');
			document.getElementById('qcModalText').focus();
		}
		function closeMemoModal() {
			document.getElementById('qcModalOverlay').classList.remove('show');
		}
		function openAddPhoneModal() {
			document.getElementById('qcAddPhoneOverlay').classList.add('show');
			document.getElementById('apName').focus();
		}
		function closeAddPhoneModal() {
			document.getElementById('qcAddPhoneOverlay').classList.remove('show');
		}
		document.addEventListener('keydown', function (e) {
			if (e.key === 'Escape') { closeMemoModal(); closeAddPhoneModal(); }
		});

		function filterRows(q) {
			q = q.toLowerCase().trim();
			var rows = document.querySelectorAll('#qcTable .qc-row');
			rows.forEach(function (row) {
				var key = row.getAttribute('data-key') || '';
				row.style.display = (q === '' || key.indexOf(q) !== -1) ? 'contents' : 'none';
			});
		}
		</script>
	</section>
</main>

<!-- #include virtual="/web/inc/bottom.asp" -->
