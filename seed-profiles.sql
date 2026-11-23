-- Extra profiles: 6 more people and 2 more organizations.
-- Run after seed.sql. Ids are looked up by username rather than hard-coded,
-- so this works no matter what ids the database has already handed out.
-- It reuses the 'python', 'sql', 'design', 'gardening' and 'students' tags
-- from seed.sql and the people/orgs created there.
--
-- Every account's password is: password123  (Werkzeug scrypt hashes)

begin;

-- ---------- accounts ----------
insert into account (username, password_hash) values
('fatima',     'scrypt:32768:8:1$uexH9DJzvitgMbNJ$eb280c6dce310fdabbce487c9b33315eb2c66a912866ce7e5722240439543b51aa8f4ba8e795c08dd3edad465049a6ec1d94f7045e20b57626fa2958c58cacc1'),
('gus',        'scrypt:32768:8:1$79LZEgUX8RfmPlMo$60e04030ac7d5ecf4763d7264044af2757d25701157ad27a2e5621fe18ab6c7878e27370a1286971c12c7b09f728b9c69eccaa312acdae472acf7015c97b26e8'),
('hana',       'scrypt:32768:8:1$IqAqB0orMX1d5hoc$6a494c4e5445bbbe685110b00641d3698e90e23281fa58022830b4d24891b2b37cf8ad91c6c95840aa2fee26e1baa1b0499d197f5d84b637671f3387449f1215'),
('ivan',       'scrypt:32768:8:1$MaGAhBO36Y4fJxqm$fda9fbeb8481e224c379715c5722bdf311a3642a1e5b4fc590f302fceb54a62a0889f58d63380f5ea39d03fc21de6c3b033c65ad71f74a3ddd62b038005f2152'),
('jade',       'scrypt:32768:8:1$KqVIHLSJAJMyGoMx$aada4083e9621431d75a02711918cbf17d27aa47b1d23d14474c346a8e6178ecb2559244bcbd829b6edc6da169f3a2c6bc091defe32e73a36b18b59440e3a2ef'),
('kofi',       'scrypt:32768:8:1$9qsEQoYJwwFAaKW0$de55000e14d1402d7fc6be8d8ccd4a18fcbb7b803b4c71999bb418ba7fa076e3afc92898d7145ec185503b42d9aba39c67999462ef176fd02c62b7f6f067ac5d'),
('makerspace', 'scrypt:32768:8:1$D6tGoAfXEhOWvUST$8b287bfe60acdd52441184539d606ac172c27fab9ea1172dcfc7a00d421ca6a84b905dec577b1577c83594363d2d44ae6cdfe0022b9d0f183ad3f972b9f0531e'),
('riverrun',   'scrypt:32768:8:1$8GFuSXkoqJmtLPZT$5c90f28089053f58385ae52d6ceff7de1f0166aa19b1898fa71f5fa6819fcd793c9bb3d0857e07da34ceee69d6328ff770eecf56345b7663a6da7f6813a949bc');

-- ---------- people + their profiles ----------
-- Each statement creates a profile and the person who owns it in one go:
-- the CTE inserts the profile and hands its new prof_id to the person insert.
with p as (insert into profile (tagline) values ('Data analyst turning spreadsheets into stories') returning prof_id)
insert into person (account_id, fname, lname, prof_id)
select (select account_id from account where username = 'fatima'), 'Fatima', 'Haddad', prof_id from p;

with p as (insert into profile (tagline) values ('Frontend dev, accessibility advocate') returning prof_id)
insert into person (account_id, fname, lname, prof_id)
select (select account_id from account where username = 'gus'), 'Gus', 'Lindqvist', prof_id from p;

with p as (insert into profile (tagline) values ('Illustrator and UX designer') returning prof_id)
insert into person (account_id, fname, lname, prof_id)
select (select account_id from account where username = 'hana'), 'Hana', 'Kim', prof_id from p;

with p as (insert into profile (tagline) values ('Hardware tinkerer, Arduino and 3D printing') returning prof_id)
insert into person (account_id, fname, lname, prof_id)
select (select account_id from account where username = 'ivan'), 'Ivan', 'Petrov', prof_id from p;

with p as (insert into profile (tagline) values ('Environmental science student who codes') returning prof_id)
insert into person (account_id, fname, lname, prof_id)
select (select account_id from account where username = 'jade'), 'Jade', 'Moreau', prof_id from p;

with p as (insert into profile (tagline) values ('Full-stack dev, mentor at Code Club') returning prof_id)
insert into person (account_id, fname, lname, prof_id)
select (select account_id from account where username = 'kofi'), 'Kofi', 'Mensah', prof_id from p;

-- ---------- organizations + their profiles ----------
with p as (insert into profile (tagline) values ('Shared workshop with tools, classes and open hours') returning prof_id)
insert into organization (account_id, title, prof_id)
select (select account_id from account where username = 'makerspace'), 'Eastside Makerspace', prof_id from p;

with p as (insert into profile (tagline) values ('Volunteers keeping the river clean and monitored') returning prof_id)
insert into organization (account_id, title, prof_id)
select (select account_id from account where username = 'riverrun'), 'River Run Alliance', prof_id from p;

-- ---------- contact info ----------
insert into person_address (person_id, street_num, street_name, city, country, postal)
select pe.id, v.street_num, v.street_name, v.city, v.country, v.postal
from (values
    ('fatima', '210', 'Birch St',    'Toronto',  'Canada', 'M4C 1A1'),
    ('gus',    '9',   'Willow Ct',   'Chicago',  'USA',    '60614'),
    ('hana',   '1500','Spruce Ave',  'Seattle',  'USA',    '98109'),
    ('ivan',   '42',  'Aspen Dr',    'Austin',   'USA',    '78701'),
    ('jade',   '6',   'Fir St',      'Portland', 'USA',    '97205'),
    ('kofi',   '88',  'Walnut Pl',   'Chicago',  'USA',    '60607')
) as v(username, street_num, street_name, city, country, postal)
join account a on a.username = v.username
join person pe on pe.account_id = a.account_id;

