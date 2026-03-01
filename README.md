# 🤖 Robot Health Monitoring & RUL Prediction System

![Status](https://img.shields.io/badge/Status-Complete-success)
![Database](https://img.shields.io/badge/Database-MySQL-blue)
![Python](https://img.shields.io/badge/Python-3.9+-yellow)
![Framework](https://img.shields.io/badge/Framework-Streamlit-red)

A powerful predictive maintenance pipeline that predicts the **Remaining Useful Life (RUL)** of robot engines using SQL-based analytics and real-time dashboarding.

---

## 🚀 Key Features

*   **🧠 SQL-Powered AI:** Implemented Linear Regression directly in MySQL for high-performance RUL prediction.
*   **📡 Real-Time Dashboard:** Interactive Streamlit UI with live status updates and critical alerts.
*   **📊 Smart Analytics:**
    *   **Normalization:** Scaled sensor data (Temp, Pressure, Vibration) for stable health scoring.
    *   **Dynamic Thresholds:** Automatic "FAIL SOON" alerts using SQL Percentiles.
*   **🛠️ Deep Diagnostics:** Identifies exactly which sensor (e.g., Vibration) is causing engine decline.
*   **📈 Proven Accuracy:** Verified against the **NASA CMAPSS Dataset** (160,000+ data points).

---

## 🎨 Dashboard Preview

> [!TIP]
> **Green (HEALTHY)** engines are running smoothly.
> **Orange (FAIL SOON)** engines are in the bottom 10% of health.
> **Red (FAILED)** engines have reached their limit (0 RUL).

---

## 🛠️ Tech Stack

- **Backend:** MySQL (SQL-based analytics & data storage)
- **Frontend:** Streamlit (Python-based dashboard)
- **Data:** Pandas (Data processing)
- **Logic:** Linear Regression & Percentile Analysis

---

## 📖 Quick Start

1.  **Database:** Run `setup_full_pipeline.sql` in MySQL Workbench to initialize the 160k+ row dataset.
2.  **Environment:** 
    ```powershell
    pip install -r requirements.txt
    ```
3.  **Launch:**
    ```powershell
    set MYSQL_PASSWORD=your_password
    streamlit run dashboard.py
    ```

For full details, see the **[MASTER_RUN_GUIDE.md](MASTER_RUN_GUIDE.md)**.

---

## 👥 Authors
- **Suzain Sayyad** - Lead Developer & SQL Architect
- **Rihan Afaraj** - Dashboard & Presentation Specialist

---

*Developed for the DBMS Robot Health Prediction Project.*
