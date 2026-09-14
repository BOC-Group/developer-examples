-- event trigger to set the owner of newly created tables to role ADOxx instead of postgres
-- such ownership is needed when updating the DB statistics
CREATE FUNCTION "ADOxx".trg_create_set_owner() RETURNS event_trigger AS
$$
DECLARE obj record;
BEGIN
    FOR obj IN SELECT * FROM pg_event_trigger_ddl_commands() WHERE command_tag='CREATE TABLE' LOOP
        EXECUTE 'ALTER TABLE ' || obj.object_identity || ' OWNER TO "ADOxx"';
    END LOOP;
END;
$$
LANGUAGE plpgsql;

CREATE EVENT TRIGGER trg_create_set_owner ON ddl_command_end
WHEN tag IN ('CREATE TABLE')
EXECUTE PROCEDURE "ADOxx".trg_create_set_owner();

CREATE TABLE "ADOxx".transact(id SMALLINT);

CREATE TABLE "ADOxx".dbinfo(type SMALLINT NOT NULL,
                            val VARCHAR(2650),
                            val2 VARCHAR(1350),
                            CONSTRAINT PK_dbinfo PRIMARY KEY (type));                             

CREATE TABLE "ADOxx".licinfo(licid BYTEA NOT NULL,
                             infotxt VARCHAR(2000) NOT NULL,
                             lastinfotxt VARCHAR(2000) NOT NULL,
                             flag SMALLINT NOT NULL,
                             CONSTRAINT PK_licinfo PRIMARY KEY (licid));
                               
CREATE TABLE "ADOxx".dblang(langid VARCHAR(60) NOT NULL,
                            CONSTRAINT PK_dblang PRIMARY KEY (langid));

CREATE TABLE "ADOxx".contextparam(paramid BYTEA NOT NULL,
                                  dynamic SMALLINT NOT NULL,
                                  dbtype SMALLINT NOT NULL,
                                  CONSTRAINT PK_contextparam PRIMARY KEY (paramid));
                                    
CREATE TABLE "ADOxx".contextdef(contextdefid BYTEA NOT NULL,
                                flag INTEGER NOT NULL,
                                CONSTRAINT PK_contextdef PRIMARY KEY (contextdefid));
                                  
CREATE TABLE "ADOxx".contextdef_param(contextdefid BYTEA NOT NULL,
                                      paramid BYTEA NOT NULL,
                                      priority SMALLINT NOT NULL,
                                      CONSTRAINT PK_contextdef_param PRIMARY KEY (contextdefid,priority));
ALTER TABLE "ADOxx".contextdef_param ADD CONSTRAINT fkctdefpar_ctdef FOREIGN KEY(contextdefid) REFERENCES "ADOxx".contextdef(contextdefid) ON DELETE CASCADE;
ALTER TABLE "ADOxx".contextdef_param ADD CONSTRAINT fkctdefpar_cparam FOREIGN KEY(paramid) REFERENCES "ADOxx".contextparam(paramid) ON DELETE CASCADE;

CREATE TABLE "ADOxx".library(libid BYTEA NOT NULL,
                             contextdefid BYTEA NULL,
                             deflang VARCHAR(60) NOT NULL,
                             flag INTEGER NOT NULL,
                             version VARCHAR(60) NOT NULL,
                             extid BYTEA NOT NULL,
                             timestamp TIMESTAMP NOT NULL,                           
                             CONSTRAINT PK_library PRIMARY KEY (libid));
ALTER TABLE "ADOxx".library ADD CONSTRAINT fklib_ctdef FOREIGN KEY(contextdefid) REFERENCES "ADOxx".contextdef(contextdefid) ON DELETE SET NULL;

CREATE TABLE "ADOxx".library_log (changeid BYTEA NOT NULL,
                                  libid BYTEA NOT NULL,
                                  type SMALLINT NOT NULL,
                                  metadata TEXT,
                                  data BYTEA,
                                  flag INTEGER NOT NULL,
                                  author TEXT NOT NULL,
                                  timestamp BIGINT GENERATED ALWAYS AS IDENTITY NOT NULL,
                                  CONSTRAINT PK_library_log PRIMARY KEY (changeid));

CREATE TABLE "ADOxx".liblang(libid BYTEA NOT NULL,
                             langid VARCHAR(60) NOT NULL,
                             indx SMALLINT NOT NULL,
                             CONSTRAINT PK_liblang PRIMARY KEY (libid,langid));
CREATE INDEX iliblang ON "ADOxx".liblang(libid,indx);
ALTER TABLE "ADOxx".liblang ADD CONSTRAINT fkliblang_lib FOREIGN KEY(libid) REFERENCES "ADOxx".library(libid) ON DELETE CASCADE;

CREATE TABLE "ADOxx".name(objid BYTEA NOT NULL,
                          indx INTEGER NOT NULL,
                          name VARCHAR(3750),
                          CONSTRAINT PK_name PRIMARY KEY (objid,indx));
CREATE INDEX inames_indx ON "ADOxx".name(indx);

CREATE TABLE "ADOxx".identifiertext(objid BYTEA NOT NULL,
                                    langid VARCHAR(60) NOT NULL,
                                    modtime INTEGER NOT NULL,
                                    indx INTEGER NOT NULL,
                                    text VARCHAR(3750),
                                    longtext TEXT,
                                    CONSTRAINT PK_identifiertext PRIMARY KEY (objid,langid,indx));
CREATE INDEX iidtfrs_indx ON "ADOxx".identifiertext(indx);

CREATE TABLE "ADOxx".libobjs(libid BYTEA NOT NULL,
                             objid BYTEA NOT NULL,
                             srclibid BYTEA NOT NULL,
                             lookupobjid BYTEA NOT NULL,
                             CONSTRAINT PK_libobjs PRIMARY KEY (libid,objid));
ALTER TABLE "ADOxx".libobjs ADD CONSTRAINT fklibobjs_lib FOREIGN KEY(libid) REFERENCES "ADOxx".library(libid) ON DELETE CASCADE;
CREATE INDEX ilibobjs_objid ON "ADOxx".libobjs(objid);

CREATE TABLE "ADOxx".direct_libobjs(libid BYTEA NOT NULL,
                                  objid BYTEA NOT NULL,
                                  CONSTRAINT PK_direct_libobjs PRIMARY KEY (libid,objid));
ALTER TABLE "ADOxx".direct_libobjs ADD CONSTRAINT fkdlibobjs_lib FOREIGN KEY(libid) REFERENCES "ADOxx".library(libid) ON DELETE CASCADE;
CREATE INDEX idlibobjs_objid ON "ADOxx".direct_libobjs(objid);

CREATE TABLE "ADOxx".deplibs(libid BYTEA NOT NULL,
                             deplibid BYTEA NOT NULL,
                             CONSTRAINT PK_deplibs PRIMARY KEY (libid,deplibid));
ALTER TABLE "ADOxx".deplibs ADD CONSTRAINT fkdeplibs_lib FOREIGN KEY(libid) REFERENCES "ADOxx".library(libid) ON DELETE CASCADE;
CREATE INDEX iddeplibs_deplibid ON "ADOxx".deplibs(deplibid);

CREATE TABLE "ADOxx".globlibid(libid BYTEA NOT NULL,
                               globid BYTEA NOT NULL,
                               indx INTEGER NOT NULL,
                               CONSTRAINT PK_globlibid PRIMARY KEY (libid,globid));
ALTER TABLE "ADOxx".globlibid ADD CONSTRAINT fgllibids_lib FOREIGN KEY(libid) REFERENCES "ADOxx".library(libid) ON DELETE CASCADE;
CREATE INDEX igllibids_indx ON "ADOxx".globlibid(indx);

CREATE TABLE "ADOxx".modeltype(modtypeid BYTEA NOT NULL,
                               contextdefid BYTEA NULL,
                               flag INTEGER NOT NULL,
                               isvisible SMALLINT NOT NULL,
                               defaultmodusid BYTEA NOT NULL,
                               CONSTRAINT PK_modeltype PRIMARY KEY (modtypeid));
ALTER TABLE "ADOxx".modeltype ADD CONSTRAINT fkmt_ctdef FOREIGN KEY(contextdefid) REFERENCES "ADOxx".contextdef(contextdefid) ON DELETE SET NULL;

CREATE TABLE "ADOxx".class(classid BYTEA NOT NULL,
                           superclassid BYTEA NOT NULL,
                           type SMALLINT NOT NULL,
                           isabstract SMALLINT NOT NULL,
                           isvisible SMALLINT NOT NULL,
                           ismodctxtspec SMALLINT NOT NULL,
                           flag INTEGER NOT NULL,
                           CONSTRAINT PK_class PRIMARY KEY (classid));
CREATE INDEX iclass_super ON "ADOxx".class(superclassid);

CREATE TABLE "ADOxx".classtomodtype(modtypeid BYTEA NOT NULL,
                                    classid BYTEA NOT NULL,
                                    CONSTRAINT PK_classtomodtype PRIMARY KEY (modtypeid, classid));

CREATE TABLE "ADOxx".modus(modusid BYTEA NOT NULL,
                           modtypeid BYTEA NOT NULL,
                           flag INTEGER NOT NULL,
                           isvisible SMALLINT NOT NULL,
                           CONSTRAINT PK_modus PRIMARY KEY (modusid));

CREATE TABLE "ADOxx".classtomodus(modusid BYTEA NOT NULL,
                                  classid BYTEA NOT NULL,
                                  CONSTRAINT PK_classtomodus PRIMARY KEY (modusid, classid));

CREATE TABLE "ADOxx".endpointdef(endpointdefid BYTEA NOT NULL,
                                 isvisible SMALLINT NOT NULL,
                                 flag INTEGER NOT NULL,
                                 direction INTEGER NOT NULL,
                                 CONSTRAINT PK_endpointdef PRIMARY KEY (endpointdefid));
                                  
CREATE TABLE "ADOxx".cardinality(endpointdefid BYTEA NOT NULL,
                                 objectid BYTEA NOT NULL,
                                 type SMALLINT NOT NULL,
                                 mincard INTEGER NOT NULL,
                                 maxcard INTEGER NOT NULL,
                                 flag INTEGER NOT NULL,
                                 CONSTRAINT PK_cardinality PRIMARY KEY (endpointdefid,objectid,type));

CREATE TABLE "ADOxx".endpointrestrict(relclassid BYTEA NOT NULL,
                                      indx SMALLINT NOT NULL,
                                      endpointdefid BYTEA NOT NULL,
                                      classid BYTEA NOT NULL,
                                      CONSTRAINT PK_endpointrestrict PRIMARY KEY (relclassid,indx,endpointdefid,classid));

CREATE TABLE "ADOxx".attrvaltype(rootid BYTEA NOT NULL,
                                 attrvaltypeid BYTEA NOT NULL,
                                 directparentid BYTEA NOT NULL,
                                 dbtype SMALLINT NOT NULL,
                                 indx INTEGER NOT NULL,
                                 CONSTRAINT PK_attrvaltype PRIMARY KEY (attrvaltypeid));
CREATE INDEX iavtyp_root ON "ADOxx".attrvaltype(rootid);
CREATE INDEX iavtyp_order ON "ADOxx".attrvaltype(rootid,directparentid,indx);

