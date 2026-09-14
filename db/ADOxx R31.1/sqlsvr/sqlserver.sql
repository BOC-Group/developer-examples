CREATE TABLE ADOxx.transact(id TINYINT);

CREATE TABLE ADOxx.dbinfo(type SMALLINT NOT NULL,
                            val NVARCHAR(2650),
                            val2 VARCHAR(1350),
                            CONSTRAINT PK_dbinfo PRIMARY KEY (type));

CREATE TABLE ADOxx.licinfo(licid BINARY(16) NOT NULL,
                             infotxt VARCHAR(2000) NOT NULL,
                             lastinfotxt VARCHAR(2000) NOT NULL,
                             flag SMALLINT NOT NULL,
                             CONSTRAINT PK_licinfo PRIMARY KEY (licid));

CREATE TABLE ADOxx.dblang(langid NVARCHAR(60) NOT NULL,
                            CONSTRAINT PK_dblang PRIMARY KEY (langid));

CREATE TABLE ADOxx.contextparam(paramid BINARY(16) NOT NULL,
                                  dynamic TINYINT NOT NULL,
                                  dbtype SMALLINT NOT NULL,
                                  CONSTRAINT PK_contextparam PRIMARY KEY (paramid));

CREATE TABLE ADOxx.contextdef(contextdefid BINARY(16) NOT NULL,
                                flag INTEGER NOT NULL,
                                CONSTRAINT PK_contextdef PRIMARY KEY (contextdefid));

CREATE TABLE ADOxx.contextdef_param(contextdefid BINARY(16) NOT NULL,
                                      paramid BINARY(16) NOT NULL,
                                      priority SMALLINT NOT NULL,
                                      CONSTRAINT PK_contextdef_param PRIMARY KEY (contextdefid,priority));
ALTER TABLE ADOxx.contextdef_param ADD CONSTRAINT fkctdefpar_ctdef FOREIGN KEY (contextdefid) REFERENCES ADOxx.contextdef (contextdefid) ON DELETE CASCADE;
ALTER TABLE ADOxx.contextdef_param ADD CONSTRAINT fkctdefpar_cparam FOREIGN KEY (paramid) REFERENCES ADOxx.contextparam (paramid) ON DELETE CASCADE;

CREATE TABLE ADOxx.library(libid BINARY(16) NOT NULL,
                             contextdefid BINARY(16) NULL,
                             deflang NVARCHAR(60) NOT NULL,
                             flag INTEGER NOT NULL,
                             version NVARCHAR(60) NOT NULL,
                             extid BINARY(16) NOT NULL,
                             timestamp DATETIME2 NOT NULL,
                             CONSTRAINT PK_library PRIMARY KEY (libid));
ALTER TABLE ADOxx.library ADD CONSTRAINT fklib_ctdef FOREIGN KEY (contextdefid) REFERENCES ADOxx.contextdef (contextdefid) ON DELETE SET NULL;

CREATE TABLE ADOxx.library_log (changeid BINARY(16) NOT NULL,
                              libid BINARY(16) NOT NULL,
                              type SMALLINT NOT NULL,
                              metadata NVARCHAR(MAX),
                              data IMAGE,
                              flag INTEGER NOT NULL,
                              author NVARCHAR(MAX) NOT NULL,
                              timestamp TIMESTAMP NOT NULL,
                              CONSTRAINT PK_library_log PRIMARY KEY (changeid));


CREATE TABLE ADOxx.liblang(libid BINARY(16) NOT NULL,
                             langid NVARCHAR(60) NOT NULL,
                             indx SMALLINT NOT NULL,
                             CONSTRAINT PK_liblang PRIMARY KEY (libid,langid));
CREATE INDEX iliblang ON ADOxx.liblang (libid,indx);
ALTER TABLE ADOxx.liblang ADD CONSTRAINT fkliblang_lib FOREIGN KEY (libid) REFERENCES ADOxx.library (libid) ON DELETE CASCADE;

CREATE TABLE ADOxx.name(objid BINARY(16) NOT NULL,
                          indx INTEGER NOT NULL,
                          name NVARCHAR(3750),
                          CONSTRAINT PK_name PRIMARY KEY (objid,indx));
CREATE INDEX inames_indx ON ADOxx.name (indx);

CREATE TABLE ADOxx.identifiertext(objid BINARY(16) NOT NULL,
                                    langid NVARCHAR(60) NOT NULL,
                                    modtime INTEGER NOT NULL,
                                    indx INTEGER NOT NULL,
                                    text NVARCHAR(3750),
                                    longtext NVARCHAR(MAX),
                                    CONSTRAINT PK_identifiertext PRIMARY KEY (objid,langid,indx));
CREATE INDEX iidtfrs_indx ON ADOxx.identifiertext (indx);

CREATE TABLE ADOxx.libobjs(libid BINARY(16) NOT NULL,
                             objid BINARY(16) NOT NULL,
                             srclibid BINARY(16) NOT NULL,
                             lookupobjid BINARY(16) NOT NULL,
                             CONSTRAINT PK_libobjs PRIMARY KEY (libid,objid));
ALTER TABLE ADOxx.libobjs ADD CONSTRAINT fklibobjs_lib FOREIGN KEY (libid) REFERENCES ADOxx.library (libid) ON DELETE CASCADE;
CREATE INDEX ilibobjs_objid ON ADOxx.libobjs (objid);

CREATE TABLE ADOxx.direct_libobjs(libid BINARY(16) NOT NULL,
                                    objid BINARY(16) NOT NULL,
                                    CONSTRAINT PK_direct_libobjs PRIMARY KEY (libid,objid));
ALTER TABLE ADOxx.direct_libobjs ADD CONSTRAINT fkdlibobjs_lib FOREIGN KEY (libid) REFERENCES ADOxx.library (libid) ON DELETE CASCADE;
CREATE INDEX idlibobjs_objid ON ADOxx.direct_libobjs (objid);

CREATE TABLE ADOxx.deplibs(libid BINARY(16) NOT NULL,
                             deplibid BINARY(16) NOT NULL,
                             CONSTRAINT PK_deplibs PRIMARY KEY (libid,deplibid));
ALTER TABLE ADOxx.deplibs ADD CONSTRAINT fkdeplibs_lib FOREIGN KEY (libid) REFERENCES ADOxx.library (libid) ON DELETE CASCADE;
CREATE INDEX iddeplibs_deplibid ON ADOxx.deplibs (deplibid);

CREATE TABLE ADOxx.globlibid(libid BINARY(16) NOT NULL,
                               globid BINARY(16) NOT NULL,
                               indx INTEGER NOT NULL,
                               CONSTRAINT PK_globlibid PRIMARY KEY (libid,globid));
ALTER TABLE ADOxx.globlibid ADD CONSTRAINT fgllibids_lib FOREIGN KEY (libid) REFERENCES ADOxx.library (libid) ON DELETE CASCADE;
CREATE INDEX igllibids_indx ON ADOxx.globlibid (indx);

CREATE TABLE ADOxx.modeltype(modtypeid BINARY(16) NOT NULL,
                               contextdefid BINARY(16) NULL,
                               flag INTEGER NOT NULL,
                               isvisible TINYINT NOT NULL,
                               defaultmodusid BINARY(16) NOT NULL,
                               CONSTRAINT PK_modeltype PRIMARY KEY (modtypeid));
ALTER TABLE ADOxx.modeltype ADD CONSTRAINT fkmt_ctdef FOREIGN KEY (contextdefid) REFERENCES ADOxx.contextdef (contextdefid) ON DELETE SET NULL;

CREATE TABLE ADOxx.class(classid BINARY(16) NOT NULL,
                           superclassid BINARY(16) NOT NULL,
                           type SMALLINT NOT NULL,
                           isabstract TINYINT NOT NULL,
                           isvisible TINYINT NOT NULL,
                           ismodctxtspec TINYINT NOT NULL,
                           flag INTEGER NOT NULL,
                           CONSTRAINT PK_class PRIMARY KEY (classid));
CREATE INDEX iclass_super ON ADOxx.class (superclassid);

CREATE TABLE ADOxx.classtomodtype(modtypeid BINARY(16) NOT NULL,
                                    classid BINARY(16) NOT NULL,
                                    CONSTRAINT PK_classtomodtype PRIMARY KEY (modtypeid, classid));

CREATE TABLE ADOxx.modus(modusid BINARY(16) NOT NULL,
                           modtypeid BINARY(16) NOT NULL,
                           flag INTEGER NOT NULL,
                           isvisible TINYINT NOT NULL,
                           CONSTRAINT PK_modus PRIMARY KEY (modusid));

CREATE TABLE ADOxx.classtomodus(modusid BINARY(16) NOT NULL,
                                  classid BINARY(16) NOT NULL,
                                  CONSTRAINT PK_classtomodus PRIMARY KEY (modusid, classid));

CREATE TABLE ADOxx.endpointdef(endpointdefid BINARY(16) NOT NULL,
                                 isvisible TINYINT NOT NULL,
                                 flag INTEGER NOT NULL,
                                 direction INTEGER NOT NULL,
                                 CONSTRAINT PK_endpointdef PRIMARY KEY (endpointdefid));

CREATE TABLE ADOxx.cardinality(endpointdefid BINARY(16) NOT NULL,
                                 objectid BINARY(16) NOT NULL,
                                 type SMALLINT NOT NULL,
                                 mincard INTEGER NOT NULL,
                                 maxcard INTEGER NOT NULL,
                                 flag INTEGER NOT NULL,
                                 CONSTRAINT PK_cardinality PRIMARY KEY (endpointdefid,objectid,type));

CREATE TABLE ADOxx.endpointrestrict(relclassid BINARY(16) NOT NULL,
                                      indx SMALLINT NOT NULL,
                                      endpointdefid BINARY(16) NOT NULL,
                                      classid BINARY(16) NOT NULL,
                                      CONSTRAINT PK_endpointrestrict PRIMARY KEY (relclassid,indx,endpointdefid,classid));

CREATE TABLE ADOxx.attrvaltype(rootid BINARY(16) NOT NULL,
                                 attrvaltypeid BINARY(16) NOT NULL,
                                 directparentid BINARY(16) NOT NULL,
                                 dbtype SMALLINT NOT NULL,
                                 indx INTEGER NOT NULL,
                                 CONSTRAINT PK_attrvaltype PRIMARY KEY (attrvaltypeid));
CREATE INDEX iavtyp_root ON ADOxx.attrvaltype (rootid);
CREATE INDEX iavtyp_order ON ADOxx.attrvaltype (rootid,directparentid,indx);

CREATE TABLE ADOxx.attrtype(attrtypeid BINARY(16) NOT NULL,
                              dbtype SMALLINT NOT NULL,
                              rootatvaltypeid BINARY(16) NOT NULL,
                              CONSTRAINT PK_attrtype PRIMARY KEY (attrtypeid));
CREATE UNIQUE INDEX iattrtype_root ON ADOxx.attrtype (rootatvaltypeid);

