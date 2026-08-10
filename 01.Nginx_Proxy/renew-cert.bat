@echo off

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "D:\vck\HocHanh\01.Udemy\01.docker\01.Nginx_Proxy\renew-cert.ps1"

exit /b %ERRORLEVEL%