CREATE TABLE "ADOxx".attrtype(attrtypeid BYTEA NOT NULL,
                              dbtype SMALLINT NOT NULL,
                              rootatvaltypeid BYTEA NOT NULL,
                              CONSTRAINT PK_attrtype PRIMARY KEY (attrtypeid));
CREATE UNIQUE INDEX iattrtype_root ON "ADOxx".attrtype(rootatvaltypeid);

CREATE TABLE "ADOxx".attrdef(attrdefid BYTEA NOT NULL,
                             attrtypeid BYTEA NOT NULL,
                             instattr SMALLINT NOT NULL,
                             ismodctxtspec SMALLINT NOT NULL,
                             islanginvariant SMALLINT NOT NULL,
                             flag INTEGER NOT NULL,
                             CONSTRAINT PK_attrdef PRIMARY KEY (attrdefid));

CREATE TABLE "ADOxx".objattrdefs(objid BYTEA NOT NULL,
                                 attrdefid BYTEA NOT NULL,
                                 type SMALLINT NOT NULL,
                                 CONSTRAINT PK_objattrdefs PRIMARY KEY (objid,attrdefid));

CREATE TABLE "ADOxx".paramdomain(paramid BYTEA NOT NULL,
                                 priority INTEGER NOT NULL,
                                 intval INTEGER,
                                 doubleval DECIMAL(28,6),
                                 text VARCHAR(3750),
                                 CONSTRAINT PK_paramdomain PRIMARY KEY (paramid,priority));
ALTER TABLE "ADOxx".paramdomain ADD CONSTRAINT fkparamdom_cparam FOREIGN KEY (paramid) REFERENCES "ADOxx".contextparam (paramid) ON DELETE CASCADE;
CREATE INDEX ipdoms_paramid ON "ADOxx".paramdomain(paramid);
CREATE INDEX ipdoms_prior ON "ADOxx".paramdomain(priority);

CREATE TABLE "ADOxx".repository(repoid BYTEA NOT NULL,
                                realrepoid INTEGER GENERATED BY DEFAULT AS IDENTITY NOT NULL,
                                CONSTRAINT PK_repository PRIMARY KEY (realrepoid));
CREATE UNIQUE INDEX irepo ON "ADOxx".repository(repoid);

CREATE TABLE "ADOxx".ci_repoobjs(repoid INTEGER NOT NULL,
                                 ctxtinstid BYTEA NOT NULL,
                                 realctxtinstid INTEGER GENERATED BY DEFAULT AS IDENTITY NOT NULL,
                                 CONSTRAINT PK_ci_repoobjs PRIMARY KEY (repoid,ctxtinstid));
CREATE UNIQUE INDEX iciro_repo_ctxtid ON "ADOxx".ci_repoobjs(repoid,ctxtinstid);

CREATE TABLE "ADOxx".contextinst(ctxtinstid INTEGER NOT NULL,
                                 paramid BYTEA NOT NULL,
                                 owner BYTEA NOT NULL,
                                 intval INTEGER,
                                 doubleval DECIMAL(28,6),
                                 text VARCHAR(3750),
                                 CONSTRAINT PK_contextinst PRIMARY KEY (ctxtinstid,paramid));
ALTER TABLE "ADOxx".contextinst ADD CONSTRAINT fkctxtinst_cparam FOREIGN KEY (paramid) REFERENCES "ADOxx".contextparam (paramid);
CREATE INDEX ictxti_owner ON "ADOxx".contextinst(owner);
CREATE INDEX ictxti_parid ON "ADOxx".contextinst(paramid);

CREATE TABLE "ADOxx".mod_repoobjs(repoid INTEGER NOT NULL,
                                  modelid BYTEA NOT NULL,
                                  realmodelid INTEGER GENERATED BY DEFAULT AS IDENTITY NOT NULL,
                                  CONSTRAINT PK_mod_repoobjs PRIMARY KEY (realmodelid));
CREATE UNIQUE INDEX imodro_repo_modid ON "ADOxx".mod_repoobjs(repoid,modelid);

CREATE TABLE "ADOxx".model(modelid INTEGER NOT NULL,
                           modtypeid BYTEA NOT NULL,
						               creationtime TIMESTAMP NOT NULL CONSTRAINT DF_model_creationtime DEFAULT (NOW() AT TIME ZONE 'UTC'),
                           CONSTRAINT PK_model PRIMARY KEY (modelid));
CREATE INDEX imodel_model_modtype ON "ADOxx".model(modelid,modtypeid);

CREATE TABLE "ADOxx".ri_repoobjs(repoid INTEGER NOT NULL,
                                 repoinstid BYTEA NOT NULL,
                                 realrepoinstid INTEGER GENERATED BY DEFAULT AS IDENTITY NOT NULL,
                                 srcrepoid INTEGER NOT NULL,
                                 CONSTRAINT PK_ri_repoobjs PRIMARY KEY (repoid,repoinstid));
CREATE INDEX iriro_realobjid ON "ADOxx".ri_repoobjs(repoid,realrepoinstid);
CREATE INDEX iriro_realid ON "ADOxx".ri_repoobjs(realrepoinstid);
CREATE INDEX iriro_srcrepoid ON "ADOxx".ri_repoobjs(srcrepoid);

CREATE TABLE "ADOxx".repoinst(repoinstid INTEGER NOT NULL,
                              classid BYTEA NOT NULL,
                              creationtime TIMESTAMP NOT NULL CONSTRAINT DF_repoinst_creationtime DEFAULT (NOW() AT TIME ZONE 'UTC'),
                              CONSTRAINT PK_repoinst PRIMARY KEY (repoinstid));
CREATE INDEX irepoinst_class ON "ADOxx".repoinst(classid);
CREATE INDEX irepoinst_riid_class ON "ADOxx".repoinst(repoinstid,classid);

CREATE TABLE "ADOxx".mi_repoobjs(repoid INTEGER NOT NULL,
                                 modinstid BYTEA NOT NULL,
                                 realmodinstid INTEGER GENERATED BY DEFAULT AS IDENTITY NOT NULL,
								 -- commented out the convert function in the following line
                                 actiontime TIMESTAMP NOT NULL CONSTRAINT DF_mi_repoobjs_actiontime DEFAULT /*CONVERT(TIMESTAMP,*/'1900-01-01 00:00:00'/*,120)*/,
                                 CONSTRAINT PK_mi_repoobjs PRIMARY KEY (realmodinstid));
CREATE UNIQUE INDEX imiro_repo_acttime_realid ON "ADOxx".mi_repoobjs (repoid,actiontime,realmodinstid);
CREATE UNIQUE INDEX imiro_repo_miid ON "ADOxx".mi_repoobjs (repoid,modinstid);

CREATE TABLE "ADOxx".modelinst(modinstid INTEGER NOT NULL,
                               repoinstid BYTEA NOT NULL,
                               modelid BYTEA NOT NULL,
                               originid BYTEA NOT NULL,
                               CONSTRAINT PK_modelinst PRIMARY KEY (modinstid));
CREATE INDEX imodelinst_riid ON "ADOxx".modelinst(repoinstid);
CREATE INDEX imodelinst_mid_riid ON "ADOxx".modelinst(modelid,repoinstid);

CREATE TABLE "ADOxx".ctxtinstobjs(ctxtinstid INTEGER NOT NULL,
                                  objid BYTEA NOT NULL,
                                  CONSTRAINT PK_ctxtinstobjs PRIMARY KEY (ctxtinstid,objid));
CREATE INDEX ictiobjs_obj ON "ADOxx".ctxtinstobjs(objid);

CREATE TABLE "ADOxx".locks(repoid BYTEA NOT NULL,
                           objid BYTEA NOT NULL,
                           userid BYTEA NOT NULL,
                           sessionid BYTEA NOT NULL,
                           type SMALLINT NOT NULL,
                           locktime TIMESTAMP NOT NULL,
                           xdata BYTEA NOT NULL,
                           persist SMALLINT NOT NULL,
                           CONSTRAINT PK_locks PRIMARY KEY (repoid,objid,sessionid,type));
CREATE UNIQUE INDEX locks_objtype ON "ADOxx".locks(repoid,objid,type,xdata);

CREATE TABLE "ADOxx".hg_repoobjs(repoid INTEGER NOT NULL,
                                 groupid BYTEA NOT NULL,
                                 realgroupid BYTEA NOT NULL,
                                 supergroupid BYTEA NOT NULL,
                                 CONSTRAINT PK_hg_repoobjs PRIMARY KEY (realgroupid));
CREATE UNIQUE INDEX ihgro_repo_groupid ON "ADOxx".hg_repoobjs (repoid,groupid);

CREATE TABLE "ADOxx".hiergroup_ctxtspec(groupid BYTEA NOT NULL,
                                        supergroupid BYTEA NOT NULL,
                                        type SMALLINT NOT NULL,
                                        CONSTRAINT PK_hiergroup_ctxtspec PRIMARY KEY (groupid));
CREATE INDEX ihgr_cs_super ON "ADOxx".hiergroup_ctxtspec(supergroupid);
CREATE INDEX ihgr_cs_type_groupid ON "ADOxx".hiergroup_ctxtspec(type,groupid);

CREATE TABLE "ADOxx".groupobjsctxtspec(groupid BYTEA NOT NULL,
                                       objid BYTEA NOT NULL,
                                       CONSTRAINT PK_groupobjsctxtspec PRIMARY KEY (groupid,objid));
ALTER TABLE "ADOxx".groupobjsctxtspec ADD CONSTRAINT fkgrobjs_cs_group FOREIGN KEY(groupid) REFERENCES "ADOxx".hiergroup_ctxtspec(groupid) ON DELETE CASCADE;
CREATE INDEX igrobjs_cs_objid ON "ADOxx".groupobjsctxtspec(objid);

CREATE TABLE "ADOxx".relepi_repoobjs(repoid INTEGER NOT NULL,
                                     relepiid BYTEA NOT NULL,
                                     realrelepiid INTEGER GENERATED BY DEFAULT AS IDENTITY NOT NULL,
                                     CONSTRAINT PK_relepi_repoobjs PRIMARY KEY (realrelepiid));
CREATE UNIQUE INDEX irepiro_repo_relepid ON "ADOxx".relepi_repoobjs (repoid,relepiid);
CREATE UNIQUE INDEX irepiro_realid ON "ADOxx".relepi_repoobjs (realrelepiid,repoid);

CREATE TABLE "ADOxx".relendpntinst(relepiid INTEGER NOT NULL,
                                   epdefid BYTEA NOT NULL,
                                   ownerid BYTEA NOT NULL,
                                   ownertype SMALLINT NOT NULL,
                                   ownerclassid BYTEA NOT NULL,
                                   targetinstid BYTEA NOT NULL,
                                   targettype SMALLINT NOT NULL,
                                   twinepid BYTEA NOT NULL,
                                   proxyid BYTEA NOT NULL,
                                   broken SMALLINT NOT NULL,
                                   targetclassid BYTEA NOT NULL,
                                   contextinstid BYTEA,
                                   modelid BYTEA,
                                   modeltypeid BYTEA,
                                   CONSTRAINT PK_relendpntinst PRIMARY KEY (relepiid));
CREATE INDEX irelepi_tgtid ON "ADOxx".relendpntinst(targetinstid,broken);
CREATE INDEX irelepi_ownerid ON "ADOxx".relendpntinst(ownerid,ownertype);
CREATE INDEX irelepi_twinownertype ON "ADOxx".relendpntinst(twinepid,ownertype);
CREATE INDEX irelepi_model ON "ADOxx".relendpntinst(modelid);

