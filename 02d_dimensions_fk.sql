-- 02d_dimensions_fk.sql
-- Add dataset & unit dimensions and enforce foreign keys (interconnect train/test/rul/live)

USE cmaps;

-- 1) Dimension tables
CREATE TABLE IF NOT EXISTS datasets (
  dataset_id TINYINT PRIMARY KEY
) ENGINE=InnoDB;

-- Ensure name column exists even if table pre-existed without it
SET @addcol := (
  SELECT IF(EXISTS(
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'datasets' AND column_name = 'name'
  ), 'SELECT 1', 'ALTER TABLE datasets ADD COLUMN name VARCHAR(28)')
);
PREPARE addc FROM @addcol; EXECUTE addc; DEALLOCATE PREPARE addc;

INSERT IGNORE INTO datasets(dataset_id)
VALUES (1),(2),(3),(4);

CREATE TABLE IF NOT EXISTS units (
  dataset_id TINYINT NOT NULL,
  unit INT NOT NULL,
  PRIMARY KEY(dataset_id, unit),
  CONSTRAINT fk_units_dataset FOREIGN KEY (dataset_id) REFERENCES datasets(dataset_id)
) ENGINE=InnoDB;

-- Populate units from current facts
INSERT IGNORE INTO units(dataset_id, unit)
SELECT dataset_id, unit FROM train_cycles GROUP BY dataset_id, unit
UNION
SELECT dataset_id, unit FROM test_cycles GROUP BY dataset_id, unit
UNION
SELECT dataset_id, unit FROM rul_truth GROUP BY dataset_id, unit
UNION
SELECT dataset_id, unit FROM live_engine_input GROUP BY dataset_id, unit;

-- 2) Drop existing FKs if present (idempotent)
-- helper: drop if exists using information_schema and prepared statements

-- train_cycles FKs
SET @sql = (
  SELECT IF(EXISTS(
    SELECT 1 FROM information_schema.table_constraints
    WHERE table_schema = DATABASE() AND table_name='train_cycles'
      AND constraint_type='FOREIGN KEY' AND constraint_name='fk_train_dataset'),
    'ALTER TABLE train_cycles DROP FOREIGN KEY fk_train_dataset', 'SELECT 1'));
PREPARE s FROM @sql; EXECUTE s; DEALLOCATE PREPARE s;

SET @sql = (
  SELECT IF(EXISTS(
    SELECT 1 FROM information_schema.table_constraints
    WHERE table_schema = DATABASE() AND table_name='train_cycles'
      AND constraint_type='FOREIGN KEY' AND constraint_name='fk_train_unit'),
    'ALTER TABLE train_cycles DROP FOREIGN KEY fk_train_unit', 'SELECT 1'));
PREPARE s FROM @sql; EXECUTE s; DEALLOCATE PREPARE s;

-- test_cycles FKs
SET @sql = (
  SELECT IF(EXISTS(
    SELECT 1 FROM information_schema.table_constraints
    WHERE table_schema = DATABASE() AND table_name='test_cycles'
      AND constraint_type='FOREIGN KEY' AND constraint_name='fk_test_dataset'),
    'ALTER TABLE test_cycles DROP FOREIGN KEY fk_test_dataset', 'SELECT 1'));
PREPARE s FROM @sql; EXECUTE s; DEALLOCATE PREPARE s;

SET @sql = (
  SELECT IF(EXISTS(
    SELECT 1 FROM information_schema.table_constraints
    WHERE table_schema = DATABASE() AND table_name='test_cycles'
      AND constraint_type='FOREIGN KEY' AND constraint_name='fk_test_unit'),
    'ALTER TABLE test_cycles DROP FOREIGN KEY fk_test_unit', 'SELECT 1'));
PREPARE s FROM @sql; EXECUTE s; DEALLOCATE PREPARE s;

-- rul_truth FKs
SET @sql = (
  SELECT IF(EXISTS(
    SELECT 1 FROM information_schema.table_constraints
    WHERE table_schema = DATABASE() AND table_name='rul_truth'
      AND constraint_type='FOREIGN KEY' AND constraint_name='fk_rul_dataset'),
    'ALTER TABLE rul_truth DROP FOREIGN KEY fk_rul_dataset', 'SELECT 1'));
PREPARE s FROM @sql; EXECUTE s; DEALLOCATE PREPARE s;

SET @sql = (
  SELECT IF(EXISTS(
    SELECT 1 FROM information_schema.table_constraints
    WHERE table_schema = DATABASE() AND table_name='rul_truth'
      AND constraint_type='FOREIGN KEY' AND constraint_name='fk_rul_unit'),
    'ALTER TABLE rul_truth DROP FOREIGN KEY fk_rul_unit', 'SELECT 1'));
PREPARE s FROM @sql; EXECUTE s; DEALLOCATE PREPARE s;

-- live_engine_input FKs
SET @sql = (
  SELECT IF(EXISTS(
    SELECT 1 FROM information_schema.table_constraints
    WHERE table_schema = DATABASE() AND table_name='live_engine_input'
      AND constraint_type='FOREIGN KEY' AND constraint_name='fk_live_dataset'),
    'ALTER TABLE live_engine_input DROP FOREIGN KEY fk_live_dataset', 'SELECT 1'));
PREPARE s FROM @sql; EXECUTE s; DEALLOCATE PREPARE s;

SET @sql = (
  SELECT IF(EXISTS(
    SELECT 1 FROM information_schema.table_constraints
    WHERE table_schema = DATABASE() AND table_name='live_engine_input'
      AND constraint_type='FOREIGN KEY' AND constraint_name='fk_live_unit'),
    'ALTER TABLE live_engine_input DROP FOREIGN KEY fk_live_unit', 'SELECT 1'));
PREPARE s FROM @sql; EXECUTE s; DEALLOCATE PREPARE s;

-- 3) Add foreign keys
ALTER TABLE train_cycles
  ADD CONSTRAINT fk_train_dataset FOREIGN KEY (dataset_id) REFERENCES datasets(dataset_id),
  ADD CONSTRAINT fk_train_unit    FOREIGN KEY (dataset_id, unit) REFERENCES units(dataset_id, unit);

ALTER TABLE test_cycles
  ADD CONSTRAINT fk_test_dataset FOREIGN KEY (dataset_id) REFERENCES datasets(dataset_id),
  ADD CONSTRAINT fk_test_unit    FOREIGN KEY (dataset_id, unit) REFERENCES units(dataset_id, unit);

ALTER TABLE rul_truth
  ADD CONSTRAINT fk_rul_dataset FOREIGN KEY (dataset_id) REFERENCES datasets(dataset_id),
  ADD CONSTRAINT fk_rul_unit    FOREIGN KEY (dataset_id, unit) REFERENCES units(dataset_id, unit);

ALTER TABLE live_engine_input
  ADD CONSTRAINT fk_live_dataset FOREIGN KEY (dataset_id) REFERENCES datasets(dataset_id),
  ADD CONSTRAINT fk_live_unit    FOREIGN KEY (dataset_id, unit) REFERENCES units(dataset_id, unit);
