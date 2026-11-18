create table account (
	account_id	int generated always as identity primary key,
	username	varchar(50) not null unique,
	password_hash	varchar(255) not null
);

create table profile (
	prof_id	int generated always as identity primary key,
	tagline	varchar(100)
);

create table person (
	id		int generated always as identity primary key,
	account_id	int not null unique,
	fname		varchar(20),
	lname		varchar(20),
	prof_id	int,
foreign key	(account_id) references account,
foreign key	(prof_id) references profile
);

create table person_address (
	person_id	int,
	street_num	varchar(10),
	street_name	varchar(20),
	city		varchar(20),
	country	varchar(20),
	postal		varchar(10),
	primary key	(person_id, street_num, street_name, city, country, postal),
	foreign key	(person_id) references person
);

create table person_email (
	person_id	int,
	email		varchar(50),
	primary key	(person_id, email),
	foreign key	(person_id) references person
);


create table person_phone (
	person_id	int,
	phone		varchar(15),
	primary key	(person_id, phone),
	foreign key	(person_id) references person
);

create table following (
	person_id		int,
	follows_person_id	int,
	check 			(person_id <> follows_person_id),
	primary key		(person_id, follows_person_id),
	foreign key		(person_id) references person,
	foreign key		(follows_person_id) references person
);

create table organization (
	org_id		int generated always as identity primary key,
	account_id	int not null unique,
	title		varchar(20),
	prof_id	int,
foreign key (account_id) references account,
foreign key	(prof_id) references profile
);

create table following_org (
	person_id		int,
	follows_org_id	int,
	primary key		(person_id, follows_org_id),
	foreign key		(person_id) references person,
	foreign key		(follows_org_id) references organization
);

create table membership (
	person_id	int,
	org_id		int,
	role		varchar(20),
	primary key	(person_id, org_id, role),
	foreign key	(person_id) references person,
	foreign key	(org_id) references organization
);

create table org_address (
	org_id		int,
	street_num	varchar(10),
	street_name	varchar(20),
	city		varchar(20),
	country	varchar(20),
	postal		varchar(10),
	primary key	(org_id, street_num, street_name, city, country, postal),
	foreign key	(org_id) references organization
);

create table org_email (
	org_id		int,
email		varchar(50),
primary key	(org_id, email),
	foreign key	(org_id) references organization
);

create table org_phone (
	org_id		int,
phone		varchar(15),
primary key	(org_id, phone),
	foreign key	(org_id) references organization
);


create table project (
	proj_id	int generated always as identity primary key,
	title		varchar(255),
	descr		text
);

create table profile_project (
	prof_id	int,
	proj_id	int,
	primary key	(prof_id, proj_id),
	foreign key	(prof_id) references profile,
	foreign key	(proj_id) references project
);


create table project_member (
	proj_id	int,
	member_id	int,
	is_lead	boolean,
	primary key 	(proj_id, member_id),
	foreign key	(proj_id) references project,
	foreign key	(member_id) references person
);

create table tag (
	tag_id		int generated always as identity primary key,
	content	varchar(255)
);

create table profile_tag (
	prof_id 	int,
	tag_id		int,
	primary key	(prof_id, tag_id),
	foreign key	(prof_id) references profile,
	foreign key	(tag_id) references tag
);

create table post (
	post_id 	int generated always as identity primary key,
	person_id	int,
	text		text,
	datetime	timestamptz,
	foreign key 	(person_id) references person
);

create table post_media (
	post_id	int,
	media		text,
	primary key	(post_id, media),
	foreign key	(post_id) references post
);

create table post_comment (
	comment_id	int generated always as identity,
	post_id	int,
	responder_id	int,
	text		text,
	datetime	timestamptz,
	media		text,
	primary key 	(comment_id, post_id),
	foreign key	(post_id) references post,
	foreign key 	(responder_id) references person
);

create type reaction_value as enum ('dislike', 'none', 'like');

create table post_reaction (
	post_id	int,
	reactor_id	int,
	datetime	timestamptz,
	value		reaction_value, 
	primary key 	(post_id, reactor_id, datetime),
	foreign key 	(post_id) references post,
	foreign key 	(reactor_id) references person
);

create table comment_reaction (
	comment_id	int,
	post_id	int,
	reactor_id	int,
	datetime	timestamptz,
	value		reaction_value,
	primary key	(comment_id, post_id, reactor_id, datetime),
	foreign key 	(comment_id, post_id) references post_comment,
	foreign key 	(reactor_id) references person
);