CREATE TABLE "ADOxx".instancename(repoid INTEGER NOT NULL,
                                  instid BYTEA NOT NULL,
                                  names TEXT NOT NULL,
                                  actiontime TIMESTAMP NOT NULL CONSTRAINT DF_instancename_actiontime DEFAULT (NOW() AT TIME ZONE 'UTC'),
                                  CONSTRAINT PK_instancename PRIMARY KEY (repoid,instid));
CREATE INDEX iiname_acttime_repoid_instid ON "ADOxx".instancename (actiontime,repoid,instid);

CREATE TABLE "ADOxx".valowner_lib(ownerid BYTEA NOT NULL,
                                  defid BYTEA NOT NULL,
                                  rootatvaltypeid BYTEA NOT NULL,
                                  iscomplex SMALLINT NOT NULL,
                                  CONSTRAINT PK_valowner_lib PRIMARY KEY (ownerid, defid));
CREATE INDEX ivalolib_defid ON "ADOxx".valowner_lib(defid);

CREATE TABLE "ADOxx".valowner_mod(ownerid INTEGER NOT NULL,
                                  defid BYTEA NOT NULL,
                                  rootatvaltypeid BYTEA NOT NULL,
                                  iscomplex SMALLINT NOT NULL,
                                  CONSTRAINT PK_valowner_mod PRIMARY KEY (ownerid, defid));
CREATE INDEX ivalomod_defid ON "ADOxx".valowner_mod(defid);

CREATE TABLE "ADOxx".valowner_ri(ownerid INTEGER NOT NULL,
                                 defid BYTEA NOT NULL,
                                 rootatvaltypeid BYTEA NOT NULL,
                                 iscomplex SMALLINT NOT NULL,
                                 CONSTRAINT PK_valowner_ri PRIMARY KEY (ownerid, defid));

CREATE INDEX ivalori_defid ON "ADOxx".valowner_ri(defid);

CREATE TABLE "ADOxx".valowner_mi(ownerid INTEGER NOT NULL,
                                 defid BYTEA NOT NULL,
                                 rootatvaltypeid BYTEA NOT NULL,
                                 iscomplex SMALLINT NOT NULL,
                                 CONSTRAINT PK_valowner_mi PRIMARY KEY (ownerid, defid));
CREATE INDEX ivalomi_defid ON "ADOxx".valowner_mi(defid);

CREATE TABLE "ADOxx".valowner_relepi(ownerid INTEGER NOT NULL,
                                     defid BYTEA NOT NULL,
                                     rootatvaltypeid BYTEA NOT NULL,
                                     iscomplex SMALLINT NOT NULL,
                                     CONSTRAINT PK_valowner_relepi PRIMARY KEY (ownerid, defid));
CREATE INDEX ivalorelepi_defid ON "ADOxx".valowner_relepi(defid);

CREATE TABLE "ADOxx".sval_mod(ownerid INTEGER NOT NULL,
                              defid BYTEA NOT NULL,
                              ctxtinstid INTEGER NOT NULL,
                              creationid BYTEA NOT NULL,
                              modtime INTEGER,
                              intval INTEGER,
                              doubleval DECIMAL(28,6),
                              strval VARCHAR(3750),
                              longstrval TEXT,
                              metaval TEXT,
                              flag INTEGER NOT NULL,
                              CONSTRAINT PK_sval_mod PRIMARY KEY (ownerid,defid,ctxtinstid));
ALTER TABLE "ADOxx".sval_mod ADD CONSTRAINT fksval_mod FOREIGN KEY(ownerid,defid) REFERENCES "ADOxx".valowner_mod(ownerid,defid) ON DELETE CASCADE;
CREATE INDEX isvalmod_ctxt ON "ADOxx".sval_mod(ctxtinstid);

CREATE TABLE "ADOxx".sval_ri(ownerid INTEGER NOT NULL,
                             defid BYTEA NOT NULL,
                             ctxtinstid INTEGER NOT NULL,
                             creationid BYTEA NOT NULL,
                             modtime INTEGER,
                             intval INTEGER,
                             doubleval DECIMAL(28,6),
                             strval VARCHAR(3750),
                             longstrval TEXT,
                             metaval TEXT,
                             flag INTEGER NOT NULL,
                             CONSTRAINT PK_sval_ri PRIMARY KEY (ownerid,defid,ctxtinstid));
ALTER TABLE "ADOxx".sval_ri ADD CONSTRAINT fksval_ri FOREIGN KEY(ownerid,defid) REFERENCES "ADOxx".valowner_ri(ownerid,defid) ON DELETE CASCADE;
CREATE INDEX isvalri_ctxt ON "ADOxx".sval_ri(ctxtinstid);

CREATE TABLE "ADOxx".sval_mi(ownerid INTEGER NOT NULL,
                             defid BYTEA NOT NULL,
                             ctxtinstid INTEGER NOT NULL,
                             creationid BYTEA NOT NULL,
                             modtime INTEGER,
                             intval INTEGER,
                             doubleval DECIMAL(28,6),
                             strval VARCHAR(3750),
                             longstrval TEXT,
                             metaval TEXT,
                             flag INTEGER NOT NULL,
                             CONSTRAINT PK_sval_mi PRIMARY KEY (ownerid,defid,ctxtinstid));
ALTER TABLE "ADOxx".sval_mi ADD CONSTRAINT fksval_mi FOREIGN KEY(ownerid,defid) REFERENCES "ADOxx".valowner_mi(ownerid,defid) ON DELETE CASCADE;
CREATE INDEX isvalmi_ctxt ON "ADOxx".sval_mi(ctxtinstid);

CREATE TABLE "ADOxx".sval_relepi(ownerid INTEGER NOT NULL,
                                 defid BYTEA NOT NULL,
                                 ctxtinstid INTEGER NOT NULL,
                                 creationid BYTEA NOT NULL,
                                 modtime INTEGER,
                                 intval INTEGER,
                                 doubleval DECIMAL(28,6),
                                 strval VARCHAR(3750),
                                 longstrval TEXT,
                                 metaval TEXT,
                                 flag INTEGER NOT NULL,
                                 actiontime TIMESTAMP NOT NULL CONSTRAINT DF_sval_relepi_actiontime DEFAULT (NOW() AT TIME ZONE 'UTC'),
                                 CONSTRAINT PK_sval_relepi PRIMARY KEY (ownerid,defid,ctxtinstid));
ALTER TABLE "ADOxx".sval_relepi ADD CONSTRAINT fksval_relepi FOREIGN KEY(ownerid,defid) REFERENCES "ADOxx".valowner_relepi(ownerid,defid) ON DELETE CASCADE;
CREATE INDEX isvalrelepi_ctxt ON "ADOxx".sval_relepi(ctxtinstid);

CREATE TABLE "ADOxx".simpleval_defval(valid BYTEA NOT NULL,
                                      ownerid BYTEA NOT NULL,
                                      langid VARCHAR(60) NOT NULL,
                                      defid BYTEA NOT NULL,
                                      creationid BYTEA NOT NULL,
                                      modtime INTEGER,
                                      intval INTEGER,
                                      doubleval DECIMAL(28,6),
                                      strval VARCHAR(3750),
                                      longstrval TEXT,
                                      metaval TEXT,
                                      flag INTEGER NOT NULL,
                                      CONSTRAINT PK_simpleval_defval PRIMARY KEY (valid, langid));
ALTER TABLE "ADOxx".simpleval_defval ADD CONSTRAINT fksvaldfval FOREIGN KEY(ownerid,defid) REFERENCES "ADOxx".valowner_lib(ownerid,defid) ON DELETE CASCADE;
CREATE INDEX isvaldfval_owner ON "ADOxx".simpleval_defval(ownerid,defid);

CREATE TABLE "ADOxx".cval_mod(valid BYTEA NOT NULL,
                             ownerid INTEGER NOT NULL,
                             defid BYTEA NOT NULL,
                             ctxtinstid INTEGER NOT NULL,
                             attrvaltypeid BYTEA NOT NULL,
                             preid BYTEA NOT NULL,
                             iscmplx SMALLINT NOT NULL,
                             creationid BYTEA NOT NULL,
                             modtime INTEGER,
                             creationtime INTEGER,
                             intval INTEGER,
                             doubleval DECIMAL(28,6),
                             strval VARCHAR(3750),
                             longstrval TEXT,
                             flag INTEGER NOT NULL,
                             CONSTRAINT PK_cval_mod PRIMARY KEY (valid));
ALTER TABLE "ADOxx".cval_mod ADD CONSTRAINT fkcvalmod FOREIGN KEY(ownerid,defid) REFERENCES "ADOxx".valowner_mod(ownerid,defid) ON DELETE CASCADE;
CREATE INDEX icvalmod_owner_ctxt ON "ADOxx".cval_mod (ownerid,defid,ctxtinstid);
CREATE INDEX icvalmod_ctxt ON "ADOxx".cval_mod(ctxtinstid);

CREATE TABLE "ADOxx".cval_ri(valid BYTEA NOT NULL,
                             ownerid INTEGER NOT NULL,
                             defid BYTEA NOT NULL,
                             ctxtinstid INTEGER NOT NULL,
                             attrvaltypeid BYTEA NOT NULL,
                             preid BYTEA NOT NULL,
                             iscmplx SMALLINT NOT NULL,
                             creationid BYTEA NOT NULL,
                             modtime INTEGER,
                             creationtime INTEGER,
                             intval INTEGER,
                             doubleval DECIMAL(28,6),
                             strval VARCHAR(3750),
                             longstrval TEXT,
                             flag INTEGER NOT NULL,
                             CONSTRAINT PK_cval_ri PRIMARY KEY (valid));
ALTER TABLE "ADOxx".cval_ri ADD CONSTRAINT fkcvalri FOREIGN KEY(ownerid,defid) REFERENCES "ADOxx".valowner_ri(ownerid,defid) ON DELETE CASCADE;
CREATE INDEX icvalri_owner_ctxt ON "ADOxx".cval_ri (ownerid,defid,ctxtinstid);
CREATE INDEX icvalri_ctxt ON "ADOxx".cval_ri(ctxtinstid);

CREATE TABLE "ADOxx".cval_mi(valid BYTEA NOT NULL,
                             ownerid INTEGER NOT NULL,
                             defid BYTEA NOT NULL,
                             ctxtinstid INTEGER NOT NULL,
                             attrvaltypeid BYTEA NOT NULL,
                             preid BYTEA NOT NULL,
                             iscmplx SMALLINT NOT NULL,
                             creationid BYTEA NOT NULL,
                             modtime INTEGER,
                             creationtime INTEGER,
                             intval INTEGER,
                             doubleval DECIMAL(28,6),
                             strval VARCHAR(3750),
                             longstrval TEXT,
                             flag INTEGER NOT NULL,
                             CONSTRAINT PK_cval_mi PRIMARY KEY (valid));
ALTER TABLE "ADOxx".cval_mi ADD CONSTRAINT fkcvalmi FOREIGN KEY(ownerid,defid) REFERENCES "ADOxx".valowner_mi(ownerid,defid) ON DELETE CASCADE;
CREATE INDEX icvalmi_owner_ctxt ON "ADOxx".cval_mi (ownerid,defid,ctxtinstid);
CREATE INDEX icvalmi_ctxt ON "ADOxx".cval_mi(ctxtinstid);

