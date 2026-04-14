# 🏀 NBA 플레이오프 2026 브래킷 이벤트

> 별도 서버/하드웨어 없이 완전 무료로 운용 가능한 NBA 플레이오프 브래킷 예측 이벤트 사이트

---

## 📁 파일 구성

```
nba-bracket-v2/
├── index.html          ← 참가자용 메인 앱
├── admin.html          ← 관리자 페이지
├── vercel.json         ← Vercel 라우팅 설정
├── supabase_schema.sql ← DB 스키마 (최초 1회 실행)
└── README.md           ← 이 파일
```

---

## 🚀 배포 순서 (처음부터 끝까지)

### STEP 1 — Supabase 가입 및 프로젝트 생성

1. [https://supabase.com](https://supabase.com) → **Start your project** 클릭
2. GitHub으로 로그인 (없으면 이메일 가입)
3. **New Project** 클릭
   - Name: 아무거나 (예: `nba-bracket-2026`)
   - Database Password: 아무 비밀번호 (나중에 안 씀)
   - Region: **Northeast Asia (Tokyo)** 권장
4. **Create new project** → 1~2분 대기

---

### STEP 2 — DB 스키마 실행

1. 프로젝트 생성 후 왼쪽 메뉴 **SQL Editor** 클릭
2. `supabase_schema.sql` 파일 전체 내용 복사 → 붙여넣기 → **Run** 클릭
3. 하단에 "Success" 뜨면 완료

---

### STEP 3 — Supabase 연결 정보 복사

1. 왼쪽 메뉴 하단 **Settings** → **API** 탭
2. 아래 두 값 복사해두기:
   - **Project URL**: `https://xxxxxxxxxxxx.supabase.co` 형태
   - **anon / public** key: `eyJhbGci...` 로 시작하는 긴 문자열

---


### STEP 3-1 — Google OAuth 설정 (로그인에 필요)

**Supabase에서:**
1. Supabase Dashboard → 왼쪽 메뉴 **Authentication** → **Providers**
2. **Google** 클릭 → **Enable** 토글 ON
3. 화면에 표시된 **Callback URL** 복사 (형태: `https://xxxx.supabase.co/auth/v1/callback`)

**Google Cloud Console에서:**
1. [https://console.cloud.google.com](https://console.cloud.google.com) 접속
2. 새 프로젝트 생성 (또는 기존 선택)
3. 좌측 메뉴 **APIs & Services** → **Credentials** → **+ CREATE CREDENTIALS** → **OAuth client ID**
4. Application type: **Web application**
5. **Authorized redirect URIs** → **+ ADD URI** → 위에서 복사한 Supabase Callback URL 입력
6. **CREATE** → **Client ID**와 **Client Secret** 복사
7. Supabase Google Provider 설정 화면에 Client ID, Client Secret 붙여넣기 → **Save**

> ⚠️ Google Cloud Console에서 **OAuth consent screen** 설정도 필요합니다.
> **External** 선택 → 앱 이름/이메일 입력 → **Test users**에 테스트할 Google 계정 추가 (심사 전 단계)
> 실제 이벤트 전에 **Publishing status를 Production**으로 변경하거나, 참가자를 Test users에 추가해야 합니다.

### STEP 4 — HTML 파일에 연결 정보 입력

`index.html`과 `admin.html` **두 파일 모두** 메모장(또는 VS Code)으로 열고 상단 CONFIG 부분 수정:

```javascript
const SUPABASE_URL  = 'YOUR_SUPABASE_URL';      // ← Project URL로 교체
const SUPABASE_ANON = 'YOUR_SUPABASE_ANON_KEY'; // ← anon key로 교체
```

> ⚠️ `index.html`, `admin.html` 두 파일 모두 수정해야 합니다.

---

### STEP 5 — Vercel 배포

#### 방법 A: GitHub 연동 (권장)

1. [https://github.com](https://github.com) 가입 → **New repository** 생성
2. 폴더 내 파일 4개 업로드 (`index.html`, `admin.html`, `vercel.json`, `supabase_schema.sql`)
3. [https://vercel.com](https://vercel.com) → GitHub으로 로그인
4. **Add New Project** → 레포 선택 → **Deploy**
5. 완료 → `https://nba-bracket-xxxx.vercel.app` 형태 주소 생성

#### 방법 B: Vercel CLI

```bash
# Node.js 설치 필요 (https://nodejs.org)
npm install -g vercel
cd nba-bracket-v2
vercel
# 안내대로 진행 → 주소 생성
```

---

### STEP 6 — 관리자 비밀번호 최초 설정

1. `https://배포주소/admin` 접속
2. **원하는 비밀번호 입력 후 로그인 클릭**
3. ✅ 최초 1회는 입력한 값이 자동으로 관리자 비밀번호로 등록됩니다
4. 이후부터는 동일 비밀번호로만 입장 가능

> 비밀번호를 바꾸고 싶을 때:  
> Supabase Dashboard → Table Editor → `settings` 테이블 → `admin_pw` 행의 value 수정

---

## 📅 운영 체크리스트

### 플레이인 완료 후 (4월 17일)

**① 관리자 페이지(`/admin`) → [경기 관리] 탭**

**② 1라운드 일괄 등록**
- "⚡ 2026 1라운드 일괄 등록" 섹션
- 플레이인 확정된 이스트/웨스트 7시드, 8시드 팀명 입력
- **일괄 등록** 클릭 → 8경기 자동 생성

**③ 2라운드~파이널 경기 미리 등록**

팀이 확정 안 됐어도 경기 틀을 미리 만들어야 "내 픽 → 다음 라운드 자동 표시" 기능이 작동합니다.
[경기 직접 추가]에서 아래 경기 등록 (팀명은 `TBD`로 입력):

| 라운드 | 컨퍼런스 | 순서 |
|--------|---------|------|
| 2 (세미파이널) | EAST | 1 |
| 2 (세미파이널) | EAST | 2 |
| 2 (세미파이널) | WEST | 3 |
| 2 (세미파이널) | WEST | 4 |
| 3 (컨퍼런스파이널) | EAST | 1 |
| 3 (컨퍼런스파이널) | WEST | 2 |
| 4 (파이널) | FINALS | 1 |

**④ 경기 연결 (next_game_id 설정)**

경기 목록에서 각 경기의 ID를 확인한 뒤,
Supabase → SQL Editor에서 아래 형식으로 실행:

```sql
-- 예: 세미파이널 EAST G1 ID=9, G2 ID=10 인 경우

-- 1라운드 EAST game_order=1 승자 → 세미파이널 EAST G1의 team1 자리
UPDATE games SET next_game_id=9, next_slot=1
  WHERE round=1 AND conference='EAST' AND game_order=1;

-- 1라운드 EAST game_order=4 승자 → 세미파이널 EAST G1의 team2 자리
UPDATE games SET next_game_id=9, next_slot=2
  WHERE round=1 AND conference='EAST' AND game_order=4;

-- 1라운드 EAST game_order=2 승자 → 세미파이널 EAST G2의 team1 자리
UPDATE games SET next_game_id=10, next_slot=1
  WHERE round=1 AND conference='EAST' AND game_order=2;

-- 1라운드 EAST game_order=3 승자 → 세미파이널 EAST G2의 team2 자리
UPDATE games SET next_game_id=10, next_slot=2
  WHERE round=1 AND conference='EAST' AND game_order=3;

-- WEST도 동일한 방식으로 (game_order 5~8 → 세미파이널 WEST 경기 ID)
```

세미파이널 → 컨퍼런스파이널, 컨퍼런스파이널 → 파이널도 같은 방식으로 연결합니다.

**⑤ 참가자에게 사이트 주소 공유**

---

### 1라운드 첫 경기 직전 (4월 18일)

- 관리자 → [경기 관리] → 1라운드 8경기 전부 **🔒 마감** 클릭

---

### 각 라운드 종료 후

1. 관리자 → **[결과 입력]** 탭
2. 승자 선택 → **저장**
3. 파이널은 시리즈 스코어(4-0, 4-1, 4-2, 4-3)도 선택
4. **🔄 전체 채점 재계산** 클릭 → 순위표 즉시 반영

---

## 🎯 점수 체계

기본값이며 관리자 **[점수 설정]** 탭에서 언제든 변경 가능합니다.
변경 후 채점 재계산 버튼 누르면 기존 예측도 새 점수로 갱신됩니다.

| 라운드 | 기본 점수 |
|--------|---------|
| 1라운드 정답 | 1점 |
| 세미파이널 정답 | 2점 |
| 컨퍼런스 파이널 정답 | 4점 |
| NBA 파이널 정답 | 8점 |
| 파이널 스코어 정확히 맞추면 | +4점 보너스 |
| **최대 합계** | **57점** |

---

## 👁 픽률 공개 설정

관리자 **[공개 설정]** 탭에서 토글로 제어:

| 설정 | 설명 |
|------|------|
| 픽률 항상 공개 | 마감 전에도 픽률 % 표시 |
| 마감 후 자동 공개 | 🔒 마감된 경기만 픽률 표시 (권장) |
| 이벤트 오픈 | OFF 시 신규 예측 불가 |

---

## 🏀 팀 로고

30개 팀 ESPN CDN 로고 자동 매핑 포함.
로고가 없거나 다를 경우 관리자 [경기 추가]에서 URL 직접 입력 가능.

ESPN 로고 URL 형식:
```
https://a.espncdn.com/combiner/i?img=/i/teamlogos/nba/500/팀코드.png
```
주요 팀 코드: `okc` `bos` `ny` `cle` `det` `atl` `tor` `hou` `min` `den` `lal` `dal` `phx` `por` `gs` `lac` `sa` `mem` `mia` `phi` `orl` `cha`

---

## ❓ FAQ

**Q. 참가자 PIN 분실 시?**  
Supabase Dashboard → Table Editor → `users` 테이블 → 해당 닉네임 행 삭제 후 재가입 안내

**Q. 예측 수정 가능?**  
마감(🔒) 전까지 자유롭게 수정 가능. 저장 버튼 누를 때마다 덮어씌워짐

**Q. 200명 넘어도 무료?**  
Supabase 무료 플랜 MAU 50,000명까지 지원. 200명은 문제없음

**Q. 커스텀 도메인 연결?**  
Vercel Dashboard → Project Settings → Domains에서 연결 가능  
도메인 구매: 가비아/Cloudflare 등 연간 1~2만원 수준
