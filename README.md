# DBMS Robot / Engine Health Prediction System

This project demonstrates a SQL-centric pipeline where MySQL performs health scoring, prediction, and status classification from robot/engine sensor data.

## Project Structure

```
dbms_robot_project/
├── 01_create_database.sql
├── 02_create_tables.sql
├── 03_load_data.sql
├── 04_views_health.sql
├── 05_predictions.sql
├── 06_live_input.sql
├── 07_demo_queries.sql
├── dashboard.py
└── requirements.txt
```

## Prerequisites
- MySQL Server 8+
- Python 3.9+
- CSV dataset (e.g., `FD001_train.csv`)

## Setup Steps
1. Open MySQL client (Workbench or CLI) and run scripts in order:
   - `01_create_database.sql`
   - `02_create_tables.sql`
   - Update path in `03_load_data.sql` then run it to load CSV
   - `04_views_health.sql`
   - `05_predictions.sql`
   - (Optional) `06_live_input.sql`
   - `07_demo_queries.sql`

2. CSV load notes (Windows):
   - Ensure server allows LOCAL INFILE: `SET GLOBAL local_infile = 1;`
   - Update the file path inside `03_load_data.sql`.
   - `train_cycles.dataset_id` defaults to 1 and is set during load for PK integrity.

3. Run the dashboard:
   ```bash
   pip install -r requirements.txt
   setx MYSQL_PASSWORD your_password
   streamlit run dashboard.py
   ```
   Or set env variables at runtime:
   ```bash
   set MYSQL_HOST=localhost
   set MYSQL_USER=root
   set MYSQL_PASSWORD=your_password
   set MYSQL_DB=cmaps
   streamlit run dashboard.py
   ```

## Live Data Simulation
Insert a new sensor reading:
```sql
INSERT INTO live_engine_input VALUES (1, 999, 1, 78.0, 35.0, 20.0);
```
Compute its health quickly:
```sql
SELECT unit, cycle,
  ROUND(100 - (sensor_2*0.5) - (sensor_4*0.3) - (sensor_11*0.2), 2) AS health_score
FROM live_engine_input
WHERE unit = 999;
```

## Notes
- Views:
  - `v_engine_health` computes health from selected sensors.
  - `v_engine_prediction` aggregates health and provides `estimated_cycles_left`.
  - `v_engine_status` classifies into `HEALTHY`, `WARNING`, `FAIL SOON`.
- Adjust formulas and thresholds as needed for your dataset or domain.
