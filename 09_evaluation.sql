-- 09_evaluation.sql
-- Evaluation views: compare SQL estimated cycles left vs CMAPSS RUL truth (test sets)

USE cmaps;

-- Join predictions at last cycle with truth
CREATE OR REPLACE VIEW v_eval_test AS
SELECT
  p.dataset_id,
  p.unit,
  p.last_cycle,
  p.avg_health,
  p.estimated_cycles_left AS predicted_rul,
  r.rul AS true_rul,
  (p.estimated_cycles_left - r.rul) AS error
FROM v_test_prediction p
JOIN rul_truth r
  ON r.dataset_id = p.dataset_id
 AND r.unit = p.unit;

-- Metrics by dataset
CREATE OR REPLACE VIEW v_eval_metrics AS
SELECT
  dataset_id,
  COUNT(*) AS n_units,
  ROUND(AVG(ABS(error)), 2) AS mae,
  ROUND(SQRT(AVG(POWER(error, 2))), 2) AS rmse
FROM v_eval_test
GROUP BY dataset_id;

-- Overall metrics
CREATE OR REPLACE VIEW v_eval_metrics_overall AS
SELECT
  COUNT(*) AS n_units,
  ROUND(AVG(ABS(error)), 2) AS mae,
  ROUND(SQRT(AVG(POWER(error, 2))), 2) AS rmse
FROM v_eval_test;