CREATE TABLE ADOxx.attrdef(attrdefid BINARY(16) NOT NULL,
                             attrtypeid BINARY(16) NOT NULL,
                             instattr TINYINT NOT NULL,
                             ismodctxtspec TINYINT NOT NULL,
                             islanginvariant TINYINT NOT NULL,
                             flag INTEGER NOT NULL,
                             CONSTRAINT PK_attrdef PRIMARY KEY (attrdefid));

CREATE TABLE ADOxx.objattrdefs(objid BINARY(16) NOT NULL,
                                 attrdefid BINARY(16) NOT NULL,
                                 type SMALLINT NOT NULL,
                                 CONSTRAINT PK_objattrdefs PRIMARY KEY (objid,attrdefid));

CREATE TABLE ADOxx.paramdomain(paramid BINARY(16) NOT NULL,
                                 priority INTEGER NOT NULL,
                                 intval INTEGER,
                                 doubleval DECIMAL(28,6),
                                 text NVARCHAR(3750),
                                 CONSTRAINT PK_paramdomain PRIMARY KEY (paramid,priority));
ALTER TABLE ADOxx.paramdomain ADD CONSTRAINT fkparamdom_cparam FOREIGN KEY (paramid) REFERENCES ADOxx.contextparam (paramid) ON DELETE CASCADE;
CREATE INDEX ipdoms_paramid ON ADOxx.paramdomain (paramid);
CREATE INDEX ipdoms_prior ON ADOxx.paramdomain (priority);

CREATE TABLE ADOxx.repository(repoid BINARY(16) NOT NULL,
                                realrepoid INTEGER IDENTITY(0, 1) NOT NULL,
                                CONSTRAINT PK_repository PRIMARY KEY (realrepoid));
CREATE UNIQUE INDEX irepo_repoid ON ADOxx.repository (repoid);

CREATE TABLE ADOxx.ci_repoobjs(repoid INTEGER NOT NULL,
                                 ctxtinstid BINARY(16) NOT NULL,
                                 realctxtinstid INTEGER IDENTITY(-2147483500, 1) NOT NULL,
                                 CONSTRAINT PK_ci_repoobjs PRIMARY KEY (realctxtinstid));
CREATE UNIQUE INDEX iciro_repo_ctxtid ON ADOxx.ci_repoobjs (repoid,ctxtinstid);

CREATE TABLE ADOxx.contextinst(ctxtinstid INTEGER NOT NULL,
                                 paramid BINARY(16) NOT NULL,
                                 owner BINARY(16) NOT NULL,
                                 intval INTEGER,
                                 doubleval DECIMAL(28,6),
                                 text NVARCHAR(3750),
                                 CONSTRAINT PK_contextinst PRIMARY KEY (ctxtinstid,paramid));
ALTER TABLE ADOxx.contextinst ADD CONSTRAINT fkctxtinst_cparam FOREIGN KEY (paramid) REFERENCES ADOxx.contextparam (paramid);
CREATE INDEX ictxti_owner ON ADOxx.contextinst (owner);
CREATE INDEX ictxti_parid ON ADOxx.contextinst (paramid);

CREATE TABLE ADOxx.mod_repoobjs(repoid INTEGER NOT NULL,
                                  modelid BINARY(16) NOT NULL,
                                  realmodelid INTEGER IDENTITY(-2147483500, 1) NOT NULL,
                                  CONSTRAINT PK_mod_repoobjs PRIMARY KEY (realmodelid));
CREATE UNIQUE INDEX imodro_repo_modid ON ADOxx.mod_repoobjs (repoid,modelid);

CREATE TABLE ADOxx.model(modelid INTEGER NOT NULL,
                           modtypeid BINARY(16) NOT NULL,
                           creationtime DATETIME2 NOT NULL CONSTRAINT DF_model_creationtime DEFAULT SYSUTCDATETIME(),
                           CONSTRAINT PK_model PRIMARY KEY (modelid));
CREATE INDEX imodel_model_modtype ON ADOxx.model (modelid,modtypeid);

CREATE TABLE ADOxx.ri_repoobjs(repoid INTEGER NOT NULL,
                                 repoinstid BINARY(16) NOT NULL,
                                 realrepoinstid INTEGER IDENTITY(-2147483500, 1) NOT NULL,
                                 srcrepoid INTEGER NOT NULL,
                                 CONSTRAINT PK_ri_repoobjs PRIMARY KEY (repoid,repoinstid));
CREATE INDEX iriro_realobjid ON ADOxx.ri_repoobjs (repoid,realrepoinstid);
CREATE INDEX iriro_realid ON ADOxx.ri_repoobjs (realrepoinstid);
CREATE INDEX iriro_srcrepoid ON ADOxx.ri_repoobjs (srcrepoid);

CREATE TABLE ADOxx.repoinst(repoinstid INTEGER NOT NULL,
                              classid BINARY(16) NOT NULL,
                              creationtime DATETIME2 NOT NULL CONSTRAINT DF_repoinst_creationtime DEFAULT SYSUTCDATETIME(),
                              CONSTRAINT PK_repoinst PRIMARY KEY (repoinstid));
CREATE INDEX irepoinst_class ON ADOxx.repoinst (classid);
CREATE INDEX irepoinst_riid_class ON ADOxx.repoinst (repoinstid,classid);

CREATE TABLE ADOxx.mi_repoobjs(repoid INTEGER NOT NULL,
                                 modinstid BINARY(16) NOT NULL,
                                 realmodinstid INTEGER IDENTITY(-2147483500, 1) NOT NULL,
                                 actiontime DATETIME2 NOT NULL CONSTRAINT DF_mi_repoobjs_actiontime DEFAULT CONVERT(DATETIME2,'1900-01-01 00:00:00',120),
                                 CONSTRAINT PK_mi_repoobjs PRIMARY KEY (realmodinstid));
CREATE UNIQUE INDEX imiro_repo_miid ON ADOxx.mi_repoobjs (repoid,modinstid);
CREATE UNIQUE INDEX imiro_repo_acttime_realid ON ADOxx.mi_repoobjs (repoid,actiontime,realmodinstid);

CREATE TABLE ADOxx.modelinst(modinstid INTEGER NOT NULL,
                               repoinstid BINARY(16) NOT NULL,
                               modelid BINARY(16) NOT NULL,
                               originid BINARY(16) NOT NULL,
                               CONSTRAINT PK_modelinst PRIMARY KEY (modinstid));
CREATE INDEX imodelinst_riid ON ADOxx.modelinst (repoinstid);
CREATE INDEX imodelinst_mid_riid ON ADOxx.modelinst (modelid,repoinstid);

CREATE TABLE ADOxx.ctxtinstobjs(ctxtinstid INTEGER NOT NULL,
                                  objid BINARY(16) NOT NULL,
                                  CONSTRAINT PK_ctxtinstobjs PRIMARY KEY (ctxtinstid,objid));
CREATE INDEX ictiobjs_obj ON ADOxx.ctxtinstobjs (objid);

CREATE TABLE ADOxx.locks(repoid BINARY(16) NOT NULL,
                           objid BINARY(16) NOT NULL,
                           userid BINARY(16) NOT NULL,
                           sessionid BINARY(16) NOT NULL,
                           type SMALLINT NOT NULL,
                           locktime DATETIME2 NOT NULL,
                           xdata BINARY(16) NOT NULL,
                           persist TINYINT NOT NULL,
                           CONSTRAINT PK_locks PRIMARY KEY (repoid,objid,sessionid,type));
CREATE UNIQUE INDEX locks_objtype ON ADOxx.locks (repoid,objid,type,xdata);
--CREATE INDEX ilocks_session_persist ON ADOxx.locks (sessionid,persist);

CREATE TABLE ADOxx.hg_repoobjs(repoid INTEGER NOT NULL,
                                 groupid BINARY(16) NOT NULL,
                                 realgroupid BINARY(16) NOT NULL,
                                 supergroupid BINARY(16) NOT NULL,
                                 CONSTRAINT PK_hg_repoobjs PRIMARY KEY (realgroupid));
CREATE UNIQUE INDEX ihgro_repo_groupid ON ADOxx.hg_repoobjs (repoid,groupid);

CREATE TABLE ADOxx.hiergroup_ctxtspec(groupid BINARY(16) NOT NULL,
                                        supergroupid BINARY(16) NOT NULL,
                                        type SMALLINT NOT NULL,
                                        CONSTRAINT PK_hiergroup_ctxtspec PRIMARY KEY (groupid));
CREATE INDEX ihgr_cs_super ON ADOxx.hiergroup_ctxtspec (supergroupid);
CREATE INDEX ihgr_cs_type_groupid ON ADOxx.hiergroup_ctxtspec (type,groupid);

CREATE TABLE ADOxx.groupobjsctxtspec(groupid BINARY(16) NOT NULL,
                                       objid BINARY(16) NOT NULL,
                                       CONSTRAINT PK_groupobjsctxtspec PRIMARY KEY (groupid,objid));
ALTER TABLE ADOxx.groupobjsctxtspec ADD CONSTRAINT fkgrobjs_cs_group FOREIGN KEY (groupid) REFERENCES ADOxx.hiergroup_ctxtspec (groupid) ON DELETE CASCADE;
CREATE INDEX igrobjs_cs_objid ON ADOxx.groupobjsctxtspec (objid);

CREATE TABLE ADOxx.relepi_repoobjs(repoid INTEGER NOT NULL,
                                     relepiid BINARY(16) NOT NULL,
                                     realrelepiid INTEGER IDENTITY(-2147483500, 1) NOT NULL,
                                     CONSTRAINT PK_relepi_repoobjs PRIMARY KEY (realrelepiid));
CREATE UNIQUE INDEX irepiro_repo_relepid ON ADOxx.relepi_repoobjs (repoid,relepiid);
CREATE UNIQUE INDEX irepiro_realid ON ADOxx.relepi_repoobjs (realrelepiid,repoid);

CREATE TABLE ADOxx.relendpntinst(relepiid INTEGER NOT NULL,
                                   epdefid BINARY(16) NOT NULL,
                                   ownerid BINARY(16) NOT NULL,
                                   ownertype SMALLINT NOT NULL,
                                   ownerclassid BINARY(16) NOT NULL,
                                   targetinstid BINARY(16) NOT NULL,
                                   targettype SMALLINT NOT NULL,
                                   twinepid BINARY(16) NOT NULL,
                                   proxyid BINARY(16) NOT NULL,
                                   broken TINYINT NOT NULL,
                                   targetclassid BINARY(16) NOT NULL,
                                   contextinstid BINARY(16),
                                   modelid BINARY(16),
                                   modeltypeid BINARY(16),
                                   CONSTRAINT PK_relendpntinst PRIMARY KEY (relepiid));
CREATE INDEX irelepi_tgtid ON ADOxx.relendpntinst (targetinstid,broken);
CREATE INDEX irelepi_ownerid ON ADOxx.relendpntinst (ownerid,ownertype);
CREATE INDEX irelepi_twinownertype ON ADOxx.relendpntinst (twinepid,ownertype);
CREATE INDEX irelepi_model ON ADOxx.relendpntinst (modelid);
-- statistics only to support better cardinality estimation
CREATE STATISTICS stat_relepi_ownertype_invalidtwin ON ADOxx.relendpntinst (ownertype) WHERE (twinepid=0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF) WITH FULLSCAN;

