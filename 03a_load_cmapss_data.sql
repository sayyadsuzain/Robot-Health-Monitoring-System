-- 03a_load_cmapss_data.sql
-- Load CMAPSS train/test/RUL text files directly into MySQL tables.
-- Note: Files are whitespace-delimited; this script maps 26 columns accordingly.

USE cmaps;

SET GLOBAL local_infile = 1;

-- Temporary stage table for RUL files
CREATE TABLE IF NOT EXISTS rul_stage (
  id INT NOT NULL AUTO_INCREMENT,
  rul INT,
  PRIMARY KEY (id)
) ENGINE=InnoDB;

-- =====================
-- TRAIN SETS (FD001-4)
-- =====================
-- Common column mapping: 26 whitespace-separated columns
-- unit, cycle, setting_1..3, sensor_1..21

-- FD001 => dataset_id=1
LOAD DATA LOCAL INFILE 'e:/DBMS-2/CMAPSSData/train_FD001.txt'
INTO TABLE train_cycles
FIELDS TERMINATED BY ' '
LINES TERMINATED BY '\n'
(@c1,@c2,@c3,@c4,@c5,@c6,@c7,@c8,@c9,@c10,@c11,@c12,@c13,@c14,@c15,@c16,@c17,@c18,@c19,@c20,@c21,@c22,@c23,@c24,@c25,@c26)
SET dataset_id=1,
  unit=NULLIF(@c1,''), cycle=NULLIF(@c2,''),
  setting_1=NULLIF(@c3,''), setting_2=NULLIF(@c4,''), setting_3=NULLIF(@c5,''),
  sensor_1=NULLIF(@c6,''), sensor_2=NULLIF(@c7,''), sensor_3=NULLIF(@c8,''), sensor_4=NULLIF(@c9,''), sensor_5=NULLIF(@c10,''),
  sensor_6=NULLIF(@c11,''), sensor_7=NULLIF(@c12,''), sensor_8=NULLIF(@c13,''), sensor_9=NULLIF(@c14,''), sensor_10=NULLIF(@c15,''),
  sensor_11=NULLIF(@c16,''), sensor_12=NULLIF(@c17,''), sensor_13=NULLIF(@c18,''), sensor_14=NULLIF(@c19,''), sensor_15=NULLIF(@c20,''),
  sensor_16=NULLIF(@c21,''), sensor_17=NULLIF(@c22,''), sensor_18=NULLIF(@c23,''), sensor_19=NULLIF(@c24,''), sensor_20=NULLIF(@c25,''),
  sensor_21=NULLIF(@c26,'');

-- FD002 => dataset_id=2
LOAD DATA LOCAL INFILE 'e:/DBMS-2/CMAPSSData/train_FD002.txt'
INTO TABLE train_cycles
FIELDS TERMINATED BY ' '
LINES TERMINATED BY '\n'
(@c1,@c2,@c3,@c4,@c5,@c6,@c7,@c8,@c9,@c10,@c11,@c12,@c13,@c14,@c15,@c16,@c17,@c18,@c19,@c20,@c21,@c22,@c23,@c24,@c25,@c26)
SET dataset_id=2,
  unit=NULLIF(@c1,''), cycle=NULLIF(@c2,''),
  setting_1=NULLIF(@c3,''), setting_2=NULLIF(@c4,''), setting_3=NULLIF(@c5,''),
  sensor_1=NULLIF(@c6,''), sensor_2=NULLIF(@c7,''), sensor_3=NULLIF(@c8,''), sensor_4=NULLIF(@c9,''), sensor_5=NULLIF(@c10,''),
  sensor_6=NULLIF(@c11,''), sensor_7=NULLIF(@c12,''), sensor_8=NULLIF(@c13,''), sensor_9=NULLIF(@c14,''), sensor_10=NULLIF(@c15,''),
  sensor_11=NULLIF(@c16,''), sensor_12=NULLIF(@c17,''), sensor_13=NULLIF(@c18,''), sensor_14=NULLIF(@c19,''), sensor_15=NULLIF(@c20,''),
  sensor_16=NULLIF(@c21,''), sensor_17=NULLIF(@c22,''), sensor_18=NULLIF(@c23,''), sensor_19=NULLIF(@c24,''), sensor_20=NULLIF(@c25,''),
  sensor_21=NULLIF(@c26,'');

