-- 10_verify.sql
-- Consolidated validation queries
USE cmaps;

-- 1) Health range and rows
SELECT COUNT(*) AS row_count, ROUND(MIN(avg_health),2) AS min_h, ROUND(MAX(avg_health),2) AS max_h
FROM v_engine_status_calibrated_norm;

-- 2) Units per dataset
SELECT dataset_id, COUNT(*) AS units
FROM v_engine_status_calibrated_norm
GROUP BY dataset_id
ORDER BY dataset_id;

-- 3) Dynamic thresholds
SELECT dataset_id, fail_max, warn_max
FROM v_dyn_thresholds
ORDER BY dataset_id;

-- 4) Evaluation metrics (normalized calibrated)
SELECT dataset_id, n_units, mae, rmse
FROM v_eval_metrics_cal_norm
ORDER BY dataset_id;

-- 5) Error percentiles (5th, 50th, 95th) from calibrated normalized evaluation
SELECT dataset_id, pctl,
       ROUND(MIN(error),2) AS min_err,
       ROUND(MAX(error),2) AS max_err
FROM (
  SELECT dataset_id, error,
         NTILE(100) OVER (PARTITION BY dataset_id ORDER BY error) AS pctl
  FROM v_eval_test_cal_norm
) t
WHERE pctl IN (5,50,95)
GROUP BY dataset_id, pctl
ORDER BY dataset_id, pctl;

-- 6) Diagnostics samples (engine)
SELECT dataset_id, unit, last_cycle,
       ROUND(last_health,2) AS last_health,
       ROUND(penalty_temp,3) AS penalty_temp,
       ROUND(penalty_pressure,3) AS penalty_pressure,
       ROUND(penalty_vibration,3) AS penalty_vibration,
       sensor_to_check
FROM v_engine_diagnostics_norm
ORDER BY last_health ASC
LIMIT 5;

-- 7) Diagnostics samples (live)
SELECT dataset_id, unit, last_cycle,
       ROUND(last_health,2) AS last_health,
       ROUND(penalty_temp,3) AS penalty_temp,
       ROUND(penalty_pressure,3) AS penalty_pressure,
       ROUND(penalty_vibration,3) AS penalty_vibration,
       sensor_to_check
FROM v_live_diagnostics_norm;

-- 8) Dynamic status row counts
SELECT (SELECT COUNT(*) FROM v_engine_status_calibrated_norm_dyn) AS hist_dyn_rows,
       (SELECT COUNT(*) FROM v_live_status_norm_dyn) AS live_dyn_rows;