CREATE TABLE ADOxx.instancename(repoid INTEGER NOT NULL,
                                  instid BINARY(16) NOT NULL,
                                  names NVARCHAR(MAX) NOT NULL,
                                  actiontime DATETIME2 NOT NULL CONSTRAINT DF_instancename_actiontime DEFAULT SYSUTCDATETIME(),
                                  CONSTRAINT PK_instancename PRIMARY KEY (repoid,instid));
CREATE INDEX iiname_acttime_repoid_instid ON ADOxx.instancename (actiontime,repoid,instid);

CREATE TABLE ADOxx.valowner_lib(ownerid BINARY(16) NOT NULL,
                                  defid BINARY(16) NOT NULL,
                                  rootatvaltypeid BINARY(16) NOT NULL,
                                  iscomplex TINYINT NOT NULL,
                                  CONSTRAINT PK_valowner_lib PRIMARY KEY (ownerid, defid));
CREATE INDEX ivalolib_defid ON ADOxx.valowner_lib (defid);

CREATE TABLE ADOxx.valowner_mod(ownerid INTEGER NOT NULL,
                                  defid BINARY(16) NOT NULL,
                                  rootatvaltypeid BINARY(16) NOT NULL,
                                  iscomplex TINYINT NOT NULL,
                                  CONSTRAINT PK_valowner_mod PRIMARY KEY (ownerid, defid));
CREATE INDEX ivalomod_defid ON ADOxx.valowner_mod (defid);

CREATE TABLE ADOxx.valowner_ri(ownerid INTEGER NOT NULL,
                                 defid BINARY(16) NOT NULL,
                                 rootatvaltypeid BINARY(16) NOT NULL,
                                 iscomplex TINYINT NOT NULL,
                                 CONSTRAINT PK_valowner_ri PRIMARY KEY (ownerid, defid));
CREATE INDEX ivalori_defid ON ADOxx.valowner_ri (defid);

CREATE TABLE ADOxx.valowner_mi(ownerid INTEGER NOT NULL,
                                 defid BINARY(16) NOT NULL,
                                 rootatvaltypeid BINARY(16) NOT NULL,
                                 iscomplex TINYINT NOT NULL,
                                 CONSTRAINT PK_valowner_mi PRIMARY KEY (ownerid, defid));
CREATE INDEX ivalomi_defid ON ADOxx.valowner_mi (defid);

CREATE TABLE ADOxx.valowner_relepi(ownerid INTEGER NOT NULL,
                                     defid BINARY(16) NOT NULL,
                                     rootatvaltypeid BINARY(16) NOT NULL,
                                     iscomplex TINYINT NOT NULL,
                                     CONSTRAINT PK_valowner_relepi PRIMARY KEY (ownerid, defid));
CREATE INDEX ivalorelepi_defid ON ADOxx.valowner_relepi (defid);

CREATE TABLE ADOxx.sval_mod(ownerid INTEGER NOT NULL,
                              defid BINARY(16) NOT NULL,
                              ctxtinstid INTEGER NOT NULL,
                              creationid BINARY(16) NOT NULL,
                              modtime INTEGER,
                              intval INTEGER,
                              doubleval DECIMAL(28,6),
                              strval NVARCHAR(3750),
                              longstrval NVARCHAR(MAX),
                              metaval NVARCHAR(MAX),
                              flag INTEGER NOT NULL,
                              CONSTRAINT PK_sval_mod PRIMARY KEY (ownerid,defid,ctxtinstid));
ALTER TABLE ADOxx.sval_mod ADD CONSTRAINT fksval_mod FOREIGN KEY (ownerid,defid) REFERENCES ADOxx.valowner_mod (ownerid,defid) ON DELETE CASCADE;
CREATE INDEX isvalmod_ctxt ON ADOxx.sval_mod (ctxtinstid);

CREATE TABLE ADOxx.sval_ri(ownerid INTEGER NOT NULL,
                             defid BINARY(16) NOT NULL,
                             ctxtinstid INTEGER NOT NULL,
                             creationid BINARY(16) NOT NULL,
                             modtime INTEGER,
                             intval INTEGER,
                             doubleval DECIMAL(28,6),
                             strval NVARCHAR(3750),
                             longstrval NVARCHAR(MAX),
                             metaval NVARCHAR(MAX),
                             flag INTEGER NOT NULL,
                             CONSTRAINT PK_sval_ri PRIMARY KEY (ownerid,defid,ctxtinstid));
ALTER TABLE ADOxx.sval_ri ADD CONSTRAINT fksval_ri FOREIGN KEY (ownerid,defid) REFERENCES ADOxx.valowner_ri (ownerid,defid) ON DELETE CASCADE;
CREATE INDEX isvalri_ctxt ON ADOxx.sval_ri (ctxtinstid);

CREATE TABLE ADOxx.sval_mi(ownerid INTEGER NOT NULL,
                             defid BINARY(16) NOT NULL,
                             ctxtinstid INTEGER NOT NULL,
                             creationid BINARY(16) NOT NULL,
                             modtime INTEGER,
                             intval INTEGER,
                             doubleval DECIMAL(28,6),
                             strval NVARCHAR(3750),
                             longstrval NVARCHAR(MAX),
                             metaval NVARCHAR(MAX),
                             flag INTEGER NOT NULL,
                             CONSTRAINT PK_sval_mi PRIMARY KEY (ownerid,defid,ctxtinstid));
ALTER TABLE ADOxx.sval_mi ADD CONSTRAINT fksval_mi FOREIGN KEY (ownerid,defid) REFERENCES ADOxx.valowner_mi (ownerid,defid) ON DELETE CASCADE;
CREATE INDEX isvalmi_ctxt ON ADOxx.sval_mi (ctxtinstid);

CREATE TABLE ADOxx.sval_relepi(ownerid INTEGER NOT NULL,
                                 defid BINARY(16) NOT NULL,
                                 ctxtinstid INTEGER NOT NULL,
                                 creationid BINARY(16) NOT NULL,
                                 modtime INTEGER,
                                 intval INTEGER,
                                 doubleval DECIMAL(28,6),
                                 strval NVARCHAR(3750),
                                 longstrval NVARCHAR(MAX),
                                 metaval NVARCHAR(MAX),
                                 flag INTEGER NOT NULL,
                                 actiontime DATETIME2 NOT NULL CONSTRAINT DF_sval_relepi_actiontime DEFAULT SYSUTCDATETIME(),
                                 CONSTRAINT PK_sval_relepi PRIMARY KEY (ownerid,defid,ctxtinstid));
ALTER TABLE ADOxx.sval_relepi ADD CONSTRAINT fksval_relepi FOREIGN KEY (ownerid,defid) REFERENCES ADOxx.valowner_relepi (ownerid,defid) ON DELETE CASCADE;
CREATE INDEX isvalrelepi_ctxt ON ADOxx.sval_relepi (ctxtinstid);

CREATE TABLE ADOxx.simpleval_defval(valid BINARY(16) NOT NULL,
                                      ownerid BINARY(16) NOT NULL,
                                      langid VARCHAR(60) NOT NULL,
                                      defid BINARY(16) NOT NULL,
                                      creationid BINARY(16) NOT NULL,
                                      modtime INTEGER,
                                      intval INTEGER,
                                      doubleval DECIMAL(28,6),
                                      strval NVARCHAR(3750),
                                      longstrval NVARCHAR(MAX),
                                      metaval NVARCHAR(MAX),
                                      flag INTEGER NOT NULL,
                                      CONSTRAINT PK_simpleval_defval PRIMARY KEY (valid, langid));
ALTER TABLE ADOxx.simpleval_defval ADD CONSTRAINT fksvaldfval FOREIGN KEY (ownerid,defid) REFERENCES ADOxx.valowner_lib (ownerid,defid) ON DELETE CASCADE;
CREATE INDEX isvaldfval_owner ON ADOxx.simpleval_defval (ownerid,defid);

CREATE TABLE ADOxx.cval_mod(valid BINARY(16) NOT NULL,
                              ownerid INTEGER NOT NULL,
                              defid BINARY(16) NOT NULL,
                              ctxtinstid INTEGER NOT NULL,
                              attrvaltypeid BINARY(16) NOT NULL,
                              preid BINARY(16) NOT NULL,
                              iscmplx TINYINT NOT NULL,
                              creationid BINARY(16) NOT NULL,
                              modtime INTEGER,
                              creationtime INTEGER,
                              intval INTEGER,
                              doubleval DECIMAL(28,6),
                              strval NVARCHAR(3750),
                              longstrval NVARCHAR(MAX),
                              flag INTEGER NOT NULL,
                              CONSTRAINT PK_cval_mod PRIMARY KEY NONCLUSTERED (valid));
ALTER TABLE ADOxx.cval_mod ADD CONSTRAINT fkcvalmod FOREIGN KEY (ownerid,defid) REFERENCES ADOxx.valowner_mod (ownerid,defid) ON DELETE CASCADE;
CREATE CLUSTERED INDEX cix_cvalmod_owner_ctxt ON ADOxx.cval_mod (ownerid,defid,ctxtinstid);
CREATE INDEX icvalmod_ctxt ON ADOxx.cval_mod (ctxtinstid);

CREATE TABLE ADOxx.cval_ri(valid BINARY(16) NOT NULL,
                             ownerid INTEGER NOT NULL,
                             defid BINARY(16) NOT NULL,
                             ctxtinstid INTEGER NOT NULL,
                             attrvaltypeid BINARY(16) NOT NULL,
                             preid BINARY(16) NOT NULL,
                             iscmplx TINYINT NOT NULL,
                             creationid BINARY(16) NOT NULL,
                             modtime INTEGER,
                             creationtime INTEGER,
                             intval INTEGER,
                             doubleval DECIMAL(28,6),
                             strval NVARCHAR(3750),
                             longstrval NVARCHAR(MAX),
                             flag INTEGER NOT NULL,
                             CONSTRAINT PK_cval_ri PRIMARY KEY NONCLUSTERED (valid));
ALTER TABLE ADOxx.cval_ri ADD CONSTRAINT fkcvalri FOREIGN KEY (ownerid,defid) REFERENCES ADOxx.valowner_ri (ownerid,defid) ON DELETE CASCADE;
CREATE CLUSTERED INDEX cix_cvalri_owner_ctxt ON ADOxx.cval_ri (ownerid,defid,ctxtinstid);
CREATE INDEX icvalri_ctxt ON ADOxx.cval_ri (ctxtinstid);

