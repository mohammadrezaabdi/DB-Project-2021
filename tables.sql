-- table making queries
drop table if exists Users;
create table Users
(
    UID    bigserial not null unique,
    NAME   text      not null unique,
    MAIL   text      not null, -- set trigger for validation
    PASS   text      not null, -- set trigger for hashing
    PHONE  text,               -- set trigger for validation
    UTYPE  char(1)   not null,
    ELIMIT smallint,           -- set default
    primary key (UID)
);

drop table if exists Crew;
create table Crew
(
    CID   bigserial not null unique,
    NAME  text      not null,
    MAIL  text      not null, -- set trigger for validation
    PHONE text,               -- set trigger for validation
    BY    smallint,           -- set constraint
    BM    char(3),            -- set constraint
    BD    smallint,           -- set constraint
    DY    smallint,           -- set constraint
    DM    char(3),            -- set constraint
    DD    smallint,           -- set constraint
    SEX   char(1),            -- set constraint
    ISDIR boolean   not null, --set trigger for some one at least has a job
    ISPRO boolean   not null,
    ISACT boolean   not null,
    ISWRT boolean   not null,
    primary key (CID)
);

drop table if exists Film;
create table Film
(
    FID   serial4 not null unique,
    NAME  text    not null unique,
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
    DIRID integer,          -- set trigger for existence
    primary key (FID),
    foreign key (DIRID) references Crew (CID) on update cascade on delete cascade
);

drop table if exists Season;
create table Season
(
    FID   integer  not null,
    SNUM  smallint not null, -- set constraint
    EPCNT smallint,          -- set constraint
    primary key (FID, SNUM),
    unique (FID, SNUM),
    foreign key (FID) references Film (FID) on update cascade on delete cascade
);

drop table if exists TrailerLink;
create table TrailerLink
(
    FID  integer not null,
    LINK text    not null,
    primary key (FID, LINK),
    unique (FID, LINK),
    foreign key (FID) references Film (FID) on update cascade on delete cascade
);

drop table if exists PictureLink;
create table PictureLink
(
    FID  integer not null,
    LINK text    not null,
    primary key (FID, LINK),
    unique (FID, LINK),
    foreign key (FID) references Film (FID) on update cascade on delete cascade
);

drop table if exists Country;
create table Country
(
    FID  integer     not null,
    NAME varchar(20) not null, -- set constraint for existence
    primary key (FID, NAME),
    unique (FID, NAME),
    foreign key (FID) references Film (FID) on update cascade on delete cascade
);

drop table if exists Review;
create table Review
(
    UID   bigint        not null,
    FID   integer       not null,
    RATE  numeric(3, 1) not null, -- set constraint
    DESCL text,
    primary key (UID, FID),
    unique (UID, FID),
    foreign key (UID) references Users (UID),
    foreign key (FID) references Film (FID)
);

drop table if exists InterestedIn;
create table InterestedIn
(
    UID bigint  not null,
    FID integer not null,
    primary key (UID, FID),
    unique (UID, FID),
    foreign key (UID) references Users (UID),
    foreign key (FID) references Film (FID)
);

drop table if exists FirstRole;
create table FirstRole
(
    CID bigint  not null,
    FID integer not null,
    primary key (CID, FID),
    unique (CID, FID),
    foreign key (CID) references Crew (CID),
    foreign key (FID) references Film (FID)
);

drop table if exists Acts;
create table Acts
(
    CID bigint  not null,
    FID integer not null,
    primary key (CID, FID),
    unique (CID, FID),
    foreign key (CID) references Crew (CID),
    foreign key (FID) references Film (FID)
);

drop table if exists Writes;
create table Writes
(
    CID bigint  not null,
    FID integer not null,
    primary key (CID, FID),
    unique (CID, FID),
    foreign key (CID) references Crew (CID),
    foreign key (FID) references Film (FID)
);

drop table if exists Produces;
create table Produces
(
    CID bigint  not null,
    FID integer not null,
    primary key (CID, FID),
    unique (CID, FID),
    foreign key (CID) references Crew (CID),
    foreign key (FID) references Film (FID)
);

drop table if exists Award;
create table Award
(
    TITLE varchar(40) not null, -- set constraint
    FEST  varchar(20) not null, -- set constraint
    YEAR  smallint    not null, -- set constraint
    FID   integer     not null,
    CID   bigint      not null,
    primary key (TITLE, FEST, FID, CID),
    unique (TITLE, FEST, FID, CID),
    foreign key (CID) references Crew (CID),
    foreign key (FID) references Film (FID)
);