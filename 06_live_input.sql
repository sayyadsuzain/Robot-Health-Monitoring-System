-- 06_live_input.sql
-- Table for simulating live input (duplicated definition is safe)

USE cmaps;

CREATE TABLE IF NOT EXISTS live_engine_input (
  dataset_id TINYINT NOT NULL DEFAULT 1,
  unit INT NOT NULL,
  cycle INT NOT NULL,
  sensor_2 DOUBLE,
  sensor_4 DOUBLE,
  sensor_11 DOUBLE,
  PRIMARY KEY (dataset_id, unit, cycle)
);

-- Example live insert
-- INSERT INTO live_engine_input VALUES (1, 999, 1, 78.0, 35.0, 20.0);
