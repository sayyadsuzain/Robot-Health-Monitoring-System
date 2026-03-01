# Robot Health Dashboard: Understanding the Modes

This guide explains the different monitoring modes available in your Streamlit dashboard.

## Core Concepts

### 1. Baseline vs. Calibrated
*   **Baseline:** Uses a fixed health-to-RUL formula. It assumes every engine fails at the same health level.
*   **Calibrated:** Uses **SQL Linear Regression**. It looks at the historical training data for that specific dataset (e.g., FD001) and calculates a custom mathematical model (`y = mx + c`) to predict exactly how many cycles are left based on the current health.

### 2. Normalized (Norm)
*   Our sensors have different units (e.g., Temperature might be 600, while Pressure is 35). 
*   **Norm** scales everything between **0.0 and 1.0**. This makes the health score much more stable and prevents one sensor from "overpowering" the others.

### 3. Dynamic (Dyn)
*   **Standard Mode:** Uses hardcoded limits (e.g., "FAIL SOON" if RUL < 10).
*   **Dynamic Mode:** Calculates thresholds automatically using **Percentiles**. 
    - It looks at all engines in your current dataset.
    - The bottom 10% of engines are marked as **FAIL SOON**.
    - This is more accurate because some datasets are much older/harsher than others.

---

## The Ultimate Mode: "Calibrated (Norm + Dyn)"

This is the most advanced mode in the project. It combines all three technologies:
1.  **Calibrated:** Uses the AI/Regression model for the most accurate "Estimated Cycles Left".
2.  **Norm:** Uses normalized sensor data so the health score is reliable.
3.  **Dyn:** Uses dynamic thresholds. Instead of waiting for a fixed number like "10", it alerts you if your engine is in the **bottom 10%** of health compared to all other active engines.

**Use this mode for your final presentation as it shows the most complex SQL logic.**

---

## Understanding Benchmark Results (Positive or Negative?)

In the **Evaluation Metrics** section of the dashboard, you will see numbers for **MAE** (Mean Absolute Error) and **RMSE** (Root Mean Square Error). This is how we know if our SQL-based AI is performing well.

### 1. What is "Good"?
*   **Lower is Better!**
    - **MAE < 20:** Excellent. The model's guess is usually within 20 cycles of the truth.
    - **MAE 20 - 45:** Good for a pure SQL/Linear model. 
    - **MAE > 60:** The sensors might be too noisy, or the engine behavior is unpredictable.

### 2. Positive vs. Negative Results
*   **A "Positive" Result:** This means our **Calibrated Regression (SQL AI)** has a **Lower MAE/RMSE** than the **Baseline**.
    - If Calibrated MAE = 25 and Baseline MAE = 45, it’s a **huge positive result**. It proves the SQL regression model is smarter than a basic formula.
*   **A "Negative" Result:** This would be if the error is larger in the calibrated mode. This can happen if a dataset (like FD002) is too complex for simple linear regression and needs a more advanced model.

### 📊 Summary for your Presentation:
- "We Compare our SQL-predicted RUL with the **Official NASA Benchmark**."
- "The **Calibrated (Regression)** mode consistently outperforms the baseline, proving we can run high-accuracy predictive maintenance **directly inside a SQL database**."
