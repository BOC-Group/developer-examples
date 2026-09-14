/*
// --------------------------------------------------------
// (C) COPYRIGHT BOC - Business Objectives Consulting 1995 - 2019
// All Rights Reserved
// Use, duplication or disclosure restricted by BOC
// Vienna, 1995 - 2019
// --------------------------------------------------------
// Description:
// Script template to create user ADOXX_BOOT with limited
// access permissions to an ADOxx database.
// --------------------------------------------------------
// Target DBMS: SQL Server
// --------------------------------------------------------
// How to use:
// - Replace the placeholder <Database name> with the
//   name (or alias) of the database on which this script
//   is to be executed.
// - Connect to the concerned ADOxx-database with a SQL
//   processor, e.g. with the utility "sqlcmd".
// - Execute the script.
// - If the login ADOXX_BOOT does already exist, according
//   error messages will be displayed. These errors can be
//   ignored. The script will just set the limited access
//   permissions in this case and finish successfully.
*/

USE master
GO

CREATE LOGIN ADOXX_BOOT WITH PASSWORD='iCfCK!lHP8S1L]Ry', DEFAULT_DATABASE=master, CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF;
GO

USE [<Database name>]
GO

CREATE USER ADOXX_BOOT FOR LOGIN ADOXX_BOOT WITH DEFAULT_SCHEMA=ADOxx;
GO

GRANT CONNECT TO ADOXX_BOOT;
GRANT SELECT ON ADOxx.dbinfo TO ADOXX_BOOT;
GO