CREATE TABLE "ADOxx".cval_relepi(valid BYTEA NOT NULL,
                                 ownerid INTEGER NOT NULL,
                                 defid BYTEA NOT NULL,
                                 ctxtinstid INTEGER NOT NULL,
                                 attrvaltypeid BYTEA NOT NULL,
                                 preid BYTEA NOT NULL,
                                 iscmplx SMALLINT NOT NULL,
                                 creationid BYTEA NOT NULL,
                                 modtime INTEGER,
                                 creationtime INTEGER,
                                 intval INTEGER,
                                 doubleval DECIMAL(28,6),
                                 strval VARCHAR(3750),
                                 longstrval TEXT,
                                 flag INTEGER NOT NULL,
                                 CONSTRAINT PK_cval_relepi PRIMARY KEY (valid));
ALTER TABLE "ADOxx".cval_relepi ADD CONSTRAINT fkcvalrelepi FOREIGN KEY(ownerid,defid) REFERENCES "ADOxx".valowner_relepi(ownerid,defid) ON DELETE CASCADE;
CREATE INDEX icvalrelepi_owner_ctxt ON "ADOxx".cval_relepi (ownerid,defid,ctxtinstid);
CREATE INDEX icvalrelepi_ctxt ON "ADOxx".cval_relepi(ctxtinstid);

CREATE TABLE "ADOxx".complexval_defval(valid BYTEA NOT NULL,
                                       ownerid BYTEA NOT NULL,
                                       langid VARCHAR(60) NOT NULL,
                                       defid BYTEA NOT NULL,
                                       attrvaltypeid BYTEA NOT NULL,
                                       preid BYTEA NOT NULL,
                                       iscmplx SMALLINT NOT NULL,
                                       creationid BYTEA NOT NULL,
                                       modtime INTEGER,
                                       creationtime INTEGER,
                                       intval INTEGER,
                                       doubleval DECIMAL(28,6),
                                       strval VARCHAR(3750),
                                       longstrval TEXT,
                                       flag INTEGER NOT NULL,
                                       CONSTRAINT PK_complexval_defval PRIMARY KEY (valid, langid));
ALTER TABLE "ADOxx".complexval_defval ADD CONSTRAINT fkcdefval FOREIGN KEY(ownerid,defid) REFERENCES "ADOxx".valowner_lib(ownerid,defid) ON DELETE CASCADE;
CREATE INDEX icdefval_owner ON "ADOxx".complexval_defval(ownerid,defid);

CREATE TABLE "ADOxx".permissions(actorid BYTEA NOT NULL,
                                 actionid BYTEA NOT NULL,
                                 contextid BYTEA NOT NULL,
                                 objectid BYTEA NOT NULL,
                                 state SMALLINT NOT NULL,
                                 CONSTRAINT PK_permissions PRIMARY KEY (actorid, actionid, contextid, objectid));
CREATE INDEX permissions_objectid ON "ADOxx".permissions(objectid);
CREATE INDEX permissions_actionid ON "ADOxx".permissions(actionid);

CREATE TABLE "ADOxx".role_mfb(roleid BYTEA NOT NULL,
                              mfbid BYTEA NOT NULL,
                              rolename VARCHAR(255) NOT NULL,
                              registered SMALLINT NOT NULL,
                              json TEXT NULL,
                              CONSTRAINT PK_role_mfb PRIMARY KEY (roleid));
CREATE UNIQUE INDEX irole_mfbid_rolename ON "ADOxx".role_mfb(mfbid,rolename);

CREATE TABLE "ADOxx".rolemember(roleid BYTEA NOT NULL,
                                  memberid BYTEA NOT NULL,
                                  isgroup SMALLINT NOT NULL,
                                  CONSTRAINT PK_rolemember PRIMARY KEY (roleid, memberid, isgroup),
                                  CONSTRAINT FK_rolemember_role_roleid FOREIGN KEY(roleid) REFERENCES "ADOxx".role_mfb(roleid) ON DELETE CASCADE);
CREATE INDEX irm_member ON "ADOxx".rolemember(memberid,isgroup);

CREATE TABLE "ADOxx".metamodelright(roleid BYTEA NOT NULL,
                                      actionid BYTEA NOT NULL,
                                      targetid BYTEA NOT NULL,
                                      targetctxtid BYTEA NOT NULL,
                                      subid1 BYTEA NOT NULL,
                                      subid2 BYTEA NOT NULL,
                                      state SMALLINT NOT NULL,
                                      CONSTRAINT PK_metamodelright PRIMARY KEY (roleid,actionid,targetid,targetctxtid,subid1,subid2),
                                      CONSTRAINT FK_metamodelright_role_roleid FOREIGN KEY(roleid) REFERENCES "ADOxx".role_mfb(roleid) ON DELETE CASCADE);
CREATE INDEX immr_target ON "ADOxx".metamodelright(targetid,targetctxtid);
CREATE INDEX immr_targetctxt ON "ADOxx".metamodelright(targetctxtid);
                                
CREATE TABLE "ADOxx".activities(trackedaction SMALLINT NOT NULL,
                                  contextid BYTEA NOT NULL,
                                  instanceid BYTEA NOT NULL,
                                  classoractorid BYTEA NOT NULL,
                                  actionid BYTEA NOT NULL,
                                  sessionid BYTEA NOT NULL,
                                  actiontime TIMESTAMP NOT NULL,
                                  flag SMALLINT NULL,
                                  CONSTRAINT PK_activities PRIMARY KEY (trackedaction,contextid,classoractorid,instanceid,actionid));                             
CREATE INDEX iact_acttime ON "ADOxx".activities (actiontime);
CREATE INDEX iact_tract_acttime ON "ADOxx".activities (trackedaction,actiontime);


CREATE TABLE "ADOxx".admin_change_transact(transactid BYTEA NOT NULL,
                                         author VARCHAR(440) NOT NULL,
                                         logversion SMALLINT NOT NULL,
                                         CONSTRAINT PK_admin_change_transact PRIMARY KEY (transactid));
CREATE INDEX iatr_author ON "ADOxx".admin_change_transact(author);

CREATE TABLE "ADOxx".admin_change_history(transactid BYTEA NOT NULL,
-- commented out (-9223372036854775808, 1) in following line
-- and chose ALWAYS, because a user-specified value shouldn't take precedence
-- (a user-specified value takes only precedence if the insert statement specifies OVERRIDING SYSTEM VALUE)
                                        actionorder BIGINT GENERATED ALWAYS AS IDENTITY /*(-9223372036854775808, 1)*/ NOT NULL,
                                        actiontime TIMESTAMP NOT NULL,
                                        actiontype INTEGER NOT NULL,
                                        actortype SMALLINT NULL,
                                        actor VARCHAR(440) NULL,
                                        target VARCHAR(3750) NULL,
                                        globalctxtid BYTEA NULL,
                                        localctxt VARCHAR(3750) NULL,
                                        langid VARCHAR(10) NULL,
                                        oldvalue TEXT NULL,
                                        newvalue TEXT NULL,
-- commented out CLUSTERED in following line
                                        CONSTRAINT PK_admin_change_history PRIMARY KEY /*CLUSTERED*/ (actionorder),
                                        CONSTRAINT FK_achist_actran_transactid FOREIGN KEY(transactid) REFERENCES "ADOxx".admin_change_transact(transactid) ON DELETE CASCADE);
CREATE INDEX iach_transactid ON "ADOxx".admin_change_history(transactid);
CREATE INDEX iach_actiontype ON "ADOxx".admin_change_history(actiontype);
CREATE INDEX iach_actiontime ON "ADOxx".admin_change_history(actiontime);
CREATE INDEX iach_actortype_actor ON "ADOxx".admin_change_history(actortype, actor);

CREATE TABLE "ADOxx".admin_change_transact_arch(transactid BYTEA NOT NULL,
                                              author VARCHAR(440) NOT NULL,
                                              logversion SMALLINT NOT NULL,
                                              CONSTRAINT PK_admin_change_transact_arch PRIMARY KEY (transactid));
CREATE INDEX iatr_author_arch ON "ADOxx".admin_change_transact_arch(author);

CREATE TABLE "ADOxx".admin_change_history_arch(transactid BYTEA NOT NULL,
                                             actionorder BIGINT NOT NULL,
                                             actiontime TIMESTAMP NOT NULL,
                                             actiontype INTEGER NOT NULL,
                                             actortype SMALLINT NULL,
                                             actor VARCHAR(440) NULL,
                                             target VARCHAR(3750) NULL,
                                             globalctxtid BYTEA NULL,
                                             localctxt VARCHAR(3750) NULL,
                                             langid VARCHAR(10) NULL,
                                             oldvalue TEXT NULL,
                                             newvalue TEXT NULL,
-- commented out CLUSTERED in following line
                                             CONSTRAINT PK_admin_change_history_arch PRIMARY KEY /*CLUSTERED*/ (actionorder));
CREATE INDEX iach_transactid_arch ON "ADOxx".admin_change_history_arch(transactid);
CREATE INDEX iach_actiontype_arch ON "ADOxx".admin_change_history_arch(actiontype);
CREATE INDEX iach_actiontime_arch ON "ADOxx".admin_change_history_arch(actiontime);
CREATE INDEX iach_actortype_actor_arch ON "ADOxx".admin_change_history_arch(actortype, actor);

CREATE TABLE "ADOxx".directories(id BYTEA NOT NULL,
                                 name VARCHAR(255) NOT NULL,
                                 parentid BYTEA,
                                 info VARCHAR(3500),
                                 repoid INT NULL,
                                 CONSTRAINT PK_directories PRIMARY KEY (id),
                                 CONSTRAINT dir_parentdir FOREIGN KEY(parentid) REFERENCES "ADOxx".directories(id)); -- ON DELETE CASCADE cannot be used, SQLServer does not allow potential cycles, code ensures consistency
CREATE UNIQUE INDEX idir_name_parentid_repoid ON "ADOxx".directories(name, parentid, repoid);
CREATE INDEX idir_repoid ON "ADOxx".directories(repoid);

CREATE TABLE "ADOxx".files(id BYTEA NOT NULL,
                           name VARCHAR(255) NOT NULL,
                           parentid BYTEA,
                           info VARCHAR(3500),
                           repoid INT NULL,
                           CONSTRAINT PK_files PRIMARY KEY (id),
                           CONSTRAINT FK_files_repo_repoid FOREIGN KEY (repoid) REFERENCES "ADOxx".repository(realrepoid) ON DELETE CASCADE,
                           CONSTRAINT file_parentdir FOREIGN KEY(parentid) REFERENCES "ADOxx".directories(id) ON DELETE CASCADE);
CREATE UNIQUE INDEX ifiles_name_parentid_repoid ON "ADOxx".files(name, parentid, repoid);
CREATE INDEX ifiles_parentid ON "ADOxx".files(parentid);
CREATE INDEX ifiles_repoid ON "ADOxx".files(repoid);

