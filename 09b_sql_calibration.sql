-- 09b_sql_calibration.sql
-- SQL-only calibration: fit per-dataset linear model RUL = a + b * health_score using TRAIN data
-- Then apply to TEST last-cycle health and evaluate against RUL truth.

USE cmaps;

-- 1) Training labels at every cycle: true RUL = max(cycle) - cycle
CREATE OR REPLACE VIEW v_train_max_cycle AS
SELECT dataset_id, unit, MAX(cycle) AS max_cycle
FROM train_cycles
GROUP BY dataset_id, unit;

CREATE OR REPLACE VIEW v_train_true_rul AS
SELECT h.dataset_id, h.unit, h.cycle, h.health_score,
       (m.max_cycle - h.cycle) AS true_rul
FROM v_engine_health h
JOIN v_train_max_cycle m
  ON m.dataset_id = h.dataset_id AND m.unit = h.unit;

-- 2) Per-dataset regression params using closed-form least squares
--    RUL ~ a + b * health_score
CREATE OR REPLACE VIEW v_regression_sufficient_stats AS
SELECT
  dataset_id,
  COUNT(*) AS n,
  SUM(health_score) AS sum_x,
  SUM(true_rul) AS sum_y,
  SUM(health_score * health_score) AS sum_xx,
  SUM(health_score * true_rul) AS sum_xy
FROM v_train_true_rul
GROUP BY dataset_id;

CREATE OR REPLACE VIEW v_regression_params AS
SELECT
  dataset_id,
  -- denominator: n*sum_xx - sum_x^2 (guard against zero)
  CASE WHEN (n * sum_xx - sum_x * sum_x) = 0 THEN 0
       ELSE (n * sum_xy - sum_x * sum_y) / (n * sum_xx - sum_x * sum_x) END AS b,
  0.0 AS a_init,
  n, sum_x, sum_y, sum_xx, sum_xy
FROM v_regression_sufficient_stats;

-- Compute intercept using means: a = ybar - b*xbar
CREATE OR REPLACE VIEW v_regression_params_final AS
SELECT
  dataset_id,
  (sum_y / n) - ((CASE WHEN (n * sum_xx - sum_x * sum_x) = 0 THEN 0
                       ELSE (n * sum_xy - sum_x * sum_y) / (n * sum_xx - sum_x * sum_x) END) * (sum_x / n)) AS a,
  (CASE WHEN (n * sum_xx - sum_x * sum_x) = 0 THEN 0
        ELSE (n * sum_xy - sum_x * sum_y) / (n * sum_xx - sum_x * sum_x) END) AS b
FROM v_regression_sufficient_stats;

-- 3) Test last-cycle health per unit
CREATE OR REPLACE VIEW v_test_last_health AS
SELECT th.dataset_id, th.unit,
       MAX(th.cycle) AS last_cycle,
       SUBSTRING_INDEX(GROUP_CONCAT(th.health_score ORDER BY th.cycle DESC), ',', 1) + 0.0 AS last_health
FROM v_test_health th
GROUP BY th.dataset_id, th.unit;

-- 4) Apply calibrated model: predicted_rul_cal = GREATEST(a + b * last_health, 0)
CREATE OR REPLACE VIEW v_test_prediction_calibrated AS
SELECT
  l.dataset_id,
  l.unit,
  l.last_cycle,
  l.last_health,
  GREATEST(ROUND(p.a + p.b * l.last_health, 0), 0) AS predicted_rul_cal
FROM v_test_last_health l
JOIN v_regression_params_final p
  ON p.dataset_id = l.dataset_id;

-- 5) Evaluation against RUL truth
CREATE OR REPLACE VIEW v_eval_test_cal AS
SELECT
  c.dataset_id,
  c.unit,
  c.last_cycle,
  c.last_health,
  c.predicted_rul_cal,
  r.rul AS true_rul,
  (c.predicted_rul_cal - r.rul) AS error
FROM v_test_prediction_calibrated c
JOIN rul_truth r
  ON r.dataset_id = c.dataset_id AND r.unit = c.unit;

CREATE OR REPLACE VIEW v_eval_metrics_cal AS
SELECT
  dataset_id,
  COUNT(*) AS n_units,
  ROUND(AVG(ABS(error)), 2) AS mae,
  ROUND(SQRT(AVG(POWER(error, 2))), 2) AS rmse
FROM v_eval_test_cal
GROUP BY dataset_id;

CREATE OR REPLACE VIEW v_eval_metrics_overall_cal AS
SELECT
  COUNT(*) AS n_units,
  ROUND(AVG(ABS(error)), 2) AS mae,
  ROUND(SQRT(AVG(POWER(error, 2))), 2) AS rmse
FROM v_eval_test_cal;
