-- =============================================
-- NBA 브래킷 이벤트 - DB 스키마 v2
-- IF NOT EXISTS 적용 → 이미 있어도 에러 없음
-- 재실행해도 안전합니다
-- =============================================

CREATE TABLE IF NOT EXISTS users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nickname TEXT UNIQUE NOT NULL,
  pin_hash TEXT NOT NULL,
  ip_address TEXT,
  user_agent TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS games (
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

CREATE TABLE IF NOT EXISTS picks (
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

CREATE TABLE IF NOT EXISTS settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL
);

INSERT INTO settings VALUES
  ('show_pickrate','false'),
  ('pickrate_after_lock','true'),
  ('scoring','{"r1":1,"r2":2,"r3":4,"r4":8,"bonus":4}'),
  ('event_title','NBA 2026 플레이오프 브래킷'),
  ('event_open','true')
ON CONFLICT (key) DO NOTHING;

-- RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE games ENABLE ROW LEVEL SECURITY;
ALTER TABLE picks ENABLE ROW LEVEL SECURITY;
ALTER TABLE settings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "users_all" ON users;
DROP POLICY IF EXISTS "games_all" ON games;
DROP POLICY IF EXISTS "picks_all" ON picks;
DROP POLICY IF EXISTS "settings_all" ON settings;

CREATE POLICY "users_all"    ON users    FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "games_all"    ON games    FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "picks_all"    ON picks    FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "settings_all" ON settings FOR ALL USING (true) WITH CHECK (true);

CREATE OR REPLACE VIEW pickrate_view AS
SELECT p.game_id, p.picked_winner,
  COUNT(*) AS pick_count,
  ROUND(COUNT(*)*100.0/NULLIF(SUM(COUNT(*)) OVER (PARTITION BY p.game_id),0),1) AS pct
FROM picks p GROUP BY p.game_id, p.picked_winner;

CREATE OR REPLACE VIEW leaderboard AS
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
