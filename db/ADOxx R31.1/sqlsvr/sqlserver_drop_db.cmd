@ECHO OFF
REM ============================================================
REM = This script deletes an SQL-Server database.              =
REM = Use with care.                                           =
REM ============================================================

REM ============================================================
REM = Default database name to be deleted.                     =
REM = This name will be used for the deletion if no other name =
REM = is passed to the script.                                 =
REM ============================================================
SET DB_DROP_DEFAULT_NAME=adoxxdb

REM ============================================================
REM ============================================================
IF "%~1"=="-?" GOTO usage

SET ADO_REGFILE=%TEMP%\regadoxxdb_odbc_ds.reg
SET DBNAME_DROP=%~1
IF "%~1"=="" SET DBNAME_DROP=%DB_DROP_DEFAULT_NAME%
SET SQL_SERVER_INST=%2

ECHO.
@ECHO Dropping ADOxx database "%DBNAME_DROP%"...
ECHO.

osql -E -Q "EXIT(drop database [%DBNAME_DROP%])" -S %SQL_SERVER_INST%

@ECHO REGEDIT4 > %ADO_REGFILE%
@ECHO. >> %ADO_REGFILE%
@ECHO [-HKEY_LOCAL_MACHINE\SOFTWARE\ODBC\ODBC.INI\%DBNAME_DROP%] >> %ADO_REGFILE%
@ECHO. >> %ADO_REGFILE%
@ECHO [HKEY_LOCAL_MACHINE\SOFTWARE\ODBC\ODBC.INI\ODBC Data Sources] >> %ADO_REGFILE%
@ECHO "%DBNAME_DROP%"=- >> %ADO_REGFILE%
@ECHO [-HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\ODBC\ODBC.INI\%DBNAME_DROP%] >> %ADO_REGFILE%
@ECHO. >> %ADO_REGFILE%
@ECHO [HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\ODBC\ODBC.INI\ODBC Data Sources] >> %ADO_REGFILE%
@ECHO "%DBNAME_DROP%"=- >> %ADO_REGFILE%

regedit /s %ADO_REGFILE%

GOTO end

:usage
ECHO.
ECHO Show help: sqlserver_drop_db -?
ECHO.
ECHO Usage:     sqlserver_drop_db ^<database-name^> [ ^<sql server instance^> ]
ECHO or:        sqlserver_drop_db "<database name with spaces>" [ ^<sql server instance^> ]
ECHO.
ECHO Example 1: sqlserver_drop_db adoxxdb
ECHO Example 2: sqlserver_drop_db adoxxdb ws313\sqlexpress
ECHO Example 3: sqlserver_drop_db "adoxx db"
ECHO.
:end
SET DBNAME_DROP=
SET ADO_REGFILE=
SET SQL_SERVER_INST=