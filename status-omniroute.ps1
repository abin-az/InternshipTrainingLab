# status-omniroute.ps1
# Checks OmniRoute status, health, and available models

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
$env:Path = "C:\Program Files\nodejs;C:\Users\abinu\AppData\Roaming\npm;" + $env:Path

Write-Host "=== OmniRoute Health ===" -ForegroundColor Cyan
omniroute health

Write-Host "`n=== Available Models ===" -ForegroundColor Cyan
omniroute models

Write-Host "`n=== Active Providers ===" -ForegroundColor Cyan
omniroute providers list
