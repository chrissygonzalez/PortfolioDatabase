-- Seed data for a freshly created database.
-- Identity columns are left out of the inserts, so ids are assigned 1, 2, 3...
-- in insert order. The ids used in later tables assume an empty database.
--
-- Every account's password is: password123  (Werkzeug scrypt hashes)

-- ---------- accounts ----------
-- 1-5 are people, 6-7 are organizations
insert into account (username, password_hash) values
('alice',      'scrypt:32768:8:1$HrkZkBbXXGUE0LVY$b5c793bf0d8d46a726c1c234f1102cb1ce9e1796d6972c164d182492dffb588877ab1b4c7a5b1526eaf648ce9f0c84410409470017bd264b7c9e2acda138652f'),
('bob',        'scrypt:32768:8:1$Bexq76uZHvDN6LW2$1ed00888d781b3e54033cd8b0875e1cfbdcdaaf34b1524cf2b8446091fba94c8ef96cc2b7c78ba2ee1fdd5b7443e1f0d3f65932d1785890ef4dddffc389728e0'),
('carmen',     'scrypt:32768:8:1$GfDgAwSEnTPv7fOy$ffc3b8a31f12c17c7ad3445908d1fe45a13a9774fbcc3d04dc9e513ce4d4ab1599d48faac9bafc572af2c89a3e7268c110e4348b4c03246e42bdf8bbf7477e02'),
('dev',        'scrypt:32768:8:1$mhPn5eAEE4VhZRFf$a0900550940a9236a3b58c7f9b680cf0e9801cad6faf0988e37e0eb4c48e4adb2db0fa0c26fa6c13f0d2348c9908c9eb936b9e3c15034acb47ad94f62a45b2fc'),
('emi',        'scrypt:32768:8:1$6QOueQVoP0eAsLe9$c5622f76453c05da7b000000d2176b68fc98f79a65795d513171a7f3b263df25afdc0e3d5f19b4d01ea11937972f8665ac49d15daa2527943e547685385893dc'),
('codeclub',   'scrypt:32768:8:1$aXPD0lFaLs32nTUM$5c535efbdae35236f04cef498b95192a4650d2d5baeb88cd60c25cec94484636826c4a2fdd064114a4248b300d0f82ac8149e2ffddd2c75fdcd653ce255b9ccb'),
('greenhouse', 'scrypt:32768:8:1$tv7iuLIUybCpvxe0$365c2ff0f61bbca44cbc35be1d721c08608cb35c1c1939d52d66b42145bac38e21f98e34db92923869534dacaa1dbe8f4ac0982d0f1cf14fc16cfa570b0c9455');

-- ---------- profiles ----------
-- 1-5 for people, 6-7 for organizations
insert into profile (tagline) values
('Backend dev who loves databases'),
('Designer and part-time photographer'),
('CS student, coffee enthusiast'),
('Building things with Python'),
('Urban gardener and data nerd'),
('A club for people who like to code'),
('Community gardens across the city');

-- ---------- people ----------
insert into person (account_id, fname, lname, prof_id) values
(1, 'Alice',  'Nguyen',   1),
(2, 'Bob',    'Okafor',   2),
(3, 'Carmen', 'Diaz',     3),
(4, 'Dev',    'Patel',    4),
(5, 'Emi',    'Tanaka',   5);

insert into person_address (person_id, street_num, street_name, city, country, postal) values
(1, '12',  'Maple St',     'Toronto',  'Canada', 'M5V 2T6'),
(2, '450', 'Oak Ave',      'Chicago',  'USA',    '60601'),
(3, '8',   'Pine Rd',      'Austin',   'USA',    '73301'),
(4, '77',  'Elm Blvd',     'Seattle',  'USA',    '98101'),
(5, '3',   'Cedar Ln',     'Portland', 'USA',    '97201');

insert into person_email (person_id, email) values
(1, 'alice@example.com'),
(1, 'alice.work@example.com'),
(2, 'bob@example.com'),
(3, 'carmen@example.com'),
(4, 'dev@example.com'),
(5, 'emi@example.com');

insert into person_phone (person_id, phone) values
(1, '416-555-0101'),
(2, '312-555-0102'),
(3, '512-555-0103'),
(4, '206-555-0104'),
(4, '206-555-0199'),
(5, '503-555-0105');

-- who follows whom (person_id follows follows_person_id)
insert into following (person_id, follows_person_id) values
(1, 2), (1, 3),
(2, 1),
(3, 1), (3, 2), (3, 4),
(4, 1),
(5, 1), (5, 3);

-- ---------- organizations ----------
-- org_id is not an identity column, so it's set explicitly
insert into organization (org_id, account_id, title, prof_id) values
(1, 6, 'Code Club',       6),
(2, 7, 'Greenhouse Co-op', 7);