CREATE TABLE ADOxx.cval_mi(valid BINARY(16) NOT NULL,
                             ownerid INTEGER NOT NULL,
                             defid BINARY(16) NOT NULL,
                             ctxtinstid INTEGER NOT NULL,
                             attrvaltypeid BINARY(16) NOT NULL,
                             preid BINARY(16) NOT NULL,
                             iscmplx TINYINT NOT NULL,
                             creationid BINARY(16) NOT NULL,
                             modtime INTEGER,
                             creationtime INTEGER,
                             intval INTEGER,
                             doubleval DECIMAL(28,6),
                             strval NVARCHAR(3750),
                             longstrval NVARCHAR(MAX),
                             flag INTEGER NOT NULL,
                             CONSTRAINT PK_cval_mi PRIMARY KEY NONCLUSTERED (valid));
ALTER TABLE ADOxx.cval_mi ADD CONSTRAINT fkcvalmi FOREIGN KEY (ownerid,defid) REFERENCES ADOxx.valowner_mi (ownerid,defid) ON DELETE CASCADE;
CREATE CLUSTERED INDEX cix_cvalmi_owner_ctxt ON ADOxx.cval_mi (ownerid,defid,ctxtinstid);
CREATE INDEX icvalmi_ctxt ON ADOxx.cval_mi (ctxtinstid);

CREATE TABLE ADOxx.cval_relepi(valid BINARY(16) NOT NULL,
                                 ownerid INTEGER NOT NULL,
                                 defid BINARY(16) NOT NULL,
                                 ctxtinstid INTEGER NOT NULL,
                                 attrvaltypeid BINARY(16) NOT NULL,
                                 preid BINARY(16) NOT NULL,
                                 iscmplx TINYINT NOT NULL,
                                 creationid BINARY(16) NOT NULL,
                                 modtime INTEGER,
                                 creationtime INTEGER,
                                 intval INTEGER,
                                 doubleval DECIMAL(28,6),
                                 strval NVARCHAR(3750),
                                 longstrval NVARCHAR(MAX),
                                 flag INTEGER NOT NULL,
                                 CONSTRAINT PK_cval_relepi PRIMARY KEY NONCLUSTERED (valid));
ALTER TABLE ADOxx.cval_relepi ADD CONSTRAINT fkcvalrelepi FOREIGN KEY (ownerid,defid) REFERENCES ADOxx.valowner_relepi (ownerid,defid) ON DELETE CASCADE;
CREATE CLUSTERED INDEX cix_cvalrelepi_owner_ctxt ON ADOxx.cval_relepi (ownerid,defid,ctxtinstid);
CREATE INDEX icvalrelepi_ctxt ON ADOxx.cval_relepi (ctxtinstid);

CREATE TABLE ADOxx.complexval_defval(valid BINARY(16) NOT NULL,
                                       ownerid BINARY(16) NOT NULL,
                                       langid VARCHAR(60) NOT NULL,
                                       defid BINARY(16) NOT NULL,
                                       attrvaltypeid BINARY(16) NOT NULL,
                                       preid BINARY(16) NOT NULL,
                                       iscmplx TINYINT NOT NULL,
                                       creationid BINARY(16) NOT NULL,
                                       modtime INTEGER,
                                       creationtime INTEGER,
                                       intval INTEGER,
                                       doubleval DECIMAL(28,6),
                                       strval NVARCHAR(3750),
                                       longstrval NVARCHAR(MAX),
                                       flag INTEGER NOT NULL,
                                       CONSTRAINT PK_complexval_defval PRIMARY KEY NONCLUSTERED (valid, langid));
ALTER TABLE ADOxx.complexval_defval ADD CONSTRAINT fkcdefval FOREIGN KEY (ownerid,defid) REFERENCES ADOxx.valowner_lib (ownerid,defid) ON DELETE CASCADE;
CREATE CLUSTERED INDEX cix_cdefval_owner ON ADOxx.complexval_defval (ownerid,defid);

CREATE TABLE ADOxx.permissions(actorid BINARY(16) NOT NULL,
                                 actionid BINARY(16) NOT NULL,
                                 contextid BINARY(16) NOT NULL,
                                 objectid BINARY(16) NOT NULL,
                                 state SMALLINT NOT NULL,
                                 CONSTRAINT PK_permissions PRIMARY KEY (actorid, actionid, contextid, objectid));
CREATE INDEX permissions_objectid ON ADOxx.permissions (objectid);
CREATE INDEX permissions_actionid ON ADOxx.permissions (actionid);

CREATE TABLE ADOxx.role_mfb(roleid BINARY(16) NOT NULL,
                              mfbid BINARY(16) NOT NULL,
                              rolename NVARCHAR(255) NOT NULL,
                              registered TINYINT NOT NULL,
                              json NVARCHAR(MAX) NULL,
                              CONSTRAINT PK_role_mfb PRIMARY KEY (roleid));
CREATE UNIQUE INDEX irole_mfbid_rolename ON ADOxx.role_mfb (mfbid,rolename);

CREATE TABLE ADOxx.rolemember(roleid BINARY(16) NOT NULL,
                                memberid BINARY(16) NOT NULL,
                                isgroup TINYINT NOT NULL,
                                CONSTRAINT PK_rolemember PRIMARY KEY (roleid, memberid, isgroup),
                                CONSTRAINT FK_rolemember_role_roleid FOREIGN KEY (roleid) REFERENCES ADOxx.role_mfb (roleid) ON DELETE CASCADE);
CREATE INDEX irm_member ON ADOxx.rolemember (memberid,isgroup);

CREATE TABLE ADOxx.metamodelright(roleid BINARY(16) NOT NULL,
                                  actionid BINARY(16) NOT NULL,
                                  targetid BINARY(16) NOT NULL,
                                  targetctxtid BINARY(16) NOT NULL,
                                  subid1 BINARY(16) NOT NULL,
                                  subid2 BINARY(16) NOT NULL,
                                  state TINYINT NOT NULL,
                                  CONSTRAINT PK_metamodelright PRIMARY KEY (roleid,actionid,targetid,targetctxtid,subid1,subid2),
                                  CONSTRAINT FK_metamodelright_role_roleid FOREIGN KEY (roleid) REFERENCES ADOxx.role_mfb (roleid) ON DELETE CASCADE);
CREATE INDEX immr_target ON ADOxx.metamodelright (targetid,targetctxtid);
CREATE INDEX immr_targetctxt ON ADOxx.metamodelright (targetctxtid);

CREATE TABLE ADOxx.activities(trackedaction SMALLINT NOT NULL,
                                contextid BINARY(16) NOT NULL,
                                instanceid BINARY(16) NOT NULL,
                                classoractorid BINARY(16) NOT NULL,
                                actionid BINARY(16) NOT NULL,
                                sessionid BINARY(16) NOT NULL,
                                actiontime DATETIME2 NOT NULL,
                                flag SMALLINT NULL,
                                CONSTRAINT PK_activities PRIMARY KEY (trackedaction,contextid,classoractorid,instanceid,actionid));
CREATE INDEX iact_acttime ON ADOxx.activities (actiontime);
CREATE INDEX iact_tract_acttime ON ADOxx.activities (trackedaction,actiontime);

CREATE TABLE ADOxx.admin_change_transact(transactid BINARY(16) NOT NULL,
                                           author NVARCHAR(440) NOT NULL,
                                           logversion SMALLINT NOT NULL,
                                           CONSTRAINT PK_admin_change_transact PRIMARY KEY (transactid));
CREATE INDEX iatr_author ON ADOxx.admin_change_transact (author);

CREATE TABLE ADOxx.admin_change_history(transactid BINARY(16) NOT NULL,
                                        actionorder BIGINT IDENTITY(-9223372036854775808, 1) NOT NULL,
                                        actiontime DATETIME2 NOT NULL,
                                        actiontype INTEGER NOT NULL,
                                        actortype TINYINT NULL,
                                        actor NVARCHAR(440) NULL,
                                        target NVARCHAR(3750) NULL,
                                        globalctxtid BINARY(16) NULL,
                                        localctxt NVARCHAR(3750) NULL,
                                        langid VARCHAR(10) NULL,
                                        oldvalue NVARCHAR(MAX) NULL,
                                        newvalue NVARCHAR(MAX) NULL,
                                        CONSTRAINT PK_admin_change_history PRIMARY KEY CLUSTERED (actionorder),
                                        CONSTRAINT FK_achist_actran_transactid FOREIGN KEY (transactid) REFERENCES ADOxx.admin_change_transact (transactid) ON DELETE CASCADE);
CREATE INDEX iach_transactid ON ADOxx.admin_change_history (transactid);
CREATE INDEX iach_actiontype ON ADOxx.admin_change_history (actiontype);
CREATE INDEX iach_actiontime ON ADOxx.admin_change_history (actiontime);
CREATE INDEX iach_actortype_actor ON ADOxx.admin_change_history (actortype, actor);

CREATE TABLE ADOxx.admin_change_transact_arch(transactid BINARY(16) NOT NULL,
                                                author NVARCHAR(440) NOT NULL,
                                                logversion SMALLINT NOT NULL,
                                                CONSTRAINT PK_admin_change_transact_arch PRIMARY KEY (transactid));
CREATE INDEX iatr_author_arch ON ADOxx.admin_change_transact_arch (author);

CREATE TABLE ADOxx.admin_change_history_arch(transactid BINARY(16) NOT NULL,
                                               actionorder BIGINT NOT NULL,
                                               actiontime DATETIME2 NOT NULL,
                                               actiontype INTEGER NOT NULL,
                                               actortype TINYINT NULL,
                                               actor NVARCHAR(440) NULL,
                                               target NVARCHAR(3750) NULL,
                                               globalctxtid BINARY(16) NULL,
                                               localctxt NVARCHAR(3750) NULL,
                                               langid VARCHAR(10) NULL,
                                               oldvalue NVARCHAR(MAX) NULL,
                                               newvalue NVARCHAR(MAX) NULL,
                                               CONSTRAINT PK_admin_change_history_arch PRIMARY KEY CLUSTERED (actionorder));
CREATE INDEX iach_transactid_arch ON ADOxx.admin_change_history_arch (transactid);
CREATE INDEX iach_actiontype_arch ON ADOxx.admin_change_history_arch (actiontype);
CREATE INDEX iach_actiontime_arch ON ADOxx.admin_change_history_arch (actiontime);
CREATE INDEX iach_actortype_actor_arch ON ADOxx.admin_change_history_arch (actortype, actor);

CREATE TABLE ADOxx.directories(id BINARY(16) NOT NULL,
                                 name NVARCHAR(255) NOT NULL,
                                 parentid BINARY(16),
                                 info VARCHAR(3500),
                                 repoid INT NULL,
                                 CONSTRAINT PK_directories PRIMARY KEY (id),
                                 CONSTRAINT dir_parentdir FOREIGN KEY (parentid) REFERENCES ADOxx.directories (id)); -- ON DELETE CASCADE cannot be used, SQLServer does not allow potential cycles, code ensures consistency

CREATE UNIQUE INDEX idir_name_parentid_repoid ON ADOxx.directories (name, parentid, repoid);
--CREATE INDEX idir_parentid ON ADOxx.directories (parentid);
CREATE INDEX idir_repoid ON ADOxx.directories (repoid);

