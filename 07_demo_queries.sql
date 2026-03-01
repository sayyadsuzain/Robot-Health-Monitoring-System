-- 07_demo_queries.sql
-- Demonstration queries

USE cmaps;

-- Show critical engines
SELECT *
FROM v_engine_status
WHERE status != 'HEALTHY'
ORDER BY estimated_cycles_left
LIMIT 10;

-- Show health trend for one engine
SELECT unit, cycle, health_score
FROM v_engine_health
WHERE unit = 1
ORDER BY cycle
LIMIT 20;
