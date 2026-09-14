/************************************************************************************
 * SQL SERVER - DATABASE CREATION SCRIPT - ADOxx
 ************************************************************************************
 Description:
 - Create empty database
 - Set up database files and performance related properties
 - Create ADOxx technical users (logins, DB users)
 - Create DB schema
 - Grant permissions
 ************************************************************************************
 Adaption:
 * Mandatory:
   - Database name (@vDBName)

 * Optional:
   - ADOxx technical user name
   - ADOxx technical user password
   - Database data file initial size and autogrowth
   - Database log file initial size and autogrowth
 ************************************************************************************/

  -- MUST BE ADAPTED: database name
  DECLARE @vDBName nvarchar(128);    -- database identifier
  SET @vDBName     = N'[adoxxdb]';     -- replace value by the required DB name

  -- Can be adapted: data file and log file settings
  DECLARE @vADOxxName nvarchar(128); -- schema and technical ADOxx user identifier
  DECLARE @vADOxxPwd nvarchar(128);  -- technical ADOxx user's password

  SET @vADOxxName  = N'ADOxx';
  SET @vADOxxPwd   = N'r0KaQIFA]cPd2Ave';

  -- Can be adapted: data file and log file settings
  DECLARE @vDBFileInitSize nvarchar(10);    -- initial size of database data file
  DECLARE @vDBFileGrowth nvarchar(10);      -- default data file growth
  DECLARE @vDBLogFileInitSize nvarchar(10); -- initial size of database log file
  DECLARE @vDBLogFileGrowth nvarchar(10);   -- default log file growth

  SET @vDBFileInitSize    = N'100MB';
  SET @vDBFileGrowth      = N'75MB';
  SET @vDBLogFileInitSize = N'50MB';
  SET @vDBLogFileGrowth   = N'75MB';


  PRINT N'********************************************************';
  PRINT N'*        Prepare ADOxx Database for SQL Server         *';
  PRINT N'********************************************************';
  PRINT N'* - Database name:               ' + @vDBName;
  PRINT N'* - Schema/technical ADOxx user: ' + @vADOxxName;
  PRINT N'********************************************************';

  DECLARE @sqltxt nvarchar(1000);

  DECLARE @ErrorMessage NVARCHAR(4000);
  DECLARE @ErrorSeverity INT;
  DECLARE @ErrorState INT;

  DECLARE @DropDBOnError char(1); -- controls whether or not the database should be dropped on error, handle carefully!!!
  SET @DropDBOnError = 0;

  -- DO NOT CHANGE!!!
  DECLARE @vADOxxBootName nvarchar(128); -- ADOxx boot user identifier
  DECLARE @vADOxxBootPwd nvarchar(128); -- ADOxx boot user's password

  SET @vADOxxBootName = 'ADOXX_BOOT';
  SET @vADOxxBootPwd  = 'iCfCK!lHP8S1L]Ry';

