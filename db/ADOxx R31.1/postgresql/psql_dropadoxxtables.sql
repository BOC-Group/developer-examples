DROP TABLE IF EXISTS "ADOxx".globlibid;
DROP TABLE IF EXISTS "ADOxx".dbinfo;
DROP TABLE IF EXISTS "ADOxx".licinfo;
DROP TABLE IF EXISTS "ADOxx".dblang;
DROP TABLE IF EXISTS "ADOxx".cardinality;
DROP TABLE IF EXISTS "ADOxx".endpointrestrict;
DROP TABLE IF EXISTS "ADOxx".sval_mod;
DROP TABLE IF EXISTS "ADOxx".sval_ri;
DROP TABLE IF EXISTS "ADOxx".sval_mi;
DROP TABLE IF EXISTS "ADOxx".sval_relepi;
DROP TABLE IF EXISTS "ADOxx".simpleval_defval;
DROP TABLE IF EXISTS "ADOxx".cval_mod;
DROP TABLE IF EXISTS "ADOxx".cval_ri;
DROP TABLE IF EXISTS "ADOxx".cval_mi;
DROP TABLE IF EXISTS "ADOxx".cval_relepi;
DROP TABLE IF EXISTS "ADOxx".complexval_defval;
DROP TABLE IF EXISTS "ADOxx".valowner_lib;
DROP TABLE IF EXISTS "ADOxx".valowner_mod;
DROP TABLE IF EXISTS "ADOxx".valowner_ri;
DROP TABLE IF EXISTS "ADOxx".valowner_mi;
--
DROP TABLE IF EXISTS "ADOxx".sval_mod_arch;
DROP TABLE IF EXISTS "ADOxx".sval_ri_arch;
DROP TABLE IF EXISTS "ADOxx".sval_mi_arch;
DROP TABLE IF EXISTS "ADOxx".cval_mod_arch;
DROP TABLE IF EXISTS "ADOxx".cval_ri_arch;
DROP TABLE IF EXISTS "ADOxx".cval_mi_arch;
DROP TABLE IF EXISTS "ADOxx".valowner_mod_arch;
DROP TABLE IF EXISTS "ADOxx".valowner_ri_arch;
DROP TABLE IF EXISTS "ADOxx".valowner_mi_arch;
--
DROP TABLE IF EXISTS "ADOxx".valowner_relepi;
DROP TABLE IF EXISTS "ADOxx".instancename;
DROP TABLE IF EXISTS "ADOxx".relendpntinst;
DROP TABLE IF EXISTS "ADOxx".relepi_repoobjs;
DROP TABLE IF EXISTS "ADOxx".endpointdef;
DROP TABLE IF EXISTS "ADOxx".groupobjsctxtspec;
DROP TABLE IF EXISTS "ADOxx".hiergroup_ctxtspec;
DROP TABLE IF EXISTS "ADOxx".ctxtinstobjs;
DROP TABLE IF EXISTS "ADOxx".modelinst;
DROP TABLE IF EXISTS "ADOxx".repoinst;
DROP TABLE IF EXISTS "ADOxx".delayedaction;
DROP TABLE IF EXISTS "ADOxx".mod_repoobjs;
DROP TABLE IF EXISTS "ADOxx".ri_repoobjs;
DROP TABLE IF EXISTS "ADOxx".mi_repoobjs;
DROP TABLE IF EXISTS "ADOxx".ci_repoobjs;
DROP TABLE IF EXISTS "ADOxx".hg_repoobjs;
DROP TABLE IF EXISTS "ADOxx".model;
DROP TABLE IF EXISTS "ADOxx".contextdef_param;
DROP TABLE IF EXISTS "ADOxx".contextinst;
DROP TABLE IF EXISTS "ADOxx".paramdomain;
DROP TABLE IF EXISTS "ADOxx".contextparam;
DROP TABLE IF EXISTS "ADOxx".objattrdefs;
DROP TABLE IF EXISTS "ADOxx".attrdef;
DROP TABLE IF EXISTS "ADOxx".attrtype;
DROP TABLE IF EXISTS "ADOxx".attrvaltype;
DROP TABLE IF EXISTS "ADOxx".classtomodus;
DROP TABLE IF EXISTS "ADOxx".modus;
DROP TABLE IF EXISTS "ADOxx".classtomodtype;
DROP TABLE IF EXISTS "ADOxx".modeltype;
DROP TABLE IF EXISTS "ADOxx".class;
DROP TABLE IF EXISTS "ADOxx".libobjs;
DROP TABLE IF EXISTS "ADOxx".direct_libobjs;
DROP TABLE IF EXISTS "ADOxx".name;
DROP TABLE IF EXISTS "ADOxx".identifiertext;
DROP TABLE IF EXISTS "ADOxx".liblang;
-- because of the dependencies drop order must be:
-- "ADOxx".deplibs, "ADOxx".library, "ADOxx".contextdef
DROP TABLE IF EXISTS "ADOxx".deplibs;
DROP TABLE IF EXISTS "ADOxx".library;
DROP TABLE IF EXISTS "ADOxx".contextdef;
DROP TABLE IF EXISTS "ADOxx".transact;
DROP TABLE IF EXISTS "ADOxx".locks;
DROP TABLE IF EXISTS "ADOxx".permissions;
DROP TABLE IF EXISTS "ADOxx".metamodelright;
DROP TABLE IF EXISTS "ADOxx".rolemember;
DROP TABLE IF EXISTS "ADOxx".role_mfb;
DROP TABLE IF EXISTS "ADOxx".activities;
DROP TABLE IF EXISTS "ADOxx".library_log;
-- because of the dependencies drop order must be:
-- "ADOxx".filedata and "ADOxx".dms_metadata before "ADOxx".files
DROP TABLE IF EXISTS "ADOxx".filedata;
DROP TABLE IF EXISTS "ADOxx".dms_metadata;
DROP TABLE IF EXISTS "ADOxx".files;
DROP TABLE IF EXISTS "ADOxx".directories;
-- because of the dependencies, drop order must be:
-- "ADOxx".files, "ADOxx".directories before "ADOxx".repository
DROP TABLE IF EXISTS "ADOxx".repository;
DROP TABLE IF EXISTS "ADOxx".generic_data;
DROP TABLE IF EXISTS "ADOxx".dep_activities;
DROP TABLE IF EXISTS "ADOxx".del_val;
-- because of the dependencies drop order must be:
-- "ADOxx".admin_change_history, "ADOxx".admin_change_transact and
-- "ADOxx".admin_change_history_arch, "ADOxx".admin_change_transact_arch
DROP TABLE IF EXISTS "ADOxx".admin_change_history;
DROP TABLE IF EXISTS "ADOxx".admin_change_transact;
DROP TABLE IF EXISTS "ADOxx".admin_change_history_arch;
DROP TABLE IF EXISTS "ADOxx".admin_change_transact_arch;