CREATE TABLE ADOxx.files(id BINARY(16) NOT NULL,
                           name NVARCHAR(255) NOT NULL,
                           parentid BINARY(16),
                           info VARCHAR(3500),
                           repoid INT NULL,
                           CONSTRAINT PK_files PRIMARY KEY (id),
                           CONSTRAINT FK_files_repo_repoid FOREIGN KEY (repoid) REFERENCES ADOxx.repository (realrepoid) ON DELETE CASCADE,
                           CONSTRAINT file_parentdir FOREIGN KEY (parentid) REFERENCES ADOxx.directories (id) ON DELETE CASCADE);
CREATE UNIQUE INDEX ifiles_name_parentid_repoid ON ADOxx.files (name, parentid, repoid);
CREATE INDEX ifiles_parentid ON ADOxx.files (parentid);
CREATE INDEX ifiles_repoid ON ADOxx.files (repoid);

CREATE TABLE ADOxx.dms_metadata(id BINARY(16) NOT NULL,
                                  repoid BINARY(16) NOT NULL,
                                  ownerid BINARY(16) NOT NULL,
                                  langid NVARCHAR(3750) NOT NULL,
                                  actiontime DATETIME2 NOT NULL CONSTRAINT DF_dms_metadata_actiontime DEFAULT SYSUTCDATETIME(),
                                  CONSTRAINT PK_dms_metadata PRIMARY KEY NONCLUSTERED (id),
                                  CONSTRAINT FK_dms_metadata_files_id FOREIGN KEY (id) REFERENCES ADOxx.files (id) ON DELETE CASCADE);
CREATE CLUSTERED INDEX cix_dms_metadata_owner_repo ON ADOxx.dms_metadata (ownerid,repoid);

CREATE TABLE ADOxx.filedata(id BINARY(16) NOT NULL,
                              sm CHAR(1),
                              data IMAGE,
                              CONSTRAINT PK_filedata PRIMARY KEY (id),
                              CONSTRAINT FK_filedata_files_id FOREIGN KEY (id) REFERENCES ADOxx.files (id) ON DELETE CASCADE);
                                  
CREATE TABLE ADOxx.generic_data(dataid BINARY(16) NOT NULL,
                              subid BINARY(16),
                              flags INTEGER NOT NULL,
                              strdata NVARCHAR(MAX),
                              bindata VARBINARY(MAX));
                                  
CREATE UNIQUE CLUSTERED INDEX cix_gendata_dataid_subid ON ADOxx.generic_data (dataid,subid);
CREATE INDEX igendata_subid ON ADOxx.generic_data (subid);

CREATE TABLE ADOxx.dep_activities(repoid INTEGER NOT NULL,
                                    relepiid BINARY(16) NOT NULL,
                                    broken TINYINT NOT NULL,
                                    epdefid BINARY(16) NOT NULL,
                                    modelid BINARY(16) NULL,
                                    modeltypeid BINARY(16) NULL,
                                    ownerid BINARY(16) NULL,
                                    ownertype SMALLINT NOT NULL,
                                    ownerclassid BINARY(16) NOT NULL,
                                    targetclassid BINARY(16) NOT NULL,
                                    targetinstid BINARY(16) NOT NULL,
                                    targettype SMALLINT NOT NULL,
                                    twinepid BINARY(16) NOT NULL,
                                    proxyid BINARY(16) NOT NULL,
                                    actiontime DATETIME2 NOT NULL,
                                    action SMALLINT NOT NULL);
CREATE CLUSTERED INDEX cix_depact_acttime ON ADOxx.dep_activities (actiontime);

CREATE TABLE ADOxx.del_val(ownerid BINARY(16) NOT NULL,
                             repoid INTEGER NOT NULL,
                             ownertype SMALLINT NOT NULL,
                             actiontime DATETIME2 NOT NULL CONSTRAINT DF_del_val_actiontime DEFAULT CONVERT(DATETIME2,'1900-01-01 00:00:00',120),
                             CONSTRAINT PK_del_val PRIMARY KEY (repoid,ownerid));
CREATE INDEX idelval_acttime ON ADOxx.del_val (actiontime);

CREATE TABLE ADOxx.delayedaction(artefactid BINARY(16) NOT NULL,
                                   repoid INT NOT NULL,
                                   actiontype SMALLINT NOT NULL,
                                   sourceid BINARY(16) NOT NULL,
                                   targetid BINARY(16) NOT NULL,
                                   actionorder INTEGER NOT NULL,
                                   actiondata NVARCHAR(3750) NULL,
                                   CONSTRAINT PK_delayedaction PRIMARY KEY NONCLUSTERED (artefactid,repoid,sourceid,actiontype));
CREATE CLUSTERED INDEX cix_dact_repo_artefact_order ON ADOxx.delayedaction (repoid,artefactid,actionorder);
CREATE INDEX idact_trgid_repoid_acttype ON ADOxx.delayedaction (targetid,repoid,actiontype);
CREATE INDEX idact_srcid_repoid ON ADOxx.delayedaction (sourceid,repoid);

-- RWF Archive Tables --> START
CREATE TABLE ADOxx.valowner_mod_arch(ownerid INTEGER NOT NULL,
                                       defid BINARY(16) NOT NULL,
                                       rootatvaltypeid BINARY(16) NOT NULL,
                                       iscomplex TINYINT NOT NULL,
                                       CONSTRAINT PK_valowner_mod_arch PRIMARY KEY (ownerid, defid),
                                       CONSTRAINT FK_vmod_arch_mod_ownerid FOREIGN KEY (ownerid) REFERENCES ADOxx.model (modelid) ON DELETE NO ACTION);
CREATE INDEX ivalomod_defid_arch ON ADOxx.valowner_mod_arch (defid);

CREATE TABLE ADOxx.valowner_ri_arch(ownerid INTEGER NOT NULL,
                                     defid BINARY(16) NOT NULL,
                                     rootatvaltypeid BINARY(16) NOT NULL,
                                     iscomplex TINYINT NOT NULL,
                                     CONSTRAINT PK_valowner_ri_arch PRIMARY KEY (ownerid, defid),
                                     CONSTRAINT FK_vri_arch_ri_ownerid FOREIGN KEY (ownerid) REFERENCES ADOxx.repoinst (repoinstid) ON DELETE NO ACTION);
CREATE INDEX ivalori_defid_arch ON ADOxx.valowner_ri_arch (defid);

CREATE TABLE ADOxx.valowner_mi_arch(ownerid INTEGER NOT NULL,
                                      defid BINARY(16) NOT NULL,
                                      rootatvaltypeid BINARY(16) NOT NULL,
                                      iscomplex TINYINT NOT NULL,
                                      CONSTRAINT PK_valowner_mi_arch PRIMARY KEY (ownerid, defid),
                                      CONSTRAINT FK_vmi_arch_mi_ownerid FOREIGN KEY (ownerid) REFERENCES ADOxx.modelinst (modinstid) ON DELETE NO ACTION);
CREATE INDEX ivalomi_defid_arch ON ADOxx.valowner_mi_arch (defid);

CREATE TABLE ADOxx.sval_mod_arch(ownerid INTEGER NOT NULL,
                                  defid BINARY(16) NOT NULL,
                                  ctxtinstid INTEGER NOT NULL,
                                  creationid BINARY(16) NOT NULL,
                                  modtime INTEGER,
                                  intval INTEGER,
                                  doubleval DECIMAL(28,6),
                                  strval NVARCHAR(3750),
                                  longstrval NVARCHAR(MAX),
                                  metaval NVARCHAR(MAX),
                                  flag INTEGER NOT NULL,
                                  CONSTRAINT PK_sval_mod_arch PRIMARY KEY (ownerid,defid,ctxtinstid),
                                  CONSTRAINT FK_svmod_arch_vmod_owner FOREIGN KEY (ownerid,defid) REFERENCES ADOxx.valowner_mod_arch (ownerid,defid) ON DELETE CASCADE);
CREATE INDEX isvalmod_ctxt_arch ON ADOxx.sval_mod_arch (ctxtinstid);

CREATE TABLE ADOxx.sval_ri_arch(ownerid INTEGER NOT NULL,
                                  defid BINARY(16) NOT NULL,
                                  ctxtinstid INTEGER NOT NULL,
                                  creationid BINARY(16) NOT NULL,
                                  modtime INTEGER,
                                  intval INTEGER,
                                  doubleval DECIMAL(28,6),
                                  strval NVARCHAR(3750),
                                  longstrval NVARCHAR(MAX),
                                  metaval NVARCHAR(MAX),
                                  flag INTEGER NOT NULL,
                                  CONSTRAINT PK_sval_ri_arch PRIMARY KEY (ownerid,defid,ctxtinstid),
                                  CONSTRAINT FK_svri_arch_vri_owner FOREIGN KEY (ownerid,defid) REFERENCES ADOxx.valowner_ri_arch (ownerid,defid) ON DELETE CASCADE);
CREATE INDEX isvalri_ctxt_arch ON ADOxx.sval_ri_arch (ctxtinstid);

CREATE TABLE ADOxx.sval_mi_arch(ownerid INTEGER NOT NULL,
                                  defid BINARY(16) NOT NULL,
                                  ctxtinstid INTEGER NOT NULL,
                                  creationid BINARY(16) NOT NULL,
                                  modtime INTEGER,
                                  intval INTEGER,
                                  doubleval DECIMAL(28,6),
                                  strval NVARCHAR(3750),
                                  longstrval NVARCHAR(MAX),
                                  metaval NVARCHAR(MAX),
                                  flag INTEGER NOT NULL,
                                  CONSTRAINT PK_sval_mi_arch PRIMARY KEY (ownerid,defid,ctxtinstid),
                                  CONSTRAINT FK_svmi_arch_vmi_owner FOREIGN KEY (ownerid,defid) REFERENCES ADOxx.valowner_mi_arch (ownerid,defid) ON DELETE CASCADE);
CREATE INDEX isvalmi_ctxt_arch ON ADOxx.sval_mi_arch (ctxtinstid);

CREATE TABLE ADOxx.cval_mod_arch(valid BINARY(16) NOT NULL,
                                   ownerid INTEGER NOT NULL,
                                   defid BINARY(16) NOT NULL,
                                   ctxtinstid INTEGER NOT NULL,
                                   attrvaltypeid BINARY(16) NOT NULL,
                                   preid BINARY(16) NOT NULL,
                                   iscmplx TINYINT NOT NULL,
                                   creationid BINARY(16) NOT NULL,
                                   modtime INTEGER,
                                   creationtime INTEGER,
                                   intval INTEGER,
                                   doubleval DECIMAL(28,6),
                                   strval NVARCHAR(3750),
                                   longstrval NVARCHAR(MAX),
                                   flag INTEGER NOT NULL,
                                   CONSTRAINT PK_cval_mod_arch PRIMARY KEY NONCLUSTERED (valid),
                                   CONSTRAINT FK_cvmod_arch_vmod_owner FOREIGN KEY (ownerid,defid) REFERENCES ADOxx.valowner_mod_arch (ownerid,defid) ON DELETE CASCADE);
