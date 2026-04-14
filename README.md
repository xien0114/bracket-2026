# 🏀 NBA 브래킷 이벤트 v2

## 신규 기능 (v1 → v2)
| 기능 | 설명 |
|------|------|
| 🏀 팀 로고 | ESPN CDN 자동 매핑 + 관리자 URL 직접 입력 |
| 📊 픽률 바 | 대진별 선택 비율 바 그래프 (관리자 공개/비공개) |
| 🎯 점수 설정 | 관리자 페이지에서 라운드별 점수 자유 조정 |
| 🏆 리더보드 | 실시간 순위표 (새로고침 버튼) |
| 📋 전체 브래킷 | 1라운드 픽 → 세미파이널 대진 자동 반영 |

---

## 🚀 배포 순서 (급할 때)

### 1. Supabase 설정
```
supabase.com 가입 → New Project → SQL Editor → supabase_schema.sql 실행
Settings > API → URL, anon key 복사
```

### 2. 파일 설정
`index.html`, `admin.html` 상단 CONFIG 수정:
```javascript
const SUPABASE_URL  = 'https://xxxxxxxxx.supabase.co';
const SUPABASE_ANON = 'eyJhbGci...';
```
`admin.html`:
```javascript
const ADMIN_PW = '원하는비밀번호';
```

### 3. Vercel 배포
```bash
npm i -g vercel
cd nba-bracket-v2
vercel
# → https://xxx.vercel.app 생성
```
또는 GitHub 레포 업로드 → vercel.com에서 연결

---

## 🔗 브래킷 연결 설정 (중요)

1라운드 일괄 등록 후 세미파이널 경기도 등록해야 합니다.
그리고 각 1라운드 경기의 `next_game_id`와 `next_slot`을 설정해야
"내 픽이 다음 라운드에 자동 표시" 기능이 작동합니다.

### 연결 구조 (2026 기준)
```
1라운드 → 세미파이널
E G1(DET vs 8시드) → 세미 E G1의 team1 자리
E G4(CLE vs TOR)  → 세미 E G1의 team2 자리
E G2(BOS vs 7시드) → 세미 E G2의 team1 자리
E G3(NYK vs ATL)  → 세미 E G2의 team2 자리
W G5(OKC vs 8시드) → 세미 W G1의 team1 자리
W G8(LAL vs DAL)  → 세미 W G1의 team2 자리
W G6(HOU vs 7시드) → 세미 W G2의 team1 자리
W G7(MIN vs DEN)  → 세미 W G2의 team2 자리
```

Supabase에서 `next_game_id` 업데이트:
```sql
-- 예시: games 테이블에서 세미파이널 E G1의 id가 9라면
UPDATE games SET next_game_id = 9, next_slot = 1 WHERE round=1 AND conference='EAST' AND game_order=1;
UPDATE games SET next_game_id = 9, next_slot = 2 WHERE round=1 AND conference='EAST' AND game_order=4;
-- ...이하 동일 패턴
```

---

## 🗓️ 운영 일정

| 날짜 | 할 일 |
|------|-------|
| 4/17 저녁 | 플레이인 완료 → 관리자에서 1라운드 일괄 등록 |
| 4/17 저녁 | 세미파이널 경기 미리 등록 (팀 TBD) + next_game_id 연결 |
| 4/18 첫 경기 직전 | 1라운드 전체 🔒 마감 |
| 각 라운드 종료 후 | 결과 입력 + 채점 재계산 |

---

## 📊 점수 체계 (기본값, 관리자에서 변경 가능)

| 라운드 | 점수 |
|--------|------|
| 1라운드 | 1점 |
| 세미파이널 | 2점 |
| 컨퍼런스 파이널 | 4점 |
| NBA 파이널 | 8점 |
| 파이널 스코어 보너스 | +4점 |
| **최대 합계** | **57점** |
