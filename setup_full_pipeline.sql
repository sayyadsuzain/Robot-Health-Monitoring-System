-- setup_full_pipeline.sql
-- COMPREHENSIVE SETUP SCRIPT FOR ENGINE HEALTH / RUL PREDICTION
-- This script replaces all individual module scripts and is compatible with MySQL Workbench.

-- 1. DATABASE INITIALIZATION
CREATE DATABASE IF NOT EXISTS cmaps;
USE cmaps;

-- 2. CLEANUP & TABLE STRUCTURES (Drop existing tables to ensure clean schema)
-- 2. CLEANUP & TABLE STRUCTURES (Drop existing tables to ensure clean schema)
SET FOREIGN_KEY_CHECKS = 0;
-- Drop Tables
DROP TABLE IF EXISTS live_engine_input;
DROP TABLE IF EXISTS rul_truth;
DROP TABLE IF EXISTS test_cycles;
DROP TABLE IF EXISTS train_cycles;
DROP TABLE IF EXISTS units;
DROP TABLE IF EXISTS datasets;
DROP TABLE IF EXISTS rul_stage;
DROP TABLE IF EXISTS test_rul;

-- Drop Views to prevent stale metadata errors (Error 1356)
DROP VIEW IF EXISTS v_live_diagnostics_norm;
DROP VIEW IF EXISTS v_live_last_norm;
DROP VIEW IF EXISTS v_engine_diagnostics_norm;
DROP VIEW IF EXISTS v_engine_last_norm;
DROP VIEW IF EXISTS v_live_status_norm_dyn;
DROP VIEW IF EXISTS v_live_prediction_calibrated_norm;
DROP VIEW IF EXISTS v_live_last_health_norm;
DROP VIEW IF EXISTS v_engine_status_calibrated_norm_dyn;
DROP VIEW IF EXISTS v_dyn_thresholds;
DROP VIEW IF EXISTS v_engine_percentiles;
DROP VIEW IF EXISTS v_eval_metrics;
DROP VIEW IF EXISTS v_eval_metrics_cal;
DROP VIEW IF EXISTS v_eval_metrics_cal_norm;
DROP VIEW IF EXISTS v_eval_test_cal_norm;
DROP VIEW IF EXISTS v_test_last_health_norm;
DROP VIEW IF EXISTS v_engine_status_calibrated_norm;
DROP VIEW IF EXISTS v_engine_prediction_calibrated_norm;
DROP VIEW IF EXISTS v_engine_last_health_norm;
DROP VIEW IF EXISTS v_regression_params_final_norm;
DROP VIEW IF EXISTS v_regression_stats_norm;
DROP VIEW IF EXISTS v_train_true_rul_norm;
DROP VIEW IF EXISTS v_train_max_cycle;
DROP VIEW IF EXISTS v_live_health_norm;
DROP VIEW IF EXISTS v_test_health_norm;
DROP VIEW IF EXISTS v_engine_health_norm;
DROP VIEW IF EXISTS v_sensor_minmax;
DROP VIEW IF EXISTS v_engine_status;
DROP VIEW IF EXISTS v_engine_status_calibrated;
DROP VIEW IF EXISTS v_engine_status_norm;
DROP VIEW IF EXISTS v_live_status;
DROP VIEW IF EXISTS v_live_status_norm;

SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE train_cycles (
  dataset_id TINYINT NOT NULL DEFAULT 1,
  unit INT NOT NULL,
  cycle INT NOT NULL,
  setting_1 DOUBLE, setting_2 DOUBLE, setting_3 DOUBLE,
  sensor_1 DOUBLE, sensor_2 DOUBLE, sensor_3 DOUBLE, sensor_4 DOUBLE, sensor_5 DOUBLE,
  sensor_6 DOUBLE, sensor_7 DOUBLE, sensor_8 DOUBLE, sensor_9 DOUBLE, sensor_10 DOUBLE,
  sensor_11 DOUBLE, sensor_12 DOUBLE, sensor_13 DOUBLE, sensor_14 DOUBLE, sensor_15 DOUBLE,
  sensor_16 DOUBLE, sensor_17 DOUBLE, sensor_18 DOUBLE, sensor_19 DOUBLE, sensor_20 DOUBLE,
  sensor_21 DOUBLE,
  PRIMARY KEY (dataset_id, unit, cycle)
);