--ALTER TABLE ADOxx.cval_mod_arch ADD CONSTRAINT fkcvalmod_avt_arch FOREIGN KEY (attrvaltypeid) REFERENCES ADOxx.attrvaltype (attrvaltypeid) ON DELETE NO ACTION;
CREATE CLUSTERED INDEX cix_cvalmod_owner_ctxt_arch ON ADOxx.cval_mod_arch (ownerid,defid,ctxtinstid);
CREATE INDEX icvalmod_ctxt_arch ON ADOxx.cval_mod_arch (ctxtinstid);

CREATE TABLE ADOxx.cval_ri_arch(valid BINARY(16) NOT NULL,
                                  ownerid INTEGER NOT NULL,
                                  defid BINARY(16) NOT NULL,
                                  ctxtinstid INTEGER NOT NULL,
                                  attrvaltypeid BINARY(16) NOT NULL,
                                  preid BINARY(16) NOT NULL,
                                  iscmplx TINYINT NOT NULL,
                                  creationid BINARY(16) NOT NULL,
                                  modtime INTEGER,
                                  creationtime INTEGER,
                                  intval INTEGER,
                                  doubleval DECIMAL(28,6),
                                  strval NVARCHAR(3750),
                                  longstrval NVARCHAR(MAX),
                                  flag INTEGER NOT NULL,
                                  CONSTRAINT PK_cval_ri_arch PRIMARY KEY NONCLUSTERED (valid),
                                  CONSTRAINT FK_cvri_arch_vri_owner FOREIGN KEY (ownerid,defid) REFERENCES ADOxx.valowner_ri_arch (ownerid,defid) ON DELETE CASCADE);
--ALTER TABLE ADOxx.cval_ri_arch ADD CONSTRAINT fkcvalri_avt_arch FOREIGN KEY (attrvaltypeid) REFERENCES ADOxx.attrvaltype (attrvaltypeid) ON DELETE NO ACTION;
CREATE CLUSTERED INDEX cix_cvalri_owner_ctxt_arch ON ADOxx.cval_ri_arch (ownerid,defid,ctxtinstid);
CREATE INDEX icvalri_ctxt_arch ON ADOxx.cval_ri_arch (ctxtinstid);

CREATE TABLE ADOxx.cval_mi_arch(valid BINARY(16) NOT NULL,
                                  ownerid INTEGER NOT NULL,
                                  defid BINARY(16) NOT NULL,
                                  ctxtinstid INTEGER NOT NULL,
                                  attrvaltypeid BINARY(16) NOT NULL,
                                  preid BINARY(16) NOT NULL,
                                  iscmplx TINYINT NOT NULL,
                                  creationid BINARY(16) NOT NULL,
                                  modtime INTEGER,
                                  creationtime INTEGER,
                                  intval INTEGER,
                                  doubleval DECIMAL(28,6),
                                  strval NVARCHAR(3750),
                                  longstrval NVARCHAR(MAX),
                                  flag INTEGER NOT NULL,
                                  CONSTRAINT PK_cval_mi_arch PRIMARY KEY NONCLUSTERED (valid),
                                  CONSTRAINT FK_cvmi_arch_vmi_owner FOREIGN KEY (ownerid,defid) REFERENCES ADOxx.valowner_mi_arch (ownerid,defid) ON DELETE CASCADE);
--ALTER TABLE ADOxx.cval_mi_arch ADD CONSTRAINT fkcvalmi_avt_arch FOREIGN KEY (attrvaltypeid) REFERENCES ADOxx.attrvaltype (attrvaltypeid) ON DELETE NO ACTION;
CREATE CLUSTERED INDEX cix_cvalmi_owner_ctxt_arch ON ADOxx.cval_mi_arch (ownerid,defid,ctxtinstid);
CREATE INDEX icvalmi_ctxt_arch ON ADOxx.cval_mi_arch (ctxtinstid);

-- RWF Archive Tables <-- END;
GO

CREATE TRIGGER ADOxx.delLib ON ADOxx.library FOR DELETE AS 
BEGIN 
  SET NOCOUNT ON; 
  DELETE FROM ADOxx.name FROM deleted WHERE ADOxx.name.objid = deleted.libid; 
  DELETE FROM ADOxx.identifiertext FROM deleted WHERE ADOxx.identifiertext.objid = deleted.libid; 
  DELETE FROM ADOxx.objattrdefs FROM deleted WHERE ADOxx.objattrdefs.objid = deleted.libid; 
  DELETE FROM ADOxx.valowner_lib FROM deleted WHERE ADOxx.valowner_lib.ownerid = deleted.libid; 
  DELETE FROM ADOxx.metamodelright FROM deleted WHERE ADOxx.metamodelright.targetctxtid = deleted.libid; 
END;
GO

CREATE TRIGGER ADOxx.delModTyp ON ADOxx.modeltype FOR DELETE AS 
BEGIN 
  SET NOCOUNT ON; 
  DELETE FROM ADOxx.name FROM deleted WHERE ADOxx.name.objid = deleted.modtypeid; 
  DELETE FROM ADOxx.identifiertext FROM deleted WHERE ADOxx.identifiertext.objid = deleted.modtypeid; 
  DELETE FROM ADOxx.libobjs FROM deleted WHERE ADOxx.libobjs.objid = deleted.modtypeid; 
  DELETE FROM ADOxx.direct_libobjs FROM deleted WHERE ADOxx.direct_libobjs.objid = deleted.modtypeid; 
  DELETE FROM ADOxx.objattrdefs FROM deleted WHERE ADOxx.objattrdefs.objid = deleted.modtypeid; 
  DELETE FROM ADOxx.valowner_lib FROM deleted WHERE ADOxx.valowner_lib.ownerid = deleted.modtypeid; 
  DELETE FROM ADOxx.cardinality FROM deleted WHERE ADOxx.cardinality.objectid = deleted.modtypeid; 
  DELETE FROM ADOxx.metamodelright FROM deleted WHERE ADOxx.metamodelright.targetid = deleted.modtypeid; 
  DELETE FROM ADOxx.metamodelright FROM deleted WHERE ADOxx.metamodelright.targetctxtid = deleted.modtypeid; 
END;
GO

CREATE TRIGGER ADOxx.delClass ON ADOxx.class FOR DELETE AS 
BEGIN 
  SET NOCOUNT ON; 
  DELETE FROM ADOxx.name FROM deleted WHERE ADOxx.name.objid = deleted.classid; 
  DELETE FROM ADOxx.identifiertext FROM deleted WHERE ADOxx.identifiertext.objid = deleted.classid; 
  DELETE FROM ADOxx.libobjs FROM deleted WHERE ADOxx.libobjs.objid = deleted.classid; 
  DELETE FROM ADOxx.direct_libobjs FROM deleted WHERE ADOxx.direct_libobjs.objid = deleted.classid; 
  DELETE FROM ADOxx.objattrdefs FROM deleted WHERE ADOxx.objattrdefs.objid = deleted.classid; 
  DELETE FROM ADOxx.cardinality FROM deleted WHERE ADOxx.cardinality.objectid = deleted.classid; 
  DELETE FROM ADOxx.valowner_lib FROM deleted WHERE ADOxx.valowner_lib.ownerid = deleted.classid; 
  DELETE FROM ADOxx.metamodelright FROM deleted WHERE ADOxx.metamodelright.targetid = deleted.classid; 
  DELETE FROM ADOxx.metamodelright FROM deleted WHERE ADOxx.metamodelright.targetctxtid = deleted.classid; 
  DELETE FROM ADOxx.metamodelright FROM deleted WHERE ADOxx.metamodelright.subid1 = deleted.classid; 
  DELETE FROM ADOxx.metamodelright FROM deleted WHERE ADOxx.metamodelright.subid2 = deleted.classid; 
END;
GO

CREATE TRIGGER ADOxx.delEndpntDef ON ADOxx.endpointdef FOR DELETE AS 
BEGIN 
  SET NOCOUNT ON; 
  DELETE FROM ADOxx.name FROM deleted WHERE ADOxx.name.objid = deleted.endpointdefid; 
  DELETE FROM ADOxx.identifiertext FROM deleted WHERE ADOxx.identifiertext.objid = deleted.endpointdefid; 
  DELETE FROM ADOxx.objattrdefs FROM deleted WHERE ADOxx.objattrdefs.objid = deleted.endpointdefid; 
  DELETE FROM ADOxx.valowner_lib FROM deleted WHERE ADOxx.valowner_lib.ownerid = deleted.endpointdefid; 
  DELETE FROM ADOxx.libobjs FROM deleted WHERE ADOxx.libobjs.objid = deleted.endpointdefid; 
  DELETE FROM ADOxx.direct_libobjs FROM deleted WHERE ADOxx.direct_libobjs.objid = deleted.endpointdefid; 
  DELETE FROM ADOxx.metamodelright FROM deleted WHERE ADOxx.metamodelright.targetctxtid = deleted.endpointdefid; 
END;
GO

CREATE TRIGGER ADOxx.delAttrValTyp ON ADOxx.attrvaltype FOR DELETE AS 
BEGIN 
  SET NOCOUNT ON; 
  DELETE FROM ADOxx.name FROM deleted WHERE ADOxx.name.objid = deleted.attrvaltypeid; 
  DELETE FROM ADOxx.identifiertext FROM deleted WHERE ADOxx.identifiertext.objid = deleted.attrvaltypeid; 
END;
GO

CREATE TRIGGER ADOxx.delAttrTyp ON ADOxx.attrtype FOR DELETE AS 
BEGIN 
  SET NOCOUNT ON; 
  DELETE FROM ADOxx.name FROM deleted WHERE ADOxx.name.objid = deleted.attrtypeid; 
  DELETE FROM ADOxx.identifiertext FROM deleted WHERE ADOxx.identifiertext.objid = deleted.attrtypeid; 
  DELETE FROM ADOxx.libobjs FROM deleted WHERE ADOxx.libobjs.objid = deleted.attrtypeid; 
  DELETE FROM ADOxx.attrvaltype FROM deleted WHERE ADOxx.attrvaltype.rootid = deleted.rootatvaltypeid; 
  DELETE FROM ADOxx.valowner_lib FROM deleted WHERE ADOxx.valowner_lib.ownerid = deleted.attrtypeid; 
END;
GO

CREATE TRIGGER ADOxx.delAttrDef ON ADOxx.attrdef FOR DELETE AS 
BEGIN 
  SET NOCOUNT ON; 
  DELETE FROM ADOxx.name FROM deleted WHERE ADOxx.name.objid = deleted.attrdefid; 
  DELETE FROM ADOxx.identifiertext FROM deleted WHERE ADOxx.identifiertext.objid = deleted.attrdefid; 
  DELETE FROM ADOxx.libobjs FROM deleted WHERE ADOxx.libobjs.objid = deleted.attrdefid; 
  DELETE FROM ADOxx.valowner_lib FROM deleted WHERE ADOxx.valowner_lib.defid = deleted.attrdefid; 
  DELETE FROM ADOxx.permissions FROM deleted WHERE ADOxx.permissions.objectid = deleted.attrdefid; 
  DELETE FROM ADOxx.metamodelright FROM deleted WHERE ADOxx.metamodelright.targetid = deleted.attrdefid; 
