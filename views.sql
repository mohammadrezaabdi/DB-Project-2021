drop view if exists Pro_Acc_Film cascade;
drop view if exists All_Actors cascade;
drop view if exists All_Award cascade;
drop view if exists All_Country cascade;
drop view if exists All_Directors cascade;
drop view if exists All_Pictures cascade;
drop view if exists All_Producers cascade;
drop view if exists All_Writers cascade;
drop view if exists All_Trailers cascade;
drop view if exists Favorite_List cascade;
drop view if exists Female_First_Role cascade;
drop view if exists Male_First_Role cascade;
drop view if exists Free_Acc_Film cascade;
drop view if exists User_Reviews cascade;
drop view if exists Film_Reviews cascade;


create view Pro_Acc_Film
as select FYR, TYR, TSTMP, NAME, LANG, DUR, GENRE, PLOTL, AGER, ISSER, DIRID, SNUM, EPCNT, BUDG, REVEN, avg(RATE)
	from (Film left outer join Season on Film.fid = Season.fid) inner join Review on film.fid = review.fid
    group by Film.fid, snum, epcnt;

create view Free_Acc_Film
	as select FYR, TYR, TSTMP, NAME, LANG, DUR, GENRE, PLOTL, AGER, ISSER, DIRID, SNUM, EPCNT, avg(RATE)
	from (Film left outer join Season on Film.fid = Season.fid) natural join Review;

create view All_Actors
	as select NAME, FID
from Acts natural join Crew;

create view Male_First_Role
	as select NAME, FID
from FirstRole natural join Crew
where  Crew.SEX = 'M';

create view Female_First_Role
	as select NAME, FID
from FirstRole natural join Crew
	where  Crew.SEX = 'F';

create view All_Directors
	as select NAME, FID
from Film natural join Crew;

create view All_Writers
	as select NAME, FID
from Writes natural join Crew;


create view All_Producers
	as select NAME, FID
from Produces natural join Crew;

create view All_Pictures
as select LINK, FID
from PictureLink natural join Film;

create view All_Trailers
as select LINK, FID
from TrailerLink natural join Film;

create view All_Country
as select Country.NAME, Film.FID
from Country inner join Film on Country.FID = Film.FID;

create view All_Award
	as select FID, TITLE, FEST, YEAR, Crew.NAME
	from Award inner join Crew on Crew.CID = Award.CID;

create view User_Reviews
	as select UID, NAME, RATE, DESCL
from Review inner join Film on Review.FID = Film.FID;

create view Film_Reviews
	as select FID, NAME, RATE, DESCL, avg(RATE) as AVG_RATE
	from Review inner join Users on Review.UID = Users.UID;

create view Favorite_List
	as select UID, Film.NAME
	from Film inner join InterestedIn on Film.FID = InterestedIn.FID;