CREATE TABLE test_cycles (
  dataset_id TINYINT NOT NULL,
  unit INT NOT NULL,
  cycle INT NOT NULL,
  setting_1 DOUBLE, setting_2 DOUBLE, setting_3 DOUBLE,
  sensor_1 DOUBLE, sensor_2 DOUBLE, sensor_3 DOUBLE, sensor_4 DOUBLE, sensor_5 DOUBLE,
  sensor_6 DOUBLE, sensor_7 DOUBLE, sensor_8 DOUBLE, sensor_9 DOUBLE, sensor_10 DOUBLE,
  sensor_11 DOUBLE, sensor_12 DOUBLE, sensor_13 DOUBLE, sensor_14 DOUBLE, sensor_15 DOUBLE,
  sensor_16 DOUBLE, sensor_17 DOUBLE, sensor_18 DOUBLE, sensor_19 DOUBLE, sensor_20 DOUBLE,
  sensor_21 DOUBLE,
  PRIMARY KEY (dataset_id, unit, cycle)
);

CREATE TABLE rul_truth (
  dataset_id TINYINT NOT NULL,
  unit INT NOT NULL,
  rul INT NOT NULL,
  PRIMARY KEY (dataset_id, unit)
);

CREATE TABLE live_engine_input (
  dataset_id TINYINT NOT NULL DEFAULT 1,
  unit INT NOT NULL,
  cycle INT NOT NULL,
  sensor_2 DOUBLE, sensor_4 DOUBLE, sensor_11 DOUBLE,
  PRIMARY KEY (dataset_id, unit, cycle)
);

CREATE TABLE datasets (
  dataset_id TINYINT PRIMARY KEY,
  name VARCHAR(28)
) ENGINE=InnoDB;

INSERT IGNORE INTO datasets(dataset_id, name) VALUES (1,'FD001'),(2,'FD002'),(3,'FD003'),(4,'FD004');

CREATE TABLE IF NOT EXISTS units (
  dataset_id TINYINT NOT NULL,
  unit INT NOT NULL,
  PRIMARY KEY(dataset_id, unit),
  CONSTRAINT fk_units_dataset FOREIGN KEY (dataset_id) REFERENCES datasets(dataset_id)
) ENGINE=InnoDB;

-- 3. DATA LOADING (Validated target directory: E:/DBMS-2/CMAPSSData/)
SET GLOBAL local_infile = 1;

CREATE TABLE IF NOT EXISTS rul_stage (id INT NOT NULL AUTO_INCREMENT, rul INT, PRIMARY KEY (id)) ENGINE=InnoDB;

