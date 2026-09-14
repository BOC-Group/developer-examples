INSERT INTO ADOxx.dbinfo(type,val2) VALUES (3,'2')
INSERT INTO ADOxx.dbinfo(type,val2) VALUES (4,'ADOxx 5.5')
INSERT INTO ADOxx.dbinfo(type,val) VALUES (5, '{11111111-1111-1111-1111-111111111111}')

INSERT INTO ADOxx.lastid(type,lastid) VALUES (0,-2147483000)
INSERT INTO ADOxx.lastid(type,lastid) VALUES (1,-2147483000)
INSERT INTO ADOxx.lastid(type,lastid) VALUES (2,-2147483000)
INSERT INTO ADOxx.lastid(type,lastid) VALUES (3,-2147483000)
INSERT INTO ADOxx.lastid(type,lastid) VALUES (4,-2147483000)
INSERT INTO ADOxx.lastid(type,lastid) VALUES (6,0)

/* Insert data for objects shared by multiple repositories */
INSERT INTO ADOxx.repository(realrepoid, repoid) VALUES (22, 0x22222222222222222222222222222222)
INSERT INTO ADOxx.repository(realrepoid, repoid) VALUES (33, 0x33333333333333333333333333333333)
INSERT INTO ADOxx.repository(realrepoid, repoid) VALUES (44, 0x44444444444444444444444444444444)
INSERT INTO ADOxx.ri_repoobjs(repoid,repoinstid,realrepoinstid,srcrepoid) VALUES (22, 0x55555555555555555555555555555555, -2147483500, 22)
INSERT INTO ADOxx.ri_repoobjs(repoid,repoinstid,realrepoinstid,srcrepoid) VALUES (44, 0x55555555555555555555555555555555, -2147483500, 22)
/* Insert a duplicate object (not shared) */
INSERT INTO ADOxx.ri_repoobjs(repoid,repoinstid,realrepoinstid,srcrepoid) VALUES (33, 0x55555555555555555555555555555555, -2147483499, 33)

