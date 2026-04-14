-- =============================================
-- NBA 브래킷 이벤트 - DB 초기화 스크립트
-- Supabase Dashboard > SQL Editor 에서 실행
-- =============================================

-- ① 테스트용 참가자만 초기화 (경기/설정 유지)
-- 가장 자주 쓸 것
TRUNCATE TABLE picks CASCADE;
TRUNCATE TABLE users CASCADE;

-- ② 경기 데이터까지 전부 초기화 (설정만 유지)
-- TRUNCATE TABLE picks, users, games CASCADE;

-- ③ 완전 초기화 (설정도 리셋, 관리자 비번 포함)
-- TRUNCATE TABLE picks, users, games, settings CASCADE;
-- 이후 아래 기본값 재삽입 필요:
-- INSERT INTO settings VALUES
--   ('show_pickrate','false'),
--   ('pickrate_after_lock','true'),
--   ('scoring','{"r1":1,"r2":2,"r3":4,"r4":8,"bonus":4}'),
--   ('event_title','NBA 2026 플레이오프 브래킷'),
--   ('event_open','true');