END;
GO

CREATE TRIGGER ADOxx.delContextParam ON ADOxx.contextparam FOR DELETE AS 
BEGIN 
  SET NOCOUNT ON; 
  DELETE FROM ADOxx.name FROM deleted WHERE ADOxx.name.objid = deleted.paramid; 
  DELETE FROM ADOxx.identifiertext FROM deleted WHERE ADOxx.identifiertext.objid = deleted.paramid; 
  DELETE FROM ADOxx.libobjs FROM deleted WHERE ADOxx.libobjs.objid = deleted.paramid; 
END;
GO

CREATE TRIGGER ADOxx.delContextDef ON ADOxx.contextdef FOR DELETE AS 
BEGIN 
  SET NOCOUNT ON; 
  DELETE FROM ADOxx.name FROM deleted WHERE ADOxx.name.objid = deleted.contextdefid; 
  DELETE FROM ADOxx.identifiertext FROM deleted WHERE ADOxx.identifiertext.objid = deleted.contextdefid; 
  DELETE FROM ADOxx.libobjs FROM deleted WHERE ADOxx.libobjs.objid = deleted.contextdefid; 
END;
GO

CREATE TRIGGER ADOxx.delCiRepoObj ON ADOxx.ci_repoobjs FOR DELETE AS 
BEGIN 
  SET NOCOUNT ON; 
  DELETE FROM ADOxx.contextinst FROM deleted WHERE ADOxx.contextinst.ctxtinstid = deleted.realctxtinstid; 
  DELETE FROM ADOxx.permissions FROM deleted WHERE ADOxx.permissions.contextid=(SELECT r.repoid FROM ADOxx.repository r WHERE r.realrepoid=deleted.repoid) AND ADOxx.permissions.objectid=deleted.ctxtinstid; 
END;
GO

CREATE TRIGGER ADOxx.delContextInst ON ADOxx.contextinst FOR DELETE AS 
BEGIN 
  SET NOCOUNT ON; 
  DELETE FROM ADOxx.ctxtinstobjs FROM deleted WHERE ADOxx.ctxtinstobjs.ctxtinstid = deleted.ctxtinstid; 
  DELETE FROM ADOxx.sval_mod FROM deleted WHERE ADOxx.sval_mod.ctxtinstid = deleted.ctxtinstid; 
  DELETE FROM ADOxx.sval_ri FROM deleted WHERE ADOxx.sval_ri.ctxtinstid = deleted.ctxtinstid; 
  DELETE FROM ADOxx.sval_mi FROM deleted WHERE ADOxx.sval_mi.ctxtinstid = deleted.ctxtinstid; 
  DELETE FROM ADOxx.sval_relepi FROM deleted WHERE ADOxx.sval_relepi.ctxtinstid = deleted.ctxtinstid; 
  DELETE FROM ADOxx.cval_mod FROM deleted WHERE ADOxx.cval_mod.ctxtinstid = deleted.ctxtinstid; 
  DELETE FROM ADOxx.cval_ri FROM deleted WHERE ADOxx.cval_ri.ctxtinstid = deleted.ctxtinstid; 
  DELETE FROM ADOxx.cval_mi FROM deleted WHERE ADOxx.cval_mi.ctxtinstid = deleted.ctxtinstid; 
  DELETE FROM ADOxx.cval_relepi FROM deleted WHERE ADOxx.cval_relepi.ctxtinstid = deleted.ctxtinstid; 
END;
GO

CREATE TRIGGER ADOxx.delRole ON ADOxx.role_mfb FOR DELETE AS 
BEGIN 
  SET NOCOUNT ON; 
  DELETE FROM ADOxx.identifiertext FROM deleted WHERE ADOxx.identifiertext.objid = deleted.roleid; 
END;
GO

CREATE TRIGGER ADOxx.delRep ON ADOxx.repository FOR DELETE AS 
BEGIN 
  SET NOCOUNT ON; 
  DELETE FROM ADOxx.libobjs FROM deleted WHERE ADOxx.libobjs.objid = deleted.repoid; 
  DELETE FROM ADOxx.directories FROM deleted WHERE ADOxx.directories.repoid=deleted.realrepoid; 
  DELETE FROM ADOxx.valowner_mi_arch FROM deleted WHERE ADOxx.valowner_mi_arch.ownerid IN (SELECT realmodinstid FROM ADOxx.mi_repoobjs WHERE repoid = deleted.realrepoid); 
  DELETE FROM ADOxx.valowner_mod_arch FROM deleted WHERE ADOxx.valowner_mod_arch.ownerid IN (SELECT realmodelid FROM ADOxx.mod_repoobjs WHERE repoid = deleted.realrepoid); 
  DELETE FROM ADOxx.valowner_ri_arch FROM deleted WHERE ADOxx.valowner_ri_arch.ownerid IN (SELECT realrepoinstid FROM ADOxx.ri_repoobjs WHERE repoid = deleted.realrepoid); 
  DELETE FROM ADOxx.ci_repoobjs FROM deleted WHERE ADOxx.ci_repoobjs.repoid = deleted.realrepoid; 
  DELETE FROM ADOxx.mod_repoobjs FROM deleted WHERE ADOxx.mod_repoobjs.repoid = deleted.realrepoid; 
  DELETE FROM ADOxx.ri_repoobjs FROM deleted WHERE ADOxx.ri_repoobjs.srcrepoid = deleted.realrepoid; 
  DELETE FROM ADOxx.ri_repoobjs FROM deleted WHERE ADOxx.ri_repoobjs.repoid = deleted.realrepoid; 
  DELETE FROM ADOxx.mi_repoobjs FROM deleted WHERE ADOxx.mi_repoobjs.repoid = deleted.realrepoid; 
  DELETE FROM ADOxx.relepi_repoobjs FROM deleted WHERE ADOxx.relepi_repoobjs.repoid = deleted.realrepoid; 
  DELETE FROM ADOxx.hg_repoobjs FROM deleted WHERE ADOxx.hg_repoobjs.repoid = deleted.realrepoid; 
  DELETE FROM ADOxx.permissions FROM deleted WHERE ADOxx.permissions.objectid = deleted.repoid; 
  DELETE FROM ADOxx.permissions FROM deleted WHERE ADOxx.permissions.contextid = deleted.repoid; 
  DELETE FROM ADOxx.name FROM deleted WHERE ADOxx.name.objid = deleted.repoid; 
  DELETE FROM ADOxx.identifiertext FROM deleted WHERE ADOxx.identifiertext.objid = deleted.repoid; 
  DELETE FROM ADOxx.dep_activities FROM deleted WHERE ADOxx.dep_activities.repoid = deleted.realrepoid; 
  DELETE FROM ADOxx.del_val FROM deleted WHERE ADOxx.del_val.repoid = deleted.realrepoid; 
  DELETE FROM ADOxx.delayedaction FROM deleted WHERE ADOxx.delayedaction.repoid = deleted.realrepoid; 
END;
GO

CREATE TRIGGER ADOxx.delModRepoObj ON ADOxx.mod_repoobjs FOR DELETE AS 
BEGIN 
  SET NOCOUNT ON; 
  DELETE FROM ADOxx.model FROM deleted WHERE ADOxx.model.modelid = deleted.realmodelid; 
  DELETE FROM ADOxx.mi_repoobjs FROM deleted WHERE ADOxx.mi_repoobjs.repoid=deleted.repoid AND ADOxx.mi_repoobjs.realmodinstid IN (SELECT mi.modinstid FROM ADOxx.modelinst mi WHERE mi.modelid=deleted.modelid); 
  DELETE FROM ADOxx.groupobjsctxtspec FROM deleted WHERE ADOxx.groupobjsctxtspec.objid=deleted.modelid AND EXISTS (SELECT hg_ro.realgroupid FROM ADOxx.hg_repoobjs hg_ro WHERE hg_ro.realgroupid=ADOxx.groupobjsctxtspec.groupid AND hg_ro.repoid=deleted.repoid); 
  DELETE FROM ADOxx.permissions FROM deleted WHERE ADOxx.permissions.contextid=(SELECT r.repoid FROM ADOxx.repository r WHERE r.realrepoid=deleted.repoid) AND ADOxx.permissions.objectid=deleted.modelid; 
  DELETE FROM ADOxx.delayedaction FROM deleted WHERE ADOxx.delayedaction.artefactid=deleted.modelid AND ADOxx.delayedaction.repoid=deleted.repoid; 
END;
GO

CREATE TRIGGER ADOxx.delModel ON ADOxx.model FOR DELETE AS 
BEGIN 
  SET NOCOUNT ON; 
  DELETE FROM ADOxx.valowner_mod FROM deleted WHERE ADOxx.valowner_mod.ownerid = deleted.modelid; 
END;
GO

CREATE TRIGGER ADOxx.delRiRepoObj ON ADOxx.ri_repoobjs FOR DELETE AS 
BEGIN 
  SET NOCOUNT ON; 
  DELETE FROM ADOxx.repoinst FROM deleted WHERE NOT EXISTS (SELECT ro.realrepoinstid FROM ADOxx.ri_repoobjs ro WHERE ro.realrepoinstid=deleted.realrepoinstid) AND ADOxx.repoinst.repoinstid = deleted.realrepoinstid; 
  DELETE FROM ADOxx.mi_repoobjs FROM deleted WHERE ADOxx.mi_repoobjs.repoid=deleted.repoid AND ADOxx.mi_repoobjs.realmodinstid IN (SELECT mi.modinstid FROM ADOxx.modelinst mi WHERE mi.repoinstid=deleted.repoinstid); 
  DELETE FROM ADOxx.relepi_repoobjs FROM deleted WHERE ADOxx.relepi_repoobjs.repoid=deleted.repoid AND ADOxx.relepi_repoobjs.realrelepiid IN (SELECT relepi.relepiid FROM ADOxx.relendpntinst relepi WHERE relepi.ownerid=deleted.repoinstid); 
  DELETE FROM ADOxx.groupobjsctxtspec FROM deleted WHERE ADOxx.groupobjsctxtspec.objid=deleted.repoinstid AND EXISTS (SELECT hg_ro.realgroupid FROM ADOxx.hg_repoobjs hg_ro WHERE hg_ro.realgroupid=ADOxx.groupobjsctxtspec.groupid AND hg_ro.repoid=deleted.repoid); 
  DELETE FROM ADOxx.permissions FROM deleted WHERE ADOxx.permissions.contextid=(SELECT r.repoid FROM ADOxx.repository r WHERE r.realrepoid=deleted.repoid) AND ADOxx.permissions.objectid=deleted.repoinstid; 
  DELETE FROM ADOxx.permissions FROM deleted WHERE deleted.repoid=0 AND ADOxx.permissions.actorid=deleted.repoinstid; 
  DELETE FROM ADOxx.rolemember FROM deleted WHERE deleted.repoid=0 AND ADOxx.rolemember.memberid=deleted.repoinstid AND ADOxx.rolemember.isgroup=0; 
  DELETE FROM ADOxx.delayedaction FROM deleted WHERE ADOxx.delayedaction.artefactid=deleted.repoinstid AND ADOxx.delayedaction.repoid=deleted.repoid; 
