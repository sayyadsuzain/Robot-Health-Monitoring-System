-- 09c_sql_calibration_norm.sql
-- SQL-only calibration using normalized health (0..100) per dataset

USE cmaps;

-- Train-side true RUL using normalized health view
CREATE OR REPLACE VIEW v_train_max_cycle AS
SELECT dataset_id, unit, MAX(cycle) AS max_cycle
FROM train_cycles
GROUP BY dataset_id, unit;

CREATE OR REPLACE VIEW v_train_true_rul_norm AS
SELECT h.dataset_id, h.unit, h.cycle, h.health_score,
       (m.max_cycle - h.cycle) AS true_rul
FROM v_engine_health_norm h
JOIN v_train_max_cycle m
  ON m.dataset_id = h.dataset_id AND m.unit = h.unit;

-- Regression params per dataset: RUL ~ a + b * health_score (normalized)
CREATE OR REPLACE VIEW v_regression_stats_norm AS
SELECT
  dataset_id,
  COUNT(*) AS n,
  SUM(health_score) AS sum_x,
  SUM(true_rul) AS sum_y,
  SUM(health_score * health_score) AS sum_xx,
  SUM(health_score * true_rul) AS sum_xy
FROM v_train_true_rul_norm
GROUP BY dataset_id;

CREATE OR REPLACE VIEW v_regression_params_final_norm AS
SELECT
  dataset_id,
  (sum_y / n) - ((CASE WHEN (n * sum_xx - sum_x * sum_x) = 0 THEN 0
                       ELSE (n * sum_xy - sum_x * sum_y) / (n * sum_xx - sum_x * sum_x) END) * (sum_x / n)) AS a,
  (CASE WHEN (n * sum_xx - sum_x * sum_x) = 0 THEN 0
        ELSE (n * sum_xy - sum_x * sum_y) / (n * sum_xx - sum_x * sum_x) END) AS b
FROM v_regression_stats_norm;

-- Test last-cycle normalized health per unit
CREATE OR REPLACE VIEW v_test_last_health_norm AS
SELECT th.dataset_id, th.unit,
       MAX(th.cycle) AS last_cycle,
       SUBSTRING_INDEX(GROUP_CONCAT(th.health_score ORDER BY th.cycle DESC), ',', 1) + 0.0 AS last_health
FROM v_test_health_norm th
GROUP BY th.dataset_id, th.unit;

-- Apply calibrated model on normalized health
CREATE OR REPLACE VIEW v_test_prediction_calibrated_norm AS
SELECT
  l.dataset_id,
  l.unit,
  l.last_cycle,
  l.last_health,
  GREATEST(ROUND(p.a + p.b * l.last_health, 0), 0) AS predicted_rul_cal
FROM v_test_last_health_norm l
JOIN v_regression_params_final_norm p
  ON p.dataset_id = l.dataset_id;

-- Evaluation against RUL truth
CREATE OR REPLACE VIEW v_eval_test_cal_norm AS
SELECT
  c.dataset_id,
  c.unit,
  c.last_cycle,
  c.last_health,
  c.predicted_rul_cal,
  r.rul AS true_rul,
  (c.predicted_rul_cal - r.rul) AS error
FROM v_test_prediction_calibrated_norm c
JOIN rul_truth r
  ON r.dataset_id = c.dataset_id AND r.unit = c.unit;

CREATE OR REPLACE VIEW v_eval_metrics_cal_norm AS
SELECT
  dataset_id,
  COUNT(*) AS n_units,
  ROUND(AVG(ABS(error)), 2) AS mae,
  ROUND(SQRT(AVG(POWER(error, 2))), 2) AS rmse
FROM v_eval_test_cal_norm
GROUP BY dataset_id;

CREATE OR REPLACE VIEW v_eval_metrics_overall_cal_norm AS
SELECT
  COUNT(*) AS n_units,
  ROUND(AVG(ABS(error)), 2) AS mae,
  ROUND(SQRT(AVG(POWER(error, 2))), 2) AS rmse
FROM v_eval_test_cal_norm;