CREATE TABLE "ADOxx".dms_metadata(id BYTEA NOT NULL,
                                 repoid BYTEA NOT NULL,
                                 ownerid BYTEA NOT NULL,
                                 langid VARCHAR(3750) NOT NULL,
                                 actiontime TIMESTAMP NOT NULL CONSTRAINT DF_dms_metadata_actiontime DEFAULT (NOW() AT TIME ZONE 'UTC'),
-- commented out NONCLUSTERED in following line
                                 CONSTRAINT PK_dms_metadata PRIMARY KEY /*NONCLUSTERED*/ (id),
                                 CONSTRAINT FK_dms_metadata_files_id FOREIGN KEY (id) REFERENCES "ADOxx".files(id) ON DELETE CASCADE);
-- commented out CLUSTERED in following line
CREATE /*CLUSTERED*/ INDEX cix_dms_metadata_owner_repo ON "ADOxx".dms_metadata(ownerid,repoid);

-- commented out CLUSTERED in following line
CREATE TABLE "ADOxx".filedata(id BYTEA NOT NULL,
                             sm CHAR(1),
                             data BYTEA,
                             CONSTRAINT PK_filedata PRIMARY KEY (id),
                             CONSTRAINT FK_filedata_files_id FOREIGN KEY (id) REFERENCES "ADOxx".files(id) ON DELETE CASCADE);
                             
CREATE TABLE "ADOxx".generic_data(dataid BYTEA NOT NULL,
                            subid BYTEA,
                            flags INTEGER NOT NULL,
                            strdata TEXT,
                            bindata BYTEA);
                             
-- commented out CLUSTERED in following line
CREATE /*CLUSTERED*/ UNIQUE INDEX igendata_dataid_subid ON "ADOxx".generic_data (dataid,subid);
CREATE INDEX igendata_subid ON "ADOxx".generic_data (subid);

CREATE TABLE "ADOxx".dep_activities(repoid INTEGER NOT NULL,
                                    relepiid BYTEA NOT NULL,
                                    broken SMALLINT NOT NULL,
                                    epdefid BYTEA NOT NULL,
                                    modelid BYTEA NULL,
                                    modeltypeid BYTEA NULL,
                                    ownerid BYTEA NULL,
                                    ownertype SMALLINT NOT NULL,
                                    ownerclassid BYTEA NOT NULL,
                                    targetclassid BYTEA NOT NULL,
                                    targetinstid BYTEA NOT NULL,
                                    targettype SMALLINT NOT NULL,
                                    twinepid BYTEA NOT NULL,
                                    proxyid BYTEA NOT NULL,
                                    actiontime TIMESTAMP NOT NULL,
                                    action SMALLINT NOT NULL);
-- commented out CLUSTERED in following line	
CREATE /*CLUSTERED*/ INDEX cix_depact_acttime ON "ADOxx".dep_activities (actiontime);

CREATE TABLE "ADOxx".del_val(ownerid BYTEA NOT NULL,
                              repoid INTEGER NOT NULL,
                              ownertype SMALLINT NOT NULL,
                              actiontime TIMESTAMP NOT NULL CONSTRAINT DF_del_val_actiontime DEFAULT /*CONVERT(TIMESTAMP,*/'1900-01-01 00:00:00'/*,120)*/,
                              CONSTRAINT PK_del_val PRIMARY KEY (repoid,ownerid));
CREATE INDEX idelval_acttime ON "ADOxx".del_val (actiontime);

CREATE TABLE "ADOxx".delayedaction(artefactid BYTEA NOT NULL,
                              repoid INT NOT NULL,
                              actiontype SMALLINT NOT NULL,
                              sourceid BYTEA NOT NULL,
                              targetid BYTEA NOT NULL,
                              actionorder INTEGER NOT NULL,
                              actiondata VARCHAR(3750) NULL,
-- commented out NONCLUSTERED in following line	
                              CONSTRAINT PK_delayedaction PRIMARY KEY /*NONCLUSTERED*/ (artefactid,repoid,sourceid,actiontype));
-- commented out CLUSTERED in following line	
CREATE /*CLUSTERED*/ INDEX cix_dact_repo_artefact_order ON "ADOxx".delayedaction (repoid,artefactid,actionorder);
CREATE INDEX idact_trgid_repoid_acttype ON "ADOxx".delayedaction (targetid,repoid,actiontype);
CREATE INDEX idact_srcid_repoid ON "ADOxx".delayedaction (sourceid,repoid);

-- RWF Archive Tables --> START
CREATE TABLE "ADOxx".valowner_mod_arch(ownerid INTEGER NOT NULL,
                                  defid BYTEA NOT NULL,
                                  rootatvaltypeid BYTEA NOT NULL,
                                  iscomplex SMALLINT NOT NULL,
                                  CONSTRAINT PK_valowner_mod_arch PRIMARY KEY (ownerid, defid),
                                  CONSTRAINT FK_vmod_arch_mod_ownerid FOREIGN KEY(ownerid) REFERENCES "ADOxx".model(modelid) ON DELETE NO ACTION);
CREATE INDEX ivalomod_defid_arch ON "ADOxx".valowner_mod_arch(defid);

CREATE TABLE "ADOxx".valowner_ri_arch(ownerid INTEGER NOT NULL,
                                 defid BYTEA NOT NULL,
                                 rootatvaltypeid BYTEA NOT NULL,
                                 iscomplex SMALLINT NOT NULL,
                                 CONSTRAINT PK_valowner_ri_arch PRIMARY KEY (ownerid, defid),
                                 CONSTRAINT FK_vri_arch_ri_ownerid FOREIGN KEY(ownerid) REFERENCES "ADOxx".repoinst(repoinstid) ON DELETE NO ACTION);
CREATE INDEX ivalori_defid_arch ON "ADOxx".valowner_ri_arch(defid);

CREATE TABLE "ADOxx".valowner_mi_arch(ownerid INTEGER NOT NULL,
                                 defid BYTEA NOT NULL,
                                 rootatvaltypeid BYTEA NOT NULL,
                                 iscomplex SMALLINT NOT NULL,
                                 CONSTRAINT PK_valowner_mi_arch PRIMARY KEY (ownerid, defid),
                                 CONSTRAINT FK_vmi_arch_mi_ownerid FOREIGN KEY(ownerid) REFERENCES "ADOxx".modelinst(modinstid) ON DELETE NO ACTION);
CREATE INDEX ivalomi_defid_arch ON "ADOxx".valowner_mi_arch(defid);

CREATE TABLE "ADOxx".sval_mod_arch(ownerid INTEGER NOT NULL,
                              defid BYTEA NOT NULL,
                              ctxtinstid INTEGER NOT NULL,
                              creationid BYTEA NOT NULL,
                              modtime INTEGER,
                              intval INTEGER,
                              doubleval DECIMAL(28,6),
                              strval VARCHAR(3750),
                              longstrval TEXT,
                              metaval TEXT,
                              flag INTEGER NOT NULL,
                              CONSTRAINT PK_sval_mod_arch PRIMARY KEY (ownerid,defid,ctxtinstid),
                              CONSTRAINT FK_svmod_arch_vmod_owner FOREIGN KEY(ownerid,defid) REFERENCES "ADOxx".valowner_mod_arch(ownerid,defid) ON DELETE CASCADE);
CREATE INDEX isvalmod_ctxt_arch ON "ADOxx".sval_mod_arch(ctxtinstid);

CREATE TABLE "ADOxx".sval_ri_arch(ownerid INTEGER NOT NULL,
                             defid BYTEA NOT NULL,
                             ctxtinstid INTEGER NOT NULL,
                             creationid BYTEA NOT NULL,
                             modtime INTEGER,
                             intval INTEGER,
                             doubleval DECIMAL(28,6),
                             strval VARCHAR(3750),
                             longstrval TEXT,
                             metaval TEXT,
                             flag INTEGER NOT NULL,
                             CONSTRAINT PK_sval_ri_arch PRIMARY KEY (ownerid,defid,ctxtinstid),
                             CONSTRAINT FK_svri_arch_vri_owner FOREIGN KEY(ownerid,defid) REFERENCES "ADOxx".valowner_ri_arch(ownerid,defid) ON DELETE CASCADE);
CREATE INDEX isvalri_ctxt_arch ON "ADOxx".sval_ri_arch(ctxtinstid);

CREATE TABLE "ADOxx".sval_mi_arch(ownerid INTEGER NOT NULL,
                             defid BYTEA NOT NULL,
                             ctxtinstid INTEGER NOT NULL,
                             creationid BYTEA NOT NULL,
                             modtime INTEGER,
                             intval INTEGER,
                             doubleval DECIMAL(28,6),
                             strval VARCHAR(3750),
                             longstrval TEXT,
                             metaval TEXT,
                             flag INTEGER NOT NULL,
                             CONSTRAINT PK_sval_mi_arch PRIMARY KEY (ownerid,defid,ctxtinstid),
                             CONSTRAINT FK_svmi_arch_vmi_owner FOREIGN KEY(ownerid,defid) REFERENCES "ADOxx".valowner_mi_arch(ownerid,defid) ON DELETE CASCADE);
CREATE INDEX isvalmi_ctxt_arch ON "ADOxx".sval_mi_arch(ctxtinstid);

CREATE TABLE "ADOxx".cval_mod_arch(valid BYTEA NOT NULL,
                             ownerid INTEGER NOT NULL,
                             defid BYTEA NOT NULL,
                             ctxtinstid INTEGER NOT NULL,
                             attrvaltypeid BYTEA NOT NULL,
                             preid BYTEA NOT NULL,
                             iscmplx SMALLINT NOT NULL,
                             creationid BYTEA NOT NULL,
                             modtime INTEGER,
                             creationtime INTEGER,
                             intval INTEGER,
                             doubleval DECIMAL(28,6),
                             strval VARCHAR(3750),
                             longstrval TEXT,
                             flag INTEGER NOT NULL,
                             CONSTRAINT PK_cval_mod_arch PRIMARY KEY (valid),
                             CONSTRAINT FK_cvmod_arch_vmod_owner FOREIGN KEY(ownerid,defid) REFERENCES "ADOxx".valowner_mod_arch(ownerid,defid) ON DELETE CASCADE);
--ALTER TABLE "ADOxx".cval_mod_arch ADD CONSTRAINT fkcvalmod_avt_arch FOREIGN KEY (attrvaltypeid) REFERENCES "ADOxx".attrvaltype (attrvaltypeid) ON DELETE NO ACTION;
CREATE INDEX icvalmod_owner_ctxt_arch ON "ADOxx".cval_mod_arch (ownerid,defid,ctxtinstid);
CREATE INDEX icvalmod_ctxt_arch ON "ADOxx".cval_mod_arch(ctxtinstid);

CREATE TABLE "ADOxx".cval_ri_arch(valid BYTEA NOT NULL,
                             ownerid INTEGER NOT NULL,
                             defid BYTEA NOT NULL,
                             ctxtinstid INTEGER NOT NULL,
                             attrvaltypeid BYTEA NOT NULL,
                             preid BYTEA NOT NULL,
                             iscmplx SMALLINT NOT NULL,
                             creationid BYTEA NOT NULL,
                             modtime INTEGER,
                             creationtime INTEGER,
                             intval INTEGER,
                             doubleval DECIMAL(28,6),
                             strval VARCHAR(3750),
                             longstrval TEXT,
                             flag INTEGER NOT NULL,
                             CONSTRAINT PK_cval_ri_arch PRIMARY KEY (valid),
                             CONSTRAINT FK_cvri_arch_vri_owner FOREIGN KEY(ownerid,defid) REFERENCES "ADOxx".valowner_ri_arch(ownerid,defid) ON DELETE CASCADE);
