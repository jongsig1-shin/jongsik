<!-- 빠른상담 하단 고정 배너 (순천 조례동 아이파크 · 엘리트공인중개사사무소)
     배치 위치: D:\Jboard\web\inc\quick_consult_banner.asp (main.asp와 같은 폴더)
     사용법은 이 파일 밖 별도 안내 참고 (SSI include 예시 문구를 이 파일 안에 적으면
     순환 include 오류가 나서 여기서는 절대 적지 않음)
-->
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@500;700;900&display=swap" rel="stylesheet">
<style>
  #qcBar, #qcBar * { box-sizing: border-box; font-family: "Noto Sans KR", "Malgun Gothic", sans-serif; }
  #qcBar {
    position: fixed; left: 0; right: 0; bottom: 0; z-index: 9999;
    display: grid; grid-template-columns: 92px 1fr; height: 60px;
    box-shadow: 0 -8px 18px -12px rgba(0,0,0,0.28);
    border-top: 1px solid #e3e0d5;
  }
  #qcBar a, #qcBar button {
    border: 0; cursor: pointer; display: flex; flex-direction: column;
    align-items: center; justify-content: center; gap: 3px;
    font-size: 11.5px; font-weight: 700; text-decoration: none;
  }
  #qcCall { background: #ffffff; color: #24504a; border-right: 1px solid #e3e0d5; }
  #qcCall svg { width: 19px; height: 19px; }
  #qcOpen { background: #b9862f; color: #2a1d08; font-size: 14px; width: 100%; }
  #qcOpen svg { width: 17px; height: 17px; }

  #qcBackdrop {
    position: fixed; inset: 0; background: rgba(10,13,22,0.5);
    opacity: 0; pointer-events: none; transition: opacity .2s ease; z-index: 9998;
  }
  #qcBackdrop.open { opacity: 1; pointer-events: auto; }

  #qcSheet {
    position: fixed; left: 0; right: 0; bottom: 0; z-index: 9999;
    background: #fff; border-radius: 18px 18px 0 0; padding: 10px 20px 24px;
    max-width: 460px; margin: 0 auto;
    transform: translateY(100%); transition: transform .28s cubic-bezier(.22,.9,.32,1);
    max-height: 86vh; overflow-y: auto;
  }
  #qcSheet.open { transform: translateY(0); }

  .qc-grip { width: 36px; height: 4px; background: #d8dbe4; border-radius: 999px; margin: 4px auto 14px; }
  #qcSheet h3 { font-size: 18px; margin: 0 0 4px; color: #17233d; }
  #qcSheet .qc-sub { font-size: 12.5px; color: #6b7280; margin: 0 0 18px; line-height: 1.6; }

  .qc-field { margin-bottom: 12px; }
  .qc-field label { display: block; font-size: 12px; font-weight: 700; margin-bottom: 6px; color: #6b7280; }
  .qc-field label .qc-req { color: #b0392c; margin-left: 2px; }
  .qc-field input, .qc-field select {
    width: 100%; padding: 11px 12px; border-radius: 10px; border: 1px solid #d8dbe4;
    background: #f6f6f6; color: #17233d; font-size: 14px; font-family: inherit;
  }
  .qc-field select option { color: #17233d; background: #ffffff; }
  .qc-field input::placeholder { color: #9aa0ab; }
  .qc-field input:focus, .qc-field select:focus { outline: 2px solid #b9862f; outline-offset: 1px; }

  .qc-consent { display: flex; align-items: flex-start; gap: 8px; font-size: 12px; color: #6b7280; margin: 16px 0 14px; line-height: 1.55; }
  .qc-consent input { margin-top: 2px; width: 15px; height: 15px; accent-color: #b9862f; flex-shrink: 0; }
  .qc-consent a { color: #17233d; text-decoration: underline; }

  #qcSubmit {
    width: 100%; border: 0; padding: 14px; border-radius: 12px; background: #b9862f;
    color: #2a1d08; font-weight: 900; font-size: 15px; cursor: pointer;
  }
  #qcSubmit:disabled { opacity: .4; cursor: not-allowed; }

  #qcSuccess { display: none; flex-direction: column; align-items: center; text-align: center; padding: 18px 6px 10px; }
  #qcSuccess.show { display: flex; }
  #qcSuccess .qc-tick {
    width: 46px; height: 46px; border-radius: 50%; background: rgba(44,110,79,.15);
    display: flex; align-items: center; justify-content: center; margin-bottom: 14px;
  }
  #qcSuccess p { margin: 0 0 18px; font-size: 12.5px; color: #6b7280; line-height: 1.6; }
  #qcSuccess button { border: 1px solid #d8dbe4; background: transparent; color: #17233d; padding: 10px 22px; border-radius: 10px; font-weight: 700; font-size: 13px; cursor: pointer; }
  #qcFormBody.hide { display: none; }
  body { padding-bottom: 60px; } /* 하단 고정바에 콘텐츠 가리지 않도록 */
</style>

<div id="qcBackdrop"></div>
<div id="qcSheet">
  <div class="qc-grip"></div>
  <div id="qcFormBody">
    <h3>빠른상담 신청</h3>
    <p class="qc-sub">순천 조례동 아이파크 전문 상담 · 엘리트공인중개사사무소<br>이름과 연락처만 남겨주시면 순차적으로 회신드립니다.</p>
    <div class="qc-field">
      <label for="qcName">이름<span class="qc-req">*</span></label>
      <input id="qcName" type="text" placeholder="홍길동" autocomplete="name" />
    </div>
    <div class="qc-field">
      <label for="qcPhone">연락처<span class="qc-req">*</span></label>
      <input id="qcPhone" type="tel" placeholder="010-0000-0000" autocomplete="tel" />
    </div>
    <div class="qc-field">
      <label for="qcUnit">관심 평형 (선택)</label>
      <select id="qcUnit">
        <option value="">선택 안 함</option>
        <option value="84㎡">전용 84㎡</option>
        <option value="85㎡초과">전용 85㎡초과</option>
      </select>
    </div>
    <label class="qc-consent">
      <input type="checkbox" id="qcConsent" />
      <span>개인정보 수집·이용에 동의합니다 (필수) - 상담 목적 외 사용하지 않으며 상담 완료 후 파기됩니다. <a href="/privacy.asp">약관 보기</a></span>
    </label>
    <button id="qcSubmit" disabled>상담 신청하기</button>
  </div>
  <div id="qcSuccess">
    <div class="qc-tick">
      <svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="#2c6e4f" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>
    </div>
    <h3>신청이 접수되었습니다</h3>
    <p>영업일 기준 1일 이내 상담원이 순차 연락드립니다.</p>
    <button id="qcCloseSuccess">닫기</button>
  </div>
</div>

<div id="qcBar">
  <a id="qcCall" href="tel:010-7175-2700">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72c.127.96.361 1.903.7 2.81a2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0 1 22 16.92z"/></svg>
    전화상담
  </a>
  <button id="qcOpen" type="button">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
    빠른상담 신청
  </button>
</div>

<script>
(function () {
  var openBtn = document.getElementById('qcOpen');
  var sheet = document.getElementById('qcSheet');
  var backdrop = document.getElementById('qcBackdrop');
  var closeSuccessBtn = document.getElementById('qcCloseSuccess');
  var nameInput = document.getElementById('qcName');
  var phoneInput = document.getElementById('qcPhone');
  var unitSelect = document.getElementById('qcUnit');
  var consent = document.getElementById('qcConsent');
  var submitBtn = document.getElementById('qcSubmit');
  var formBody = document.getElementById('qcFormBody');
  var success = document.getElementById('qcSuccess');

  function openSheet() { sheet.classList.add('open'); backdrop.classList.add('open'); }
  function closeSheet() {
    sheet.classList.remove('open'); backdrop.classList.remove('open');
    setTimeout(function () { formBody.classList.remove('hide'); success.classList.remove('show'); }, 250);
  }

  openBtn.addEventListener('click', openSheet);
  backdrop.addEventListener('click', closeSheet);
  closeSuccessBtn.addEventListener('click', closeSheet);

  function validate() {
    submitBtn.disabled = !(nameInput.value.trim() && phoneInput.value.trim() && consent.checked);
  }
  [nameInput, phoneInput, consent].forEach(function (el) { el.addEventListener('input', validate); });

  submitBtn.addEventListener('click', function () {
    submitBtn.disabled = true;
    var body = new URLSearchParams({
      name: nameInput.value.trim(),
      phone: phoneInput.value.trim(),
      unit: unitSelect.value,
      message: '',
      consent: consent.checked ? '1' : '0'
    });
    fetch('/web/inc/consult_proc.asp', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: body.toString()
    })
      .then(function (res) { return res.json(); })
      .then(function (data) {
        if (data.ok) {
          formBody.classList.add('hide');
          success.classList.add('show');
        } else {
          alert(data.error || '신청 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.');
          submitBtn.disabled = false;
        }
      })
      .catch(function () {
        alert('네트워크 오류로 신청에 실패했습니다. 전화상담을 이용해주세요.');
        submitBtn.disabled = false;
      });
  });
})();
</script>
