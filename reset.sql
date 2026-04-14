-- =============================================
-- 완전 초기화 - 전부 지우고 새로 만들기
-- Supabase SQL Editor에서 전체 실행
-- =============================================

-- 1. 뷰 먼저 삭제
DROP VIEW IF EXISTS leaderboard CASCADE;
DROP VIEW IF EXISTS pickrate_view CASCADE;

-- 2. 테이블 전부 삭제
DROP TABLE IF EXISTS picks CASCADE;
DROP TABLE IF EXISTS games CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS settings CASCADE;

-- 3. 새로 생성
CREATE TABLE users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nickname TEXT UNIQUE NOT NULL,
  pin_hash TEXT NOT NULL,
  ip_address TEXT,
  user_agent TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE games (
  id SERIAL PRIMARY KEY,
  round INTEGER NOT NULL,
  conference TEXT,
  game_order INTEGER NOT NULL,
  team1 TEXT,
  team2 TEXT,
  team1_logo TEXT,
  team2_logo TEXT,
  winner TEXT,
  finals_score TEXT,
  is_locked BOOLEAN DEFAULT FALSE,
  next_game_id INTEGER,
  next_slot INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE picks (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  game_id INTEGER REFERENCES games(id) ON DELETE CASCADE,
  picked_winner TEXT NOT NULL,
  finals_score TEXT,
  is_correct BOOLEAN,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, game_id)
);

CREATE TABLE settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL
);

INSERT INTO settings VALUES
  ('show_pickrate','false'),
  ('pickrate_after_lock','true'),
  ('scoring','{"r1":1,"r2":2,"r3":4,"r4":8,"bonus":4}'),
  ('event_title','NBA 2026 플레이오프 브래킷'),
  ('event_open','true');

-- 4. RLS 설정
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE games ENABLE ROW LEVEL SECURITY;
ALTER TABLE picks ENABLE ROW LEVEL SECURITY;
ALTER TABLE settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users_all"    ON users    FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "games_all"    ON games    FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "picks_all"    ON picks    FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "settings_all" ON settings FOR ALL USING (true) WITH CHECK (true);

-- 5. 뷰 재생성
CREATE VIEW pickrate_view AS
SELECT p.game_id, p.picked_winner,
  COUNT(*) AS pick_count,
  ROUND(COUNT(*)*100.0/NULLIF(SUM(COUNT(*)) OVER (PARTITION BY p.game_id),0),1) AS pct
FROM picks p GROUP BY p.game_id, p.picked_winner;

CREATE VIEW leaderboard AS
WITH s AS (
  SELECT p.user_id,
    SUM(CASE WHEN p.is_correct THEN
      CASE g.round WHEN 1 THEN 1 WHEN 2 THEN 2 WHEN 3 THEN 4 WHEN 4 THEN 8 ELSE 0 END
      + CASE WHEN g.round=4 AND p.finals_score=g.finals_score THEN 4 ELSE 0 END
    ELSE 0 END) AS score,
    COUNT(CASE WHEN p.is_correct THEN 1 END) AS correct,
    COUNT(CASE WHEN g.winner IS NOT NULL THEN 1 END) AS judged,
    COUNT(p.id) AS total_picks
  FROM picks p JOIN games g ON p.game_id=g.id GROUP BY p.user_id
)
SELECT u.id, u.nickname, u.ip_address,
  COALESCE(s.score,0) AS score, COALESCE(s.correct,0) AS correct,
  COALESCE(s.judged,0) AS judged, COALESCE(s.total_picks,0) AS total_picks,
  u.created_at
FROM users u LEFT JOIN s ON u.id=s.user_id
ORDER BY score DESC, correct DESC, created_at ASC;

-- 6. 스키마 캐시 강제 갱신
NOTIFY pgrst, 'reload schema';
