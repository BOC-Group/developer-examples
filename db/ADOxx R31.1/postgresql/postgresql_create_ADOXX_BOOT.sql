/*
// --------------------------------------------------------
// (C) COPYRIGHT BOC - Business Objectives Consulting 1995 - 2021
// All Rights Reserved
// Use, duplication or disclosure restricted by BOC
// Vienna, 1995 - 2021
// --------------------------------------------------------
// Description:
// Script template to create user ADOXX_BOOT with limited
// access permissions to an ADOxx database.
// --------------------------------------------------------
// Target DBMS: PostgreSQL
// --------------------------------------------------------
// How to use:
// - Replace the placeholder vDBName with the
//   name (or alias) of the database on which this script
//   is to be executed.
// - Connect to the concerned ADOxx-database with a SQL
//   processor, e.g. with the utility "psql".
// - Execute the script.
// - If the login ADOXX_BOOT does already exist, according
//   error messages will be displayed. These errors can be
//   ignored. The script will just set the limited access
//   permissions in this case and finish successfully.
*/

\set vDBName 'adoxxdb'
\connect :vDBName;

GRANT CONNECT ON DATABASE :vDBName TO "ADOXX_BOOT";
GRANT USAGE ON SCHEMA "ADOxx" TO "ADOXX_BOOT";
GRANT SELECT ON "ADOxx".dbinfo TO "ADOXX_BOOT";