insert into org_address (org_id, street_num, street_name, city, country, postal) values
(1, '100', 'Main St',  'Chicago',  'USA', '60602'),
(2, '25',  'Garden Way', 'Portland', 'USA', '97202');

insert into org_email (org_id, email) values
(1, 'hello@codeclub.example.com'),
(2, 'info@greenhouse.example.com');

insert into org_phone (org_id, phone) values
(1, '312-555-0200'),
(2, '503-555-0300');

insert into following_org (person_id, follows_org_id) values
(1, 1), (2, 1), (3, 1), (4, 1),
(5, 2), (3, 2);

insert into membership (person_id, org_id, role) values
(1, 1, 'organizer'),
(3, 1, 'member'),
(4, 1, 'member'),
(5, 2, 'organizer'),
(3, 2, 'volunteer');

-- ---------- projects ----------
insert into project (title, descr) values
('Study Buddy',   'A web app that matches students for study sessions.'),
('Plant Tracker', 'Track watering and harvests across community gardens.'),
('Club Website',  'The Code Club public site and event calendar.');

insert into profile_project (prof_id, proj_id) values
(1, 1), (3, 1),
(5, 2), (7, 2),
(1, 3), (4, 3), (6, 3);

insert into project_member (proj_id, member_id, is_lead) values
(1, 1, true),  (1, 3, false),
(2, 5, true),
(3, 4, true),  (3, 1, false), (3, 3, false);

-- ---------- tags ----------
insert into tag (content) values
('python'), ('sql'), ('design'), ('gardening'), ('students');

insert into profile_tag (prof_id, tag_id) values
(1, 2), (1, 1),
(2, 3),
(3, 5), (3, 1),
(4, 1),
(5, 4), (5, 2),
(6, 1), (6, 5),
(7, 4);

-- ---------- posts ----------
insert into post (person_id, text, datetime) values
(1, 'Just finished normalizing my schema. Feels good!',            '2026-11-01 09:15:00-05'),
(2, 'New photo series from the lakefront this weekend.',           '2026-11-02 18:40:00-06'),
(3, 'Anyone want to study for the databases midterm together?',    '2026-11-03 20:05:00-06'),
(4, 'Code Club meetup Thursday: intro to Flask.',                  '2026-11-05 12:00:00-08'),
(5, 'First frost tonight, covering the kale beds.',                '2026-11-07 17:30:00-08'),
(1, 'Hot take: always name your columns in INSERT statements.',    '2026-11-10 08:45:00-05');

insert into post_media (post_id, media) values
(2, 'https://example.com/media/lakefront1.jpg'),
(2, 'https://example.com/media/lakefront2.jpg'),
(5, 'https://example.com/media/kale.jpg');

-- comment_id is generated: comments 1-7 in this order
insert into post_comment (post_id, responder_id, text, datetime, media) values
(1, 3, 'What normal form did you end up at?',   '2026-11-01 10:00:00-05', null),
(1, 4, 'Congrats!',                             '2026-11-01 11:30:00-05', null),
(2, 1, 'These are beautiful.',                  '2026-11-02 19:00:00-06', null),
(3, 1, 'I''m in. Library at 6?',                '2026-11-03 20:30:00-06', null),
(3, 4, 'Count me in too.',                      '2026-11-03 21:00:00-06', null),
(5, 3, 'Mine are covered too!',                 '2026-11-07 18:00:00-08', 'https://example.com/media/cover.jpg'),
(6, 2, 'Learned that one the hard way.',        '2026-11-10 09:00:00-05', null);

insert into post_reaction (post_id, reactor_id, datetime, value) values
(1, 2, '2026-11-01 09:30:00-05', 'like'),
(1, 3, '2026-11-01 09:45:00-05', 'like'),
(1, 4, '2026-11-01 10:10:00-05', 'like'),
(2, 1, '2026-11-02 19:05:00-06', 'like'),
(2, 5, '2026-11-02 20:00:00-06', 'like'),
(3, 1, '2026-11-03 20:25:00-06', 'like'),
(3, 2, '2026-11-03 22:00:00-06', 'dislike'),
(4, 1, '2026-11-05 12:30:00-08', 'like'),
(4, 3, '2026-11-05 13:00:00-08', 'none'),
(5, 3, '2026-11-07 17:50:00-08', 'like'),
(6, 2, '2026-11-10 08:55:00-05', 'like'),
(6, 4, '2026-11-10 09:20:00-05', 'dislike');

insert into comment_reaction (comment_id, post_id, reactor_id, datetime, value) values
(1, 1, 1, '2026-11-01 10:05:00-05', 'like'),
(2, 1, 1, '2026-11-01 11:35:00-05', 'like'),
(4, 3, 3, '2026-11-03 20:35:00-06', 'like'),
(5, 3, 3, '2026-11-03 21:05:00-06', 'like'),
(7, 6, 1, '2026-11-10 09:10:00-05', 'like');
