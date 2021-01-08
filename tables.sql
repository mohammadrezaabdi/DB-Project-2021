drop table if exists award;
drop table if exists produces;
drop table if exists writes;
drop table if exists acts;
drop table if exists firstRole;
drop table if exists interestedin;
drop table if exists Review;
drop table if exists country;
drop table if exists picturelink;
drop table if exists trailerlink;
drop table if exists Review;
drop table if exists season;
drop table if exists film;
drop table if exists crew;
drop table if exists users;

-- table making queries
create table Users
(
    UID    uuid    not null,        -- set trigger for assign
    NAME   text    not null unique,
    MAIL   text    not null unique, -- set trigger for validation
    PASS   text    not null,        -- set trigger for hashing
    PHONE  text,                    -- set trigger for validation
    UTYPE  char(1) not null,
    ELIMIT smallint,                -- the default limit fir number of editing for free account
    primary key (UID)
);

create table Crew
(
    CID   uuid    not null,        -- set trigger for assign
    NAME  text    not null,
    MAIL  text    not null unique, -- set trigger for validation
    PHONE text,                    -- set trigger for validation
    BY    smallint,                -- set constraint
    BM    char(3),                 -- set constraint
    BD    smallint,                -- set constraint
    DY    smallint,                -- set constraint
    DM    char(3),                 -- set constraint
    DD    smallint,                -- set constraint
    SEX   char(1),                 -- set constraint
    ISDIR boolean not null,        --set trigger for some one at least has a job
    ISPRO boolean not null,
    ISACT boolean not null,
    ISWRT boolean not null,
    primary key (CID)
);

create table Film
(
    FID   uuid    not null, -- set trigger for assign
    NAME  text    not null,
    FYR   smallint,         -- set constraint
    TYR   smallint,         -- set constraint
    LANG  text,
    DUR   smallint,         -- set constraint
    GENRE text,
    BUDG  numeric(10, 5),   -- set constraint
    PLOTL text,
    REVEN numeric(10, 5),   -- set constraint
    AGER  text,             -- set constraint
    LEDIT date    not null, -- set default
    ISSER boolean not null,
    DIRID uuid,             -- set trigger for existence
    primary key (FID),
    unique (NAME, FYR, TYR),
    foreign key (DIRID) references Crew (CID) on update cascade on delete cascade
);

create table Season
(
    FID   uuid     not null,
    SNUM  smallint not null, -- set constraint
    EPCNT smallint,          -- set constraint
    primary key (FID, SNUM),
    unique (FID, SNUM),
    foreign key (FID) references Film (FID) on update cascade on delete cascade
);

create table TrailerLink
(
    FID  uuid not null,
    LINK text not null,
    primary key (FID, LINK),
    unique (FID, LINK),
    foreign key (FID) references Film (FID) on update cascade on delete cascade
);

create table PictureLink
(
    FID  uuid not null,
    LINK text not null,
    primary key (FID, LINK),
    unique (FID, LINK),
    foreign key (FID) references Film (FID) on update cascade on delete cascade
);

create table Country
(
    FID  uuid        not null,
    NAME varchar(20) not null, -- set constraint for existence
    primary key (FID, NAME),
    unique (FID, NAME),
    foreign key (FID) references Film (FID) on update cascade on delete cascade
);


create table Review
(
    UID   uuid          not null,
    FID   uuid          not null,
    RATE  numeric(3, 1) not null, -- set constraint
    DESCL text,
    primary key (UID, FID),
    unique (UID, FID),
    foreign key (UID) references Users (UID),
    foreign key (FID) references Film (FID)
);

create table InterestedIn
(
    UID uuid not null,
    FID uuid not null,
    primary key (UID, FID),
    unique (UID, FID),
    foreign key (UID) references Users (UID),
    foreign key (FID) references Film (FID)
);


create table FirstRole
(
    CID uuid not null,
    FID uuid not null,
    primary key (CID, FID),
    unique (CID, FID),
    foreign key (CID) references Crew (CID),
    foreign key (FID) references Film (FID)
);


create table Acts
(
    CID uuid not null,
    FID uuid not null,
    primary key (CID, FID),
    unique (CID, FID),
    foreign key (CID) references Crew (CID),
    foreign key (FID) references Film (FID)
);


create table Writes
(
    CID uuid not null,
    FID uuid not null,
    primary key (CID, FID),
    unique (CID, FID),
    foreign key (CID) references Crew (CID),
    foreign key (FID) references Film (FID)
);

create table Produces
(
    CID uuid not null,
    FID uuid not null,
    primary key (CID, FID),
    unique (CID, FID),
    foreign key (CID) references Crew (CID),
    foreign key (FID) references Film (FID)
);

create table Award
(
    TITLE varchar(40) not null, -- set constraint
    FEST  varchar(20) not null, -- set constraint
    YEAR  smallint    not null, -- set constraint
    FID   uuid        not null,
    CID   uuid        not null,
    primary key (TITLE, FEST, FID, CID),
    unique (TITLE, FEST, FID, CID),
    foreign key (CID) references Crew (CID),
    foreign key (FID) references Film (FID)
);