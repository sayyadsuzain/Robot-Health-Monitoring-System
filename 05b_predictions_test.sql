-- 05b_predictions_test.sql
-- Test-side prediction view for CMAPSS test sets

USE cmaps;

CREATE OR REPLACE VIEW v_test_prediction AS
SELECT
  dataset_id,
  unit,
  MAX(cycle) AS last_cycle,
  ROUND(AVG(health_score), 2) AS avg_health,
  GREATEST(
    ROUND(AVG(health_score) / 4, 0),
    0
  ) AS estimated_cycles_left
FROM v_test_health
GROUP BY dataset_id, unit;
