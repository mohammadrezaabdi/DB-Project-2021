drop view if exists Pro_Acc_Film cascade;
create view Pro_Acc_Film
as select FYR, TYR, TSTMP, NAME, LANG, DUR, GENRE, PLOTL, AGER, ISSER, DIRID, SNUM, EPCNT, BUDG, REVEN, avg(RATE) As AVRATE
	from (Film left outer join Season on Film.fid = Season.fid) inner join Review on film.fid = review.fid
    group by Film.fid, snum, epcnt;

drop view if exists Free_Acc_Film cascade;
create view Free_Acc_Film
	as select FYR, TYR, TSTMP, NAME, LANG, DUR, GENRE, PLOTL, AGER, ISSER, DIRID, SNUM, EPCNT, AVRATE
	from Pro_Acc_Film;

drop view if exists All_Actors cascade;
create view All_Actors
	as select NAME, FID
from Acts natural join Crew;

drop view if exists Male_First_Role cascade;
create view Male_First_Role
	as select NAME, FID
from FirstRole natural join Crew
where  Crew.SEX = 'M';

drop view if exists Female_First_Role cascade;
create view Female_First_Role
	as select NAME, FID
from FirstRole natural join Crew
	where  Crew.SEX = 'F';

drop view if exists All_Directors cascade;
create view All_Directors
	as select NAME, FID
from Film natural join Crew;

drop view if exists All_Writers cascade;
create view All_Writers
	as select NAME, FID
from Writes natural join Crew;

drop view if exists All_Producers cascade;
create view All_Producers
	as select NAME, FID
from Produces natural join Crew;

drop view if exists All_Pictures cascade;
create view All_Pictures
as select LINK, FID
from PictureLink natural join Film;

drop view if exists All_Trailers cascade;
create view All_Trailers
as select LINK, FID
from TrailerLink natural join Film;

drop view if exists All_Country cascade;
create view All_Country
as select Country.NAME, Film.FID
from Country inner join Film on Country.FID = Film.FID;

drop view if exists All_Award cascade;
create view All_Award
	as select FID, TITLE, FEST, YEAR, Crew.NAME
	from Award inner join Crew on Crew.CID = Award.CID;

drop view if exists Film_Reviews cascade;
create view Film_Reviews
	as select Review.UID, Users.NAME, RATE, DESCL
from Review inner join Users on Review.UID = Users.UID;

drop view if exists User_Reviews cascade;
create view User_Reviews
	as select Review.FID, NAME, RATE, DESCL
	from Review inner join Film on Review.FID = Film.FID;

drop view if exists Favorite_List cascade;
create view Favorite_List
	as select UID, Film.NAME
	from Film inner join InterestedIn on Film.FID = InterestedIn.FID;