-- Load Training Data
LOAD DATA LOCAL INFILE 'e:/DBMS-2/CMAPSSData/train_FD001.txt' INTO TABLE train_cycles FIELDS TERMINATED BY ' ' LINES TERMINATED BY '\n' (@c1,@c2,@c3,@c4,@c5,@c6,@c7,@c8,@c9,@c10,@c11,@c12,@c13,@c14,@c15,@c16,@c17,@c18,@c19,@c20,@c21,@c22,@c23,@c24,@c25,@c26,@d1,@d2) SET dataset_id=1, unit=NULLIF(@c1,''), cycle=NULLIF(@c2,''), setting_1=NULLIF(@c3,''), setting_2=NULLIF(@c4,''), setting_3=NULLIF(@c5,''), sensor_1=NULLIF(@c6,''), sensor_2=NULLIF(@c7,''), sensor_3=NULLIF(@c8,''), sensor_4=NULLIF(@c9,''), sensor_5=NULLIF(@c10,''), sensor_11=NULLIF(@c16,'');
LOAD DATA LOCAL INFILE 'e:/DBMS-2/CMAPSSData/train_FD002.txt' INTO TABLE train_cycles FIELDS TERMINATED BY ' ' LINES TERMINATED BY '\n' (@c1,@c2,@c3,@c4,@c5,@c6,@c7,@c8,@c9,@c10,@c11,@c12,@c13,@c14,@c15,@c16,@c17,@c18,@c19,@c20,@c21,@c22,@c23,@c24,@c25,@c26,@d1,@d2) SET dataset_id=2, unit=NULLIF(@c1,''), cycle=NULLIF(@c2,''), setting_1=NULLIF(@c3,''), setting_2=NULLIF(@c4,''), setting_3=NULLIF(@c5,''), sensor_1=NULLIF(@c6,''), sensor_2=NULLIF(@c7,''), sensor_3=NULLIF(@c8,''), sensor_4=NULLIF(@c9,''), sensor_5=NULLIF(@c10,''), sensor_11=NULLIF(@c16,'');
LOAD DATA LOCAL INFILE 'e:/DBMS-2/CMAPSSData/train_FD003.txt' INTO TABLE train_cycles FIELDS TERMINATED BY ' ' LINES TERMINATED BY '\n' (@c1,@c2,@c3,@c4,@c5,@c6,@c7,@c8,@c9,@c10,@c11,@c12,@c13,@c14,@c15,@c16,@c17,@c18,@c19,@c20,@c21,@c22,@c23,@c24,@c25,@c26,@d1,@d2) SET dataset_id=3, unit=NULLIF(@c1,''), cycle=NULLIF(@c2,''), setting_1=NULLIF(@c3,''), setting_2=NULLIF(@c4,''), setting_3=NULLIF(@c5,''), sensor_1=NULLIF(@c6,''), sensor_2=NULLIF(@c7,''), sensor_3=NULLIF(@c8,''), sensor_4=NULLIF(@c9,''), sensor_5=NULLIF(@c10,''), sensor_11=NULLIF(@c16,'');
LOAD DATA LOCAL INFILE 'e:/DBMS-2/CMAPSSData/train_FD004.txt' INTO TABLE train_cycles FIELDS TERMINATED BY ' ' LINES TERMINATED BY '\n' (@c1,@c2,@c3,@c4,@c5,@c6,@c7,@c8,@c9,@c10,@c11,@c12,@c13,@c14,@c15,@c16,@c17,@c18,@c19,@c20,@c21,@c22,@c23,@c24,@c25,@c26,@d1,@d2) SET dataset_id=4, unit=NULLIF(@c1,''), cycle=NULLIF(@c2,''), setting_1=NULLIF(@c3,''), setting_2=NULLIF(@c4,''), setting_3=NULLIF(@c5,''), sensor_1=NULLIF(@c6,''), sensor_2=NULLIF(@c7,''), sensor_3=NULLIF(@c8,''), sensor_4=NULLIF(@c9,''), sensor_5=NULLIF(@c10,''), sensor_11=NULLIF(@c16,'');

