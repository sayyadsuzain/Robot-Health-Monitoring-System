# MASTER RUN GUIDE: Engine Health & RUL Project

Follow these exact steps to set up the database, fix any connection errors, and launch the monitoring dashboard.

## Prerequisites
- **MySQL Server** installed and running.
- **Python 3.9+** installed.
- **CMAPSS Data**: Ensure the folder `E:\DBMS-2\CMAPSSData` contains the `.txt` files (train_FD001.txt, etc.).

---

## Step 1: Database Setup (SQL)

1.  **Open MySQL Workbench**.
2.  **Fix Access Error (2068)** before running:
    -   On the Workbench home screen, **Right-click** your connection and select **Edit Connection**.
    -   Go to the **Advanced** tab.
    -   In the **Others** box at the bottom, type: `OPT_LOCAL_INFILE=1`
    -   Click **Test Connection** then **Close**.
    -   **Re-open** the connection.
3.  **Open the file**: `e:\DBMS-2\dbms_robot_project\setup_full_pipeline.sql`.
4.  **Run the script**: Click the **Execute (Lightning Bolt icon)** or press `Ctrl+Shift+Enter`.
    -   It will create the `cmaps` database, tables, and load the dataset.
5.  **Verify**: Look at the bottom "Action Output" tab. You should see a green checkmark and **"SUCCESS! DATABASE COMPLETED."** message.

---

## Step 2: Python Environment Setup

1.  **Open a terminal** (Command Prompt or PowerShell) inside VS Code.
2.  **Navigate to the project directory**:
    ```powershell
    cd "e:\DBMS-2\dbms_robot_project"
    ```
3.  **Activate Environment & Update Dependencies**:
    ```powershell
    .\.venv\Scripts\python.exe -m pip install -r requirements.txt
    ```

---

## Step 3: Launch the Dashboard

1.  **Set your MySQL Password** (Replace `your_actual_password` with your real MySQL password):
    ```powershell
    $env:MYSQL_PASSWORD="your_actual_password"
    ```
2.  **Run Streamlit**:
    ```powershell
    .\.venv\Scripts\python.exe -m streamlit run dashboard.py
    ```
3.  **Access the Dashboard**: Streamlit will provide a URL (usually `http://localhost:8501`). Open this in your browser.

---

## Step 4: Verification in Dashboard

1.  **Check Connection**: In the sidebar, enter your MySQL Host, User, and Database (`cmaps`).
2.  **View Data**: Click **"Refresh Data"**. You should see the **Engine Status Table** populated with data.
3.  **Test RUL**: Expand the **Evaluation Metrics** section to see how accurate the SQL model is (MAE/RMSE).
4.  **Add Live Data**: Use the **Add Live Reading** form to insert a new test cycle and watch the dashboard update instantly.
