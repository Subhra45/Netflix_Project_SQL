-- Netflix Project

drop table if exists netflix;

create table if not exists netflix
(
	show_id	varchar(6),
	type varchar(20),
	title varchar (150),
	director varchar(208),
	casts varchar(1000),
	country	varchar(150),
	date_added varchar(50),
	release_year int,
	rating varchar(10),
	duration varchar(15),	
	listed_in varchar(100),
	description varchar(250)
);

select * from netflix;