-- Load Test Data
LOAD DATA LOCAL INFILE 'e:/DBMS-2/CMAPSSData/test_FD001.txt' INTO TABLE test_cycles FIELDS TERMINATED BY ' ' LINES TERMINATED BY '\n' (@c1,@c2,@c3,@c4,@c5,@c6,@c7,@c8,@c9,@c10,@c11,@c12,@c13,@c14,@c15,@c16,@c17,@c18,@c19,@c20,@c21,@c22,@c23,@c24,@c25,@c26,@d1,@d2) SET dataset_id=1, unit=NULLIF(@c1,''), cycle=NULLIF(@c2,''), setting_1=NULLIF(@c3,''), setting_2=NULLIF(@c4,''), setting_3=NULLIF(@c5,''), sensor_1=NULLIF(@c6,''), sensor_2=NULLIF(@c7,''), sensor_3=NULLIF(@c8,''), sensor_4=NULLIF(@c9,''), sensor_5=NULLIF(@c10,''), sensor_11=NULLIF(@c16,'');
LOAD DATA LOCAL INFILE 'e:/DBMS-2/CMAPSSData/test_FD002.txt' INTO TABLE test_cycles FIELDS TERMINATED BY ' ' LINES TERMINATED BY '\n' (@c1,@c2,@c3,@c4,@c5,@c6,@c7,@c8,@c9,@c10,@c11,@c12,@c13,@c14,@c15,@c16,@c17,@c18,@c19,@c20,@c21,@c22,@c23,@c24,@c25,@c26,@d1,@d2) SET dataset_id=2, unit=NULLIF(@c1,''), cycle=NULLIF(@c2,''), setting_1=NULLIF(@c3,''), setting_2=NULLIF(@c4,''), setting_3=NULLIF(@c5,''), sensor_1=NULLIF(@c6,''), sensor_2=NULLIF(@c7,''), sensor_3=NULLIF(@c8,''), sensor_4=NULLIF(@c9,''), sensor_5=NULLIF(@c10,''), sensor_11=NULLIF(@c16,'');
LOAD DATA LOCAL INFILE 'e:/DBMS-2/CMAPSSData/test_FD003.txt' INTO TABLE test_cycles FIELDS TERMINATED BY ' ' LINES TERMINATED BY '\n' (@c1,@c2,@c3,@c4,@c5,@c6,@c7,@c8,@c9,@c10,@c11,@c12,@c13,@c14,@c15,@c16,@c17,@c18,@c19,@c20,@c21,@c22,@c23,@c24,@c25,@c26,@d1,@d2) SET dataset_id=3, unit=NULLIF(@c1,''), cycle=NULLIF(@c2,''), setting_1=NULLIF(@c3,''), setting_2=NULLIF(@c4,''), setting_3=NULLIF(@c5,''), sensor_1=NULLIF(@c6,''), sensor_2=NULLIF(@c7,''), sensor_3=NULLIF(@c8,''), sensor_4=NULLIF(@c9,''), sensor_5=NULLIF(@c10,''), sensor_11=NULLIF(@c16,'');
LOAD DATA LOCAL INFILE 'e:/DBMS-2/CMAPSSData/test_FD004.txt' INTO TABLE test_cycles FIELDS TERMINATED BY ' ' LINES TERMINATED BY '\n' (@c1,@c2,@c3,@c4,@c5,@c6,@c7,@c8,@c9,@c10,@c11,@c12,@c13,@c14,@c15,@c16,@c17,@c18,@c19,@c20,@c21,@c22,@c23,@c24,@c25,@c26,@d1,@d2) SET dataset_id=4, unit=NULLIF(@c1,''), cycle=NULLIF(@c2,''), setting_1=NULLIF(@c3,''), setting_2=NULLIF(@c4,''), setting_3=NULLIF(@c5,''), sensor_1=NULLIF(@c6,''), sensor_2=NULLIF(@c7,''), sensor_3=NULLIF(@c8,''), sensor_4=NULLIF(@c9,''), sensor_5=NULLIF(@c10,''), sensor_11=NULLIF(@c16,'');

-- Load RUL Truth
TRUNCATE rul_stage;
LOAD DATA LOCAL INFILE 'e:/DBMS-2/CMAPSSData/RUL_FD001.txt' INTO TABLE rul_stage FIELDS TERMINATED BY ' ' LINES TERMINATED BY '\n' (@rul,@d1) SET rul = NULLIF(@rul,'');
INSERT IGNORE INTO rul_truth (dataset_id, unit, rul) SELECT 1, id, rul FROM rul_stage;
TRUNCATE rul_stage;
LOAD DATA LOCAL INFILE 'e:/DBMS-2/CMAPSSData/RUL_FD002.txt' INTO TABLE rul_stage FIELDS TERMINATED BY ' ' LINES TERMINATED BY '\n' (@rul,@d1) SET rul = NULLIF(@rul,'');
INSERT IGNORE INTO rul_truth (dataset_id, unit, rul) SELECT 2, id, rul FROM rul_stage;
TRUNCATE rul_stage;
LOAD DATA LOCAL INFILE 'e:/DBMS-2/CMAPSSData/RUL_FD003.txt' INTO TABLE rul_stage FIELDS TERMINATED BY ' ' LINES TERMINATED BY '\n' (@rul,@d1) SET rul = NULLIF(@rul,'');
INSERT IGNORE INTO rul_truth (dataset_id, unit, rul) SELECT 3, id, rul FROM rul_stage;
TRUNCATE rul_stage;
LOAD DATA LOCAL INFILE 'e:/DBMS-2/CMAPSSData/RUL_FD004.txt' INTO TABLE rul_stage FIELDS TERMINATED BY ' ' LINES TERMINATED BY '\n' (@rul,@d1) SET rul = NULLIF(@rul,'');
INSERT IGNORE INTO rul_truth (dataset_id, unit, rul) SELECT 4, id, rul FROM rul_stage;

