# Presentation Script: Robot Health & RUL Prediction
**Speakers: Suzain Sayyad & Rihan Afaraj**

---

### Phase 1: The Foundation (SQL Setup)

**Suzain:** Good morning everyone! My name is Suzain Sayyad, and along with Rihan Afaraj, we are going to show you how to build a **Predictive Maintenance System** using only SQL and Python. 

**Rihan:** Suzain, show them where it all starts! 

**Suzain:** (Opening MySQL Workbench) It starts right here in our **`setup_full_pipeline.sql`** script. Watch as I run this... (Execute script). In just a few seconds, this script:
1.  Creates our **`cmaps`** database from scratch.
2.  Sets up tables for **160,000+ rows** of NASA sensor data.
3.  Calculates **Linear Regression models** directly inside SQL to predict engine failure.

**Rihan:** Wow! You mean the database is actually "learning" from the data?

**Suzain:** Exactly, Rihan. We aren't just storing data; we are using SQL math to predict the future. Look at the message at the bottom: **"SUCCESS! DATABASE COMPLETED."** This means our "SQL Brain" is ready.

---

### Phase 2: Installing & Launching the Dashboard

**Suzain:** Now that the database is ready, we need our application to connect to it. Rihan, look at my screen—some lines are red in the editor because we haven't installed our dependencies yet. We fix that with this single command:
```powershell
pip install -r requirements.txt
```
**(Wait for install)** Now, the red lines are gone, and we can launch the UI:
```powershell
streamlit run dashboard.py
```

**Suzain:** And there it is! Our **Robot Health Monitoring Dashboard**.

---

### Phase 3: Explaining the Dashboard

**Rihan:** (Pointing to the screen) This looks cool, but what are all these colors? 🟢 **Green**, 🟠 **Orange**, 🔴 **Red**?

**Suzain:** This represents the **Health Status** of our robots. 
*   🔴 **FAILED (0 RUL):** This engine has already reached its limit and must be replaced.
*   🟠 **FAIL SOON:** These engines are in the bottom 10% of health. They are critical!
*   🟢 **HEALTHY:** These engines are running perfectly.

**Rihan:** And what about this **"Estimated Cycles Left"** column?

**Suzain:** That is the **RUL (Remaining Useful Life)**. Our SQL AI predicts exactly how many more hours that engine can work. For example, Unit 1 has 2 cycles left—we need to fix it right now!

**Rihan:** And look at the **"Sensor Diagnostics"** section at the bottom. It says **"sensor_2 (Temperature)"** is the problem.

**Suzain:** Exactly. We don't just say an engine is failing; we tell the mechanic exactly which sensor is causing the trouble. Is it heat? Is it pressure? Or is it vibration? The dashboard tells you everything.

**Rihan:** So, by using this, we can stop a robot from breaking *before* it actually happens.

**Suzain:** That’s the power of **Predictive Maintenance**. We save time, we save money, and we keep the robots running safely. Thank you all for watching our demo!

---
**[End of Presentation]**