-- FD003 => dataset_id=3
LOAD DATA LOCAL INFILE 'e:/DBMS-2/CMAPSSData/train_FD003.txt'
INTO TABLE train_cycles
FIELDS TERMINATED BY ' '
LINES TERMINATED BY '\n'
(@c1,@c2,@c3,@c4,@c5,@c6,@c7,@c8,@c9,@c10,@c11,@c12,@c13,@c14,@c15,@c16,@c17,@c18,@c19,@c20,@c21,@c22,@c23,@c24,@c25,@c26)
SET dataset_id=3,
  unit=NULLIF(@c1,''), cycle=NULLIF(@c2,''),
  setting_1=NULLIF(@c3,''), setting_2=NULLIF(@c4,''), setting_3=NULLIF(@c5,''),
  sensor_1=NULLIF(@c6,''), sensor_2=NULLIF(@c7,''), sensor_3=NULLIF(@c8,''), sensor_4=NULLIF(@c9,''), sensor_5=NULLIF(@c10,''),
  sensor_6=NULLIF(@c11,''), sensor_7=NULLIF(@c12,''), sensor_8=NULLIF(@c13,''), sensor_9=NULLIF(@c14,''), sensor_10=NULLIF(@c15,''),
  sensor_11=NULLIF(@c16,''), sensor_12=NULLIF(@c17,''), sensor_13=NULLIF(@c18,''), sensor_14=NULLIF(@c19,''), sensor_15=NULLIF(@c20,''),
  sensor_16=NULLIF(@c21,''), sensor_17=NULLIF(@c22,''), sensor_18=NULLIF(@c23,''), sensor_19=NULLIF(@c24,''), sensor_20=NULLIF(@c25,''),
  sensor_21=NULLIF(@c26,'');

-- FD004 => dataset_id=4
LOAD DATA LOCAL INFILE 'e:/DBMS-2/CMAPSSData/train_FD004.txt'
INTO TABLE train_cycles
FIELDS TERMINATED BY ' '
LINES TERMINATED BY '\n'
(@c1,@c2,@c3,@c4,@c5,@c6,@c7,@c8,@c9,@c10,@c11,@c12,@c13,@c14,@c15,@c16,@c17,@c18,@c19,@c20,@c21,@c22,@c23,@c24,@c25,@c26)
SET dataset_id=4,
  unit=NULLIF(@c1,''), cycle=NULLIF(@c2,''),
  setting_1=NULLIF(@c3,''), setting_2=NULLIF(@c4,''), setting_3=NULLIF(@c5,''),
  sensor_1=NULLIF(@c6,''), sensor_2=NULLIF(@c7,''), sensor_3=NULLIF(@c8,''), sensor_4=NULLIF(@c9,''), sensor_5=NULLIF(@c10,''),
  sensor_6=NULLIF(@c11,''), sensor_7=NULLIF(@c12,''), sensor_8=NULLIF(@c13,''), sensor_9=NULLIF(@c14,''), sensor_10=NULLIF(@c15,''),
  sensor_11=NULLIF(@c16,''), sensor_12=NULLIF(@c17,''), sensor_13=NULLIF(@c18,''), sensor_14=NULLIF(@c19,''), sensor_15=NULLIF(@c20,''),
  sensor_16=NULLIF(@c21,''), sensor_17=NULLIF(@c22,''), sensor_18=NULLIF(@c23,''), sensor_19=NULLIF(@c24,''), sensor_20=NULLIF(@c25,''),
  sensor_21=NULLIF(@c26,'');

