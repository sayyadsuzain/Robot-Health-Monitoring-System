-- 04_views_health.sql
-- Health computation views

USE cmaps;

CREATE OR REPLACE VIEW v_engine_cycles AS
SELECT
  dataset_id,
  unit,
  cycle,
  setting_1,
  setting_2,
  setting_3,
  sensor_1, sensor_2, sensor_3, sensor_4, sensor_5,
  sensor_6, sensor_7, sensor_8, sensor_9, sensor_10,
  sensor_11, sensor_12, sensor_13, sensor_14, sensor_15,
  sensor_16, sensor_17, sensor_18, sensor_19, sensor_20,
  sensor_21
FROM train_cycles;

CREATE OR REPLACE VIEW v_engine_health AS
SELECT
  dataset_id,
  unit,
  cycle,
  sensor_2 AS temperature,
  sensor_4 AS pressure,
  sensor_11 AS vibration,
  ROUND(
    100
    - (sensor_2 * 0.5)
    - (sensor_4 * 0.3)
    - (sensor_11 * 0.2),
  2) AS health_score
FROM v_engine_cycles;
