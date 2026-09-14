@ECHO OFF
:: this file is originally located in src/services/database/dbscripts

IF "%~1"=="" GOTO usage
IF "%2"=="" GOTO usage
IF "%3"=="" GOTO usage

SET ADOXX_SQLSERVER_DBA_NAME=%2
SET ADOXX_SQLSERVER_DBA_PWD=%3

SET DBNAME=%~1
SET SQL_SERVER_INST=%4
goto start

:start
ECHO.
@ECHO Init ADOxx database "%DBNAME%" for unittests ...
ECHO.

osql -U %ADOXX_SQLSERVER_DBA_NAME% -P %ADOXX_SQLSERVER_DBA_PWD% -d "%DBNAME%" -S %SQL_SERVER_INST% -isqlserver_dropadoxxtables.sql
osql -U %ADOXX_SQLSERVER_DBA_NAME% -P %ADOXX_SQLSERVER_DBA_PWD% -d "%DBNAME%" -S %SQL_SERVER_INST% -isqlserver.sql
osql -U %ADOXX_SQLSERVER_DBA_NAME% -P %ADOXX_SQLSERVER_DBA_PWD% -d "%DBNAME%" -S %SQL_SERVER_INST% -isqlserver_init_unittests.sql
osql -U %ADOXX_SQLSERVER_DBA_NAME% -P %ADOXX_SQLSERVER_DBA_PWD% -d "%DBNAME%" -S %SQL_SERVER_INST% -isqlserver_updstats.sql

GOTO end

:usage
ECHO.
ECHO Usage:     sqlserver_init_unittests ^<DATABASE-NAME^> ^<DBA-username^> ^<DBA-password^> [ ^<sql server instance^> ]
ECHO or:        sqlserver_init_unittests "<DATABASE NAME WITH SPACES>" ^<DBA-username^> ^<DBA-password^> [ ^<sql server instance^> ]
ECHO.
ECHO Example 1: sqlserver_init_unittests adoxxdb sa sapwd
ECHO Example 2: sqlserver_init_unittests adoxxdb sa sapwd ws313\sqlexpress
ECHO Example 3: sqlserver_init_unittests "adoxx db" sa sapwd

:end
SET DBNAME=
SET SQL_SERVER_INST=
SET ADOXX_SQLSERVER_DBA_NAME=
SET ADOXX_SQLSERVER_DBA_PWD=

