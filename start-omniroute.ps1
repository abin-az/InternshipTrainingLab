# start-omniroute.ps1
# Starts the OmniRoute AI Gateway server in the background

$ErrorActionPreference = "Stop"
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

$env:Path = "C:\Program Files\nodejs;C:\Users\abinu\AppData\Roaming\npm;" + $env:Path

Write-Host "Starting OmniRoute server on http://localhost:20128..." -ForegroundColor Cyan
omniroute serve --daemon --no-open

Write-Host "Checking status..." -ForegroundColor Green
omniroute status
