-- ① 참가자 픽만 초기화 (경기/설정 유지)
TRUNCATE TABLE picks CASCADE;
TRUNCATE TABLE users CASCADE;

-- ② 경기까지 초기화
-- TRUNCATE TABLE picks, users, games CASCADE;

-- ③ 완전 초기화 → supabase_schema.sql 재실행