-- Populate units
INSERT IGNORE INTO units(dataset_id, unit) 
SELECT dataset_id, unit FROM train_cycles GROUP BY dataset_id, unit UNION 
SELECT dataset_id, unit FROM test_cycles GROUP BY dataset_id, unit;

-- 4. ANALYTICAL VIEWS (Base Logic)
CREATE OR REPLACE VIEW v_sensor_minmax AS SELECT dataset_id, MIN(sensor_2) AS min_s2, MAX(sensor_2) AS max_s2, MIN(sensor_4) AS min_s4, MAX(sensor_4) AS max_s4, MIN(sensor_11) AS min_s11, MAX(sensor_11) AS max_s11 FROM train_cycles GROUP BY dataset_id;

CREATE OR REPLACE VIEW v_engine_health_norm AS SELECT c.dataset_id, c.unit, c.cycle, LEAST(GREATEST((c.sensor_2 - s.min_s2)/NULLIF(s.max_s2 - s.min_s2,0),0),1) AS n_s2, LEAST(GREATEST((c.sensor_4 - s.min_s4)/NULLIF(s.max_s4 - s.min_s4,0),0),1) AS n_s4, LEAST(GREATEST((c.sensor_11 - s.min_s11)/NULLIF(s.max_s11 - s.min_s11,0),0),1) AS n_s11, ROUND(LEAST(GREATEST(100 - (50*LEAST(GREATEST((c.sensor_2 - s.min_s2)/NULLIF(s.max_s2 - s.min_s2,0),0),1) + 30*LEAST(GREATEST((c.sensor_4 - s.min_s4)/NULLIF(s.max_s4 - s.min_s4,0),0),1) + 20*LEAST(GREATEST((c.sensor_11 - s.min_s11)/NULLIF(s.max_s11 - s.min_s11,0),0),1)), 0), 100), 2) AS health_score FROM train_cycles c JOIN v_sensor_minmax s USING (dataset_id);

CREATE OR REPLACE VIEW v_test_health_norm AS SELECT c.dataset_id, c.unit, c.cycle, LEAST(GREATEST((c.sensor_2 - s.min_s2)/NULLIF(s.max_s2 - s.min_s2,0),0),1) AS n_s2, LEAST(GREATEST((c.sensor_4 - s.min_s4)/NULLIF(s.max_s4 - s.min_s4,0),0),1) AS n_s4, LEAST(GREATEST((c.sensor_11 - s.min_s11)/NULLIF(s.max_s11 - s.min_s11,0),0),1) AS n_s11, ROUND(LEAST(GREATEST(100 - (50*LEAST(GREATEST((c.sensor_2 - s.min_s2)/NULLIF(s.max_s2 - s.min_s2,0),0),1) + 30*LEAST(GREATEST((c.sensor_4 - s.min_s4)/NULLIF(s.max_s4 - s.min_s4,0),0),1) + 20*LEAST(GREATEST((c.sensor_11 - s.min_s11)/NULLIF(s.max_s11 - s.min_s11,0),0),1)), 0), 100), 2) AS health_score FROM test_cycles c JOIN v_sensor_minmax s USING (dataset_id);

