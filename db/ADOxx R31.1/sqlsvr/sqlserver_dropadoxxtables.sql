DROP TABLE ADOxx.globlibid;
DROP TABLE ADOxx.dbinfo;
DROP TABLE ADOxx.licinfo;
DROP TABLE ADOxx.dblang;
DROP TABLE ADOxx.cardinality;
DROP TABLE ADOxx.endpointrestrict;
DROP TABLE ADOxx.sval_mod;
DROP TABLE ADOxx.sval_ri;
DROP TABLE ADOxx.sval_mi;
DROP TABLE ADOxx.sval_relepi;
DROP TABLE ADOxx.simpleval_defval;
DROP TABLE ADOxx.cval_mod;
DROP TABLE ADOxx.cval_ri;
DROP TABLE ADOxx.cval_mi;
DROP TABLE ADOxx.cval_relepi;
DROP TABLE ADOxx.complexval_defval;
DROP TABLE ADOxx.valowner_lib;
DROP TABLE ADOxx.valowner_mod;
DROP TABLE ADOxx.valowner_ri;
DROP TABLE ADOxx.valowner_mi;
--
DROP TABLE ADOxx.sval_mod_arch;
DROP TABLE ADOxx.sval_ri_arch;
DROP TABLE ADOxx.sval_mi_arch;
DROP TABLE ADOxx.cval_mod_arch;
DROP TABLE ADOxx.cval_ri_arch;
DROP TABLE ADOxx.cval_mi_arch;
DROP TABLE ADOxx.valowner_mod_arch;
DROP TABLE ADOxx.valowner_ri_arch;
DROP TABLE ADOxx.valowner_mi_arch;
--
DROP TABLE ADOxx.valowner_relepi;
DROP TABLE ADOxx.instancename;
-- because of the dependencies drop order must be:
-- ADOxx.ep_brokenep_iname before ADOxx.brokenep_iname AND ADOxx.relendpntinst
DROP TABLE ADOxx.relendpntinst;
DROP TABLE ADOxx.relepi_repoobjs;
DROP TABLE ADOxx.endpointdef;
DROP TABLE ADOxx.groupobjsctxtspec;
DROP TABLE ADOxx.hiergroup_ctxtspec;
DROP TABLE ADOxx.ctxtinstobjs;
DROP TABLE ADOxx.modelinst;
DROP TABLE ADOxx.repoinst;
DROP TABLE ADOxx.delayedaction;
DROP TABLE ADOxx.mod_repoobjs;
DROP TABLE ADOxx.ri_repoobjs;
DROP TABLE ADOxx.mi_repoobjs;
DROP TABLE ADOxx.ci_repoobjs;
DROP TABLE ADOxx.hg_repoobjs;
DROP TABLE ADOxx.model;
DROP TABLE ADOxx.contextdef_param;
DROP TABLE ADOxx.contextinst;
DROP TABLE ADOxx.paramdomain;
DROP TABLE ADOxx.contextparam;
DROP TABLE ADOxx.objattrdefs;
DROP TABLE ADOxx.attrdef;
DROP TABLE ADOxx.attrtype;
DROP TABLE ADOxx.attrvaltype;
DROP TABLE ADOxx.classtomodus;
DROP TABLE ADOxx.modus;
DROP TABLE ADOxx.classtomodtype;
DROP TABLE ADOxx.modeltype;
DROP TABLE ADOxx.class;
DROP TABLE ADOxx.libobjs;
DROP TABLE ADOxx.direct_libobjs;
DROP TABLE ADOxx.name;
DROP TABLE ADOxx.identifiertext;
DROP TABLE ADOxx.liblang;
-- because of the dependencies drop order must be:
-- ADOxx.deplibs, ADOxx.library, ADOxx.contextdef
DROP TABLE ADOxx.deplibs;
DROP TABLE ADOxx.library;
DROP TABLE ADOxx.contextdef;
DROP TABLE ADOxx.transact;
DROP TABLE ADOxx.locks;
DROP TABLE ADOxx.permissions;
DROP TABLE ADOxx.metamodelright;
DROP TABLE ADOxx.rolemember;
DROP TABLE ADOxx.role_mfb;
DROP TABLE ADOxx.activities;
DROP TABLE ADOxx.library_log;
-- because of the dependencies drop order must be:
-- ADOxx.filedata and ADOxx.dms_metadata before ADOxx.files
DROP TABLE ADOxx.filedata;
DROP TABLE ADOxx.dms_metadata;
DROP TABLE ADOxx.files;
DROP TABLE ADOxx.directories;
-- because of the dependencies, drop order must be:
-- ADOxx.files, ADOxx.directories before ADOxx.repository
DROP TABLE ADOxx.repository;
DROP TABLE ADOxx.generic_data;
DROP TABLE ADOxx.dep_activities;
DROP TABLE ADOxx.del_val;
-- because of the dependencies drop order must be:
-- ADOxx.admin_change_history, ADOxx.admin_change_transact and
-- ADOxx.admin_change_history_arch, ADOxx.admin_change_transact_arch
DROP TABLE ADOxx.admin_change_history;
DROP TABLE ADOxx.admin_change_transact;
DROP TABLE ADOxx.admin_change_history_arch;
DROP TABLE ADOxx.admin_change_transact_arch;


