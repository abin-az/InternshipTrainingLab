# stop-omniroute.ps1
# Stops the OmniRoute AI Gateway server

$ErrorActionPreference = "SilentlyContinue"
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

$env:Path = "C:\Program Files\nodejs;C:\Users\abinu\AppData\Roaming\npm;" + $env:Path

Write-Host "Stopping OmniRoute..." -ForegroundColor Yellow
omniroute stop
Write-Host "OmniRoute stopped." -ForegroundColor Green