END;
GO

CREATE TRIGGER ADOxx.delRepInst ON ADOxx.repoinst FOR DELETE AS 
BEGIN 
  SET NOCOUNT ON; 
  DELETE FROM ADOxx.valowner_ri FROM deleted WHERE ADOxx.valowner_ri.ownerid=deleted.repoinstid; 
END;
GO

CREATE TRIGGER ADOxx.delMiRepoObj ON ADOxx.mi_repoobjs FOR DELETE AS 
BEGIN 
  SET NOCOUNT ON; 
  INSERT INTO ADOxx.del_val (repoid,ownerid,ownertype,actiontime) SELECT repoid,modinstid,4,CONVERT(DATETIME2,'1900-01-01 00:00:00',120) FROM deleted; 
  DELETE FROM ADOxx.modelinst FROM deleted WHERE ADOxx.modelinst.modinstid=deleted.realmodinstid; 
  DELETE FROM ADOxx.relepi_repoobjs FROM deleted WHERE ADOxx.relepi_repoobjs.repoid=deleted.repoid AND ADOxx.relepi_repoobjs.realrelepiid IN (SELECT relepi.relepiid FROM ADOxx.relendpntinst relepi WHERE relepi.ownerid=deleted.modinstid); 
  DELETE FROM ADOxx.permissions FROM deleted WHERE ADOxx.permissions.contextid=(SELECT r.repoid FROM ADOxx.repository r WHERE r.realrepoid=deleted.repoid) AND ADOxx.permissions.objectid=deleted.modinstid; 
END;
GO

CREATE TRIGGER ADOxx.delModInst ON ADOxx.modelinst FOR DELETE AS 
BEGIN 
  SET NOCOUNT ON; 
  DELETE FROM ADOxx.valowner_mi FROM deleted WHERE ADOxx.valowner_mi.ownerid=deleted.modinstid; 
END;
GO

CREATE TRIGGER ADOxx.delRepiRepoObj ON ADOxx.relepi_repoobjs FOR DELETE AS 
BEGIN 
  SET NOCOUNT ON; 
  INSERT INTO ADOxx.dep_activities 
    SELECT deleted.repoid,
           deleted.relepiid,
           relepi.broken,
           relepi.epdefid,
           relepi.modelid,
           relepi.modeltypeid,
           relepi.ownerid,
           relepi.ownertype,
           relepi.ownerclassid,
           relepi.targetclassid,
           relepi.targetinstid,
           relepi.targettype,
           relepi.twinepid,
           relepi.proxyid,
           SYSUTCDATETIME(),
           0 
    FROM deleted 
      INNER JOIN ADOxx.relendpntinst relepi 
        ON relepi.relepiid = deleted.realrelepiid; 
  DELETE FROM ADOxx.relendpntinst FROM deleted WHERE ADOxx.relendpntinst.relepiid = deleted.realrelepiid; 
END;
GO

CREATE TRIGGER ADOxx.delRelEpInst ON ADOxx.relendpntinst FOR DELETE AS 
BEGIN 
  SET NOCOUNT ON; 
  DECLARE @instid binary(16)
  DELETE FROM ADOxx.valowner_relepi FROM deleted WHERE ADOxx.valowner_relepi.ownerid=deleted.relepiid; 
  INSERT INTO ADOxx.dep_activities 
    SELECT relepi_ro.repoid,
           relepi_ro.relepiid,
           deleted.broken,
           deleted.epdefid,
           deleted.modelid,
           deleted.modeltypeid,
           deleted.ownerid,
           deleted.ownertype,
           deleted.ownerclassid,
           deleted.targetclassid,
           deleted.targetinstid,
           deleted.targettype,
           deleted.twinepid,
           deleted.proxyid,
           SYSUTCDATETIME(),
           0 
    FROM deleted 
      INNER JOIN ADOxx.relepi_repoobjs relepi_ro 
        ON relepi_ro.realrelepiid = deleted.relepiid; 
END;
GO

CREATE TRIGGER ADOxx.upsertRelEpInst ON ADOxx.relendpntinst FOR INSERT, UPDATE AS 
BEGIN 
  SET NOCOUNT ON; 
  DECLARE @action SMALLINT; 
  SET @action = 0; 
  IF EXISTS(SELECT * FROM deleted) 
  BEGIN 
    IF EXISTS(SELECT * FROM inserted i, deleted d WHERE i.relepiid = d.relepiid AND i.broken <> d.broken) 
    BEGIN 
      SET @action = @action | 1; 
    END; 
    IF EXISTS(SELECT * FROM inserted i, deleted d WHERE i.relepiid = d.relepiid AND i.twinepid <> d.twinepid) 
    BEGIN 
      SET @action = @action | 2; 
    END; 
    IF EXISTS(SELECT * FROM inserted i, deleted d WHERE i.relepiid = d.relepiid AND i.targetinstid <> d.targetinstid) 
    BEGIN 
      SET @action = @action | 4; 
    END; 
  END 
  ELSE 
  BEGIN 
    SET @action = 8; 
  END; 

  IF (@action <> 0) 
  BEGIN 
    INSERT INTO ADOxx.dep_activities 
      SELECT relepi_ro.repoid,
             relepi_ro.relepiid,
             inserted.broken,
             inserted.epdefid,
             inserted.modelid,
             inserted.modeltypeid,
             inserted.ownerid,
             inserted.ownertype,
             inserted.ownerclassid,
             inserted.targetclassid,
             inserted.targetinstid,
             inserted.targettype,
             inserted.twinepid,
             inserted.proxyid,
             SYSUTCDATETIME(),
             @action 
      FROM ADOxx.relepi_repoobjs relepi_ro, inserted 
      WHERE relepi_ro.realrelepiid = inserted.relepiid 
  END; 
END;
GO

CREATE TRIGGER ADOxx.delHgRepoObj ON ADOxx.hg_repoobjs FOR DELETE AS 
BEGIN 
  SET NOCOUNT ON; 
  DELETE FROM ADOxx.hiergroup_ctxtspec FROM deleted WHERE ADOxx.hiergroup_ctxtspec.groupid = deleted.realgroupid; 
  DELETE FROM ADOxx.permissions FROM deleted WHERE ADOxx.permissions.contextid=(SELECT r.repoid FROM ADOxx.repository r WHERE r.realrepoid=deleted.repoid) AND ADOxx.permissions.actorid=deleted.groupid; 
  DELETE FROM ADOxx.permissions FROM deleted WHERE ADOxx.permissions.contextid=(SELECT r.repoid FROM ADOxx.repository r WHERE r.realrepoid=deleted.repoid) AND ADOxx.permissions.objectid=deleted.groupid; 
  DELETE FROM ADOxx.rolemember FROM deleted WHERE deleted.repoid=0 AND ADOxx.rolemember.memberid=deleted.groupid AND ADOxx.rolemember.isgroup=1; 
END;
GO

CREATE TRIGGER ADOxx.delGroupCtxtSpec ON ADOxx.hiergroup_ctxtspec FOR DELETE AS 
BEGIN 
  SET NOCOUNT ON; 
  DELETE FROM ADOxx.name FROM deleted WHERE ADOxx.name.objid = deleted.groupid; 
  DELETE FROM ADOxx.identifiertext FROM deleted WHERE ADOxx.identifiertext.objid = deleted.groupid; 
END;
GO

CREATE TRIGGER ADOxx.updInstancename ON ADOxx.instancename FOR UPDATE AS 
BEGIN 
  SET NOCOUNT ON;
  UPDATE ADOxx.instancename SET actiontime = SYSUTCDATETIME() FROM inserted WHERE instancename.repoid = inserted.repoid AND instancename.instid = inserted.instid; 
END;
GO

CREATE TRIGGER ADOxx.delSValMi ON ADOxx.sval_mi FOR DELETE AS 
BEGIN 
  SET NOCOUNT ON; 
  UPDATE ADOxx.mi_repoobjs SET actiontime=CONVERT(DATETIME2,'1900-01-01 00:00:00',120) FROM deleted WHERE deleted.ownerid=mi_repoobjs.realmodinstid; 
END;
GO

CREATE TRIGGER ADOxx.delCValMi ON ADOxx.cval_mi FOR DELETE AS 
BEGIN 
  SET NOCOUNT ON; 
  UPDATE ADOxx.mi_repoobjs SET actiontime=CONVERT(DATETIME2,'1900-01-01 00:00:00',120) FROM deleted WHERE deleted.ownerid=mi_repoobjs.realmodinstid; 
END;
GO

CREATE TRIGGER ADOxx.upsertSValMi ON ADOxx.sval_mi FOR INSERT, UPDATE AS 
BEGIN 
  SET NOCOUNT ON; 
  UPDATE ADOxx.mi_repoobjs SET actiontime=CONVERT(DATETIME2,'1900-01-01 00:00:00',120) FROM inserted WHERE mi_repoobjs.realmodinstid=inserted.ownerid; 
END;
GO

CREATE TRIGGER ADOxx.upsertCValMi ON ADOxx.cval_mi FOR INSERT, UPDATE AS 
BEGIN 
  SET NOCOUNT ON; 
  UPDATE ADOxx.mi_repoobjs SET actiontime=CONVERT(DATETIME2,'1900-01-01 00:00:00',120) FROM inserted WHERE mi_repoobjs.realmodinstid=inserted.ownerid; 
END;
GO

CREATE TRIGGER ADOxx.updSValRelepi ON ADOxx.sval_relepi FOR UPDATE AS 
BEGIN 
  SET NOCOUNT ON;
  UPDATE ADOxx.sval_relepi SET actiontime = SYSUTCDATETIME() FROM inserted WHERE sval_relepi.ownerid = inserted.ownerid; 
END;
GO

CREATE TRIGGER ADOxx.delAdminChangeTranArch ON ADOxx.admin_change_transact_arch FOR DELETE AS 
BEGIN 
  SET NOCOUNT ON; 
  DELETE FROM ADOxx.admin_change_history_arch FROM deleted WHERE ADOxx.admin_change_history_arch.transactid = deleted.transactid; 
END;
GO

CREATE TRIGGER ADOxx.updDMSMetadata ON ADOxx.dms_metadata FOR UPDATE AS 
BEGIN 
  SET NOCOUNT ON;
  UPDATE ADOxx.dms_metadata SET actiontime = SYSUTCDATETIME() FROM inserted WHERE dms_metadata.id = inserted.id; 
END;
GO

CREATE TRIGGER ADOxx.insertMiRepoobjs ON ADOxx.mi_repoobjs FOR INSERT AS
BEGIN
  SET NOCOUNT ON;
  DELETE FROM ADOxx.del_val FROM inserted WHERE ADOxx.del_val.repoid = inserted.repoid AND ADOxx.del_val.ownerid = inserted.modinstid;
END;
GO
