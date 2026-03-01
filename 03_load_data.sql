-- 03_load_data.sql
-- Load historical training cycles into train_cycles from local CSV
-- NOTE: Ensure MySQL server permits LOCAL INFILE and update the path below.

USE cmaps;

-- Requires SUPER privilege; alternatively enable in my.ini as: local_infile=1
SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 'C:/Users/SAYYAD/Desktop/FD001_train.csv'
INTO TABLE train_cycles
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
  unit, cycle,
  setting_1, setting_2, setting_3,
  sensor_1, sensor_2, sensor_3, sensor_4, sensor_5,
  sensor_6, sensor_7, sensor_8, sensor_9, sensor_10,
  sensor_11, sensor_12, sensor_13, sensor_14, sensor_15,
  sensor_16, sensor_17, sensor_18, sensor_19, sensor_20,
  sensor_21, @rul
)
SET dataset_id = 1; -- ensure dataset_id is set for PK
