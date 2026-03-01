-- 08_sample_data.sql
-- Optional: Minimal seed data to validate views without CSV

USE cmaps;

-- Clean small test subset (optional)
DELETE FROM train_cycles WHERE unit IN (1001) AND dataset_id = 1;

INSERT INTO train_cycles (
  dataset_id, unit, cycle,
  setting_1, setting_2, setting_3,
  sensor_1, sensor_2, sensor_3, sensor_4, sensor_5,
  sensor_6, sensor_7, sensor_8, sensor_9, sensor_10,
  sensor_11, sensor_12, sensor_13, sensor_14, sensor_15,
  sensor_16, sensor_17, sensor_18, sensor_19, sensor_20,
  sensor_21
) VALUES
(1, 1001, 1, 0,0,0,  10, 70, 12, 30,  5,  6,  7,  8,  9, 10,  12,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11),
(1, 1001, 2, 0,0,0,  10, 72, 12, 33,  5,  6,  7,  8,  9, 10,  15,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11),
(1, 1001, 3, 0,0,0,  10, 68, 12, 29,  5,  6,  7,  8,  9, 10,  13,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11);

-- Quick checks
SELECT * FROM v_engine_health WHERE unit = 1001 ORDER BY cycle;
SELECT * FROM v_engine_prediction WHERE unit = 1001;
SELECT * FROM v_engine_status WHERE unit = 1001;
