
drop table if exists users cascade;
create table Users
(
    UID    uuid                        not null,
    NAME   user_name                   not null unique,
    MAIL   email_address               not null unique,
    PASS   valid_password              not null,
    PHONE  phone_number,
    UTYPE  user_type                   not null,
    ELIMIT user_edit_number_limitation not null, -- todo change during editing
    primary key (UID)
);

drop table if exists crew cascade;
create table Crew
(
    CID   uuid          not null,
    NAME  user_name     not null,
    MAIL  email_address not null unique,
    PHONE phone_number,
    BYEAR valid_year,
    BMON  valid_month,
    BDAY  valid_day,
    DYEAR valid_year,
    DMON  valid_month,
    DDAY  valid_day,
    SEX   sex           not null,
    ISDIR boolean       not null,
    ISPRO boolean       not null,
    ISACT boolean       not null,
    ISWRT boolean       not null,
    primary key (CID)
);

drop table if exists film cascade;
create table Film
(
    FID   uuid        not null,
    NAME  movie_name  not null,
    FYR   valid_year,
    TYR   valid_year,
    LANG  varchar(64),
    DUR   normal_number,
    GENRE genre,
    BUDG  million_dollar,
    PLOTL link,
    REVEN million_dollar,
    AGER  mpa_film_rating,
    TSTMP modify_date not null,
    ISSER boolean     not null,
    DIRID uuid,
    primary key (FID),
    unique (NAME, FYR, TYR),
    foreign key (DIRID) references Crew (CID) on update cascade on delete cascade
);

drop table if exists season cascade;
create table Season
(
    FID   uuid          not null,
    SNUM  normal_number not null,
    EPCNT normal_number,
    primary key (FID, SNUM),
    unique (FID, SNUM),
    foreign key (FID) references Film (FID) on update cascade on delete cascade
);

drop table if exists trailerlink cascade;
create table TrailerLink
(
    FID  uuid not null,
    LINK link not null,
    primary key (FID, LINK),
    unique (FID, LINK),
    foreign key (FID) references Film (FID) on update cascade on delete cascade
);

drop table if exists picturelink cascade;
create table PictureLink
(
    FID  uuid not null,
    LINK link not null,
    primary key (FID, LINK),
    unique (FID, LINK),
    foreign key (FID) references Film (FID) on update cascade on delete cascade
);

drop table if exists country cascade;
create table Country
(
    FID  uuid        not null,
    NAME varchar(64) not null,
    primary key (FID, NAME),
    unique (FID, NAME),
    foreign key (FID) references Film (FID) on update cascade on delete cascade
);

drop table if exists Review cascade;
create table Review
(
    UID   uuid not null,
    FID   uuid not null,
    RATE  rate not null,
    DESCL link,
    primary key (UID, FID),
    unique (UID, FID),
    foreign key (UID) references Users (UID),
    foreign key (FID) references Film (FID)
);

drop table if exists interestedin cascade;
create table InterestedIn
(
    UID uuid not null,
    FID uuid not null,
    primary key (UID, FID),
    unique (UID, FID),
    foreign key (UID) references Users (UID),
    foreign key (FID) references Film (FID)
);

drop table if exists firstRole cascade;
create table FirstRole
(
    CID uuid not null,
    FID uuid not null,
    primary key (CID, FID),
    unique (CID, FID),
    foreign key (CID) references Crew (CID),
    foreign key (FID) references Film (FID)
);

drop table if exists acts cascade;
create table Acts
(
    CID uuid not null,
    FID uuid not null,
    primary key (CID, FID),
    unique (CID, FID),
    foreign key (CID) references Crew (CID),
    foreign key (FID) references Film (FID)
);

drop table if exists writes cascade;
create table Writes
(
    CID uuid not null,
    FID uuid not null,
    primary key (CID, FID),
    unique (CID, FID),
    foreign key (CID) references Crew (CID),
    foreign key (FID) references Film (FID)
);

drop table if exists produces cascade;
create table Produces
(
    CID uuid not null,
    FID uuid not null,
    primary key (CID, FID),
    unique (CID, FID),
    foreign key (CID) references Crew (CID),
    foreign key (FID) references Film (FID)
);

drop table if exists award cascade;
create table Award
(
    TITLE multi_word_name not null, -- todo checking with real names by trigger
    FEST  multi_word_name not null, -- todo checking with real names by trigger
    YEAR  valid_year      not null,
    FID   uuid            not null,
    CID   uuid            not null,
    primary key (TITLE, FEST, FID, CID),
    unique (TITLE, FEST, FID, CID),
    foreign key (CID) references Crew (CID),
    foreign key (FID) references Film (FID)
);