-- =====================
-- TEST SETS (FD001-4)
-- =====================
LOAD DATA LOCAL INFILE 'e:/DBMS-2/CMAPSSData/test_FD001.txt'
INTO TABLE test_cycles
FIELDS TERMINATED BY ' '
LINES TERMINATED BY '\n'
(@c1,@c2,@c3,@c4,@c5,@c6,@c7,@c8,@c9,@c10,@c11,@c12,@c13,@c14,@c15,@c16,@c17,@c18,@c19,@c20,@c21,@c22,@c23,@c24,@c25,@c26)
SET dataset_id=1,
  unit=NULLIF(@c1,''), cycle=NULLIF(@c2,''),
  setting_1=NULLIF(@c3,''), setting_2=NULLIF(@c4,''), setting_3=NULLIF(@c5,''),
  sensor_1=NULLIF(@c6,''), sensor_2=NULLIF(@c7,''), sensor_3=NULLIF(@c8,''), sensor_4=NULLIF(@c9,''), sensor_5=NULLIF(@c10,''),
  sensor_6=NULLIF(@c11,''), sensor_7=NULLIF(@c12,''), sensor_8=NULLIF(@c13,''), sensor_9=NULLIF(@c14,''), sensor_10=NULLIF(@c15,''),
  sensor_11=NULLIF(@c16,''), sensor_12=NULLIF(@c17,''), sensor_13=NULLIF(@c18,''), sensor_14=NULLIF(@c19,''), sensor_15=NULLIF(@c20,''),
  sensor_16=NULLIF(@c21,''), sensor_17=NULLIF(@c22,''), sensor_18=NULLIF(@c23,''), sensor_19=NULLIF(@c24,''), sensor_20=NULLIF(@c25,''),
  sensor_21=NULLIF(@c26,'');

LOAD DATA LOCAL INFILE 'e:/DBMS-2/CMAPSSData/test_FD002.txt'
INTO TABLE test_cycles
FIELDS TERMINATED BY ' '
LINES TERMINATED BY '\n'
(@c1,@c2,@c3,@c4,@c5,@c6,@c7,@c8,@c9,@c10,@c11,@c12,@c13,@c14,@c15,@c16,@c17,@c18,@c19,@c20,@c21,@c22,@c23,@c24,@c25,@c26)
SET dataset_id=2,
  unit=NULLIF(@c1,''), cycle=NULLIF(@c2,''),
  setting_1=NULLIF(@c3,''), setting_2=NULLIF(@c4,''), setting_3=NULLIF(@c5,''),
  sensor_1=NULLIF(@c6,''), sensor_2=NULLIF(@c7,''), sensor_3=NULLIF(@c8,''), sensor_4=NULLIF(@c9,''), sensor_5=NULLIF(@c10,''),
  sensor_6=NULLIF(@c11,''), sensor_7=NULLIF(@c12,''), sensor_8=NULLIF(@c13,''), sensor_9=NULLIF(@c14,''), sensor_10=NULLIF(@c15,''),
  sensor_11=NULLIF(@c16,''), sensor_12=NULLIF(@c17,''), sensor_13=NULLIF(@c18,''), sensor_14=NULLIF(@c19,''), sensor_15=NULLIF(@c20,''),
  sensor_16=NULLIF(@c21,''), sensor_17=NULLIF(@c22,''), sensor_18=NULLIF(@c23,''), sensor_19=NULLIF(@c24,''), sensor_20=NULLIF(@c25,''),
  sensor_21=NULLIF(@c26,'');

LOAD DATA LOCAL INFILE 'e:/DBMS-2/CMAPSSData/test_FD003.txt'
INTO TABLE test_cycles
FIELDS TERMINATED BY ' '
LINES TERMINATED BY '\n'
(@c1,@c2,@c3,@c4,@c5,@c6,@c7,@c8,@c9,@c10,@c11,@c12,@c13,@c14,@c15,@c16,@c17,@c18,@c19,@c20,@c21,@c22,@c23,@c24,@c25,@c26)
SET dataset_id=3,
  unit=NULLIF(@c1,''), cycle=NULLIF(@c2,''),
  setting_1=NULLIF(@c3,''), setting_2=NULLIF(@c4,''), setting_3=NULLIF(@c5,''),
  sensor_1=NULLIF(@c6,''), sensor_2=NULLIF(@c7,''), sensor_3=NULLIF(@c8,''), sensor_4=NULLIF(@c9,''), sensor_5=NULLIF(@c10,''),
  sensor_6=NULLIF(@c11,''), sensor_7=NULLIF(@c12,''), sensor_8=NULLIF(@c13,''), sensor_9=NULLIF(@c14,''), sensor_10=NULLIF(@c15,''),
  sensor_11=NULLIF(@c16,''), sensor_12=NULLIF(@c17,''), sensor_13=NULLIF(@c18,''), sensor_14=NULLIF(@c19,''), sensor_15=NULLIF(@c20,''),
  sensor_16=NULLIF(@c21,''), sensor_17=NULLIF(@c22,''), sensor_18=NULLIF(@c23,''), sensor_19=NULLIF(@c24,''), sensor_20=NULLIF(@c25,''),
  sensor_21=NULLIF(@c26,'');