insert into person_email (person_id, email)
select pe.id, v.email
from (values
    ('fatima', 'fatima@example.com'),
    ('gus',    'gus@example.com'),
    ('hana',   'hana@example.com'),
    ('hana',   'hana.studio@example.com'),
    ('ivan',   'ivan@example.com'),
    ('jade',   'jade@example.com'),
    ('kofi',   'kofi@example.com')
) as v(username, email)
join account a on a.username = v.username
join person pe on pe.account_id = a.account_id;

insert into person_phone (person_id, phone)
select pe.id, v.phone
from (values
    ('fatima', '416-555-0106'),
    ('gus',    '312-555-0107'),
    ('hana',   '206-555-0108'),
    ('ivan',   '512-555-0109'),
    ('jade',   '503-555-0110'),
    ('kofi',   '312-555-0111')
) as v(username, phone)
join account a on a.username = v.username
join person pe on pe.account_id = a.account_id;

insert into org_address (org_id, street_num, street_name, city, country, postal)
select o.org_id, v.street_num, v.street_name, v.city, v.country, v.postal
from (values
    ('makerspace', '300', 'Factory Rd', 'Austin',   'USA', '78702'),
    ('riverrun',   '14',  'Bridge St',  'Portland', 'USA', '97204')
) as v(username, street_num, street_name, city, country, postal)
join account a on a.username = v.username
join organization o on o.account_id = a.account_id;

insert into org_email (org_id, email)
select o.org_id, v.email
from (values
    ('makerspace', 'hello@makerspace.example.com'),
    ('riverrun',   'team@riverrun.example.com')
) as v(username, email)
join account a on a.username = v.username
join organization o on o.account_id = a.account_id;

insert into org_phone (org_id, phone)
select o.org_id, v.phone
from (values
    ('makerspace', '512-555-0400'),
    ('riverrun',   '503-555-0500')
) as v(username, phone)
join account a on a.username = v.username
join organization o on o.account_id = a.account_id;

-- ---------- tags ----------
insert into tag (content) values
('javascript'), ('accessibility'), ('hardware'), ('data-viz'), ('environment');

-- tag each profile, looked up through the owning person or organization
with owner as (
    select a.username, pe.prof_id from account a join person pe on pe.account_id = a.account_id
    union all
    select a.username, o.prof_id  from account a join organization o on o.account_id = a.account_id
)
insert into profile_tag (prof_id, tag_id)
select owner.prof_id, t.tag_id
from (values
    ('fatima',     'sql'),
    ('fatima',     'python'),
    ('fatima',     'data-viz'),
    ('gus',        'javascript'),
    ('gus',        'accessibility'),
    ('hana',       'design'),
    ('hana',       'accessibility'),
    ('ivan',       'hardware'),
    ('ivan',       'python'),
    ('jade',       'environment'),
    ('jade',       'students'),
    ('jade',       'data-viz'),
    ('kofi',       'javascript'),
    ('kofi',       'python'),
    ('kofi',       'sql'),
    ('makerspace', 'hardware'),
    ('makerspace', 'design'),
    ('riverrun',   'environment'),
    ('riverrun',   'data-viz')
) as v(username, tag)
join owner on owner.username = v.username
join tag t on t.content = v.tag;

-- ---------- social links to existing seed data ----------
insert into following (person_id, follows_person_id)
select p1.id, p2.id
from (values
    ('fatima', 'alice'),
    ('fatima', 'jade'),
    ('gus',    'hana'),
    ('gus',    'kofi'),
    ('hana',   'bob'),
    ('hana',   'gus'),
    ('ivan',   'dev'),
    ('jade',   'emi'),
    ('jade',   'fatima'),
    ('kofi',   'alice'),
    ('kofi',   'gus'),
    ('alice',  'kofi'),
    ('emi',    'jade')
) as v(follower, followee)
join account a1 on a1.username = v.follower join person p1 on p1.account_id = a1.account_id
join account a2 on a2.username = v.followee join person p2 on p2.account_id = a2.account_id;

insert into following_org (person_id, follows_org_id)
select pe.id, o.org_id
from (values
    ('ivan',   'makerspace'),
    ('hana',   'makerspace'),
    ('dev',    'makerspace'),
    ('jade',   'riverrun'),
    ('emi',    'riverrun'),
    ('fatima', 'riverrun'),
    ('kofi',   'codeclub'),
    ('gus',    'codeclub')
) as v(person, org)
join account pa on pa.username = v.person join person pe on pe.account_id = pa.account_id
join account oa on oa.username = v.org    join organization o on o.account_id = oa.account_id;

insert into membership (person_id, org_id, role)
select pe.id, o.org_id, v.role
from (values
    ('ivan',   'makerspace', 'organizer'),
    ('hana',   'makerspace', 'instructor'),
    ('jade',   'riverrun',   'organizer'),
    ('fatima', 'riverrun',   'volunteer'),
    ('kofi',   'codeclub',   'mentor'),
    ('gus',    'codeclub',   'member')
) as v(person, org, role)
join account pa on pa.username = v.person join person pe on pe.account_id = pa.account_id
join account oa on oa.username = v.org    join organization o on o.account_id = oa.account_id;

commit;
