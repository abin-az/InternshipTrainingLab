# stop-omniroute-service.ps1
# Stops the OmniRoute background service and process

$nodeDir = "C:\Program Files\nodejs"
$npmDir = "C:\Users\abinu\AppData\Roaming\npm"
$env:Path = "$nodeDir;$npmDir;" + $env:Path

Write-Host "[INFO] Stopping OmniRoute service..." -ForegroundColor Yellow

# Try graceful stop via CLI
omniroute stop 2>$null

# Check port 20128 and terminate if still bound
$activeConns = Get-NetTCPConnection -LocalPort 20128 -ErrorAction SilentlyContinue
foreach ($conn in $activeConns) {
    if ($conn.OwningProcess -and $conn.OwningProcess -ne 0) {
        Write-Host "[INFO] Terminating PID $($conn.OwningProcess)..."
        Stop-Process -Id $conn.OwningProcess -Force -ErrorAction SilentlyContinue
    }
}

Write-Host "[SUCCESS] OmniRoute service stopped." -ForegroundColor Green
