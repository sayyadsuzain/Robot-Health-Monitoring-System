-- 02b_create_test_tables.sql
-- Additional tables for CMAPSS test sets and RUL truth

USE cmaps;

CREATE TABLE IF NOT EXISTS test_cycles (
  dataset_id TINYINT NOT NULL,
  unit INT NOT NULL,
  cycle INT NOT NULL,
  setting_1 DOUBLE,
  setting_2 DOUBLE,
  setting_3 DOUBLE,
  sensor_1 DOUBLE,
  sensor_2 DOUBLE,
  sensor_3 DOUBLE,
  sensor_4 DOUBLE,
  sensor_5 DOUBLE,
  sensor_6 DOUBLE,
  sensor_7 DOUBLE,
  sensor_8 DOUBLE,
  sensor_9 DOUBLE,
  sensor_10 DOUBLE,
  sensor_11 DOUBLE,
  sensor_12 DOUBLE,
  sensor_13 DOUBLE,
  sensor_14 DOUBLE,
  sensor_15 DOUBLE,
  sensor_16 DOUBLE,
  sensor_17 DOUBLE,
  sensor_18 DOUBLE,
  sensor_19 DOUBLE,
  sensor_20 DOUBLE,
  sensor_21 DOUBLE,
  PRIMARY KEY (dataset_id, unit, cycle)
);

CREATE TABLE IF NOT EXISTS rul_truth (
  dataset_id TINYINT NOT NULL,
  unit INT NOT NULL,
  rul INT NOT NULL,
  PRIMARY KEY (dataset_id, unit)
);
