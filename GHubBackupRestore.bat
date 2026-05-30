@echo off
setlocal
title Logitech G HUB Backup/Restore
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0GHubBackupRestore.ps1"
echo.
pause
