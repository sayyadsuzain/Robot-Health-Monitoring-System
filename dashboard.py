# dashboard.py
# Streamlit dashboard for Robot/Engine Health Monitoring

import os
import pandas as pd
import streamlit as st
import mysql.connector

st.set_page_config(page_title="Robot Health Monitoring", layout="wide")

st.title("Robot Health Monitoring Dashboard")

# Connection config
DB_HOST = os.getenv("MYSQL_HOST", "localhost")
DB_USER = os.getenv("MYSQL_USER", "root")
DB_PASS = os.getenv("MYSQL_PASSWORD", "your_password")
DB_NAME = os.getenv("MYSQL_DB", "cmaps")

with st.sidebar:
    st.header("Database Connection")
    host = st.text_input("Host", DB_HOST)
    user = st.text_input("User", DB_USER)
    password = st.text_input("Password", DB_PASS, type="password")
    database = st.text_input("Database", DB_NAME)
    mode = st.selectbox(
        "Mode",
        [
            "Calibrated (Norm)",
            "Baseline (Norm)",
            "Calibrated (Norm + Dyn)",
            "Calibrated",
            "Baseline",
            "Live (Norm)",
            "Live (Norm + Dyn)",
            "Live",
        ],
        index=0,
    )
    refresh = st.button("Refresh Data")

def _connect(_host, _user, _password, _database):
    return mysql.connector.connect(
        host=_host,
        user=_user,
        password=_password,
        database=_database,
        allow_local_infile=True,
    )

def insert_live_row(_host, _user, _password, _database,
                    dataset_id: int, unit: int, cycle: int,
                    s2: float, s4: float, s11: float) -> bool:
    """Insert a live reading into live_engine_input. Returns True on success."""
    try:
        conn = _connect(_host, _user, _password, _database)
        cur = conn.cursor()
        cur.execute(
            """
            INSERT INTO live_engine_input
            (dataset_id, unit, cycle, sensor_2, sensor_4, sensor_11)
            VALUES (%s, %s, %s, %s, %s, %s)
            """,
            (dataset_id, unit, cycle, s2, s4, s11),
        )
        conn.commit()
        cur.close()
        conn.close()
        return True
    except Exception:
        return False

@st.cache_data(ttl=30)
def load_status(_host, _user, _password, _database, view_name: str):
    conn = mysql.connector.connect(
        host=_host,
        user=_user,
        password=_password,
        database=_database,
        allow_local_infile=True,
    )
    try:
        # Guard against SQL injection by whitelisting view names
        allowed = {
            "v_engine_status",
            "v_engine_status_calibrated",
            "v_engine_status_norm",
            "v_engine_status_calibrated_norm",
            "v_engine_status_calibrated_norm_dyn",
            "v_live_status",
            "v_live_status_norm",
            "v_live_status_norm_dyn",
        }
        if view_name not in allowed:
            view_name = "v_engine_status"
        df = pd.read_sql(f"SELECT * FROM {view_name}", conn)
    finally:
        conn.close()
    return df

if refresh:
    load_status.clear()