--ALTER TABLE "ADOxx".cval_ri_arch ADD CONSTRAINT fkcvalri_avt_arch FOREIGN KEY (attrvaltypeid) REFERENCES "ADOxx".attrvaltype (attrvaltypeid) ON DELETE NO ACTION;
CREATE INDEX icvalri_owner_ctxt_arch ON "ADOxx".cval_ri_arch (ownerid,defid,ctxtinstid);
CREATE INDEX icvalri_ctxt_arch ON "ADOxx".cval_ri_arch(ctxtinstid);

CREATE TABLE "ADOxx".cval_mi_arch(valid BYTEA NOT NULL,
                             ownerid INTEGER NOT NULL,
                             defid BYTEA NOT NULL,
                             ctxtinstid INTEGER NOT NULL,
                             attrvaltypeid BYTEA NOT NULL,
                             preid BYTEA NOT NULL,
                             iscmplx SMALLINT NOT NULL,
                             creationid BYTEA NOT NULL,
                             modtime INTEGER,
                             creationtime INTEGER,
                             intval INTEGER,
                             doubleval DECIMAL(28,6),
                             strval VARCHAR(3750),
                             longstrval TEXT,
                             flag INTEGER NOT NULL,
                             CONSTRAINT PK_cval_mi_arch PRIMARY KEY (valid),
                             CONSTRAINT FK_cvmi_arch_vmi_owner FOREIGN KEY(ownerid,defid) REFERENCES "ADOxx".valowner_mi_arch(ownerid,defid) ON DELETE CASCADE);
--ALTER TABLE "ADOxx".cval_mi_arch ADD CONSTRAINT fkcvalmi_avt_arch FOREIGN KEY (attrvaltypeid) REFERENCES "ADOxx".attrvaltype (attrvaltypeid) ON DELETE NO ACTION;
CREATE INDEX icvalmi_owner_arch ON "ADOxx".cval_mi_arch (ownerid,defid,ctxtinstid);
CREATE INDEX icvalmi_ctxt_arch ON "ADOxx".cval_mi_arch(ctxtinstid);

-- RWF Archive Tables <-- END

CREATE FUNCTION "ADOxx".delLib() RETURNS trigger AS
$$
BEGIN 
  DELETE FROM "ADOxx".name WHERE "ADOxx".name.objid = OLD.libid; 
  DELETE FROM "ADOxx".identifiertext WHERE "ADOxx".identifiertext.objid = OLD.libid; 
  DELETE FROM "ADOxx".objattrdefs WHERE "ADOxx".objattrdefs.objid = OLD.libid; 
  DELETE FROM "ADOxx".valowner_lib WHERE "ADOxx".valowner_lib.ownerid = OLD.libid; 
  DELETE FROM "ADOxx".metamodelright WHERE "ADOxx".metamodelright.targetctxtid = OLD.libid;
  RETURN OLD;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER delLib AFTER DELETE ON "ADOxx".library
FOR EACH ROW
EXECUTE PROCEDURE "ADOxx".delLib();

CREATE FUNCTION "ADOxx".delModTyp() RETURNS trigger AS
$$
BEGIN 
  DELETE FROM "ADOxx".name WHERE "ADOxx".name.objid = OLD.modtypeid; 
  DELETE FROM "ADOxx".identifiertext WHERE "ADOxx".identifiertext.objid = OLD.modtypeid; 
  DELETE FROM "ADOxx".libobjs WHERE "ADOxx".libobjs.objid = OLD.modtypeid; 
  DELETE FROM "ADOxx".direct_libobjs WHERE "ADOxx".direct_libobjs.objid = OLD.modtypeid; 
  DELETE FROM "ADOxx".objattrdefs WHERE "ADOxx".objattrdefs.objid = OLD.modtypeid; 
  DELETE FROM "ADOxx".valowner_lib WHERE "ADOxx".valowner_lib.ownerid = OLD.modtypeid; 
  DELETE FROM "ADOxx".cardinality WHERE "ADOxx".cardinality.objectid = OLD.modtypeid; 
  DELETE FROM "ADOxx".metamodelright WHERE "ADOxx".metamodelright.targetid = OLD.modtypeid; 
  DELETE FROM "ADOxx".metamodelright WHERE "ADOxx".metamodelright.targetctxtid = OLD.modtypeid; 
  RETURN OLD;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER delModTyp AFTER DELETE ON "ADOxx".modeltype 
FOR EACH ROW
EXECUTE PROCEDURE "ADOxx".delModTyp();


CREATE FUNCTION "ADOxx".delClass() RETURNS trigger AS
$$
BEGIN 
  DELETE FROM "ADOxx".name WHERE "ADOxx".name.objid = OLD.classid; 
  DELETE FROM "ADOxx".identifiertext WHERE "ADOxx".identifiertext.objid = OLD.classid; 
  DELETE FROM "ADOxx".objattrdefs WHERE "ADOxx".objattrdefs.objid = OLD.classid; 
  DELETE FROM "ADOxx".libobjs WHERE "ADOxx".libobjs.objid = OLD.classid; 
  DELETE FROM "ADOxx".direct_libobjs WHERE "ADOxx".direct_libobjs.objid = OLD.classid; 
  DELETE FROM "ADOxx".valowner_lib WHERE "ADOxx".valowner_lib.ownerid = OLD.classid; 
  DELETE FROM "ADOxx".cardinality WHERE "ADOxx".cardinality.objectid = OLD.classid; 
  DELETE FROM "ADOxx".metamodelright WHERE "ADOxx".metamodelright.targetid = OLD.classid; 
  DELETE FROM "ADOxx".metamodelright WHERE "ADOxx".metamodelright.targetctxtid = OLD.classid; 
  DELETE FROM "ADOxx".metamodelright WHERE "ADOxx".metamodelright.subid1 = OLD.classid; 
  DELETE FROM "ADOxx".metamodelright WHERE "ADOxx".metamodelright.subid2 = OLD.classid; 
  RETURN OLD;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER delClass AFTER DELETE ON "ADOxx".class 
FOR EACH ROW
EXECUTE PROCEDURE "ADOxx".delClass();


CREATE FUNCTION "ADOxx".delEndpntDef() RETURNS trigger AS
$$
BEGIN 
  DELETE FROM "ADOxx".name WHERE "ADOxx".name.objid = OLD.endpointdefid; 
  DELETE FROM "ADOxx".identifiertext WHERE "ADOxx".identifiertext.objid = OLD.endpointdefid; 
  DELETE FROM "ADOxx".objattrdefs WHERE "ADOxx".objattrdefs.objid = OLD.endpointdefid; 
  DELETE FROM "ADOxx".valowner_lib WHERE "ADOxx".valowner_lib.ownerid = OLD.endpointdefid; 
  DELETE FROM "ADOxx".libobjs WHERE "ADOxx".libobjs.objid = OLD.endpointdefid; 
  DELETE FROM "ADOxx".direct_libobjs WHERE "ADOxx".direct_libobjs.objid = OLD.endpointdefid; 
  DELETE FROM "ADOxx".metamodelright WHERE "ADOxx".metamodelright.targetctxtid = OLD.endpointdefid; 
  RETURN OLD;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER delEndpntDef AFTER DELETE ON "ADOxx".endpointdef 
FOR EACH ROW
EXECUTE PROCEDURE "ADOxx".delEndpntDef();


CREATE FUNCTION "ADOxx".delAttrValTyp() RETURNS trigger AS 
$$
BEGIN 
  DELETE FROM "ADOxx".name WHERE "ADOxx".name.objid = OLD.attrvaltypeid; 
  DELETE FROM "ADOxx".identifiertext WHERE "ADOxx".identifiertext.objid = OLD.attrvaltypeid; 
  RETURN OLD;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER delAttrValTyp AFTER DELETE ON "ADOxx".attrvaltype 
FOR EACH ROW
EXECUTE PROCEDURE "ADOxx".delAttrValTyp();


CREATE FUNCTION "ADOxx".delAttrTyp() RETURNS trigger AS 
$$
BEGIN 
  DELETE FROM "ADOxx".name WHERE "ADOxx".name.objid = OLD.attrtypeid; 
  DELETE FROM "ADOxx".identifiertext WHERE "ADOxx".identifiertext.objid = OLD.attrtypeid; 
  DELETE FROM "ADOxx".libobjs WHERE "ADOxx".libobjs.objid = OLD.attrtypeid; 
  DELETE FROM "ADOxx".attrvaltype WHERE "ADOxx".attrvaltype.rootid = OLD.rootatvaltypeid; 
  DELETE FROM "ADOxx".valowner_lib WHERE "ADOxx".valowner_lib.ownerid = OLD.attrtypeid; 
  RETURN OLD;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER delAttrTyp AFTER DELETE ON "ADOxx".attrtype 
FOR EACH ROW
EXECUTE PROCEDURE "ADOxx".delAttrTyp();


CREATE FUNCTION "ADOxx".delAttrDef() RETURNS trigger AS 
$$
BEGIN 
  DELETE FROM "ADOxx".name WHERE "ADOxx".name.objid = OLD.attrdefid; 
  DELETE FROM "ADOxx".identifiertext WHERE "ADOxx".identifiertext.objid = OLD.attrdefid; 
  DELETE FROM "ADOxx".libobjs WHERE "ADOxx".libobjs.objid = OLD.attrdefid; 
  DELETE FROM "ADOxx".valowner_lib WHERE "ADOxx".valowner_lib.defid = OLD.attrdefid; 
  DELETE FROM "ADOxx".permissions WHERE "ADOxx".permissions.objectid = OLD.attrdefid; 
  DELETE FROM "ADOxx".metamodelright WHERE "ADOxx".metamodelright.targetid = OLD.attrdefid; 
  RETURN OLD;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER delAttrDef AFTER DELETE ON "ADOxx".attrdef 
FOR EACH ROW
EXECUTE PROCEDURE "ADOxx".delAttrDef();


CREATE FUNCTION "ADOxx".delContextParam() RETURNS trigger AS
$$
BEGIN 
  DELETE FROM "ADOxx".name WHERE "ADOxx".name.objid = OLD.paramid; 
  DELETE FROM "ADOxx".identifiertext WHERE "ADOxx".identifiertext.objid = OLD.paramid; 
  DELETE FROM "ADOxx".libobjs WHERE "ADOxx".libobjs.objid = OLD.paramid; 
  RETURN OLD;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER delContextParam AFTER DELETE ON "ADOxx".contextparam 
FOR EACH ROW
EXECUTE PROCEDURE "ADOxx".delContextParam();


CREATE FUNCTION "ADOxx".delContextDef() RETURNS trigger AS 
$$
BEGIN 
  DELETE FROM "ADOxx".name WHERE "ADOxx".name.objid = OLD.contextdefid; 
  DELETE FROM "ADOxx".identifiertext WHERE "ADOxx".identifiertext.objid = OLD.contextdefid; 
  DELETE FROM "ADOxx".libobjs WHERE "ADOxx".libobjs.objid = OLD.contextdefid;
  RETURN OLD;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER delContextDef AFTER DELETE ON "ADOxx".contextdef 
FOR EACH ROW
EXECUTE PROCEDURE "ADOxx".delContextDef();

