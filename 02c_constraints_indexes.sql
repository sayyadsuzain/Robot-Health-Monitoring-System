-- 02c_constraints_indexes.sql
-- DBMS hardening: constraints and helpful indexes

USE cmaps;

-- Train cycles: enforce dataset_id range and positive cycle
ALTER TABLE train_cycles
  ADD CONSTRAINT chk_train_dataset_id CHECK (dataset_id BETWEEN 1 AND 4),
  ADD CONSTRAINT chk_train_cycle CHECK (cycle >= 1),
  ADD CONSTRAINT chk_train_s2 CHECK (sensor_2 IS NULL OR sensor_2 BETWEEN -100000 AND 100000),
  ADD CONSTRAINT chk_train_s4 CHECK (sensor_4 IS NULL OR sensor_4 BETWEEN -100000 AND 100000),
  ADD CONSTRAINT chk_train_s11 CHECK (sensor_11 IS NULL OR sensor_11 BETWEEN -100000 AND 100000);

-- Test cycles
ALTER TABLE test_cycles
  ADD CONSTRAINT chk_test_dataset_id CHECK (dataset_id BETWEEN 1 AND 4),
  ADD CONSTRAINT chk_test_cycle CHECK (cycle >= 1),
  ADD CONSTRAINT chk_test_s2 CHECK (sensor_2 IS NULL OR sensor_2 BETWEEN -100000 AND 100000),
  ADD CONSTRAINT chk_test_s4 CHECK (sensor_4 IS NULL OR sensor_4 BETWEEN -100000 AND 100000),
  ADD CONSTRAINT chk_test_s11 CHECK (sensor_11 IS NULL OR sensor_11 BETWEEN -100000 AND 100000);

-- Live input
ALTER TABLE live_engine_input
  ADD CONSTRAINT chk_live_dataset_id CHECK (dataset_id BETWEEN 1 AND 4),
  ADD CONSTRAINT chk_live_cycle CHECK (cycle >= 1),
  ADD CONSTRAINT chk_live_s2 CHECK (sensor_2 IS NULL OR sensor_2 BETWEEN -100000 AND 100000),
  ADD CONSTRAINT chk_live_s4 CHECK (sensor_4 IS NULL OR sensor_4 BETWEEN -100000 AND 100000),
  ADD CONSTRAINT chk_live_s11 CHECK (sensor_11 IS NULL OR sensor_11 BETWEEN -100000 AND 100000);

-- Helpful indexes for common filters (drop if exist, then create)
-- helper procedure to drop index if exists (session-level)
SET @sql := (
  SELECT IF(
    (SELECT COUNT(1) FROM information_schema.statistics
      WHERE table_schema = DATABASE()
        AND table_name = 'train_cycles'
        AND index_name = 'idx_train_unit') > 0,
    'ALTER TABLE train_cycles DROP INDEX idx_train_unit',
    'SELECT 1'
  )
);
PREPARE s1 FROM @sql; EXECUTE s1; DEALLOCATE PREPARE s1;
CREATE INDEX idx_train_unit ON train_cycles(unit);

SET @sql := (
  SELECT IF(
    (SELECT COUNT(1) FROM information_schema.statistics
      WHERE table_schema = DATABASE()
        AND table_name = 'test_cycles'
        AND index_name = 'idx_test_unit') > 0,
    'ALTER TABLE test_cycles DROP INDEX idx_test_unit',
    'SELECT 1'
  )
);
PREPARE s2 FROM @sql; EXECUTE s2; DEALLOCATE PREPARE s2;
CREATE INDEX idx_test_unit ON test_cycles(unit);

SET @sql := (
  SELECT IF(
    (SELECT COUNT(1) FROM information_schema.statistics
      WHERE table_schema = DATABASE()
        AND table_name = 'live_engine_input'
        AND index_name = 'idx_live_unit') > 0,
    'ALTER TABLE live_engine_input DROP INDEX idx_live_unit',
    'SELECT 1'
  )
);
PREPARE s3 FROM @sql; EXECUTE s3; DEALLOCATE PREPARE s3;
CREATE INDEX idx_live_unit ON live_engine_input(unit);
