@ECHO OFF
REM ============================================================
REM = This script lists all SQL-Server databases on the        =
REM = local computer.                                          =
REM ============================================================
REM = The SQL Server instance can be passed as parameter.      =
REM ============================================================

SET SQL_STATEMENT_GET_DBS="SELECT name FROM sys.databases WHERE name NOT IN ('master', 'tempdb', 'model', 'msdb');"

IF "%1"=="" goto simple

ECHO.
ECHO Databases on SQL Server instance %1:
ECHO.
ECHO Please wait...
ECHO.

sqlcmd -U ADOxx -P r0KaQIFA]cPd2Ave -h-1 -S %1 -Q %SQL_STATEMENT_GET_DBS%
goto end

:simple
ECHO.
ECHO Databases on the SQL Server default instance on this computer:
ECHO.
ECHO Please wait...
ECHO.
sqlcmd -U ADOxx -P r0KaQIFA]cPd2Ave -h-1 -Q %SQL_STATEMENT_GET_DBS%

:end
SET SQL_STATEMENT_GET_DBS=
