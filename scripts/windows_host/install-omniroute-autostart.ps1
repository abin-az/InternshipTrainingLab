# install-omniroute-autostart.ps1
# Installs OmniRoute as a permanent Windows autostart background service

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$vbsSource = "$scriptDir\launch-omniroute-silent.vbs"
$startupFolder = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Startup)
$vbsTarget = "$startupFolder\Launch-OmniRoute.vbs"

Write-Host "==> [1/3] Installing Windows User Startup launcher..." -ForegroundColor Cyan
Copy-Item -Path $vbsSource -Destination $vbsTarget -Force
Write-Host "    Installed to: $vbsTarget" -ForegroundColor Green

Write-Host "==> [2/3] Checking Scheduled Task / Startup registration..." -ForegroundColor Cyan
$taskName = "OmniRoute-AutoStart"
$psScript = "$scriptDir\start-omniroute-service.ps1"
try {
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -NoProfile -WindowStyle Hidden -File `"$psScript`""
    $trigger = New-ScheduledTaskTrigger -AtLogOn
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue | Out-Null
    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Description "OmniRoute AI Gateway Autostart" -ErrorAction Stop | Out-Null
    Write-Host "    Scheduled Task '$taskName' registered." -ForegroundColor Green
} catch {
    Write-Host "    User Startup folder shortcut is active (standard non-admin autostart)." -ForegroundColor Yellow
}

Write-Host "==> [3/3] Starting OmniRoute service in background..." -ForegroundColor Cyan
& "$scriptDir\start-omniroute-service.ps1"

Start-Sleep -Seconds 3

Write-Host "`n==> Verifying service status:" -ForegroundColor Cyan
& "$scriptDir\check-omniroute-service.ps1"
