@ECHO OFF
:: this file is originally located in src/services/database/dbscripts

IF "%~1"=="" GOTO usage
IF "%2"=="" GOTO usage
IF "%3"=="" GOTO usage

SET ADOXX_SQLSERVER_DBA_NAME=%2
SET ADOXX_SQLSERVER_DBA_PWD=%3

SET DBNAME_CREATETABS=%~1
SET SQL_SERVER_INST=%4
goto start

:start
ECHO.
@ECHO Creating ADOxx database tables for database "%DBNAME_CREATETABS%"
ECHO.

osql -U %ADOXX_SQLSERVER_DBA_NAME% -P %ADOXX_SQLSERVER_DBA_PWD% -d "%DBNAME_CREATETABS%" -S %SQL_SERVER_INST% -isqlserver_dropadoxxtables.sql
osql -U %ADOXX_SQLSERVER_DBA_NAME% -P %ADOXX_SQLSERVER_DBA_PWD% -d "%DBNAME_CREATETABS%" -S %SQL_SERVER_INST% -isqlserver.sql

ECHO.
@ECHO Created ADOxx tables...
ECHO.

goto end

:usage
ECHO.
ECHO Usage:     sqlserver_create_tabs ^<DATABASE-NAME^> ^<DBA-username^> ^<DBA-password^> [ ^<sql server instance^> ]
ECHO or:        sqlserver_create_tabs "<DATABASE NAME WITH SPACES>" ^<DBA-username^> ^<DBA-password^> [ ^<sql server instance^> ]
ECHO.
ECHO Example 1: sqlserver_create_tabs adoxxdb sa sapwd
ECHO Example 2: sqlserver_create_tabs adoxxdb sa sapwd ws313\sqlexpress
ECHO Example 3: sqlserver_create_tabs "adoxx db" sa sapwd

:end
SET DBNAME_CREATETABS=
SET SQL_SERVER_INST=
SET ADOXX_SQLSERVER_DBA_NAME=
SET ADOXX_SQLSERVER_DBA_PWD=

