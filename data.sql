/* ===============================================================
   Gotta Love Games — sample instance for A3
   ===============================================================*/

/* ---------- MEMBERS (all club members) ------------------------ */

INSERT INTO member(mid,name,email,los) VALUES
 (1,'Jason','jason@example.com','Undergraduate'),
 (2,'Zach','zach@example.com','Undergraduate'),
 (3,'Josh','josh@example.com','Undergraduate'),
 (4,'Eryka','eryka@example.com','Undergraduate'),
 (5,'Grace','grace@example.com','Undergraduate'),
 (6,'Tawfiq','tawfiq@example.com','Undergraduate'),
 (7,'Jimbo','jimbo@example.com','Undergraduate'),
 (8,'Evelyn','evelyn@example.com','Undergraduate'),
 (9,'Christian','christian@example.com','Undergraduate'),
(10,'Ella','ella@example.com','Undergraduate'),
(11,'Cameron','cameron@example.com','Undergraduate'),
(12,'Honda','honda@example.com','Undergraduate'),
(13,'Justin','justin@example.com','Undergraduate'),
(14,'Ari','ari@example.com','Undergraduate'),
(15,'Max','max@example.com','Undergraduate'),
(16,'Akshay','akshay@example.com','Undergraduate');

/* ---------- EXECUTIVE MEMBERS --------------------------------- */
INSERT INTO exec_member(mid,role,role_start_date) VALUES
 (1,'Organizer','2024-09-01'),
 (2,'Organizer','2024-09-01'),
 (3,'Organizer','2024-09-01'),
 (4,'Organizer','2024-09-01');

/* ---------- BOARD GAMES --------------------------------------- */
INSERT INTO board_game(gid,title,category,min_players,max_players,
                       publisher,release_year)
VALUES
 (1,'Blood on the Clocktower','Social-deduction',5,20,'The Pandemonium Institute',2022),
 (2,'Turing Machine','Strategy',1,2,'Scorpion Masqué',2022),
 (3,'Cascadia','Strategy',1,4,'Flatout Games',2021),
 (4,'Cryptid','Strategy',3,5,'Osprey Games',2018),
 (5,'Avalon','Social-deduction',5,10,'Indie Boards & Cards',2012),
 (6,'7 Wonders','Strategy',3,7,'Repos Production',2010);

/* ---------- PHYSICAL COPIES ----------------------------------- */
INSERT INTO game_copy(cid,gid,acquisition_date,condition) VALUES
 (1,1,'2024-01-15','New'),   -- Blood on the Clocktower
 (2,2,'2024-02-24','New'),   -- Turing Machine
 (3,3,'2024-03-16','New'),   -- Cascadia
 (4,4,'2024-01-21','New'),   -- Cryptid
 (5,5,'2024-06-12','New'),   -- Avalon copy #1
 (6,5,'2024-05-27','New'),   -- Avalon copy #2
 (7,6,'2024-11-22','New'),   -- 7 Wonders copy #1
 (8,6,'2024-12-30','New');   -- 7 Wonders copy #2

/* ---------- EVENT SERIES -------------------------------------- */
INSERT INTO event_series(series_id,name,start_ts,end_ts) VALUES
 (1,'Weekly Boardgame',   '18:00','22:00'),
 (2,'Basement Clocktower','22:00','02:00'),
 (3,'Outdoor Social',     '12:00','16:00');

/* ---------- EVENT OCCURRENCES --------------------------------- */
INSERT INTO event(eid,series_id,event_date,location) VALUES
 (101,1,'2025-03-05','Bahen 1230'),
 (102,1,'2025-03-12','Bahen 1230'),
 (201,2,'2025-03-05','Club Basement'),
 (202,2,'2025-03-12','Club Basement'),
 (301,3,'2024-12-20','Front Campus');

/* ---------- ORGANISING COMMITTEES ----------------------------- */
INSERT INTO event_committee(committee_id,event_series_name) VALUES
 (1,'Weekly Boardgame'),
 (2,'Basement Clocktower'),
 (3,'Outdoor Social');

INSERT INTO committee_member(committee_id,exec_member_id,is_lead) VALUES
 (1,1,TRUE),   -- Jason leads weekly event
 (2,2,TRUE),   -- Zach leads basement event
 (3,3,TRUE),   -- Josh leads outdoor social
 (3,4,FALSE);  -- Eryka helps

/* ---------- GAME SESSIONS ------------------------------------- */
INSERT INTO game_session(sid,event,game_copy,facilitator) VALUES
 -- 5 Mar Weekly
 (1001,101,2,4),   -- Turing Machine, fac. Eryka
 (1002,101,7,1),   -- 7 Wonders,   fac. Jason
 -- 12 Mar Weekly
 (1003,102,3,4),   -- Cascadia,     fac. Eryka
 (1004,102,5,1),   -- Avalon,       fac. Jason
 (1005,102,8,3),   -- 7 Wonders,    fac. Josh
 -- Basement Clocktower (one per occurrence)
 (2001,201,1,2),   -- 5 Mar, fac. Zach
 (2002,202,1,2);   -- 12 Mar, fac. Zach

/* ---------- SESSION PARTICIPANTS ------------------------------ */
-- 5 Mar Weekly
INSERT INTO session_participant(session,participant) VALUES
 (1001,4),(1001,3),(1001,5),                 -- Turing Machine
 (1002,6),(1002,7),(1002,8),(1002,9);        -- 7 Wonders
-- 12 Mar Weekly
INSERT INTO session_participant(session,participant) VALUES
 (1003,4),(1003,5),(1003,8),(1003,10),       -- Cascadia
 (1004,1),(1004,7),(1004,6),(1004,11),
 (1004,2),(1004,12),                         -- Avalon
 (1005,3),(1005,13),(1005,14),(1005,15);     -- 7 Wonders
-- Basement Clocktower
INSERT INTO session_participant(session,participant) VALUES
 (2001,7),(2001,6),(2001,1),(2001,8),(2001,12),(2001,16),
 (2002,7),(2002,6),(2002,1),(2002,8),(2002,12),(2002,16);
