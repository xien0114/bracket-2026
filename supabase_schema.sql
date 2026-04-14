-- =============================================
-- NBA 브래킷 이벤트 v2 스키마
-- Supabase Dashboard > SQL Editor 에서 실행
-- =============================================

-- 1. 참가자
CREATE TABLE users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nickname TEXT UNIQUE NOT NULL,
  pin_hash TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. 경기
-- next_game_id / next_slot: 승자가 진출하는 다음 경기 슬롯 연결
CREATE TABLE games (
  id SERIAL PRIMARY KEY,
  round INTEGER NOT NULL,          -- 1=1라운드 2=세미 3=컨파 4=파이널
  conference TEXT,                  -- 'EAST' 'WEST' 'FINALS'
  game_order INTEGER NOT NULL,      -- 라운드 내 순서
  team1 TEXT,
  team2 TEXT,
  team1_logo TEXT,                  -- 로고 URL
  team2_logo TEXT,
  winner TEXT,                      -- 실제 승자
  finals_score TEXT,                -- 파이널만: '4-2'
  is_locked BOOLEAN DEFAULT FALSE,
  next_game_id INTEGER,             -- 승자가 이동할 다음 경기 ID
  next_slot INTEGER,                -- 1=team1 자리, 2=team2 자리
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. 예측
CREATE TABLE picks (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  game_id INTEGER REFERENCES games(id) ON DELETE CASCADE,
  picked_winner TEXT NOT NULL,
  finals_score TEXT,
  is_correct BOOLEAN,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, game_id)
);

-- 4. 설정 (관리자 조정 가능)
CREATE TABLE settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL
);

-- 기본 설정값
INSERT INTO settings VALUES
  ('show_pickrate', 'false'),           -- 픽률 공개 여부
  ('pickrate_after_lock', 'true'),      -- 마감 후 자동 공개
  ('scoring', '{"r1":1,"r2":2,"r3":4,"r4":8,"bonus":4}'), -- 점수 체계
  ('event_title', 'NBA 2026 플레이오프 브래킷'),
  ('event_open', 'true');               -- 예측 접수 여부

-- =============================================
-- RLS 설정
-- =============================================
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE games ENABLE ROW LEVEL SECURITY;
ALTER TABLE picks ENABLE ROW LEVEL SECURITY;
ALTER TABLE settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users_all" ON users FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "games_all" ON games FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "picks_all" ON picks FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "settings_all" ON settings FOR ALL USING (true) WITH CHECK (true);

-- =============================================
-- 픽률 집계 뷰
-- =============================================
CREATE VIEW pickrate_view AS
SELECT
  p.game_id,
  p.picked_winner,
  COUNT(*) AS pick_count,
  ROUND(COUNT(*) * 100.0 / NULLIF(SUM(COUNT(*)) OVER (PARTITION BY p.game_id), 0), 1) AS pct
FROM picks p
GROUP BY p.game_id, p.picked_winner;

-- =============================================
-- 리더보드 뷰
-- =============================================
CREATE VIEW leaderboard AS
WITH score_calc AS (
  SELECT
    p.user_id,
    SUM(
      CASE WHEN p.is_correct = true THEN
        CASE g.round WHEN 1 THEN 1 WHEN 2 THEN 2 WHEN 3 THEN 4 WHEN 4 THEN 8 ELSE 0 END
        + CASE WHEN g.round = 4 AND p.finals_score = g.finals_score THEN 4 ELSE 0 END
      ELSE 0 END
    ) AS score,
    COUNT(CASE WHEN p.is_correct = true THEN 1 END) AS correct,
    COUNT(CASE WHEN g.winner IS NOT NULL THEN 1 END) AS judged,
    COUNT(p.id) AS total_picks
  FROM picks p
  JOIN games g ON p.game_id = g.id
  GROUP BY p.user_id
)
SELECT
  u.id,
  u.nickname,
  COALESCE(s.score, 0) AS score,
  COALESCE(s.correct, 0) AS correct,
  COALESCE(s.judged, 0) AS judged,
  COALESCE(s.total_picks, 0) AS total_picks,
  u.created_at
FROM users u
LEFT JOIN score_calc s ON u.id = s.user_id
ORDER BY score DESC, correct DESC, created_at ASC;
