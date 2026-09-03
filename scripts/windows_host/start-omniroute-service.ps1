# start-omniroute-service.ps1
# Starts OmniRoute as an independent Windows background service

$ErrorActionPreference = "SilentlyContinue"

# Setup environment paths
$nodeDir = "C:\Program Files\nodejs"
$npmDir = "C:\Users\abinu\AppData\Roaming\npm"
$env:Path = "$nodeDir;$npmDir;" + $env:Path

$logDir = "C:\Users\abinu\.omniroute"
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

$logFile = "$logDir\service.log"
$pidFile = "$logDir\service.pid"

# Check if already running on port 20128
$portActive = Get-NetTCPConnection -LocalPort 20128 -ErrorAction SilentlyContinue
if ($portActive) {
    Write-Host "[INFO] OmniRoute is already running on port 20128 (PID: $($portActive.OwningProcess))." -ForegroundColor Green
    exit 0
}

Write-Host "[INFO] Starting OmniRoute standalone service..." -ForegroundColor Cyan

# Launch omniroute in background process
$cmdPath = "$npmDir\omniroute.cmd"
$startInfo = New-Object System.Diagnostics.ProcessStartInfo
$startInfo.FileName = $cmdPath
$startInfo.Arguments = "serve --no-open --log"
$startInfo.RedirectStandardOutput = $true
$startInfo.RedirectStandardError = $true
$startInfo.UseShellExecute = $false
$startInfo.CreateNoWindow = $true
$startInfo.WorkingDirectory = "C:\Users\abinu\.omniroute"

# Redirect environment
$startInfo.EnvironmentVariables["Path"] = $env:Path

$process = New-Object System.Diagnostics.Process
$process.StartInfo = $startInfo
$process.Start() | Out-Null

$process.Id | Out-File -FilePath $pidFile -Encoding ascii -Force

Write-Host "[SUCCESS] OmniRoute started in background with PID: $($process.Id)" -ForegroundColor Green
Write-Host "[INFO] Logs are streaming to: $logFile"
Write-Host "[INFO] Dashboard available at: http://localhost:20128"