LOAD DATA LOCAL INFILE 'e:/DBMS-2/CMAPSSData/test_FD004.txt'
INTO TABLE test_cycles
FIELDS TERMINATED BY ' '
LINES TERMINATED BY '\n'
(@c1,@c2,@c3,@c4,@c5,@c6,@c7,@c8,@c9,@c10,@c11,@c12,@c13,@c14,@c15,@c16,@c17,@c18,@c19,@c20,@c21,@c22,@c23,@c24,@c25,@c26)
SET dataset_id=4,
  unit=NULLIF(@c1,''), cycle=NULLIF(@c2,''),
  setting_1=NULLIF(@c3,''), setting_2=NULLIF(@c4,''), setting_3=NULLIF(@c5,''),
  sensor_1=NULLIF(@c6,''), sensor_2=NULLIF(@c7,''), sensor_3=NULLIF(@c8,''), sensor_4=NULLIF(@c9,''), sensor_5=NULLIF(@c10,''),
  sensor_6=NULLIF(@c11,''), sensor_7=NULLIF(@c12,''), sensor_8=NULLIF(@c13,''), sensor_9=NULLIF(@c14,''), sensor_10=NULLIF(@c15,''),
  sensor_11=NULLIF(@c16,''), sensor_12=NULLIF(@c17,''), sensor_13=NULLIF(@c18,''), sensor_14=NULLIF(@c19,''), sensor_15=NULLIF(@c20,''),
  sensor_16=NULLIF(@c21,''), sensor_17=NULLIF(@c22,''), sensor_18=NULLIF(@c23,''), sensor_19=NULLIF(@c24,''), sensor_20=NULLIF(@c25,''),
  sensor_21=NULLIF(@c26,'');

-- =====================
-- RUL TRUTH (FD001-4)
-- =====================
TRUNCATE rul_stage;
LOAD DATA LOCAL INFILE 'e:/DBMS-2/CMAPSSData/RUL_FD001.txt' INTO TABLE rul_stage FIELDS TERMINATED BY ' ' LINES TERMINATED BY '\n' (@rul) SET rul = NULLIF(@rul,'');
INSERT IGNORE INTO rul_truth (dataset_id, unit, rul) SELECT 1 AS dataset_id, id AS unit, rul FROM rul_stage;

TRUNCATE rul_stage;
LOAD DATA LOCAL INFILE 'e:/DBMS-2/CMAPSSData/RUL_FD002.txt' INTO TABLE rul_stage FIELDS TERMINATED BY ' ' LINES TERMINATED BY '\n' (@rul) SET rul = NULLIF(@rul,'');
INSERT IGNORE INTO rul_truth (dataset_id, unit, rul) SELECT 2, id, rul FROM rul_stage;

TRUNCATE rul_stage;
LOAD DATA LOCAL INFILE 'e:/DBMS-2/CMAPSSData/RUL_FD003.txt' INTO TABLE rul_stage FIELDS TERMINATED BY ' ' LINES TERMINATED BY '\n' (@rul) SET rul = NULLIF(@rul,'');
INSERT IGNORE INTO rul_truth (dataset_id, unit, rul) SELECT 3, id, rul FROM rul_stage;

TRUNCATE rul_stage;
LOAD DATA LOCAL INFILE 'e:/DBMS-2/CMAPSSData/RUL_FD004.txt' INTO TABLE rul_stage FIELDS TERMINATED BY ' ' LINES TERMINATED BY '\n' (@rul) SET rul = NULLIF(@rul,'');
INSERT IGNORE INTO rul_truth (dataset_id, unit, rul) SELECT 4, id, rul FROM rul_stage;

-- Done.