BEGIN TRY
  PRINT N'********************************************************';
  PRINT N'*         Create empty ADOxx Database                  *';
  PRINT N'********************************************************';
  SET @sqltxt = N'CREATE DATABASE ' + @vDBName;
  EXECUTE sp_executesql @sqltxt;

  PRINT N'...Database created.';

  PRINT N'********************************************************';
  PRINT N'*        Setting DB file sizes and autogrowth          *';
  PRINT N'********************************************************';
  BEGIN TRY
    SET @sqltxt = N'ALTER DATABASE ' + @vDBName
          + N' MODIFY FILE (NAME=' + @vDBName + N', SIZE=' + @vDBFileInitSize
          + N', MAXSIZE=UNLIMITED, FILEGROWTH=' + @vDBFileGrowth + N')';
    EXECUTE sp_executesql @sqltxt;

      PRINT N'...Database data file size and autogrowth set.';
  END TRY
  BEGIN CATCH
    PRINT N'Error while setting DB data file size and autogrowth ';
    PRINT N'-> ' + ERROR_MESSAGE();
    PRINT N'Please adjust the data file settings manually.';
  END CATCH

  PRINT N'********************************************************';
  PRINT N'*        Setting DB log file sizes and autogrowth      *';
  PRINT N'********************************************************';
  BEGIN TRY
    SET @sqltxt = N'ALTER DATABASE ' + @vDBName
          + N' MODIFY FILE (NAME=' + @vDBName + N'_log, SIZE=' + @vDBLogFileInitSize
          + N', MAXSIZE=UNLIMITED, FILEGROWTH=' + @vDBLogFileGrowth + N')';
    EXECUTE sp_executesql @sqltxt;

      PRINT N'...Database log file size and autogrowth set.';
  END TRY
  BEGIN CATCH
    PRINT N'Error while setting DB log file size and autogrowth ';
    PRINT N'-> ' + ERROR_MESSAGE();
    PRINT N'Please adjust the log file settings manually.';
  END CATCH


  PRINT N'********************************************************';
  PRINT N'*        Create logins for the ADOxx technical users   *';
  PRINT N'********************************************************';
  BEGIN TRY
    SET @sqltxt = N'CREATE LOGIN ' + @vADOxxBootName + N' WITH PASSWORD = ''' + @vADOxxBootPwd + N'''';
    EXECUTE sp_executesql @sqltxt;
  END TRY
  BEGIN CATCH
    IF @@ERROR = 15025
    BEGIN
      PRINT N'...Login ' + @vADOxxBootName + N' already exists. No action taken.';
    END
    ELSE
    BEGIN

      SELECT 
        @ErrorMessage = ERROR_MESSAGE(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE();

      -- Re-throw exception
      RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END
  END CATCH

  BEGIN TRY
  SET @sqltxt = N'CREATE LOGIN ' + @vADOxxName + N' WITH PASSWORD = ''' + @vADOxxPwd + N'''';
  EXECUTE sp_executesql @sqltxt;
  END TRY
  BEGIN CATCH
    IF @@ERROR = 15025
    BEGIN
      PRINT N'...Login ' + @vADOxxName + N' already exists. No action taken.';
    END
    ELSE
    BEGIN

      SELECT 
        @ErrorMessage = ERROR_MESSAGE(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE();

      -- Re-throw exception
      RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END
  END CATCH

  PRINT N'...Logins for the ADOxx technical users created.';


  /***********************************************************
   *  New database created, it should be dropped on error
   ***********************************************************/
  SET @DropDBOnError = 1;

  PRINT N'********************************************************';
  PRINT N'*        Setting DB properties for performance         *';
  PRINT N'********************************************************';

  SET @sqltxt = N'ALTER DATABASE ' + @vDBName + N' SET AUTO_CLOSE OFF';
  EXECUTE sp_executesql @sqltxt;

  SET @sqltxt = N'ALTER DATABASE ' + @vDBName + N' SET AUTO_SHRINK OFF';
  EXECUTE sp_executesql @sqltxt;

  SET @sqltxt = N'ALTER DATABASE ' + @vDBName + N' SET AUTO_CREATE_STATISTICS ON';
  EXECUTE sp_executesql @sqltxt;

  SET @sqltxt = N'ALTER DATABASE ' + @vDBName + N' SET AUTO_UPDATE_STATISTICS ON';
  EXECUTE sp_executesql @sqltxt;

  SET @sqltxt = N'ALTER DATABASE ' + @vDBName + N' SET AUTO_UPDATE_STATISTICS_ASYNC ON';
  EXECUTE sp_executesql @sqltxt;

  SET @sqltxt = N'ALTER DATABASE ' + @vDBName + N' SET TORN_PAGE_DETECTION OFF';
  EXECUTE sp_executesql @sqltxt;

  PRINT N'...DB properties for performance set.';

  /***********************************************************
   *  After successful creation of database, connect to given
   *  new database and configure it, grant rights
   *  in new database to the ADOxx technical users
   ***********************************************************/
  PRINT N'********************************************************';
  PRINT N'*        Connect to the new database                   *';
  PRINT N'********************************************************';
  SET @sqltxt = N'USE ' + @vDBName;
  EXECUTE sp_executesql @sqltxt;

  PRINT N'...Connection to the database ' + @vDBName  + N' succeeded.';

  PRINT N'********************************************************';
  PRINT N'*        Create DB users for the ADOxx technical users *';
  PRINT N'********************************************************';
  SET @sqltxt = N'USE ' + @vDBName + N';CREATE USER ' + @vADOxxBootName + N' FROM LOGIN ' + @vADOxxBootName + N' WITH DEFAULT_SCHEMA=' + @vADOxxName;
  EXECUTE sp_executesql @sqltxt;

  PRINT N'...Boot user ' + @vADOxxBootName + N' created';

  SET @sqltxt = N'USE ' + @vDBName + N';CREATE USER ' + @vADOxxName + N' FROM LOGIN ' + @vADOxxName + N' WITH DEFAULT_SCHEMA=' + @vADOxxName;
  EXECUTE sp_executesql @sqltxt;

  PRINT N'...ADOxx user ' + @vADOxxName + N' created.';


  PRINT N'********************************************************';
  PRINT N'*        Create schema and grant access                *';
  PRINT N'********************************************************';
  SET @sqltxt = N'USE ' + @vDBName + N'; execute sp_executesql N''CREATE SCHEMA ' + @vADOxxName + N'''';
  EXECUTE sp_executesql @sqltxt;

  PRINT N'...Schema ' + @vADOxxName + N' created.';

  SET @sqltxt = N'USE ' + @vDBName + N';GRANT SELECT,INSERT,UPDATE,DELETE,ALTER ON SCHEMA :: ' + @vADOxxName + N' TO ' + @vADOxxName;
  EXECUTE sp_executesql @sqltxt;

  PRINT N'...Access granted.';
 
END TRY
BEGIN CATCH
  PRINT N'Error while preparing the ADOxx database:';
  PRINT N'-> ' + ERROR_MESSAGE();
  IF @DropDBOnError = 1
  BEGIN
    BEGIN TRY
      PRINT N'Dropping database ' + @vDBName + N' ...';
      SET @sqltxt = N'DROP DATABASE ' + @vDBName;
      EXECUTE sp_executesql @sqltxt;

      PRINT N'...Database ' + @vDBName + N' dropped.';
    END TRY
    BEGIN CATCH
      PRINT N'Database ' + @vDBName + N' could not be dropped.';
    END CATCH
  END
END CATCH
