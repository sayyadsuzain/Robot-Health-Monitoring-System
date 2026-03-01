-- 05d_predictions_norm.sql
-- Predictions and status views using normalized health (bounded 0..100)

USE cmaps;

-- Engine (history) predictions using normalized health
CREATE OR REPLACE VIEW v_engine_prediction_norm AS
SELECT
  dataset_id,
  unit,
  MAX(cycle) AS last_cycle,
  ROUND(AVG(health_score), 2) AS avg_health,
  GREATEST(ROUND(AVG(health_score) / 4, 0), 0) AS estimated_cycles_left
FROM v_engine_health_norm
GROUP BY dataset_id, unit;

CREATE OR REPLACE VIEW v_engine_status_norm AS
SELECT
  dataset_id,
  unit,
  last_cycle,
  avg_health,
  estimated_cycles_left,
  CASE
    WHEN estimated_cycles_left < 10 THEN 'FAIL SOON'
    WHEN estimated_cycles_left < 25 THEN 'WARNING'
    ELSE 'HEALTHY'
  END AS status
FROM v_engine_prediction_norm;

-- Test predictions using normalized health
CREATE OR REPLACE VIEW v_test_prediction_norm AS
SELECT
  dataset_id,
  unit,
  MAX(cycle) AS last_cycle,
  ROUND(AVG(health_score), 2) AS avg_health,
  GREATEST(ROUND(AVG(health_score) / 4, 0), 0) AS estimated_cycles_left
FROM v_test_health_norm
GROUP BY dataset_id, unit;
