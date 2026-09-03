Set objShell = CreateObject("WScript.Shell")
strCommand = "powershell.exe -ExecutionPolicy Bypass -NoProfile -WindowStyle Hidden -File ""C:\Users\abinu\Documents\antigravity\optimistic-meitner\scripts\windows_host\start-omniroute-service.ps1"""
objShell.Run strCommand, 0, False
