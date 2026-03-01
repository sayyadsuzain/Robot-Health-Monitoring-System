# run_all.ps1
# Automate the setup and launch of the Robot Health Project

Write-Host "--- 🛠️ Starting Robot Health Project Setup ---" -ForegroundColor Cyan

# 1. Activate Virtual Environment
if (Test-Path ".venv\Scripts\Activate.ps1") {
    Write-Host "[1/3] Activating Virtual Environment..." -ForegroundColor Yellow
    & .venv\Scripts\Activate.ps1
} else {
    Write-Host "[!] .venv not found. Creating one now..." -ForegroundColor Red
    python -m venv .venv
    & .venv\Scripts\Activate.ps1
}

# 2. Install Dependencies
Write-Host "[2/3] Installing Dependencies (Streamlit, Pandas, MySQL)..." -ForegroundColor Yellow
pip install -r requirements.txt

# 3. Reminder for SQL Setup
Write-Host "`n[!] IMPORTANT: ENSURE YOUR SQL SCRIPT HAS RUN IN WORKBENCH FIRST!" -ForegroundColor Magenta
Write-Host "   Run 'setup_full_pipeline.sql' in MySQL Workbench to load the data." -ForegroundColor White

$confirm = Read-Host "`nHave you already run the SQL script? (y/n)"
if ($confirm -ne 'y') {
    Write-Host "`n[!] Please run the SQL script in Workbench, then run this script again." -ForegroundColor Red
    pause
    exit
}

# 4. Launch Dashboard
Write-Host "`n[3/3] Launching Dashboard..." -ForegroundColor Green
streamlit run dashboard.py