----------------------------------------------------------------
DROP FUNCTION IF EXISTS "ADOxx".delAdminChangeTranArch();
DROP FUNCTION IF EXISTS "ADOxx".delAttrDef();
DROP FUNCTION IF EXISTS "ADOxx".delAttrValTyp();
DROP FUNCTION IF EXISTS "ADOxx".delAttrTyp();
DROP FUNCTION IF EXISTS "ADOxx".delCValMi();
DROP FUNCTION IF EXISTS "ADOxx".delCiRepoObj();
DROP FUNCTION IF EXISTS "ADOxx".delClass();
DROP FUNCTION IF EXISTS "ADOxx".delContextDef();
DROP FUNCTION IF EXISTS "ADOxx".delContextInst();
DROP FUNCTION IF EXISTS "ADOxx".delContextParam();
DROP FUNCTION IF EXISTS "ADOxx".delEndpntDef();
DROP FUNCTION IF EXISTS "ADOxx".delGroupCtxtSpec();
DROP FUNCTION IF EXISTS "ADOxx".delHgRepoObj();
DROP FUNCTION IF EXISTS "ADOxx".delLib();
DROP FUNCTION IF EXISTS "ADOxx".delMiRepoObj();
DROP FUNCTION IF EXISTS "ADOxx".delModInst();
DROP FUNCTION IF EXISTS "ADOxx".delModRepoObj();
DROP FUNCTION IF EXISTS "ADOxx".delModTyp();
DROP FUNCTION IF EXISTS "ADOxx".delModel();
DROP FUNCTION IF EXISTS "ADOxx".delRelEpInst();
DROP FUNCTION IF EXISTS "ADOxx".delRep();
DROP FUNCTION IF EXISTS "ADOxx".delRepInst();
DROP FUNCTION IF EXISTS "ADOxx".delRepiRepoObj();
DROP FUNCTION IF EXISTS "ADOxx".delRiRepoObj();
DROP FUNCTION IF EXISTS "ADOxx".delRole();
DROP FUNCTION IF EXISTS "ADOxx".delSValMi();
DROP FUNCTION IF EXISTS "ADOxx".updDMSMetadata();
DROP FUNCTION IF EXISTS "ADOxx".updInstancename();
DROP FUNCTION IF EXISTS "ADOxx".updSValRelepi();
DROP FUNCTION IF EXISTS "ADOxx".upsertCValMi();
DROP FUNCTION IF EXISTS "ADOxx".upsertRelEpInst();
DROP FUNCTION IF EXISTS "ADOxx".upsertSValMi();
DROP FUNCTION IF EXISTS "ADOxx".insertMiRepoobjs();
DROP FUNCTION IF EXISTS "ADOxx".trg_create_set_owner() CASCADE;