CREATE FUNCTION "ADOxx".delCiRepoObj() RETURNS trigger AS 
$$
BEGIN 
  DELETE FROM "ADOxx".contextinst WHERE "ADOxx".contextinst.ctxtinstid=OLD.realctxtinstid; 
  DELETE FROM "ADOxx".permissions WHERE "ADOxx".permissions.contextid=(SELECT r.repoid FROM "ADOxx".repository r WHERE r.realrepoid=OLD.repoid) AND permissions.objectid=OLD.ctxtinstid; 
  RETURN OLD;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER delCiRepoObj AFTER DELETE ON "ADOxx".ci_repoobjs 
FOR EACH ROW
EXECUTE PROCEDURE "ADOxx".delCiRepoObj();


CREATE FUNCTION "ADOxx".delContextInst() RETURNS trigger AS 
$$
BEGIN 
  DELETE FROM "ADOxx".ctxtinstobjs WHERE "ADOxx".ctxtinstobjs.ctxtinstid = OLD.ctxtinstid; 
  DELETE FROM "ADOxx".sval_mod WHERE "ADOxx".sval_mod.ctxtinstid = OLD.ctxtinstid; 
  DELETE FROM "ADOxx".sval_ri WHERE "ADOxx".sval_ri.ctxtinstid = OLD.ctxtinstid; 
  DELETE FROM "ADOxx".sval_mi WHERE "ADOxx".sval_mi.ctxtinstid = OLD.ctxtinstid; 
  DELETE FROM "ADOxx".sval_relepi WHERE "ADOxx".sval_relepi.ctxtinstid = OLD.ctxtinstid; 
  DELETE FROM "ADOxx".cval_mod WHERE "ADOxx".cval_mod.ctxtinstid = OLD.ctxtinstid; 
  DELETE FROM "ADOxx".cval_ri WHERE "ADOxx".cval_ri.ctxtinstid = OLD.ctxtinstid; 
  DELETE FROM "ADOxx".cval_mi WHERE "ADOxx".cval_mi.ctxtinstid = OLD.ctxtinstid; 
  DELETE FROM "ADOxx".cval_relepi WHERE "ADOxx".cval_relepi.ctxtinstid = OLD.ctxtinstid; 
  RETURN OLD;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER delContextInst AFTER DELETE ON "ADOxx".contextinst 
FOR EACH ROW
EXECUTE PROCEDURE "ADOxx".delContextInst();


CREATE FUNCTION "ADOxx".delRole() RETURNS trigger AS 
$$
BEGIN 
  DELETE FROM "ADOxx".identifiertext WHERE "ADOxx".identifiertext.objid = OLD.roleid; 
  RETURN OLD;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER delRole AFTER DELETE ON "ADOxx".role_mfb 
FOR EACH ROW
EXECUTE PROCEDURE "ADOxx".delRole();


CREATE FUNCTION "ADOxx".delRep() RETURNS trigger AS 
$$
BEGIN 
  DELETE FROM "ADOxx".libobjs WHERE "ADOxx".libobjs.objid = OLD.repoid; 
  DELETE FROM "ADOxx".directories WHERE "ADOxx".directories.repoid = OLD.realrepoid; 
  DELETE FROM "ADOxx".valowner_mi_arch WHERE "ADOxx".valowner_mi_arch.ownerid IN (SELECT realmodinstid FROM "ADOxx".mi_repoobjs WHERE repoid = OLD.realrepoid); 
  DELETE FROM "ADOxx".valowner_mod_arch WHERE "ADOxx".valowner_mod_arch.ownerid IN (SELECT realmodelid FROM "ADOxx".mod_repoobjs WHERE repoid = OLD.realrepoid); 
  DELETE FROM "ADOxx".valowner_ri_arch WHERE "ADOxx".valowner_ri_arch.ownerid IN (SELECT realrepoinstid FROM "ADOxx".ri_repoobjs WHERE repoid = OLD.realrepoid); 
  DELETE FROM "ADOxx".ci_repoobjs WHERE "ADOxx".ci_repoobjs.repoid = OLD.realrepoid; 
  DELETE FROM "ADOxx".mod_repoobjs WHERE "ADOxx".mod_repoobjs.repoid = OLD.realrepoid; 
  DELETE FROM "ADOxx".ri_repoobjs WHERE "ADOxx".ri_repoobjs.srcrepoid = OLD.realrepoid; 
  DELETE FROM "ADOxx".ri_repoobjs WHERE "ADOxx".ri_repoobjs.repoid = OLD.realrepoid; 
  DELETE FROM "ADOxx".mi_repoobjs WHERE "ADOxx".mi_repoobjs.repoid = OLD.realrepoid; 
  DELETE FROM "ADOxx".relepi_repoobjs WHERE "ADOxx".relepi_repoobjs.repoid = OLD.realrepoid; 
  DELETE FROM "ADOxx".hg_repoobjs WHERE "ADOxx".hg_repoobjs.repoid = OLD.realrepoid; 
  DELETE FROM "ADOxx".permissions WHERE "ADOxx".permissions.objectid = OLD.repoid; 
  DELETE FROM "ADOxx".permissions WHERE "ADOxx".permissions.contextid = OLD.repoid; 
  DELETE FROM "ADOxx".name WHERE "ADOxx".name.objid=OLD.repoid; 
  DELETE FROM "ADOxx".identifiertext WHERE "ADOxx".identifiertext.objid=OLD.repoid;   
  DELETE FROM "ADOxx".dep_activities WHERE "ADOxx".dep_activities.repoid=OLD.realrepoid; 
  DELETE FROM "ADOxx".del_val WHERE "ADOxx".del_val.repoid=OLD.realrepoid; 
  DELETE FROM "ADOxx".delayedaction WHERE "ADOxx".delayedaction.repoid=OLD.realrepoid; 
  RETURN OLD;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER delRep AFTER DELETE ON "ADOxx".repository 
FOR EACH ROW
EXECUTE PROCEDURE "ADOxx".delRep();


CREATE FUNCTION "ADOxx".delModRepoObj() RETURNS trigger AS 
$$
BEGIN 
  DELETE FROM "ADOxx".model WHERE "ADOxx".model.modelid=OLD.realmodelid; 
  DELETE FROM "ADOxx".mi_repoobjs WHERE "ADOxx".mi_repoobjs.repoid=OLD.repoid AND "ADOxx".mi_repoobjs.realmodinstid IN (SELECT mi.modinstid FROM "ADOxx".modelinst mi WHERE mi.modelid=OLD.modelid); 
  DELETE FROM "ADOxx".groupobjsctxtspec WHERE "ADOxx".groupobjsctxtspec.objid=OLD.modelid AND EXISTS (SELECT hg_ro.realgroupid FROM "ADOxx".hg_repoobjs hg_ro WHERE hg_ro.realgroupid="ADOxx".groupobjsctxtspec.groupid AND hg_ro.repoid=OLD.repoid); 
  DELETE FROM "ADOxx".permissions WHERE "ADOxx".permissions.contextid=(SELECT r.repoid FROM "ADOxx".repository r WHERE r.realrepoid=OLD.repoid) AND "ADOxx".permissions.objectid=OLD.modelid; 
  DELETE FROM "ADOxx".delayedaction WHERE "ADOxx".delayedaction.artefactid=OLD.modelid AND "ADOxx".delayedaction.repoid=OLD.repoid; 
  RETURN OLD;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER delModRepoObj AFTER DELETE ON "ADOxx".mod_repoobjs 
FOR EACH ROW
EXECUTE PROCEDURE "ADOxx".delModRepoObj();


CREATE FUNCTION "ADOxx".delModel() RETURNS trigger AS 
$$
BEGIN 
  DELETE FROM "ADOxx".valowner_mod WHERE "ADOxx".valowner_mod.ownerid = OLD.modelid; 
  RETURN OLD;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER delModel AFTER DELETE ON "ADOxx".model 
FOR EACH ROW
EXECUTE PROCEDURE "ADOxx".delModel();


CREATE FUNCTION "ADOxx".delRiRepoObj() RETURNS trigger AS 
$$
BEGIN 
  DELETE FROM "ADOxx".repoinst WHERE NOT EXISTS (SELECT ro.realrepoinstid FROM "ADOxx".ri_repoobjs ro WHERE ro.realrepoinstid=OLD.realrepoinstid) AND "ADOxx".repoinst.repoinstid = OLD.realrepoinstid; 
  DELETE FROM "ADOxx".mi_repoobjs WHERE "ADOxx".mi_repoobjs.repoid=OLD.repoid AND "ADOxx".mi_repoobjs.realmodinstid IN (SELECT mi.modinstid FROM "ADOxx".modelinst mi WHERE mi.repoinstid=OLD.repoinstid); 
  DELETE FROM "ADOxx".relepi_repoobjs WHERE "ADOxx".relepi_repoobjs.repoid=OLD.repoid AND "ADOxx".relepi_repoobjs.realrelepiid IN (SELECT relepi.relepiid FROM "ADOxx".relendpntinst relepi WHERE relepi.ownerid=OLD.repoinstid); 
  DELETE FROM "ADOxx".groupobjsctxtspec WHERE "ADOxx".groupobjsctxtspec.objid=OLD.repoinstid AND EXISTS (SELECT hg_ro.realgroupid FROM "ADOxx".hg_repoobjs hg_ro WHERE hg_ro.realgroupid="ADOxx".groupobjsctxtspec.groupid AND hg_ro.repoid=OLD.repoid); 
  DELETE FROM "ADOxx".permissions WHERE "ADOxx".permissions.contextid=(SELECT r.repoid FROM "ADOxx".repository r WHERE r.realrepoid=OLD.repoid) AND "ADOxx".permissions.objectid=OLD.repoinstid; 
  DELETE FROM "ADOxx".permissions WHERE OLD.repoid=1 AND "ADOxx".permissions.actorid=OLD.repoinstid; 
  DELETE FROM "ADOxx".rolemember WHERE OLD.repoid=1 AND "ADOxx".rolemember.memberid=OLD.repoinstid AND "ADOxx".rolemember.isgroup=0; 
  DELETE FROM "ADOxx".delayedaction WHERE "ADOxx".delayedaction.artefactid=OLD.repoinstid AND "ADOxx".delayedaction.repoid=OLD.repoid; 
  RETURN OLD;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER delRiRepoObj AFTER DELETE ON "ADOxx".ri_repoobjs 
FOR EACH ROW
EXECUTE PROCEDURE "ADOxx".delRiRepoObj();


CREATE FUNCTION "ADOxx".delRepInst() RETURNS trigger AS  
$$
BEGIN 
  DELETE FROM "ADOxx".valowner_ri  WHERE "ADOxx".valowner_ri.ownerid=OLD.repoinstid; 
  RETURN OLD;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER delRepInst AFTER DELETE ON "ADOxx".repoinst
FOR EACH ROW
EXECUTE PROCEDURE "ADOxx".delRepInst();