CREATE OR REPLACE VIEW v_live_health_norm AS SELECT l.dataset_id, l.unit, l.cycle, LEAST(GREATEST((l.sensor_2 - s.min_s2)/NULLIF(s.max_s2 - s.min_s2,0),0),1) AS n_s2, LEAST(GREATEST((l.sensor_4 - s.min_s4)/NULLIF(s.max_s4 - s.min_s4,0),0),1) AS n_s4, LEAST(GREATEST((l.sensor_11 - s.min_s11)/NULLIF(s.max_s11 - s.min_s11,0),0),1) AS n_s11, ROUND(LEAST(GREATEST(100 - (50*LEAST(GREATEST((l.sensor_2 - s.min_s2)/NULLIF(s.max_s2 - s.min_s2,0),0),1) + 30*LEAST(GREATEST((l.sensor_4 - s.min_s4)/NULLIF(s.max_s4 - s.min_s4,0),0),1) + 20*LEAST(GREATEST((l.sensor_11 - s.min_s11)/NULLIF(s.max_s11 - s.min_s11,0),0),1)), 0), 100), 2) AS health_score FROM live_engine_input l JOIN v_sensor_minmax s USING (dataset_id);

-- 5. REGRESSION & CALIBRATION
CREATE OR REPLACE VIEW v_train_max_cycle AS SELECT dataset_id, unit, MAX(cycle) AS max_cycle FROM train_cycles GROUP BY dataset_id, unit;

CREATE OR REPLACE VIEW v_train_true_rul_norm AS SELECT h.dataset_id, h.unit, h.cycle, h.health_score, (m.max_cycle - h.cycle) AS true_rul FROM v_engine_health_norm h JOIN v_train_max_cycle m ON m.dataset_id = h.dataset_id AND m.unit = h.unit;

CREATE OR REPLACE VIEW v_regression_stats_norm AS SELECT dataset_id, COUNT(*) AS n, SUM(health_score) AS sum_x, SUM(true_rul) AS sum_y, SUM(health_score * health_score) AS sum_xx, SUM(health_score * true_rul) AS sum_xy FROM v_train_true_rul_norm GROUP BY dataset_id;

CREATE OR REPLACE VIEW v_regression_params_final_norm AS SELECT dataset_id, (sum_y / n) - ((CASE WHEN (n * sum_xx - sum_x * sum_x) = 0 THEN 0 ELSE (n * sum_xy - sum_x * sum_y) / (n * sum_xx - sum_x * sum_x) END) * (sum_x / n)) AS a, (CASE WHEN (n * sum_xx - sum_x * sum_x) = 0 THEN 0 ELSE (n * sum_xy - sum_x * sum_y) / (n * sum_xx - sum_x * sum_x) END) AS b FROM v_regression_stats_norm;

-- 6. FINAL PERFORMANCE VIEWS
CREATE OR REPLACE VIEW v_engine_last_health_norm AS SELECT h.dataset_id, h.unit, h.cycle AS last_cycle, h.health_score AS last_health FROM v_engine_health_norm h JOIN (SELECT dataset_id, unit, MAX(cycle) AS max_cycle FROM v_engine_health_norm GROUP BY dataset_id, unit) m ON h.dataset_id = m.dataset_id AND h.unit = m.unit AND h.cycle = m.max_cycle;

CREATE OR REPLACE VIEW v_engine_prediction_calibrated_norm AS SELECT l.dataset_id, l.unit, l.last_cycle, l.last_health, GREATEST(ROUND(p.a + p.b * l.last_health, 0), 0) AS estimated_cycles_left FROM v_engine_last_health_norm l JOIN v_regression_params_final_norm p ON p.dataset_id = l.dataset_id;

CREATE OR REPLACE VIEW v_engine_status_calibrated_norm AS SELECT dataset_id, unit, last_cycle, last_health AS avg_health, estimated_cycles_left, CASE WHEN estimated_cycles_left = 0 THEN 'FAILED' WHEN estimated_cycles_left < 10 THEN 'FAIL SOON' WHEN estimated_cycles_left < 25 THEN 'WARNING' ELSE 'HEALTHY' END AS status FROM v_engine_prediction_calibrated_norm;

-- 7. EVALUATION
CREATE OR REPLACE VIEW v_test_last_health_norm AS SELECT h.dataset_id, h.unit, h.cycle AS last_cycle, h.health_score AS last_health FROM v_test_health_norm h JOIN (SELECT dataset_id, unit, MAX(cycle) AS max_cycle FROM v_test_health_norm GROUP BY dataset_id, unit) m ON h.dataset_id = m.dataset_id AND h.unit = m.unit AND h.cycle = m.max_cycle;

