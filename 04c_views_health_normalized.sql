-- 04c_views_health_normalized.sql
-- Normalize selected sensors using per-dataset min-max from TRAIN data.
-- Health goes to a bounded [0,100] scale.

USE cmaps;

-- Min/Max per dataset for sensors used in health formula
CREATE OR REPLACE VIEW v_sensor_minmax AS
SELECT
  dataset_id,
  MIN(sensor_2) AS min_s2,
  MAX(sensor_2) AS max_s2,
  MIN(sensor_4) AS min_s4,
  MAX(sensor_4) AS max_s4,
  MIN(sensor_11) AS min_s11,
  MAX(sensor_11) AS max_s11
FROM train_cycles
GROUP BY dataset_id;

-- Helper to clamp division safely
-- In MySQL views, implement normalization inline with NULLIF and LEAST/GREATEST

-- TRAIN/HISTORY normalized health
CREATE OR REPLACE VIEW v_engine_health_norm AS
SELECT
  c.dataset_id,
  c.unit,
  c.cycle,
  -- normalized sensors in [0,1]
  LEAST(GREATEST((c.sensor_2 - s.min_s2) / NULLIF(s.max_s2 - s.min_s2,0), 0), 1) AS n_s2,
  LEAST(GREATEST((c.sensor_4 - s.min_s4) / NULLIF(s.max_s4 - s.min_s4,0), 0), 1) AS n_s4,
  LEAST(GREATEST((c.sensor_11 - s.min_s11) / NULLIF(s.max_s11 - s.min_s11,0), 0), 1) AS n_s11,
  -- weighted health, 0 bad -> 100 good
  ROUND(
    LEAST(GREATEST(100 - (50*LEAST(GREATEST((c.sensor_2 - s.min_s2)/NULLIF(s.max_s2 - s.min_s2,0),0),1)
                       + 30*LEAST(GREATEST((c.sensor_4 - s.min_s4)/NULLIF(s.max_s4 - s.min_s4,0),0),1)
                       + 20*LEAST(GREATEST((c.sensor_11 - s.min_s11)/NULLIF(s.max_s11 - s.min_s11,0),0),1)), 0), 100)
  , 2) AS health_score
FROM train_cycles c
JOIN v_sensor_minmax s USING (dataset_id);

-- TEST normalized health
CREATE OR REPLACE VIEW v_test_health_norm AS
SELECT
  c.dataset_id,
  c.unit,
  c.cycle,
  LEAST(GREATEST((c.sensor_2 - s.min_s2) / NULLIF(s.max_s2 - s.min_s2,0), 0), 1) AS n_s2,
  LEAST(GREATEST((c.sensor_4 - s.min_s4) / NULLIF(s.max_s4 - s.min_s4,0), 0), 1) AS n_s4,
  LEAST(GREATEST((c.sensor_11 - s.min_s11) / NULLIF(s.max_s11 - s.min_s11,0), 0), 1) AS n_s11,
  ROUND(
    LEAST(GREATEST(100 - (50*LEAST(GREATEST((c.sensor_2 - s.min_s2)/NULLIF(s.max_s2 - s.min_s2,0),0),1)
                       + 30*LEAST(GREATEST((c.sensor_4 - s.min_s4)/NULLIF(s.max_s4 - s.min_s4,0),0),1)
                       + 20*LEAST(GREATEST((c.sensor_11 - s.min_s11)/NULLIF(s.max_s11 - s.min_s11,0),0),1)), 0), 100)
  , 2) AS health_score
FROM test_cycles c
JOIN v_sensor_minmax s USING (dataset_id);

-- LIVE normalized health
CREATE OR REPLACE VIEW v_live_health_norm AS
SELECT
  l.dataset_id,
  l.unit,
  l.cycle,
  LEAST(GREATEST((l.sensor_2 - s.min_s2) / NULLIF(s.max_s2 - s.min_s2,0), 0), 1) AS n_s2,
  LEAST(GREATEST((l.sensor_4 - s.min_s4) / NULLIF(s.max_s4 - s.min_s4,0), 0), 1) AS n_s4,
  LEAST(GREATEST((l.sensor_11 - s.min_s11) / NULLIF(s.max_s11 - s.min_s11,0), 0), 1) AS n_s11,
  ROUND(
    LEAST(GREATEST(100 - (50*LEAST(GREATEST((l.sensor_2 - s.min_s2)/NULLIF(s.max_s2 - s.min_s2,0),0),1)
                       + 30*LEAST(GREATEST((l.sensor_4 - s.min_s4)/NULLIF(s.max_s4 - s.min_s4,0),0),1)
                       + 20*LEAST(GREATEST((l.sensor_11 - s.min_s11)/NULLIF(s.max_s11 - s.min_s11,0),0),1)), 0), 100)
  , 2) AS health_score
FROM live_engine_input l
JOIN v_sensor_minmax s USING (dataset_id);