try:
    # Select backing view from the chosen mode
    view_map = {
        "Baseline": "v_engine_status",
        "Calibrated": "v_engine_status_calibrated",
        "Baseline (Norm)": "v_engine_status_norm",
        "Calibrated (Norm)": "v_engine_status_calibrated_norm",
        "Calibrated (Norm + Dyn)": "v_engine_status_calibrated_norm_dyn",
        "Live": "v_live_status",
        "Live (Norm)": "v_live_status_norm",
        "Live (Norm + Dyn)": "v_live_status_norm_dyn",
    }
    view_name = view_map.get(mode, "v_engine_status")
    df = load_status(host, user, password, database, view_name)
    if df.empty:
        st.info("No data available. Ensure the selected view has rows and required views are created.")
    else:
        # Summary Metrics
        m1, m2, m3, m4 = st.columns(4)
        total = len(df)
        failed = len(df[df["status"] == "FAILED"])
        critical = len(df[df["status"] == "FAIL SOON"])
        healthy = len(df[df["status"] == "HEALTHY"])
        
        m1.metric("Total Engines", total)
        m2.metric("Failed (0 RUL)", failed, delta=-failed if failed > 0 else 0, delta_color="inverse")
        m3.metric("Critical", critical, delta=-critical if critical > 0 else 0, delta_color="inverse")
        m4.metric("Healthy", healthy)

        def color_status(val):
            color = "#2ecc71" # healthy green
            if val == "FAILED": color = "#e74c3c" # red
            elif val == "FAIL SOON": color = "#e67e22" # orange
            elif val == "WARNING": color = "#f1c40f" # yellow
            return f'background-color: {color}'

        left, right = st.columns([3, 2])
        with left:
            st.subheader(f"All Engines ({mode})")
            st.dataframe(df.style.applymap(color_status, subset=['status']), use_container_width=True)

        with right:
            st.subheader("Action Required (FAILED / FAIL SOON)")
            needed = df[df["status"].isin(["FAILED", "FAIL SOON"])]
            if needed.empty:
                st.success("All systems operational!")
            else:
                st.dataframe(needed.style.applymap(color_status, subset=['status']), use_container_width=True)

        st.subheader("Remaining Useful Life (RUL) Forecast")
        st.bar_chart(df.set_index("unit")["estimated_cycles_left"])

        # Diagnostics (which sensor to check/replace) based on normalized penalties
        with st.expander("Sensor Diagnostics (which sensor to check)"):
            diag_view = "v_engine_diagnostics_norm"
            if "Live" in mode:
                diag_view = "v_live_diagnostics_norm"
            try:
                conn = _connect(host, user, password, database)
                try:
                    diag = pd.read_sql(f"SELECT * FROM {diag_view}", conn)
                except Exception:
                    diag = pd.DataFrame()
            except Exception:
                diag = pd.DataFrame()
            finally:
                try:
                    conn.close()
                except Exception:
                    pass

            if diag.empty:
                st.write("No diagnostics available yet.")
            else:
                show_cols = [
                    "dataset_id","unit","last_cycle","last_health",
                    "penalty_temp","penalty_pressure","penalty_vibration","sensor_to_check"
                ]
                existing = [c for c in show_cols if c in diag.columns]
                st.dataframe(diag[existing].sort_values(["dataset_id","unit"]).reset_index(drop=True), use_container_width=True)

        # Evaluation metrics (if present)
        with st.expander("Evaluation Metrics (CMAPSS test)"):
            conn = None
            try:
                conn = _connect(host, user, password, database)
                try:
                    baseline = pd.read_sql("SELECT * FROM v_eval_metrics ORDER BY dataset_id", conn)
                except Exception:
                    baseline = pd.DataFrame()
                try:
                    calibrated = pd.read_sql("SELECT * FROM v_eval_metrics_cal ORDER BY dataset_id", conn)
                except Exception:
                    calibrated = pd.DataFrame()
            except Exception:
                baseline = pd.DataFrame()
                calibrated = pd.DataFrame()
            finally:
                if conn is not None:
                    conn.close()

            cols = st.columns(2)
            with cols[0]:
                st.markdown("**Baseline (SQL formula)**")
                if baseline.empty:
                    st.write("No metrics.")
                else:
                    st.dataframe(baseline, use_container_width=True)
            with cols[1]:
                st.markdown("**Calibrated (SQL regression)**")
                if calibrated.empty:
                    st.write("No metrics.")
                else:
                    st.dataframe(calibrated, use_container_width=True)

        # Live input form
        with st.expander("Add Live Reading"):
            with st.form("live_form"):
                c1, c2, c3 = st.columns(3)
                with c1:
                    f_dataset = st.number_input("Dataset ID", min_value=1, max_value=4, value=1, step=1)
                    f_unit = st.number_input("Unit", min_value=1, value=999, step=1)
                with c2:
                    f_cycle = st.number_input("Cycle", min_value=1, value=1, step=1)
                    f_s2 = st.number_input("sensor_2 (Temp)", value=75.0)
                with c3:
                    f_s4 = st.number_input("sensor_4 (Pressure)", value=35.0)
                    f_s11 = st.number_input("sensor_11 (Vibration)", value=20.0)
                submitted = st.form_submit_button("Insert")
            if submitted:
                ok = insert_live_row(host, user, password, database,
                                     int(f_dataset), int(f_unit), int(f_cycle),
                                     float(f_s2), float(f_s4), float(f_s11))
                if ok:
                    st.success("Inserted live reading. Click 'Refresh Data' to update the tables.")
                else:
                    st.error("Failed to insert live reading. Check connection and constraints.")
except mysql.connector.Error as e:
    st.error(f"Database error: {e}")
    st.stop()
