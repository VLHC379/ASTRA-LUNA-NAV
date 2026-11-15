# One-command launcher for LUNA NAV (Windows PowerShell).
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

$py = Join-Path $PSScriptRoot ".venv\Scripts\python.exe"
if (-not (Test-Path $py)) {
  Write-Host "Creating virtual environment ..." -ForegroundColor Cyan
  $made = $false
  try { & py -3.12 -m venv .venv; if (Test-Path $py) { $made = $true } } catch {}
  if (-not $made) {
    try { & python -m venv .venv; if (Test-Path $py) { $made = $true } } catch {}
  }
  if (-not $made) { throw "Python 3.10+ was not found. Install it from python.org and run this again." }
  & $py -m pip install --quiet --upgrade pip
  & $py -m pip install --quiet -r requirements.txt
}

if (-not (Test-Path (Join-Path $PSScriptRoot "data\cache\catalog.json"))) {
  Write-Host "No cache found; fetching data and building (several minutes) ..." -ForegroundColor Yellow
  & $py scripts\fetch_data.py
  & $py -m lunanav.build --all
}

Write-Host ""
Write-Host "  LUNA NAV  -  starting server ..." -ForegroundColor Cyan
$server = Start-Process -FilePath $py -ArgumentList @("-m", "uvicorn", "lunanav.api:app", "--host", "127.0.0.1", "--port", "8010") -PassThru -NoNewWindow -WorkingDirectory $PSScriptRoot
$ready = $false
for ($i = 0; $i -lt 80; $i++) {
  try {
    $r = Invoke-WebRequest "http://127.0.0.1:8010/api/health" -UseBasicParsing -TimeoutSec 2
    if ($r.StatusCode -eq 200) { $ready = $true; break }
  } catch {}
  Start-Sleep -Milliseconds 500
}
if ($ready) {
  Write-Host "  API ready  -  http://127.0.0.1:8010" -ForegroundColor Green
  Start-Process "http://127.0.0.1:8010"
} else {
  Write-Host "  Server did not answer on port 8010. Check the messages above." -ForegroundColor Red
}
Write-Host "  Keep this window open. Press Ctrl+C to stop." -ForegroundColor DarkGray
Wait-Process -Id $server.Id
