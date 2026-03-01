-- 11_security.sql
-- Create a least-privilege MySQL user for the dashboard
-- IMPORTANT: replace 'StrongPass_ChangeMe' with a secure password before running.

CREATE USER IF NOT EXISTS 'dashboard'@'localhost' IDENTIFIED BY 'StrongPass_ChangeMe';

-- Minimal privileges: read status and metrics, insert live readings
GRANT SELECT ON cmaps.v_engine_status TO 'dashboard'@'localhost';
GRANT SELECT ON cmaps.v_engine_status_norm TO 'dashboard'@'localhost';
GRANT SELECT ON cmaps.v_engine_status_calibrated TO 'dashboard'@'localhost';
GRANT SELECT ON cmaps.v_engine_status_calibrated_norm TO 'dashboard'@'localhost';
GRANT SELECT ON cmaps.v_engine_status_calibrated_norm_dyn TO 'dashboard'@'localhost';
GRANT SELECT ON cmaps.v_live_status TO 'dashboard'@'localhost';
GRANT SELECT ON cmaps.v_live_status_norm TO 'dashboard'@'localhost';
GRANT SELECT ON cmaps.v_live_status_norm_dyn TO 'dashboard'@'localhost';
GRANT SELECT ON cmaps.v_eval_metrics TO 'dashboard'@'localhost';
GRANT SELECT ON cmaps.v_eval_metrics_cal TO 'dashboard'@'localhost';
GRANT SELECT ON cmaps.v_eval_metrics_cal_norm TO 'dashboard'@'localhost';
GRANT SELECT ON cmaps.v_engine_diagnostics_norm TO 'dashboard'@'localhost';
GRANT SELECT ON cmaps.v_live_diagnostics_norm TO 'dashboard'@'localhost';

-- Insert permission for live input
GRANT INSERT, UPDATE ON cmaps.live_engine_input TO 'dashboard'@'localhost';

FLUSH PRIVILEGES;
