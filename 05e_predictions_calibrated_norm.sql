-- 05e_predictions_calibrated_norm.sql
-- Calibrated predictions and status using normalized health (0..100)

USE cmaps;

-- Last health from normalized historical engine cycles
CREATE OR REPLACE VIEW v_engine_last_health_norm AS
SELECT 
  h.dataset_id,
  h.unit,
  MAX(h.cycle) AS last_cycle,
  SUBSTRING_INDEX(GROUP_CONCAT(h.health_score ORDER BY h.cycle DESC), ',', 1) + 0.0 AS last_health
FROM v_engine_health_norm h
GROUP BY h.dataset_id, h.unit;

-- Calibrated prediction on normalized historical cycles
CREATE OR REPLACE VIEW v_engine_prediction_calibrated_norm AS
SELECT 
  l.dataset_id,
  l.unit,
  l.last_cycle,
  l.last_health,
  GREATEST(ROUND(p.a + p.b * l.last_health, 0), 0) AS estimated_cycles_left
FROM v_engine_last_health_norm l
JOIN v_regression_params_final_norm p
  ON p.dataset_id = l.dataset_id;

CREATE OR REPLACE VIEW v_engine_status_calibrated_norm AS
SELECT
  dataset_id,
  unit,
  last_cycle,
  last_health AS avg_health,
  estimated_cycles_left,
  CASE
    WHEN estimated_cycles_left < 10 THEN 'FAIL SOON'
    WHEN estimated_cycles_left < 25 THEN 'WARNING'
    ELSE 'HEALTHY'
  END AS status
FROM v_engine_prediction_calibrated_norm;

-- Live normalized calibrated predictions
CREATE OR REPLACE VIEW v_live_last_health_norm AS
SELECT 
  dataset_id,
  unit,
  MAX(cycle) AS last_cycle,
  SUBSTRING_INDEX(GROUP_CONCAT(health_score ORDER BY cycle DESC), ',', 1) + 0.0 AS last_health
FROM v_live_health_norm
GROUP BY dataset_id, unit;

CREATE OR REPLACE VIEW v_live_prediction_calibrated_norm AS
SELECT 
  l.dataset_id,
  l.unit,
  l.last_cycle,
  l.last_health,
  GREATEST(ROUND(p.a + p.b * l.last_health, 0), 0) AS estimated_cycles_left
FROM v_live_last_health_norm l
JOIN v_regression_params_final_norm p
  ON p.dataset_id = l.dataset_id;

CREATE OR REPLACE VIEW v_live_status_norm AS
SELECT
  dataset_id,
  unit,
  last_cycle,
  last_health AS avg_health,
  estimated_cycles_left,
  CASE
    WHEN estimated_cycles_left < 10 THEN 'FAIL SOON'
    WHEN estimated_cycles_left < 25 THEN 'WARNING'
    ELSE 'HEALTHY'
  END AS status
FROM v_live_prediction_calibrated_norm;
