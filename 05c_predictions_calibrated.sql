-- 05c_predictions_calibrated.sql
-- Calibrated predictions (train/history) and live predictions using regression params

USE cmaps;

-- Last health from historical engine cycles
CREATE OR REPLACE VIEW v_engine_last_health AS
SELECT 
  h.dataset_id,
  h.unit,
  MAX(h.cycle) AS last_cycle,
  SUBSTRING_INDEX(GROUP_CONCAT(h.health_score ORDER BY h.cycle DESC), ',', 1) + 0.0 AS last_health
FROM v_engine_health h
GROUP BY h.dataset_id, h.unit;

-- Calibrated prediction on historical cycles
CREATE OR REPLACE VIEW v_engine_prediction_calibrated AS
SELECT 
  l.dataset_id,
  l.unit,
  l.last_cycle,
  l.last_health,
  GREATEST(ROUND(p.a + p.b * l.last_health, 0), 0) AS estimated_cycles_left
FROM v_engine_last_health l
JOIN v_regression_params_final p
  ON p.dataset_id = l.dataset_id;

CREATE OR REPLACE VIEW v_engine_status_calibrated AS
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
FROM v_engine_prediction_calibrated;

-- Live monitoring: compute health directly from live input
CREATE OR REPLACE VIEW v_live_health AS
SELECT
  dataset_id,
  unit,
  cycle,
  sensor_2 AS temperature,
  sensor_4 AS pressure,
  sensor_11 AS vibration,
  ROUND(100 - (sensor_2 * 0.5) - (sensor_4 * 0.3) - (sensor_11 * 0.2), 2) AS health_score
FROM live_engine_input;

CREATE OR REPLACE VIEW v_live_last_health AS
SELECT 
  dataset_id,
  unit,
  MAX(cycle) AS last_cycle,
  SUBSTRING_INDEX(GROUP_CONCAT(health_score ORDER BY cycle DESC), ',', 1) + 0.0 AS last_health
FROM v_live_health
GROUP BY dataset_id, unit;

CREATE OR REPLACE VIEW v_live_prediction_calibrated AS
SELECT 
  l.dataset_id,
  l.unit,
  l.last_cycle,
  l.last_health,
  GREATEST(ROUND(p.a + p.b * l.last_health, 0), 0) AS estimated_cycles_left
FROM v_live_last_health l
JOIN v_regression_params_final p
  ON p.dataset_id = l.dataset_id;

CREATE OR REPLACE VIEW v_live_status AS
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
FROM v_live_prediction_calibrated;
