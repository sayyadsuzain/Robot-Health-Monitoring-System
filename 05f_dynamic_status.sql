-- 05f_dynamic_status.sql
-- Dynamic status thresholds (dataset-specific) and diagnostics for sensors

USE cmaps;

-- Base: calibrated predictions with normalized health (history)
-- v_engine_prediction_calibrated_norm already exists

-- Percentile buckets per dataset (1..100) by estimated cycles left
CREATE OR REPLACE VIEW v_engine_percentiles AS
SELECT
  dataset_id,
  unit,
  estimated_cycles_left,
  NTILE(100) OVER (PARTITION BY dataset_id ORDER BY estimated_cycles_left) AS pctl
FROM v_engine_prediction_calibrated_norm;

-- Thresholds per dataset based on percentiles
-- fail_max: max est_cycles within bottom 10%
-- warn_max: max est_cycles within bottom 25%
CREATE OR REPLACE VIEW v_dyn_thresholds AS
SELECT
  dataset_id,
  MAX(CASE WHEN pctl <= 10 THEN estimated_cycles_left END) AS fail_max,
  MAX(CASE WHEN pctl <= 25 THEN estimated_cycles_left END) AS warn_max
FROM v_engine_percentiles
GROUP BY dataset_id;

-- Dynamic status for engine (history)
CREATE OR REPLACE VIEW v_engine_status_calibrated_norm_dyn AS
SELECT
  p.dataset_id,
  p.unit,
  p.last_cycle,
  p.last_health AS avg_health,
  p.estimated_cycles_left,
  CASE
    WHEN p.estimated_cycles_left <= t.fail_max THEN 'FAIL SOON'
    WHEN p.estimated_cycles_left <= t.warn_max THEN 'WARNING'
    ELSE 'HEALTHY'
  END AS status
FROM v_engine_prediction_calibrated_norm p
JOIN v_dyn_thresholds t USING (dataset_id);

-- Apply dynamic thresholds to live predictions as well
CREATE OR REPLACE VIEW v_live_status_norm_dyn AS
SELECT
  p.dataset_id,
  p.unit,
  p.last_cycle,
  p.last_health AS avg_health,
  p.estimated_cycles_left,
  CASE
    WHEN p.estimated_cycles_left <= t.fail_max THEN 'FAIL SOON'
    WHEN p.estimated_cycles_left <= t.warn_max THEN 'WARNING'
    ELSE 'HEALTHY'
  END AS status
FROM v_live_prediction_calibrated_norm p
JOIN v_dyn_thresholds t USING (dataset_id);

-- =============================
-- Sensor diagnostics (which sensor to check/replace)
-- Contribution weights: 50 for s2 (temp), 30 for s4 (pressure), 20 for s11 (vibration)
-- Highest contribution -> primary sensor to check
-- =============================

-- Last normalized sensors per engine (history)
CREATE OR REPLACE VIEW v_engine_last_norm AS
SELECT dataset_id, unit, cycle, n_s2, n_s4, n_s11, health_score
FROM (
  SELECT 
    dataset_id, unit, cycle, n_s2, n_s4, n_s11, health_score,
    ROW_NUMBER() OVER (PARTITION BY dataset_id, unit ORDER BY cycle DESC) AS rn
  FROM v_engine_health_norm
) x
WHERE rn = 1;

CREATE OR REPLACE VIEW v_engine_diagnostics_norm AS
SELECT
  e.dataset_id,
  e.unit,
  e.cycle AS last_cycle,
  e.health_score AS last_health,
  ROUND(50*e.n_s2,2) AS penalty_temp,
  ROUND(30*e.n_s4,2) AS penalty_pressure,
  ROUND(20*e.n_s11,2) AS penalty_vibration,
  CASE 
    WHEN 50*e.n_s2 >= 30*e.n_s4 AND 50*e.n_s2 >= 20*e.n_s11 THEN 'sensor_2 (Temperature)'
    WHEN 30*e.n_s4 >= 50*e.n_s2 AND 30*e.n_s4 >= 20*e.n_s11 THEN 'sensor_4 (Pressure)'
    ELSE 'sensor_11 (Vibration)'
  END AS sensor_to_check
FROM v_engine_last_norm e;

-- Live diagnostics (latest reading per unit)
CREATE OR REPLACE VIEW v_live_last_norm AS
SELECT dataset_id, unit, cycle, n_s2, n_s4, n_s11, health_score
FROM (
  SELECT 
    dataset_id, unit, cycle, n_s2, n_s4, n_s11, health_score,
    ROW_NUMBER() OVER (PARTITION BY dataset_id, unit ORDER BY cycle DESC) AS rn
  FROM v_live_health_norm
) x
WHERE rn = 1;

CREATE OR REPLACE VIEW v_live_diagnostics_norm AS
SELECT
  l.dataset_id,
  l.unit,
  l.cycle AS last_cycle,
  l.health_score AS last_health,
  ROUND(50*l.n_s2,2) AS penalty_temp,
  ROUND(30*l.n_s4,2) AS penalty_pressure,
  ROUND(20*l.n_s11,2) AS penalty_vibration,
  CASE 
    WHEN 50*l.n_s2 >= 30*l.n_s4 AND 50*l.n_s2 >= 20*l.n_s11 THEN 'sensor_2 (Temperature)'
    WHEN 30*l.n_s4 >= 50*l.n_s2 AND 30*l.n_s4 >= 20*l.n_s11 THEN 'sensor_4 (Pressure)'
    ELSE 'sensor_11 (Vibration)'
  END AS sensor_to_check
FROM v_live_last_norm l;