CREATE FUNCTION "ADOxx".delMiRepoObj() RETURNS trigger AS  
$$
BEGIN 
  INSERT INTO "ADOxx".del_val (repoid,ownerid,ownertype,actiontime) VALUES (OLD.repoid, OLD.modinstid, 4, CAST('1900-01-01 00:00:00' AS timestamp)); 
  DELETE FROM "ADOxx".modelinst  WHERE "ADOxx".modelinst.modinstid=OLD.realmodinstid; 
  DELETE FROM "ADOxx".relepi_repoobjs  WHERE "ADOxx".relepi_repoobjs.repoid=OLD.repoid AND "ADOxx".relepi_repoobjs.realrelepiid IN (SELECT relepi.relepiid FROM "ADOxx".relendpntinst relepi WHERE relepi.ownerid=OLD.modinstid); 
  DELETE FROM "ADOxx".permissions  WHERE "ADOxx".permissions.contextid=(SELECT r.repoid FROM "ADOxx".repository r WHERE r.realrepoid=OLD.repoid) AND "ADOxx".permissions.objectid=OLD.modinstid; 
  RETURN OLD;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER delMiRepoObj AFTER DELETE ON "ADOxx".mi_repoobjs
FOR EACH ROW
EXECUTE PROCEDURE "ADOxx".delMiRepoObj();


CREATE FUNCTION "ADOxx".delModInst() RETURNS trigger AS  
$$
BEGIN 
  DELETE FROM "ADOxx".valowner_mi  WHERE "ADOxx".valowner_mi.ownerid=OLD.modinstid; 
  RETURN OLD;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER delModInst AFTER DELETE ON "ADOxx".modelinst
FOR EACH ROW
EXECUTE PROCEDURE "ADOxx".delModInst();


CREATE FUNCTION "ADOxx".delRepiRepoObj() RETURNS trigger AS 
$$
BEGIN 
  INSERT INTO "ADOxx".dep_activities
    SELECT OLD.repoid,
           OLD.relepiid,
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
           CURRENT_TIMESTAMP AT TIME ZONE 'UTC',
           0
    FROM "ADOxx".relendpntinst relepi
    WHERE relepi.relepiid = OLD.realrelepiid;
  --DELETE FROM "ADOxx".relendpntinst WHERE "ADOxx".relendpntinst.relepiid = OLD.realrelepiid; 
  RETURN OLD;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER delRepiRepoObj AFTER DELETE ON "ADOxx".relepi_repoobjs
FOR EACH ROW
EXECUTE PROCEDURE "ADOxx".delRepiRepoObj();


CREATE FUNCTION "ADOxx".delRelEpInst() RETURNS trigger AS  
$$
BEGIN 
  DELETE FROM "ADOxx".valowner_relepi vo WHERE vo.ownerid=OLD.relepiid;
  INSERT INTO "ADOxx".dep_activities
    SELECT relepi_ro.repoid,
           relepi_ro.relepiid,
           OLD.broken,
           OLD.epdefid,
           OLD.modelid,
           OLD.modeltypeid,
           OLD.ownerid,
           OLD.ownertype,
           OLD.ownerclassid,
           OLD.targetclassid,
           OLD.targetinstid,
           OLD.targettype,
           OLD.twinepid,
           OLD.proxyid,
           CURRENT_TIMESTAMP AT TIME ZONE 'UTC',
           0
           FROM "ADOxx".relepi_repoobjs relepi_ro
           WHERE relepi_ro.realrelepiid = OLD.relepiid;
  RETURN OLD;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER delRelEpInst AFTER DELETE ON "ADOxx".relendpntinst
FOR EACH ROW
EXECUTE PROCEDURE "ADOxx".delRelEpInst();


CREATE FUNCTION "ADOxx".upsertRelEpInst() RETURNS trigger AS  
$$
DECLARE 
  v_action INTEGER := 0; 
BEGIN 
  IF TG_OP = 'UPDATE' THEN 
    IF (OLD.broken <> NEW.broken) THEN 
      v_action := (v_action + 1) - (v_action & 1);      
    END IF; 
    IF (OLD.twinepid <> NEW.twinepid) THEN 
      v_action := (v_action + 2) - (v_action & 2); 
    END IF; 
    IF (OLD.targetinstid <> NEW.targetinstid) THEN 
      v_action := (v_action + 4) - (v_action & 4); 
    END IF; 
  ELSE 
    v_action := 8; 
  END IF; 

  IF (v_action <> 0) THEN 
    INSERT INTO "ADOxx".dep_activities 
      SELECT relepi_ro.repoid, 
             relepi_ro.relepiid,
             NEW.broken,
             NEW.epdefid,
             NEW.modelid,
             NEW.modeltypeid,
             NEW.ownerid,
             NEW.ownertype,
             NEW.ownerclassid,
             NEW.targetclassid,
             NEW.targetinstid,
             NEW.targettype,
             NEW.twinepid,
             NEW.proxyid,
             CURRENT_TIMESTAMP AT TIME ZONE 'UTC',
             v_action 
             FROM "ADOxx".relepi_repoobjs relepi_ro 
             WHERE relepi_ro.realrelepiid = NEW.relepiid; 
  END IF; 
  RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER upsertRelEpInst AFTER INSERT OR UPDATE ON "ADOxx".relendpntinst
FOR EACH ROW
EXECUTE PROCEDURE "ADOxx".upsertRelEpInst();


CREATE FUNCTION "ADOxx".delHgRepoObj() RETURNS trigger AS  
$$
BEGIN 
  DELETE FROM "ADOxx".hiergroup_ctxtspec  WHERE "ADOxx".hiergroup_ctxtspec.groupid = OLD.realgroupid; 
  DELETE FROM "ADOxx".permissions  WHERE "ADOxx".permissions.contextid=(SELECT r.repoid FROM "ADOxx".repository r WHERE r.realrepoid=OLD.repoid) AND "ADOxx".permissions.actorid=OLD.groupid; 
  DELETE FROM "ADOxx".permissions  WHERE "ADOxx".permissions.contextid=(SELECT r.repoid FROM "ADOxx".repository r WHERE r.realrepoid=OLD.repoid) AND "ADOxx".permissions.objectid=OLD.groupid; 
  DELETE FROM "ADOxx".rolemember  WHERE OLD.repoid=1 AND "ADOxx".rolemember.memberid=OLD.groupid AND "ADOxx".rolemember.isgroup=1; 
  RETURN OLD;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER delHgRepoObj AFTER DELETE ON "ADOxx".hg_repoobjs
FOR EACH ROW
EXECUTE PROCEDURE "ADOxx".delHgRepoObj();


CREATE FUNCTION "ADOxx".delGroupCtxtSpec() RETURNS trigger AS  
$$
BEGIN 
  DELETE FROM "ADOxx".name  WHERE "ADOxx".name.objid = OLD.groupid; 
  DELETE FROM "ADOxx".identifiertext  WHERE "ADOxx".identifiertext.objid = OLD.groupid; 
  RETURN OLD;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER delGroupCtxtSpec AFTER DELETE ON "ADOxx".hiergroup_ctxtspec
FOR EACH ROW
EXECUTE PROCEDURE "ADOxx".delGroupCtxtSpec();


CREATE FUNCTION "ADOxx".updInstancename() RETURNS trigger AS  
$$
BEGIN 
  NEW.actiontime = CURRENT_TIMESTAMP AT TIME ZONE 'UTC'; 
  RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER updInstancename BEFORE UPDATE ON "ADOxx".instancename 
FOR EACH ROW
WHEN (pg_trigger_depth() < 1)
EXECUTE PROCEDURE "ADOxx".updInstancename();


CREATE FUNCTION "ADOxx".delSValMi() RETURNS trigger AS 
$$
BEGIN 
  UPDATE "ADOxx".mi_repoobjs SET actiontime=CAST('1900-01-01 00:00:00' AS timestamp)  WHERE OLD.ownerid=mi_repoobjs.realmodinstid; 
  RETURN OLD;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER delSValMi AFTER DELETE ON "ADOxx".sval_mi
FOR EACH ROW
EXECUTE PROCEDURE "ADOxx".delSValMi();


CREATE FUNCTION "ADOxx".delCValMi() RETURNS trigger AS  
$$
BEGIN 
  UPDATE "ADOxx".mi_repoobjs SET actiontime=CAST('1900-01-01 00:00:00' AS timestamp)  WHERE OLD.ownerid=mi_repoobjs.realmodinstid; 
  RETURN OLD;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER delCValMi AFTER DELETE ON "ADOxx".cval_mi
FOR EACH ROW
EXECUTE PROCEDURE "ADOxx".delCValMi();


CREATE FUNCTION "ADOxx".upsertSValMi() RETURNS trigger AS  
$$
BEGIN 
  UPDATE "ADOxx".mi_repoobjs SET actiontime=CAST('1900-01-01 00:00:00' AS timestamp) WHERE mi_repoobjs.realmodinstid=NEW.ownerid; 
  RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER upsertSValMi AFTER INSERT OR UPDATE ON "ADOxx".sval_mi
FOR EACH ROW
EXECUTE PROCEDURE "ADOxx".upsertSValMi();


CREATE FUNCTION "ADOxx".upsertCValMi() RETURNS trigger AS  
$$
BEGIN 
  UPDATE "ADOxx".mi_repoobjs SET actiontime=CAST('1900-01-01 00:00:00' AS timestamp) WHERE mi_repoobjs.realmodinstid=NEW.ownerid; 
  RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER upsertCValMi AFTER INSERT OR UPDATE ON "ADOxx".cval_mi
FOR EACH ROW
EXECUTE PROCEDURE "ADOxx".upsertCValMi();


CREATE FUNCTION "ADOxx".updSValRelepi() RETURNS trigger AS  
$$
BEGIN 
  NEW.actiontime = CURRENT_TIMESTAMP AT TIME ZONE 'UTC'; 
  RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER updSValRelepi BEFORE UPDATE ON "ADOxx".sval_relepi
FOR EACH ROW
WHEN (pg_trigger_depth() < 1)
EXECUTE PROCEDURE "ADOxx".updSValRelepi();


CREATE FUNCTION "ADOxx".delAdminChangeTranArch() RETURNS trigger AS  
$$
BEGIN 
  DELETE FROM "ADOxx".admin_change_history_arch  WHERE "ADOxx".admin_change_history_arch.transactid = OLD.transactid; 
  RETURN OLD;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER delAdminChangeTranArch AFTER DELETE ON "ADOxx".admin_change_transact_arch
FOR EACH ROW
EXECUTE PROCEDURE "ADOxx".delAdminChangeTranArch();


CREATE FUNCTION "ADOxx".updDMSMetadata() RETURNS trigger AS  
$$
BEGIN 
  NEW.actiontime = CURRENT_TIMESTAMP AT TIME ZONE 'UTC'; 
  RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER updDMSMetadata BEFORE UPDATE ON "ADOxx".dms_metadata
FOR EACH ROW
WHEN (pg_trigger_depth() < 1)
EXECUTE PROCEDURE "ADOxx".updDMSMetadata();

CREATE FUNCTION "ADOxx".insertMiRepoobjs() RETURNS trigger AS 
$$
BEGIN 
  DELETE FROM "ADOxx".del_val WHERE "ADOxx".del_val.repoid = NEW.repoid AND "ADOxx".del_val.ownerid = NEW.modinstid;
  RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER insertMiRepoobjs AFTER INSERT ON "ADOxx".mi_repoobjs
FOR EACH ROW
WHEN (pg_trigger_depth() < 1)
EXECUTE PROCEDURE "ADOxx".insertMiRepoobjs();

GRANT SELECT ON "ADOxx".dbinfo TO "ADOXX_BOOT";