CREATE OR REPLACE VIEW v_eval_test_cal_norm AS SELECT h.dataset_id, h.unit, h.last_cycle, h.last_health, GREATEST(ROUND(p.a + p.b * h.last_health, 0), 0) AS predicted_rul_cal, r.rul AS true_rul, (GREATEST(ROUND(p.a + p.b * h.last_health, 0), 0) - r.rul) AS error FROM v_test_last_health_norm h JOIN rul_truth r ON r.dataset_id = h.dataset_id AND r.unit = h.unit JOIN v_regression_params_final_norm p ON p.dataset_id = h.dataset_id;

CREATE OR REPLACE VIEW v_eval_metrics_cal_norm AS SELECT dataset_id, COUNT(*) AS n_units, ROUND(AVG(ABS(error)), 2) AS mae, ROUND(SQRT(AVG(POWER(error, 2))), 2) AS rmse FROM v_eval_test_cal_norm GROUP BY dataset_id;

-- 8. DYNAMIC STATUS
CREATE OR REPLACE VIEW v_engine_percentiles AS SELECT p1.dataset_id, p1.unit, p1.estimated_cycles_left, (SELECT COUNT(*) FROM v_engine_prediction_calibrated_norm p2 WHERE p2.dataset_id = p1.dataset_id AND p2.estimated_cycles_left <= p1.estimated_cycles_left) * 100.0 / (SELECT NULLIF(COUNT(*),0) FROM v_engine_prediction_calibrated_norm p3 WHERE p3.dataset_id = p1.dataset_id) AS pctl FROM v_engine_prediction_calibrated_norm p1;

CREATE OR REPLACE VIEW v_dyn_thresholds AS SELECT dataset_id, MAX(CASE WHEN pctl <= 10 THEN estimated_cycles_left END) AS fail_max, MAX(CASE WHEN pctl <= 25 THEN estimated_cycles_left END) AS warn_max FROM v_engine_percentiles GROUP BY dataset_id;

CREATE OR REPLACE VIEW v_engine_status_calibrated_norm_dyn AS SELECT p.dataset_id, p.unit, p.last_cycle, p.last_health AS avg_health, p.estimated_cycles_left, CASE WHEN p.estimated_cycles_left = 0 THEN 'FAILED' WHEN p.estimated_cycles_left <= t.fail_max THEN 'FAIL SOON' WHEN p.estimated_cycles_left <= t.warn_max THEN 'WARNING' ELSE 'HEALTHY' END AS status FROM v_engine_prediction_calibrated_norm p JOIN v_dyn_thresholds t USING (dataset_id);

-- 9. LIVE PREDICTIONS
CREATE OR REPLACE VIEW v_live_last_health_norm AS SELECT h.dataset_id, h.unit, h.cycle AS last_cycle, h.health_score AS last_health FROM v_live_health_norm h JOIN (SELECT dataset_id, unit, MAX(cycle) AS max_cycle FROM v_live_health_norm GROUP BY dataset_id, unit) m ON h.dataset_id = m.dataset_id AND h.unit = m.unit AND h.cycle = m.max_cycle;

CREATE OR REPLACE VIEW v_live_prediction_calibrated_norm AS SELECT l.dataset_id, l.unit, l.last_cycle, l.last_health, GREATEST(ROUND(p.a + p.b * l.last_health, 0), 0) AS estimated_cycles_left FROM v_live_last_health_norm l JOIN v_regression_params_final_norm p ON p.dataset_id = l.dataset_id;

CREATE OR REPLACE VIEW v_live_status_norm_dyn AS SELECT p.dataset_id, p.unit, p.last_cycle, p.last_health AS avg_health, p.estimated_cycles_left, CASE WHEN p.estimated_cycles_left = 0 THEN 'FAILED' WHEN p.estimated_cycles_left <= t.fail_max THEN 'FAIL SOON' WHEN p.estimated_cycles_left <= t.warn_max THEN 'WARNING' ELSE 'HEALTHY' END AS status FROM v_live_prediction_calibrated_norm p JOIN v_dyn_thresholds t USING (dataset_id);

