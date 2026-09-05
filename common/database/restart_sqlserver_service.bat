@echo off
REM ====================================================================
REM SLIIT SE2030 - Web-Based Boat Safari Trip Management System
REM Group: Y2-S1-MLB-B8G1-09
REM Restart MSSQL$SQLEXPRESS to activate TCP/IP Port 1433 & Mixed Mode
REM ====================================================================

echo [1/2] Stopping SQL Server (SQLEXPRESS)...
net stop "MSSQL$SQLEXPRESS"

echo [2/2] Starting SQL Server (SQLEXPRESS)...
net start "MSSQL$SQLEXPRESS"

echo.
echo ====================================================================
echo SUCCESS: SQL Server service restarted with TCP/IP port 1433 active.
echo Database: boat_safari_db is ready for SSMS and JDBC connections.
echo ====================================================================
pause
