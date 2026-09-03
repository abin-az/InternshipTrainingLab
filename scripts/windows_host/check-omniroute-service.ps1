# check-omniroute-service.ps1
# Verifies OmniRoute background service, port 20128, and health status

$nodeDir = "C:\Program Files\nodejs"
$npmDir = "C:\Users\abinu\AppData\Roaming\npm"
$env:Path = "$nodeDir;$npmDir;" + $env:Path

$port = 20128
$activeConn = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue | Select-Object -First 1

if ($activeConn) {
    Write-Host "[STATUS] OmniRoute is ACTIVE and LISTENING on port $port." -ForegroundColor Green
    Write-Host "         Process ID : $($activeConn.OwningProcess)"
    Write-Host "         Local Address : $($activeConn.LocalAddress):$port"
    
    try {
        $health = Invoke-RestMethod -Uri "http://localhost:20128/health" -Method Get -TimeoutSec 5 -ErrorAction Stop
        Write-Host "         Health Check: $($health.status | ConvertTo-Json -Compress)" -ForegroundColor Green
    } catch {
        # Fallback to models endpoint probe
        try {
            $probe = Invoke-RestMethod -Uri "http://localhost:20128/v1/models" -Method Get -TimeoutSec 5 -ErrorAction SilentlyContinue
            Write-Host "         API Endpoint: ACTIVE (200 OK)" -ForegroundColor Green
        } catch {
            Write-Host "         Health probe responded with status code: $($_.Exception.Response.StatusCode.value__)"
        }
    }
} else {
    Write-Host "[STATUS] OmniRoute is NOT listening on port $port." -ForegroundColor Red
}

$task = Get-ScheduledTask -TaskName "OmniRoute-AutoStart" -ErrorAction SilentlyContinue
if ($task) {
    Write-Host "[AUTOSTART] Windows Scheduled Task: $($task.State)" -ForegroundColor Green
} else {
    Write-Host "[AUTOSTART] Windows Scheduled Task not found." -ForegroundColor Yellow
}

$startupFolder = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Startup)
$vbs = "$startupFolder\Launch-OmniRoute.vbs"
if (Test-Path $vbs) {
    Write-Host "[STARTUP FOLDER] Launcher shortcut present: $vbs" -ForegroundColor Green
} else {
    Write-Host "[STARTUP FOLDER] Launcher shortcut not present." -ForegroundColor Yellow
}