-- 10. DIAGNOSTICS
CREATE OR REPLACE VIEW v_engine_last_norm AS SELECT h.dataset_id, h.unit, h.cycle, h.n_s2, h.n_s4, h.n_s11, h.health_score FROM v_engine_health_norm h JOIN (SELECT dataset_id, unit, MAX(cycle) AS max_cycle FROM v_engine_health_norm GROUP BY dataset_id, unit) m ON h.dataset_id = m.dataset_id AND h.unit = m.unit AND h.cycle = m.max_cycle;

CREATE OR REPLACE VIEW v_engine_diagnostics_norm AS SELECT e.dataset_id, e.unit, e.cycle AS last_cycle, e.health_score AS last_health, ROUND(50*e.n_s2,2) AS penalty_temp, ROUND(30*e.n_s4,2) AS penalty_pressure, ROUND(20*e.n_s11,2) AS penalty_vibration, CASE WHEN 50*e.n_s2 >= 30*e.n_s4 AND 50*e.n_s2 >= 20*e.n_s11 THEN 'sensor_2 (Temperature)' WHEN 30*e.n_s4 >= 50*e.n_s2 AND 30*e.n_s4 >= 20*e.n_s11 THEN 'sensor_4 (Pressure)' ELSE 'sensor_11 (Vibration)' END AS sensor_to_check FROM v_engine_last_norm e;

CREATE OR REPLACE VIEW v_live_last_norm AS SELECT h.dataset_id, h.unit, h.cycle, h.n_s2, h.n_s4, h.n_s11, h.health_score FROM v_live_health_norm h JOIN (SELECT dataset_id, unit, MAX(cycle) AS max_cycle FROM v_live_health_norm GROUP BY dataset_id, unit) m ON h.dataset_id = m.dataset_id AND h.unit = m.unit AND h.cycle = m.max_cycle;

CREATE OR REPLACE VIEW v_live_diagnostics_norm AS SELECT l.dataset_id, l.unit, l.cycle AS last_cycle, l.health_score AS last_health, ROUND(50*l.n_s2,2) AS penalty_temp, ROUND(30*l.n_s4,2) AS penalty_pressure, ROUND(20*l.n_s11,2) AS penalty_vibration, CASE WHEN 50*l.n_s2 >= 30*l.n_s4 AND 50*l.n_s2 >= 20*l.n_s11 THEN 'sensor_2 (Temperature)' WHEN 30*l.n_s4 >= 50*l.n_s2 AND 30*l.n_s4 >= 20*l.n_s11 THEN 'sensor_4 (Pressure)' ELSE 'sensor_11 (Vibration)' END AS sensor_to_check FROM v_live_last_norm l;

-- 11. ALIASES FOR DASHBOARD COMPATIBILITY (Must be at the end)
CREATE OR REPLACE VIEW v_engine_status AS SELECT * FROM v_engine_status_calibrated_norm;
CREATE OR REPLACE VIEW v_engine_status_calibrated AS SELECT * FROM v_engine_status_calibrated_norm;
CREATE OR REPLACE VIEW v_engine_status_norm AS SELECT * FROM v_engine_status_calibrated_norm;
CREATE OR REPLACE VIEW v_live_status AS SELECT * FROM v_live_status_norm_dyn;
CREATE OR REPLACE VIEW v_live_status_norm AS SELECT * FROM v_live_status_norm_dyn;
CREATE OR REPLACE VIEW v_eval_metrics AS SELECT * FROM v_eval_metrics_cal_norm;
CREATE OR REPLACE VIEW v_eval_metrics_cal AS SELECT * FROM v_eval_metrics_cal_norm;

-- FINAL VERIFICATION
SELECT 'SUCCESS! DATABASE COMPLETED.' AS Message, (SELECT COUNT(*) FROM train_cycles) AS Total_Train_Rows, (SELECT COUNT(*) FROM test_cycles) AS Total_Test_Rows;
