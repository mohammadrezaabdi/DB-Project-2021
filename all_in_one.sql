--------------- init
create schema if not exists public;
create extension if not exists "uuid-ossp";
create extension if not exists "pgcrypto";

--------------- domains
drop domain if exists multi_word_name cascade;
drop domain if exists set_of_words cascade;
drop domain if exists phone_number cascade;
drop domain if exists email_address cascade;
drop domain if exists user_name cascade;
drop domain if exists link cascade;
drop domain if exists valid_password cascade;
drop domain if exists valid_year cascade;
drop domain if exists valid_month cascade;
drop domain if exists valid_day cascade;
drop domain if exists sex cascade;
drop domain if exists user_type cascade;
drop domain if exists user_edit_number_limitation cascade;
drop domain if exists normal_number cascade;
drop domain if exists mpa_film_rating cascade;
drop domain if exists million_dollar cascade;
drop domain if exists modify_date cascade;
drop domain if exists rate cascade;

create domain multi_word_name as text
    check ( value ~ '([a-zA-Z]+\s)*[a-zA-Z]+$');

create domain set_of_words as text
    check ( value ~ '([a-zA-Z\s]+(\s*,\s*))*[a-zA-Z\s]+$');

create domain phone_number as text
    check ( value ~ '^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$' );

create domain email_address as text
    check ( value ~
            '^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$' );

create domain user_name as text -- just with letters, numbers, _, -
    check ( value ~ '^[A-Za-z0-9]+(?:[ _-][A-Za-z0-9]+)*$');

create domain link as text
    check ( value ~
            '^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$');

create domain valid_password as text -- Minimum eight characters, at least one letter and one number
    check ( value ~ '^(?=.*\d)((?=.*[a-z])|(?=.*[A-Z]))(?=.*[a-zA-Z]).{8,}$');

create domain valid_year as smallint
    check (value >= 1888 and value <= date_part('year', now()));

create domain valid_month as char(3)
    check (upper(value) in ('JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'));

create domain valid_day as smallint
    check (value <= 31 and value >= 1);

create domain sex as char(1)
    check (upper(value) in ('M', 'F'));

create domain user_type as char(1) default 'F'
    check (upper(value) in ('P', 'F'));

create domain user_edit_number_limitation as smallint default 5
    check (value <= 5 and value >= 0);

create domain normal_number as smallint
    check (value > 0);

create domain mpa_film_rating as varchar(5) -- The Motion Picture Association (MPA) film rating system
    check (value in ('G', 'GP', 'PG', 'PG-13', 'R', 'NC-17', 'X', 'M'));

create domain million_dollar as numeric(10, 5)
    check (value >= 0.0);

create domain modify_date as text
    check (value ~ '^\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2}$');

create domain rate as numeric(3, 1)
    check (value >= 0.0 and value <= 10.0);

--------------- tables

drop table if exists award cascade;
drop table if exists produces cascade;
drop table if exists writes cascade;
drop table if exists acts cascade;
drop table if exists firstRole cascade;
drop table if exists interestedin cascade;
drop table if exists Review cascade;
drop table if exists country cascade;
drop table if exists picturelink cascade;
drop table if exists trailerlink cascade;
drop table if exists Review cascade;
drop table if exists season cascade;
drop table if exists film cascade;
drop table if exists crew cascade;
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

create table Film
(
    FID   uuid        not null,
    NAME  text        not null, -- todo set proper regex
    FYR   valid_year,
    TYR   valid_year,
    LANG  varchar(64),
    DUR   normal_number,
    GENRE set_of_words,         -- todo checking with real names by trigger
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

create table Season
(
    FID   uuid          not null,
    SNUM  normal_number not null,
    EPCNT normal_number,
    primary key (FID, SNUM),
    unique (FID, SNUM),
    foreign key (FID) references Film (FID) on update cascade on delete cascade
);

create table TrailerLink
(
    FID  uuid not null,
    LINK link not null,
    primary key (FID, LINK),
    unique (FID, LINK),
    foreign key (FID) references Film (FID) on update cascade on delete cascade
);

create table PictureLink
(
    FID  uuid not null,
    LINK link not null,
    primary key (FID, LINK),
    unique (FID, LINK),
    foreign key (FID) references Film (FID) on update cascade on delete cascade
);

create table Country
(
    FID  uuid        not null,
    NAME varchar(64) not null,
    primary key (FID, NAME),
    unique (FID, NAME),
    foreign key (FID) references Film (FID) on update cascade on delete cascade
);

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

--------------- countries
DROP TABLE IF EXISTS Country_list;
CREATE TABLE Country_list (id VARCHAR(64) NOT NULL, value VARCHAR(64) NOT NULL, PRIMARY KEY(id));

INSERT INTO Country_list ("id", "value") VALUES (E'AF', E'Afghanistan');
INSERT INTO Country_list ("id", "value") VALUES (E'AX', E'Åland Islands');
INSERT INTO Country_list ("id", "value") VALUES (E'AL', E'Albania');
INSERT INTO Country_list ("id", "value") VALUES (E'DZ', E'Algeria');
INSERT INTO Country_list ("id", "value") VALUES (E'AS', E'American Samoa');
INSERT INTO Country_list ("id", "value") VALUES (E'AD', E'Andorra');
INSERT INTO Country_list ("id", "value") VALUES (E'AO', E'Angola');
INSERT INTO Country_list ("id", "value") VALUES (E'AI', E'Anguilla');
INSERT INTO Country_list ("id", "value") VALUES (E'AQ', E'Antarctica');
INSERT INTO Country_list ("id", "value") VALUES (E'AG', E'Antigua & Barbuda');
INSERT INTO Country_list ("id", "value") VALUES (E'AR', E'Argentina');
INSERT INTO Country_list ("id", "value") VALUES (E'AM', E'Armenia');
INSERT INTO Country_list ("id", "value") VALUES (E'AW', E'Aruba');
INSERT INTO Country_list ("id", "value") VALUES (E'AU', E'Australia');
INSERT INTO Country_list ("id", "value") VALUES (E'AT', E'Austria');
INSERT INTO Country_list ("id", "value") VALUES (E'AZ', E'Azerbaijan');
INSERT INTO Country_list ("id", "value") VALUES (E'BS', E'Bahamas');
INSERT INTO Country_list ("id", "value") VALUES (E'BH', E'Bahrain');
INSERT INTO Country_list ("id", "value") VALUES (E'BD', E'Bangladesh');
INSERT INTO Country_list ("id", "value") VALUES (E'BB', E'Barbados');
INSERT INTO Country_list ("id", "value") VALUES (E'BY', E'Belarus');
INSERT INTO Country_list ("id", "value") VALUES (E'BE', E'Belgium');
INSERT INTO Country_list ("id", "value") VALUES (E'BZ', E'Belize');
INSERT INTO Country_list ("id", "value") VALUES (E'BJ', E'Benin');
INSERT INTO Country_list ("id", "value") VALUES (E'BM', E'Bermuda');
INSERT INTO Country_list ("id", "value") VALUES (E'BT', E'Bhutan');
INSERT INTO Country_list ("id", "value") VALUES (E'BO', E'Bolivia');
INSERT INTO Country_list ("id", "value") VALUES (E'BA', E'Bosnia & Herzegovina');
INSERT INTO Country_list ("id", "value") VALUES (E'BW', E'Botswana');
INSERT INTO Country_list ("id", "value") VALUES (E'BV', E'Bouvet Island');
INSERT INTO Country_list ("id", "value") VALUES (E'BR', E'Brazil');
INSERT INTO Country_list ("id", "value") VALUES (E'IO', E'British Indian Ocean Territory');
INSERT INTO Country_list ("id", "value") VALUES (E'VG', E'British Virgin Islands');
INSERT INTO Country_list ("id", "value") VALUES (E'BN', E'Brunei');
INSERT INTO Country_list ("id", "value") VALUES (E'BG', E'Bulgaria');
INSERT INTO Country_list ("id", "value") VALUES (E'BF', E'Burkina Faso');
INSERT INTO Country_list ("id", "value") VALUES (E'BI', E'Burundi');
INSERT INTO Country_list ("id", "value") VALUES (E'KH', E'Cambodia');
INSERT INTO Country_list ("id", "value") VALUES (E'CM', E'Cameroon');
INSERT INTO Country_list ("id", "value") VALUES (E'CA', E'Canada');
INSERT INTO Country_list ("id", "value") VALUES (E'CV', E'Cape Verde');
INSERT INTO Country_list ("id", "value") VALUES (E'BQ', E'Caribbean Netherlands');
INSERT INTO Country_list ("id", "value") VALUES (E'KY', E'Cayman Islands');
INSERT INTO Country_list ("id", "value") VALUES (E'CF', E'Central African Republic');
INSERT INTO Country_list ("id", "value") VALUES (E'TD', E'Chad');
INSERT INTO Country_list ("id", "value") VALUES (E'CL', E'Chile');
INSERT INTO Country_list ("id", "value") VALUES (E'CN', E'China');
INSERT INTO Country_list ("id", "value") VALUES (E'CX', E'Christmas Island');
INSERT INTO Country_list ("id", "value") VALUES (E'CC', E'Cocos (Keeling) Islands');
INSERT INTO Country_list ("id", "value") VALUES (E'CO', E'Colombia');
INSERT INTO Country_list ("id", "value") VALUES (E'KM', E'Comoros');
INSERT INTO Country_list ("id", "value") VALUES (E'CG', E'Congo - Brazzaville');
INSERT INTO Country_list ("id", "value") VALUES (E'CD', E'Congo - Kinshasa');
INSERT INTO Country_list ("id", "value") VALUES (E'CK', E'Cook Islands');
INSERT INTO Country_list ("id", "value") VALUES (E'CR', E'Costa Rica');
INSERT INTO Country_list ("id", "value") VALUES (E'CI', E'Côte d’Ivoire');
INSERT INTO Country_list ("id", "value") VALUES (E'HR', E'Croatia');
INSERT INTO Country_list ("id", "value") VALUES (E'CU', E'Cuba');
INSERT INTO Country_list ("id", "value") VALUES (E'CW', E'Curaçao');
INSERT INTO Country_list ("id", "value") VALUES (E'CY', E'Cyprus');
INSERT INTO Country_list ("id", "value") VALUES (E'CZ', E'Czechia');
INSERT INTO Country_list ("id", "value") VALUES (E'DK', E'Denmark');
INSERT INTO Country_list ("id", "value") VALUES (E'DJ', E'Djibouti');
INSERT INTO Country_list ("id", "value") VALUES (E'DM', E'Dominica');
INSERT INTO Country_list ("id", "value") VALUES (E'DO', E'Dominican Republic');
INSERT INTO Country_list ("id", "value") VALUES (E'EC', E'Ecuador');
INSERT INTO Country_list ("id", "value") VALUES (E'EG', E'Egypt');
INSERT INTO Country_list ("id", "value") VALUES (E'SV', E'El Salvador');
INSERT INTO Country_list ("id", "value") VALUES (E'GQ', E'Equatorial Guinea');
INSERT INTO Country_list ("id", "value") VALUES (E'ER', E'Eritrea');
INSERT INTO Country_list ("id", "value") VALUES (E'EE', E'Estonia');
INSERT INTO Country_list ("id", "value") VALUES (E'SZ', E'Eswatini');
INSERT INTO Country_list ("id", "value") VALUES (E'ET', E'Ethiopia');
INSERT INTO Country_list ("id", "value") VALUES (E'FK', E'Falkland Islands');
INSERT INTO Country_list ("id", "value") VALUES (E'FO', E'Faroe Islands');
INSERT INTO Country_list ("id", "value") VALUES (E'FJ', E'Fiji');
INSERT INTO Country_list ("id", "value") VALUES (E'FI', E'Finland');
INSERT INTO Country_list ("id", "value") VALUES (E'FR', E'France');
INSERT INTO Country_list ("id", "value") VALUES (E'GF', E'French Guiana');
INSERT INTO Country_list ("id", "value") VALUES (E'PF', E'French Polynesia');
INSERT INTO Country_list ("id", "value") VALUES (E'TF', E'French Southern Territories');
INSERT INTO Country_list ("id", "value") VALUES (E'GA', E'Gabon');
INSERT INTO Country_list ("id", "value") VALUES (E'GM', E'Gambia');
INSERT INTO Country_list ("id", "value") VALUES (E'GE', E'Georgia');
INSERT INTO Country_list ("id", "value") VALUES (E'DE', E'Germany');
INSERT INTO Country_list ("id", "value") VALUES (E'GH', E'Ghana');
INSERT INTO Country_list ("id", "value") VALUES (E'GI', E'Gibraltar');
INSERT INTO Country_list ("id", "value") VALUES (E'GR', E'Greece');
INSERT INTO Country_list ("id", "value") VALUES (E'GL', E'Greenland');
INSERT INTO Country_list ("id", "value") VALUES (E'GD', E'Grenada');
INSERT INTO Country_list ("id", "value") VALUES (E'GP', E'Guadeloupe');
INSERT INTO Country_list ("id", "value") VALUES (E'GU', E'Guam');
INSERT INTO Country_list ("id", "value") VALUES (E'GT', E'Guatemala');
INSERT INTO Country_list ("id", "value") VALUES (E'GG', E'Guernsey');
INSERT INTO Country_list ("id", "value") VALUES (E'GN', E'Guinea');
INSERT INTO Country_list ("id", "value") VALUES (E'GW', E'Guinea-Bissau');
INSERT INTO Country_list ("id", "value") VALUES (E'GY', E'Guyana');
INSERT INTO Country_list ("id", "value") VALUES (E'HT', E'Haiti');
INSERT INTO Country_list ("id", "value") VALUES (E'HM', E'Heard & McDonald Islands');
INSERT INTO Country_list ("id", "value") VALUES (E'HN', E'Honduras');
INSERT INTO Country_list ("id", "value") VALUES (E'HK', E'Hong Kong SAR China');
INSERT INTO Country_list ("id", "value") VALUES (E'HU', E'Hungary');
INSERT INTO Country_list ("id", "value") VALUES (E'IS', E'Iceland');
INSERT INTO Country_list ("id", "value") VALUES (E'IN', E'India');
INSERT INTO Country_list ("id", "value") VALUES (E'ID', E'Indonesia');
INSERT INTO Country_list ("id", "value") VALUES (E'IR', E'Iran');
INSERT INTO Country_list ("id", "value") VALUES (E'IQ', E'Iraq');
INSERT INTO Country_list ("id", "value") VALUES (E'IE', E'Ireland');
INSERT INTO Country_list ("id", "value") VALUES (E'IM', E'Isle of Man');
INSERT INTO Country_list ("id", "value") VALUES (E'IL', E'Israel');
INSERT INTO Country_list ("id", "value") VALUES (E'IT', E'Italy');
INSERT INTO Country_list ("id", "value") VALUES (E'JM', E'Jamaica');
INSERT INTO Country_list ("id", "value") VALUES (E'JP', E'Japan');
INSERT INTO Country_list ("id", "value") VALUES (E'JE', E'Jersey');
INSERT INTO Country_list ("id", "value") VALUES (E'JO', E'Jordan');
INSERT INTO Country_list ("id", "value") VALUES (E'KZ', E'Kazakhstan');
INSERT INTO Country_list ("id", "value") VALUES (E'KE', E'Kenya');
INSERT INTO Country_list ("id", "value") VALUES (E'KI', E'Kiribati');
INSERT INTO Country_list ("id", "value") VALUES (E'KW', E'Kuwait');
INSERT INTO Country_list ("id", "value") VALUES (E'KG', E'Kyrgyzstan');
INSERT INTO Country_list ("id", "value") VALUES (E'LA', E'Laos');
INSERT INTO Country_list ("id", "value") VALUES (E'LV', E'Latvia');
INSERT INTO Country_list ("id", "value") VALUES (E'LB', E'Lebanon');
INSERT INTO Country_list ("id", "value") VALUES (E'LS', E'Lesotho');
INSERT INTO Country_list ("id", "value") VALUES (E'LR', E'Liberia');
INSERT INTO Country_list ("id", "value") VALUES (E'LY', E'Libya');
INSERT INTO Country_list ("id", "value") VALUES (E'LI', E'Liechtenstein');
INSERT INTO Country_list ("id", "value") VALUES (E'LT', E'Lithuania');
INSERT INTO Country_list ("id", "value") VALUES (E'LU', E'Luxembourg');
INSERT INTO Country_list ("id", "value") VALUES (E'MO', E'Macao SAR China');
INSERT INTO Country_list ("id", "value") VALUES (E'MG', E'Madagascar');
INSERT INTO Country_list ("id", "value") VALUES (E'MW', E'Malawi');
INSERT INTO Country_list ("id", "value") VALUES (E'MY', E'Malaysia');
INSERT INTO Country_list ("id", "value") VALUES (E'MV', E'Maldives');
INSERT INTO Country_list ("id", "value") VALUES (E'ML', E'Mali');
INSERT INTO Country_list ("id", "value") VALUES (E'MT', E'Malta');
INSERT INTO Country_list ("id", "value") VALUES (E'MH', E'Marshall Islands');
INSERT INTO Country_list ("id", "value") VALUES (E'MQ', E'Martinique');
INSERT INTO Country_list ("id", "value") VALUES (E'MR', E'Mauritania');
INSERT INTO Country_list ("id", "value") VALUES (E'MU', E'Mauritius');
INSERT INTO Country_list ("id", "value") VALUES (E'YT', E'Mayotte');
INSERT INTO Country_list ("id", "value") VALUES (E'MX', E'Mexico');
INSERT INTO Country_list ("id", "value") VALUES (E'FM', E'Micronesia');
INSERT INTO Country_list ("id", "value") VALUES (E'MD', E'Moldova');
INSERT INTO Country_list ("id", "value") VALUES (E'MC', E'Monaco');
INSERT INTO Country_list ("id", "value") VALUES (E'MN', E'Mongolia');
INSERT INTO Country_list ("id", "value") VALUES (E'ME', E'Montenegro');
INSERT INTO Country_list ("id", "value") VALUES (E'MS', E'Montserrat');
INSERT INTO Country_list ("id", "value") VALUES (E'MA', E'Morocco');
INSERT INTO Country_list ("id", "value") VALUES (E'MZ', E'Mozambique');
INSERT INTO Country_list ("id", "value") VALUES (E'MM', E'Myanmar (Burma)');
INSERT INTO Country_list ("id", "value") VALUES (E'NA', E'Namibia');
INSERT INTO Country_list ("id", "value") VALUES (E'NR', E'Nauru');
INSERT INTO Country_list ("id", "value") VALUES (E'NP', E'Nepal');
INSERT INTO Country_list ("id", "value") VALUES (E'NL', E'Netherlands');
INSERT INTO Country_list ("id", "value") VALUES (E'NC', E'New Caledonia');
INSERT INTO Country_list ("id", "value") VALUES (E'NZ', E'New Zealand');
INSERT INTO Country_list ("id", "value") VALUES (E'NI', E'Nicaragua');
INSERT INTO Country_list ("id", "value") VALUES (E'NE', E'Niger');
INSERT INTO Country_list ("id", "value") VALUES (E'NG', E'Nigeria');
INSERT INTO Country_list ("id", "value") VALUES (E'NU', E'Niue');
INSERT INTO Country_list ("id", "value") VALUES (E'NF', E'Norfolk Island');
INSERT INTO Country_list ("id", "value") VALUES (E'KP', E'North Korea');
INSERT INTO Country_list ("id", "value") VALUES (E'MK', E'North Macedonia');
INSERT INTO Country_list ("id", "value") VALUES (E'MP', E'Northern Mariana Islands');
INSERT INTO Country_list ("id", "value") VALUES (E'NO', E'Norway');
INSERT INTO Country_list ("id", "value") VALUES (E'OM', E'Oman');
INSERT INTO Country_list ("id", "value") VALUES (E'PK', E'Pakistan');
INSERT INTO Country_list ("id", "value") VALUES (E'PW', E'Palau');
INSERT INTO Country_list ("id", "value") VALUES (E'PS', E'Palestinian Territories');
INSERT INTO Country_list ("id", "value") VALUES (E'PA', E'Panama');
INSERT INTO Country_list ("id", "value") VALUES (E'PG', E'Papua New Guinea');
INSERT INTO Country_list ("id", "value") VALUES (E'PY', E'Paraguay');
INSERT INTO Country_list ("id", "value") VALUES (E'PE', E'Peru');
INSERT INTO Country_list ("id", "value") VALUES (E'PH', E'Philippines');
INSERT INTO Country_list ("id", "value") VALUES (E'PN', E'Pitcairn Islands');
INSERT INTO Country_list ("id", "value") VALUES (E'PL', E'Poland');
INSERT INTO Country_list ("id", "value") VALUES (E'PT', E'Portugal');
INSERT INTO Country_list ("id", "value") VALUES (E'PR', E'Puerto Rico');
INSERT INTO Country_list ("id", "value") VALUES (E'QA', E'Qatar');
INSERT INTO Country_list ("id", "value") VALUES (E'RE', E'Réunion');
INSERT INTO Country_list ("id", "value") VALUES (E'RO', E'Romania');
INSERT INTO Country_list ("id", "value") VALUES (E'RU', E'Russia');
INSERT INTO Country_list ("id", "value") VALUES (E'RW', E'Rwanda');
INSERT INTO Country_list ("id", "value") VALUES (E'WS', E'Samoa');
INSERT INTO Country_list ("id", "value") VALUES (E'SM', E'San Marino');
INSERT INTO Country_list ("id", "value") VALUES (E'ST', E'São Tomé & Príncipe');
INSERT INTO Country_list ("id", "value") VALUES (E'SA', E'Saudi Arabia');
INSERT INTO Country_list ("id", "value") VALUES (E'SN', E'Senegal');
INSERT INTO Country_list ("id", "value") VALUES (E'RS', E'Serbia');
INSERT INTO Country_list ("id", "value") VALUES (E'SC', E'Seychelles');
INSERT INTO Country_list ("id", "value") VALUES (E'SL', E'Sierra Leone');
INSERT INTO Country_list ("id", "value") VALUES (E'SG', E'Singapore');
INSERT INTO Country_list ("id", "value") VALUES (E'SX', E'Sint Maarten');
INSERT INTO Country_list ("id", "value") VALUES (E'SK', E'Slovakia');
INSERT INTO Country_list ("id", "value") VALUES (E'SI', E'Slovenia');
INSERT INTO Country_list ("id", "value") VALUES (E'SB', E'Solomon Islands');
INSERT INTO Country_list ("id", "value") VALUES (E'SO', E'Somalia');
INSERT INTO Country_list ("id", "value") VALUES (E'ZA', E'South Africa');
INSERT INTO Country_list ("id", "value") VALUES (E'GS', E'South Georgia & South Sandwich Islands');
INSERT INTO Country_list ("id", "value") VALUES (E'KR', E'South Korea');
INSERT INTO Country_list ("id", "value") VALUES (E'SS', E'South Sudan');
INSERT INTO Country_list ("id", "value") VALUES (E'ES', E'Spain');
INSERT INTO Country_list ("id", "value") VALUES (E'LK', E'Sri Lanka');
INSERT INTO Country_list ("id", "value") VALUES (E'BL', E'St. Barthélemy');
INSERT INTO Country_list ("id", "value") VALUES (E'SH', E'St. Helena');
INSERT INTO Country_list ("id", "value") VALUES (E'KN', E'St. Kitts & Nevis');
INSERT INTO Country_list ("id", "value") VALUES (E'LC', E'St. Lucia');
INSERT INTO Country_list ("id", "value") VALUES (E'MF', E'St. Martin');
INSERT INTO Country_list ("id", "value") VALUES (E'PM', E'St. Pierre & Miquelon');
INSERT INTO Country_list ("id", "value") VALUES (E'VC', E'St. Vincent & Grenadines');
INSERT INTO Country_list ("id", "value") VALUES (E'SD', E'Sudan');
INSERT INTO Country_list ("id", "value") VALUES (E'SR', E'Suriname');
INSERT INTO Country_list ("id", "value") VALUES (E'SJ', E'Svalbard & Jan Mayen');
INSERT INTO Country_list ("id", "value") VALUES (E'SE', E'Sweden');
INSERT INTO Country_list ("id", "value") VALUES (E'CH', E'Switzerland');
INSERT INTO Country_list ("id", "value") VALUES (E'SY', E'Syria');
INSERT INTO Country_list ("id", "value") VALUES (E'TW', E'Taiwan');
INSERT INTO Country_list ("id", "value") VALUES (E'TJ', E'Tajikistan');
INSERT INTO Country_list ("id", "value") VALUES (E'TZ', E'Tanzania');
INSERT INTO Country_list ("id", "value") VALUES (E'TH', E'Thailand');
INSERT INTO Country_list ("id", "value") VALUES (E'TL', E'Timor-Leste');
INSERT INTO Country_list ("id", "value") VALUES (E'TG', E'Togo');
INSERT INTO Country_list ("id", "value") VALUES (E'TK', E'Tokelau');
INSERT INTO Country_list ("id", "value") VALUES (E'TO', E'Tonga');
INSERT INTO Country_list ("id", "value") VALUES (E'TT', E'Trinidad & Tobago');
INSERT INTO Country_list ("id", "value") VALUES (E'TN', E'Tunisia');
INSERT INTO Country_list ("id", "value") VALUES (E'TR', E'Turkey');
INSERT INTO Country_list ("id", "value") VALUES (E'TM', E'Turkmenistan');
INSERT INTO Country_list ("id", "value") VALUES (E'TC', E'Turks & Caicos Islands');
INSERT INTO Country_list ("id", "value") VALUES (E'TV', E'Tuvalu');
INSERT INTO Country_list ("id", "value") VALUES (E'UM', E'U.S. Outlying Islands');
INSERT INTO Country_list ("id", "value") VALUES (E'VI', E'U.S. Virgin Islands');
INSERT INTO Country_list ("id", "value") VALUES (E'UG', E'Uganda');
INSERT INTO Country_list ("id", "value") VALUES (E'UA', E'Ukraine');
INSERT INTO Country_list ("id", "value") VALUES (E'AE', E'United Arab Emirates');
INSERT INTO Country_list ("id", "value") VALUES (E'GB', E'United Kingdom');
INSERT INTO Country_list ("id", "value") VALUES (E'US', E'United States');
INSERT INTO Country_list ("id", "value") VALUES (E'UY', E'Uruguay');
INSERT INTO Country_list ("id", "value") VALUES (E'UZ', E'Uzbekistan');
INSERT INTO Country_list ("id", "value") VALUES (E'VU', E'Vanuatu');
INSERT INTO Country_list ("id", "value") VALUES (E'VA', E'Vatican City');
INSERT INTO Country_list ("id", "value") VALUES (E'VE', E'Venezuela');
INSERT INTO Country_list ("id", "value") VALUES (E'VN', E'Vietnam');
INSERT INTO Country_list ("id", "value") VALUES (E'WF', E'Wallis & Futuna');
INSERT INTO Country_list ("id", "value") VALUES (E'EH', E'Western Sahara');
INSERT INTO Country_list ("id", "value") VALUES (E'YE', E'Yemen');
INSERT INTO Country_list ("id", "value") VALUES (E'ZM', E'Zambia');
INSERT INTO Country_list ("id", "value") VALUES (E'ZW', E'Zimbabwe');

--------------- languages
DROP TABLE IF EXISTS Language_list;
CREATE TABLE Language_list (id VARCHAR(64) NOT NULL, value VARCHAR(64) NOT NULL, PRIMARY KEY(id));

INSERT INTO Language_list ("id", "value") VALUES (E'ab', E'Abkhazian');
INSERT INTO Language_list ("id", "value") VALUES (E'ace', E'Achinese');
INSERT INTO Language_list ("id", "value") VALUES (E'ach', E'Acoli');
INSERT INTO Language_list ("id", "value") VALUES (E'ada', E'Adangme');
INSERT INTO Language_list ("id", "value") VALUES (E'ady', E'Adyghe');
INSERT INTO Language_list ("id", "value") VALUES (E'aa', E'Afar');
INSERT INTO Language_list ("id", "value") VALUES (E'afh', E'Afrihili');
INSERT INTO Language_list ("id", "value") VALUES (E'af', E'Afrikaans');
INSERT INTO Language_list ("id", "value") VALUES (E'agq', E'Aghem');
INSERT INTO Language_list ("id", "value") VALUES (E'ain', E'Ainu');
INSERT INTO Language_list ("id", "value") VALUES (E'ak', E'Akan');
INSERT INTO Language_list ("id", "value") VALUES (E'akk', E'Akkadian');
INSERT INTO Language_list ("id", "value") VALUES (E'bss', E'Akoose');
INSERT INTO Language_list ("id", "value") VALUES (E'akz', E'Alabama');
INSERT INTO Language_list ("id", "value") VALUES (E'sq', E'Albanian');
INSERT INTO Language_list ("id", "value") VALUES (E'ale', E'Aleut');
INSERT INTO Language_list ("id", "value") VALUES (E'arq', E'Algerian Arabic');
INSERT INTO Language_list ("id", "value") VALUES (E'en_US', E'American English');
INSERT INTO Language_list ("id", "value") VALUES (E'ase', E'American Sign Language');
INSERT INTO Language_list ("id", "value") VALUES (E'am', E'Amharic');
INSERT INTO Language_list ("id", "value") VALUES (E'egy', E'Ancient Egyptian');
INSERT INTO Language_list ("id", "value") VALUES (E'grc', E'Ancient Greek');
INSERT INTO Language_list ("id", "value") VALUES (E'anp', E'Angika');
INSERT INTO Language_list ("id", "value") VALUES (E'njo', E'Ao Naga');
INSERT INTO Language_list ("id", "value") VALUES (E'ar', E'Arabic');
INSERT INTO Language_list ("id", "value") VALUES (E'an', E'Aragonese');
INSERT INTO Language_list ("id", "value") VALUES (E'arc', E'Aramaic');
INSERT INTO Language_list ("id", "value") VALUES (E'aro', E'Araona');
INSERT INTO Language_list ("id", "value") VALUES (E'arp', E'Arapaho');
INSERT INTO Language_list ("id", "value") VALUES (E'arw', E'Arawak');
INSERT INTO Language_list ("id", "value") VALUES (E'hy', E'Armenian');
INSERT INTO Language_list ("id", "value") VALUES (E'rup', E'Aromanian');
INSERT INTO Language_list ("id", "value") VALUES (E'frp', E'Arpitan');
INSERT INTO Language_list ("id", "value") VALUES (E'as', E'Assamese');
INSERT INTO Language_list ("id", "value") VALUES (E'ast', E'Asturian');
INSERT INTO Language_list ("id", "value") VALUES (E'asa', E'Asu');
INSERT INTO Language_list ("id", "value") VALUES (E'cch', E'Atsam');
INSERT INTO Language_list ("id", "value") VALUES (E'en_AU', E'Australian English');
INSERT INTO Language_list ("id", "value") VALUES (E'de_AT', E'Austrian German');
INSERT INTO Language_list ("id", "value") VALUES (E'av', E'Avaric');
INSERT INTO Language_list ("id", "value") VALUES (E'ae', E'Avestan');
INSERT INTO Language_list ("id", "value") VALUES (E'awa', E'Awadhi');
INSERT INTO Language_list ("id", "value") VALUES (E'ay', E'Aymara');
INSERT INTO Language_list ("id", "value") VALUES (E'az', E'Azerbaijani');
INSERT INTO Language_list ("id", "value") VALUES (E'bfq', E'Badaga');
INSERT INTO Language_list ("id", "value") VALUES (E'ksf', E'Bafia');
INSERT INTO Language_list ("id", "value") VALUES (E'bfd', E'Bafut');
INSERT INTO Language_list ("id", "value") VALUES (E'bqi', E'Bakhtiari');
INSERT INTO Language_list ("id", "value") VALUES (E'ban', E'Balinese');
INSERT INTO Language_list ("id", "value") VALUES (E'bal', E'Baluchi');
INSERT INTO Language_list ("id", "value") VALUES (E'bm', E'Bambara');
INSERT INTO Language_list ("id", "value") VALUES (E'bax', E'Bamun');
INSERT INTO Language_list ("id", "value") VALUES (E'bjn', E'Banjar');
INSERT INTO Language_list ("id", "value") VALUES (E'bas', E'Basaa');
INSERT INTO Language_list ("id", "value") VALUES (E'ba', E'Bashkir');
INSERT INTO Language_list ("id", "value") VALUES (E'eu', E'Basque');
INSERT INTO Language_list ("id", "value") VALUES (E'bbc', E'Batak Toba');
INSERT INTO Language_list ("id", "value") VALUES (E'bar', E'Bavarian');
INSERT INTO Language_list ("id", "value") VALUES (E'bej', E'Beja');
INSERT INTO Language_list ("id", "value") VALUES (E'be', E'Belarusian');
INSERT INTO Language_list ("id", "value") VALUES (E'bem', E'Bemba');
INSERT INTO Language_list ("id", "value") VALUES (E'bez', E'Bena');
INSERT INTO Language_list ("id", "value") VALUES (E'bn', E'Bengali');
INSERT INTO Language_list ("id", "value") VALUES (E'bew', E'Betawi');
INSERT INTO Language_list ("id", "value") VALUES (E'bho', E'Bhojpuri');
INSERT INTO Language_list ("id", "value") VALUES (E'bik', E'Bikol');
INSERT INTO Language_list ("id", "value") VALUES (E'bin', E'Bini');
INSERT INTO Language_list ("id", "value") VALUES (E'bpy', E'Bishnupriya');
INSERT INTO Language_list ("id", "value") VALUES (E'bi', E'Bislama');
INSERT INTO Language_list ("id", "value") VALUES (E'byn', E'Blin');
INSERT INTO Language_list ("id", "value") VALUES (E'zbl', E'Blissymbols');
INSERT INTO Language_list ("id", "value") VALUES (E'brx', E'Bodo');
INSERT INTO Language_list ("id", "value") VALUES (E'bs', E'Bosnian');
INSERT INTO Language_list ("id", "value") VALUES (E'brh', E'Brahui');
INSERT INTO Language_list ("id", "value") VALUES (E'bra', E'Braj');
INSERT INTO Language_list ("id", "value") VALUES (E'pt_BR', E'Brazilian Portuguese');
INSERT INTO Language_list ("id", "value") VALUES (E'br', E'Breton');
INSERT INTO Language_list ("id", "value") VALUES (E'en_GB', E'British English');
INSERT INTO Language_list ("id", "value") VALUES (E'bug', E'Buginese');
INSERT INTO Language_list ("id", "value") VALUES (E'bg', E'Bulgarian');
INSERT INTO Language_list ("id", "value") VALUES (E'bum', E'Bulu');
INSERT INTO Language_list ("id", "value") VALUES (E'bua', E'Buriat');
INSERT INTO Language_list ("id", "value") VALUES (E'my', E'Burmese');
INSERT INTO Language_list ("id", "value") VALUES (E'cad', E'Caddo');
INSERT INTO Language_list ("id", "value") VALUES (E'frc', E'Cajun French');
INSERT INTO Language_list ("id", "value") VALUES (E'en_CA', E'Canadian English');
INSERT INTO Language_list ("id", "value") VALUES (E'fr_CA', E'Canadian French');
INSERT INTO Language_list ("id", "value") VALUES (E'yue', E'Cantonese');
INSERT INTO Language_list ("id", "value") VALUES (E'cps', E'Capiznon');
INSERT INTO Language_list ("id", "value") VALUES (E'car', E'Carib');
INSERT INTO Language_list ("id", "value") VALUES (E'ca', E'Catalan');
INSERT INTO Language_list ("id", "value") VALUES (E'cay', E'Cayuga');
INSERT INTO Language_list ("id", "value") VALUES (E'ceb', E'Cebuano');
INSERT INTO Language_list ("id", "value") VALUES (E'tzm', E'Central Atlas Tamazight');
INSERT INTO Language_list ("id", "value") VALUES (E'dtp', E'Central Dusun');
INSERT INTO Language_list ("id", "value") VALUES (E'ckb', E'Central Kurdish');
INSERT INTO Language_list ("id", "value") VALUES (E'esu', E'Central Yupik');
INSERT INTO Language_list ("id", "value") VALUES (E'shu', E'Chadian Arabic');
INSERT INTO Language_list ("id", "value") VALUES (E'chg', E'Chagatai');
INSERT INTO Language_list ("id", "value") VALUES (E'ch', E'Chamorro');
INSERT INTO Language_list ("id", "value") VALUES (E'ce', E'Chechen');
INSERT INTO Language_list ("id", "value") VALUES (E'chr', E'Cherokee');
INSERT INTO Language_list ("id", "value") VALUES (E'chy', E'Cheyenne');
INSERT INTO Language_list ("id", "value") VALUES (E'chb', E'Chibcha');
INSERT INTO Language_list ("id", "value") VALUES (E'cgg', E'Chiga');
INSERT INTO Language_list ("id", "value") VALUES (E'qug', E'Chimborazo Highland Quichua');
INSERT INTO Language_list ("id", "value") VALUES (E'zh', E'Chinese');
INSERT INTO Language_list ("id", "value") VALUES (E'chn', E'Chinook Jargon');
INSERT INTO Language_list ("id", "value") VALUES (E'chp', E'Chipewyan');
INSERT INTO Language_list ("id", "value") VALUES (E'cho', E'Choctaw');
INSERT INTO Language_list ("id", "value") VALUES (E'cu', E'Church Slavic');
INSERT INTO Language_list ("id", "value") VALUES (E'chk', E'Chuukese');
INSERT INTO Language_list ("id", "value") VALUES (E'cv', E'Chuvash');
INSERT INTO Language_list ("id", "value") VALUES (E'nwc', E'Classical Newari');
INSERT INTO Language_list ("id", "value") VALUES (E'syc', E'Classical Syriac');
INSERT INTO Language_list ("id", "value") VALUES (E'ksh', E'Colognian');
INSERT INTO Language_list ("id", "value") VALUES (E'swb', E'Comorian');
INSERT INTO Language_list ("id", "value") VALUES (E'swc', E'Congo Swahili');
INSERT INTO Language_list ("id", "value") VALUES (E'cop', E'Coptic');
INSERT INTO Language_list ("id", "value") VALUES (E'kw', E'Cornish');
INSERT INTO Language_list ("id", "value") VALUES (E'co', E'Corsican');
INSERT INTO Language_list ("id", "value") VALUES (E'cr', E'Cree');
INSERT INTO Language_list ("id", "value") VALUES (E'mus', E'Creek');
INSERT INTO Language_list ("id", "value") VALUES (E'crh', E'Crimean Turkish');
INSERT INTO Language_list ("id", "value") VALUES (E'hr', E'Croatian');
INSERT INTO Language_list ("id", "value") VALUES (E'cs', E'Czech');
INSERT INTO Language_list ("id", "value") VALUES (E'dak', E'Dakota');
INSERT INTO Language_list ("id", "value") VALUES (E'da', E'Danish');
INSERT INTO Language_list ("id", "value") VALUES (E'dar', E'Dargwa');
INSERT INTO Language_list ("id", "value") VALUES (E'dzg', E'Dazaga');
INSERT INTO Language_list ("id", "value") VALUES (E'del', E'Delaware');
INSERT INTO Language_list ("id", "value") VALUES (E'din', E'Dinka');
INSERT INTO Language_list ("id", "value") VALUES (E'dv', E'Divehi');
INSERT INTO Language_list ("id", "value") VALUES (E'doi', E'Dogri');
INSERT INTO Language_list ("id", "value") VALUES (E'dgr', E'Dogrib');
INSERT INTO Language_list ("id", "value") VALUES (E'dua', E'Duala');
INSERT INTO Language_list ("id", "value") VALUES (E'nl', E'Dutch');
INSERT INTO Language_list ("id", "value") VALUES (E'dyu', E'Dyula');
INSERT INTO Language_list ("id", "value") VALUES (E'dz', E'Dzongkha');
INSERT INTO Language_list ("id", "value") VALUES (E'frs', E'Eastern Frisian');
INSERT INTO Language_list ("id", "value") VALUES (E'efi', E'Efik');
INSERT INTO Language_list ("id", "value") VALUES (E'arz', E'Egyptian Arabic');
INSERT INTO Language_list ("id", "value") VALUES (E'eka', E'Ekajuk');
INSERT INTO Language_list ("id", "value") VALUES (E'elx', E'Elamite');
INSERT INTO Language_list ("id", "value") VALUES (E'ebu', E'Embu');
INSERT INTO Language_list ("id", "value") VALUES (E'egl', E'Emilian');
INSERT INTO Language_list ("id", "value") VALUES (E'en', E'English');
INSERT INTO Language_list ("id", "value") VALUES (E'myv', E'Erzya');
INSERT INTO Language_list ("id", "value") VALUES (E'eo', E'Esperanto');
INSERT INTO Language_list ("id", "value") VALUES (E'et', E'Estonian');
INSERT INTO Language_list ("id", "value") VALUES (E'pt_PT', E'European Portuguese');
INSERT INTO Language_list ("id", "value") VALUES (E'es_ES', E'European Spanish');
INSERT INTO Language_list ("id", "value") VALUES (E'ee', E'Ewe');
INSERT INTO Language_list ("id", "value") VALUES (E'ewo', E'Ewondo');
INSERT INTO Language_list ("id", "value") VALUES (E'ext', E'Extremaduran');
INSERT INTO Language_list ("id", "value") VALUES (E'fan', E'Fang');
INSERT INTO Language_list ("id", "value") VALUES (E'fat', E'Fanti');
INSERT INTO Language_list ("id", "value") VALUES (E'fo', E'Faroese');
INSERT INTO Language_list ("id", "value") VALUES (E'hif', E'Fiji Hindi');
INSERT INTO Language_list ("id", "value") VALUES (E'fj', E'Fijian');
INSERT INTO Language_list ("id", "value") VALUES (E'fil', E'Filipino');
INSERT INTO Language_list ("id", "value") VALUES (E'fi', E'Finnish');
INSERT INTO Language_list ("id", "value") VALUES (E'nl_BE', E'Flemish');
INSERT INTO Language_list ("id", "value") VALUES (E'fon', E'Fon');
INSERT INTO Language_list ("id", "value") VALUES (E'gur', E'Frafra');
INSERT INTO Language_list ("id", "value") VALUES (E'fr', E'French');
INSERT INTO Language_list ("id", "value") VALUES (E'fur', E'Friulian');
INSERT INTO Language_list ("id", "value") VALUES (E'ff', E'Fulah');
INSERT INTO Language_list ("id", "value") VALUES (E'gaa', E'Ga');
INSERT INTO Language_list ("id", "value") VALUES (E'gag', E'Gagauz');
INSERT INTO Language_list ("id", "value") VALUES (E'gl', E'Galician');
INSERT INTO Language_list ("id", "value") VALUES (E'gan', E'Gan Chinese');
INSERT INTO Language_list ("id", "value") VALUES (E'lg', E'Ganda');
INSERT INTO Language_list ("id", "value") VALUES (E'gay', E'Gayo');
INSERT INTO Language_list ("id", "value") VALUES (E'gba', E'Gbaya');
INSERT INTO Language_list ("id", "value") VALUES (E'gez', E'Geez');
INSERT INTO Language_list ("id", "value") VALUES (E'ka', E'Georgian');
INSERT INTO Language_list ("id", "value") VALUES (E'de', E'German');
INSERT INTO Language_list ("id", "value") VALUES (E'aln', E'Gheg Albanian');
INSERT INTO Language_list ("id", "value") VALUES (E'bbj', E'Ghomala');
INSERT INTO Language_list ("id", "value") VALUES (E'glk', E'Gilaki');
INSERT INTO Language_list ("id", "value") VALUES (E'gil', E'Gilbertese');
INSERT INTO Language_list ("id", "value") VALUES (E'gom', E'Goan Konkani');
INSERT INTO Language_list ("id", "value") VALUES (E'gon', E'Gondi');
INSERT INTO Language_list ("id", "value") VALUES (E'gor', E'Gorontalo');
INSERT INTO Language_list ("id", "value") VALUES (E'got', E'Gothic');
INSERT INTO Language_list ("id", "value") VALUES (E'grb', E'Grebo');
INSERT INTO Language_list ("id", "value") VALUES (E'el', E'Greek');
INSERT INTO Language_list ("id", "value") VALUES (E'gn', E'Guarani');
INSERT INTO Language_list ("id", "value") VALUES (E'gu', E'Gujarati');
INSERT INTO Language_list ("id", "value") VALUES (E'guz', E'Gusii');
INSERT INTO Language_list ("id", "value") VALUES (E'gwi', E'Gwichʼin');
INSERT INTO Language_list ("id", "value") VALUES (E'hai', E'Haida');
INSERT INTO Language_list ("id", "value") VALUES (E'ht', E'Haitian');
INSERT INTO Language_list ("id", "value") VALUES (E'hak', E'Hakka Chinese');
INSERT INTO Language_list ("id", "value") VALUES (E'ha', E'Hausa');
INSERT INTO Language_list ("id", "value") VALUES (E'haw', E'Hawaiian');
INSERT INTO Language_list ("id", "value") VALUES (E'he', E'Hebrew');
INSERT INTO Language_list ("id", "value") VALUES (E'hz', E'Herero');
INSERT INTO Language_list ("id", "value") VALUES (E'hil', E'Hiligaynon');
INSERT INTO Language_list ("id", "value") VALUES (E'hi', E'Hindi');
INSERT INTO Language_list ("id", "value") VALUES (E'ho', E'Hiri Motu');
INSERT INTO Language_list ("id", "value") VALUES (E'hit', E'Hittite');
INSERT INTO Language_list ("id", "value") VALUES (E'hmn', E'Hmong');
INSERT INTO Language_list ("id", "value") VALUES (E'hu', E'Hungarian');
INSERT INTO Language_list ("id", "value") VALUES (E'hup', E'Hupa');
INSERT INTO Language_list ("id", "value") VALUES (E'iba', E'Iban');
INSERT INTO Language_list ("id", "value") VALUES (E'ibb', E'Ibibio');
INSERT INTO Language_list ("id", "value") VALUES (E'is', E'Icelandic');
INSERT INTO Language_list ("id", "value") VALUES (E'io', E'Ido');
INSERT INTO Language_list ("id", "value") VALUES (E'ig', E'Igbo');
INSERT INTO Language_list ("id", "value") VALUES (E'ilo', E'Iloko');
INSERT INTO Language_list ("id", "value") VALUES (E'smn', E'Inari Sami');
INSERT INTO Language_list ("id", "value") VALUES (E'id', E'Indonesian');
INSERT INTO Language_list ("id", "value") VALUES (E'izh', E'Ingrian');
INSERT INTO Language_list ("id", "value") VALUES (E'inh', E'Ingush');
INSERT INTO Language_list ("id", "value") VALUES (E'ia', E'Interlingua');
INSERT INTO Language_list ("id", "value") VALUES (E'ie', E'Interlingue');
INSERT INTO Language_list ("id", "value") VALUES (E'iu', E'Inuktitut');
INSERT INTO Language_list ("id", "value") VALUES (E'ik', E'Inupiaq');
INSERT INTO Language_list ("id", "value") VALUES (E'ga', E'Irish');
INSERT INTO Language_list ("id", "value") VALUES (E'it', E'Italian');
INSERT INTO Language_list ("id", "value") VALUES (E'jam', E'Jamaican Creole English');
INSERT INTO Language_list ("id", "value") VALUES (E'ja', E'Japanese');
INSERT INTO Language_list ("id", "value") VALUES (E'jv', E'Javanese');
INSERT INTO Language_list ("id", "value") VALUES (E'kaj', E'Jju');
INSERT INTO Language_list ("id", "value") VALUES (E'dyo', E'Jola-Fonyi');
INSERT INTO Language_list ("id", "value") VALUES (E'jrb', E'Judeo-Arabic');
INSERT INTO Language_list ("id", "value") VALUES (E'jpr', E'Judeo-Persian');
INSERT INTO Language_list ("id", "value") VALUES (E'jut', E'Jutish');
INSERT INTO Language_list ("id", "value") VALUES (E'kbd', E'Kabardian');
INSERT INTO Language_list ("id", "value") VALUES (E'kea', E'Kabuverdianu');
INSERT INTO Language_list ("id", "value") VALUES (E'kab', E'Kabyle');
INSERT INTO Language_list ("id", "value") VALUES (E'kac', E'Kachin');
INSERT INTO Language_list ("id", "value") VALUES (E'kgp', E'Kaingang');
INSERT INTO Language_list ("id", "value") VALUES (E'kkj', E'Kako');
INSERT INTO Language_list ("id", "value") VALUES (E'kl', E'Kalaallisut');
INSERT INTO Language_list ("id", "value") VALUES (E'kln', E'Kalenjin');
INSERT INTO Language_list ("id", "value") VALUES (E'xal', E'Kalmyk');
INSERT INTO Language_list ("id", "value") VALUES (E'kam', E'Kamba');
INSERT INTO Language_list ("id", "value") VALUES (E'kbl', E'Kanembu');
INSERT INTO Language_list ("id", "value") VALUES (E'kn', E'Kannada');
INSERT INTO Language_list ("id", "value") VALUES (E'kr', E'Kanuri');
INSERT INTO Language_list ("id", "value") VALUES (E'kaa', E'Kara-Kalpak');
INSERT INTO Language_list ("id", "value") VALUES (E'krc', E'Karachay-Balkar');
INSERT INTO Language_list ("id", "value") VALUES (E'krl', E'Karelian');
INSERT INTO Language_list ("id", "value") VALUES (E'ks', E'Kashmiri');
INSERT INTO Language_list ("id", "value") VALUES (E'csb', E'Kashubian');
INSERT INTO Language_list ("id", "value") VALUES (E'kaw', E'Kawi');
INSERT INTO Language_list ("id", "value") VALUES (E'kk', E'Kazakh');
INSERT INTO Language_list ("id", "value") VALUES (E'ken', E'Kenyang');
INSERT INTO Language_list ("id", "value") VALUES (E'kha', E'Khasi');
INSERT INTO Language_list ("id", "value") VALUES (E'km', E'Khmer');
INSERT INTO Language_list ("id", "value") VALUES (E'kho', E'Khotanese');
INSERT INTO Language_list ("id", "value") VALUES (E'khw', E'Khowar');
INSERT INTO Language_list ("id", "value") VALUES (E'ki', E'Kikuyu');
INSERT INTO Language_list ("id", "value") VALUES (E'kmb', E'Kimbundu');
INSERT INTO Language_list ("id", "value") VALUES (E'krj', E'Kinaray-a');
INSERT INTO Language_list ("id", "value") VALUES (E'rw', E'Kinyarwanda');
INSERT INTO Language_list ("id", "value") VALUES (E'kiu', E'Kirmanjki');
INSERT INTO Language_list ("id", "value") VALUES (E'tlh', E'Klingon');
INSERT INTO Language_list ("id", "value") VALUES (E'bkm', E'Kom');
INSERT INTO Language_list ("id", "value") VALUES (E'kv', E'Komi');
INSERT INTO Language_list ("id", "value") VALUES (E'koi', E'Komi-Permyak');
INSERT INTO Language_list ("id", "value") VALUES (E'kg', E'Kongo');
INSERT INTO Language_list ("id", "value") VALUES (E'kok', E'Konkani');
INSERT INTO Language_list ("id", "value") VALUES (E'ko', E'Korean');
INSERT INTO Language_list ("id", "value") VALUES (E'kfo', E'Koro');
INSERT INTO Language_list ("id", "value") VALUES (E'kos', E'Kosraean');
INSERT INTO Language_list ("id", "value") VALUES (E'avk', E'Kotava');
INSERT INTO Language_list ("id", "value") VALUES (E'khq', E'Koyra Chiini');
INSERT INTO Language_list ("id", "value") VALUES (E'ses', E'Koyraboro Senni');
INSERT INTO Language_list ("id", "value") VALUES (E'kpe', E'Kpelle');
INSERT INTO Language_list ("id", "value") VALUES (E'kri', E'Krio');
INSERT INTO Language_list ("id", "value") VALUES (E'kj', E'Kuanyama');
INSERT INTO Language_list ("id", "value") VALUES (E'kum', E'Kumyk');
INSERT INTO Language_list ("id", "value") VALUES (E'ku', E'Kurdish');
INSERT INTO Language_list ("id", "value") VALUES (E'kru', E'Kurukh');
INSERT INTO Language_list ("id", "value") VALUES (E'kut', E'Kutenai');
INSERT INTO Language_list ("id", "value") VALUES (E'nmg', E'Kwasio');
INSERT INTO Language_list ("id", "value") VALUES (E'ky', E'Kyrgyz');
INSERT INTO Language_list ("id", "value") VALUES (E'quc', E'Kʼicheʼ');
INSERT INTO Language_list ("id", "value") VALUES (E'lad', E'Ladino');
INSERT INTO Language_list ("id", "value") VALUES (E'lah', E'Lahnda');
INSERT INTO Language_list ("id", "value") VALUES (E'lkt', E'Lakota');
INSERT INTO Language_list ("id", "value") VALUES (E'lam', E'Lamba');
INSERT INTO Language_list ("id", "value") VALUES (E'lag', E'Langi');
INSERT INTO Language_list ("id", "value") VALUES (E'lo', E'Lao');
INSERT INTO Language_list ("id", "value") VALUES (E'ltg', E'Latgalian');
INSERT INTO Language_list ("id", "value") VALUES (E'la', E'Latin');
INSERT INTO Language_list ("id", "value") VALUES (E'es_419', E'Latin American Spanish');
INSERT INTO Language_list ("id", "value") VALUES (E'lv', E'Latvian');
INSERT INTO Language_list ("id", "value") VALUES (E'lzz', E'Laz');
INSERT INTO Language_list ("id", "value") VALUES (E'lez', E'Lezghian');
INSERT INTO Language_list ("id", "value") VALUES (E'lij', E'Ligurian');
INSERT INTO Language_list ("id", "value") VALUES (E'li', E'Limburgish');
INSERT INTO Language_list ("id", "value") VALUES (E'ln', E'Lingala');
INSERT INTO Language_list ("id", "value") VALUES (E'lfn', E'Lingua Franca Nova');
INSERT INTO Language_list ("id", "value") VALUES (E'lzh', E'Literary Chinese');
INSERT INTO Language_list ("id", "value") VALUES (E'lt', E'Lithuanian');
INSERT INTO Language_list ("id", "value") VALUES (E'liv', E'Livonian');
INSERT INTO Language_list ("id", "value") VALUES (E'jbo', E'Lojban');
INSERT INTO Language_list ("id", "value") VALUES (E'lmo', E'Lombard');
INSERT INTO Language_list ("id", "value") VALUES (E'nds', E'Low German');
INSERT INTO Language_list ("id", "value") VALUES (E'sli', E'Lower Silesian');
INSERT INTO Language_list ("id", "value") VALUES (E'dsb', E'Lower Sorbian');
INSERT INTO Language_list ("id", "value") VALUES (E'loz', E'Lozi');
INSERT INTO Language_list ("id", "value") VALUES (E'lu', E'Luba-Katanga');
INSERT INTO Language_list ("id", "value") VALUES (E'lua', E'Luba-Lulua');
INSERT INTO Language_list ("id", "value") VALUES (E'lui', E'Luiseno');
INSERT INTO Language_list ("id", "value") VALUES (E'smj', E'Lule Sami');
INSERT INTO Language_list ("id", "value") VALUES (E'lun', E'Lunda');
INSERT INTO Language_list ("id", "value") VALUES (E'luo', E'Luo');
INSERT INTO Language_list ("id", "value") VALUES (E'lb', E'Luxembourgish');
INSERT INTO Language_list ("id", "value") VALUES (E'luy', E'Luyia');
INSERT INTO Language_list ("id", "value") VALUES (E'mde', E'Maba');
INSERT INTO Language_list ("id", "value") VALUES (E'mk', E'Macedonian');
INSERT INTO Language_list ("id", "value") VALUES (E'jmc', E'Machame');
INSERT INTO Language_list ("id", "value") VALUES (E'mad', E'Madurese');
INSERT INTO Language_list ("id", "value") VALUES (E'maf', E'Mafa');
INSERT INTO Language_list ("id", "value") VALUES (E'mag', E'Magahi');
INSERT INTO Language_list ("id", "value") VALUES (E'vmf', E'Main-Franconian');
INSERT INTO Language_list ("id", "value") VALUES (E'mai', E'Maithili');
INSERT INTO Language_list ("id", "value") VALUES (E'mak', E'Makasar');
INSERT INTO Language_list ("id", "value") VALUES (E'mgh', E'Makhuwa-Meetto');
INSERT INTO Language_list ("id", "value") VALUES (E'kde', E'Makonde');
INSERT INTO Language_list ("id", "value") VALUES (E'mg', E'Malagasy');
INSERT INTO Language_list ("id", "value") VALUES (E'ms', E'Malay');
INSERT INTO Language_list ("id", "value") VALUES (E'ml', E'Malayalam');
INSERT INTO Language_list ("id", "value") VALUES (E'mt', E'Maltese');
INSERT INTO Language_list ("id", "value") VALUES (E'mnc', E'Manchu');
INSERT INTO Language_list ("id", "value") VALUES (E'mdr', E'Mandar');
INSERT INTO Language_list ("id", "value") VALUES (E'man', E'Mandingo');
INSERT INTO Language_list ("id", "value") VALUES (E'mni', E'Manipuri');
INSERT INTO Language_list ("id", "value") VALUES (E'gv', E'Manx');
INSERT INTO Language_list ("id", "value") VALUES (E'mi', E'Maori');
INSERT INTO Language_list ("id", "value") VALUES (E'arn', E'Mapuche');
INSERT INTO Language_list ("id", "value") VALUES (E'mr', E'Marathi');
INSERT INTO Language_list ("id", "value") VALUES (E'chm', E'Mari');
INSERT INTO Language_list ("id", "value") VALUES (E'mh', E'Marshallese');
INSERT INTO Language_list ("id", "value") VALUES (E'mwr', E'Marwari');
INSERT INTO Language_list ("id", "value") VALUES (E'mas', E'Masai');
INSERT INTO Language_list ("id", "value") VALUES (E'mzn', E'Mazanderani');
INSERT INTO Language_list ("id", "value") VALUES (E'byv', E'Medumba');
INSERT INTO Language_list ("id", "value") VALUES (E'men', E'Mende');
INSERT INTO Language_list ("id", "value") VALUES (E'mwv', E'Mentawai');
INSERT INTO Language_list ("id", "value") VALUES (E'mer', E'Meru');
INSERT INTO Language_list ("id", "value") VALUES (E'mgo', E'Metaʼ');
INSERT INTO Language_list ("id", "value") VALUES (E'es_MX', E'Mexican Spanish');
INSERT INTO Language_list ("id", "value") VALUES (E'mic', E'Micmac');
INSERT INTO Language_list ("id", "value") VALUES (E'dum', E'Middle Dutch');
INSERT INTO Language_list ("id", "value") VALUES (E'enm', E'Middle English');
INSERT INTO Language_list ("id", "value") VALUES (E'frm', E'Middle French');
INSERT INTO Language_list ("id", "value") VALUES (E'gmh', E'Middle High German');
INSERT INTO Language_list ("id", "value") VALUES (E'mga', E'Middle Irish');
INSERT INTO Language_list ("id", "value") VALUES (E'nan', E'Min Nan Chinese');
INSERT INTO Language_list ("id", "value") VALUES (E'min', E'Minangkabau');
INSERT INTO Language_list ("id", "value") VALUES (E'xmf', E'Mingrelian');
INSERT INTO Language_list ("id", "value") VALUES (E'mwl', E'Mirandese');
INSERT INTO Language_list ("id", "value") VALUES (E'lus', E'Mizo');
INSERT INTO Language_list ("id", "value") VALUES (E'ar_001', E'Modern Standard Arabic');
INSERT INTO Language_list ("id", "value") VALUES (E'moh', E'Mohawk');
INSERT INTO Language_list ("id", "value") VALUES (E'mdf', E'Moksha');
INSERT INTO Language_list ("id", "value") VALUES (E'ro_MD', E'Moldavian');
INSERT INTO Language_list ("id", "value") VALUES (E'lol', E'Mongo');
INSERT INTO Language_list ("id", "value") VALUES (E'mn', E'Mongolian');
INSERT INTO Language_list ("id", "value") VALUES (E'mfe', E'Morisyen');
INSERT INTO Language_list ("id", "value") VALUES (E'ary', E'Moroccan Arabic');
INSERT INTO Language_list ("id", "value") VALUES (E'mos', E'Mossi');
INSERT INTO Language_list ("id", "value") VALUES (E'mul', E'Multiple Languages');
INSERT INTO Language_list ("id", "value") VALUES (E'mua', E'Mundang');
INSERT INTO Language_list ("id", "value") VALUES (E'ttt', E'Muslim Tat');
INSERT INTO Language_list ("id", "value") VALUES (E'mye', E'Myene');
INSERT INTO Language_list ("id", "value") VALUES (E'naq', E'Nama');
INSERT INTO Language_list ("id", "value") VALUES (E'na', E'Nauru');
INSERT INTO Language_list ("id", "value") VALUES (E'nv', E'Navajo');
INSERT INTO Language_list ("id", "value") VALUES (E'ng', E'Ndonga');
INSERT INTO Language_list ("id", "value") VALUES (E'nap', E'Neapolitan');
INSERT INTO Language_list ("id", "value") VALUES (E'ne', E'Nepali');
INSERT INTO Language_list ("id", "value") VALUES (E'new', E'Newari');
INSERT INTO Language_list ("id", "value") VALUES (E'sba', E'Ngambay');
INSERT INTO Language_list ("id", "value") VALUES (E'nnh', E'Ngiemboon');
INSERT INTO Language_list ("id", "value") VALUES (E'jgo', E'Ngomba');
INSERT INTO Language_list ("id", "value") VALUES (E'yrl', E'Nheengatu');
INSERT INTO Language_list ("id", "value") VALUES (E'nia', E'Nias');
INSERT INTO Language_list ("id", "value") VALUES (E'niu', E'Niuean');
INSERT INTO Language_list ("id", "value") VALUES (E'zxx', E'No linguistic content');
INSERT INTO Language_list ("id", "value") VALUES (E'nog', E'Nogai');
INSERT INTO Language_list ("id", "value") VALUES (E'nd', E'North Ndebele');
INSERT INTO Language_list ("id", "value") VALUES (E'frr', E'Northern Frisian');
INSERT INTO Language_list ("id", "value") VALUES (E'se', E'Northern Sami');
INSERT INTO Language_list ("id", "value") VALUES (E'nso', E'Northern Sotho');
INSERT INTO Language_list ("id", "value") VALUES (E'no', E'Norwegian');
INSERT INTO Language_list ("id", "value") VALUES (E'nb', E'Norwegian Bokmål');
INSERT INTO Language_list ("id", "value") VALUES (E'nn', E'Norwegian Nynorsk');
INSERT INTO Language_list ("id", "value") VALUES (E'nov', E'Novial');
INSERT INTO Language_list ("id", "value") VALUES (E'nus', E'Nuer');
INSERT INTO Language_list ("id", "value") VALUES (E'nym', E'Nyamwezi');
INSERT INTO Language_list ("id", "value") VALUES (E'ny', E'Nyanja');
INSERT INTO Language_list ("id", "value") VALUES (E'nyn', E'Nyankole');
INSERT INTO Language_list ("id", "value") VALUES (E'tog', E'Nyasa Tonga');
INSERT INTO Language_list ("id", "value") VALUES (E'nyo', E'Nyoro');
INSERT INTO Language_list ("id", "value") VALUES (E'nzi', E'Nzima');
INSERT INTO Language_list ("id", "value") VALUES (E'nqo', E'NʼKo');
INSERT INTO Language_list ("id", "value") VALUES (E'oc', E'Occitan');
INSERT INTO Language_list ("id", "value") VALUES (E'oj', E'Ojibwa');
INSERT INTO Language_list ("id", "value") VALUES (E'ang', E'Old English');
INSERT INTO Language_list ("id", "value") VALUES (E'fro', E'Old French');
INSERT INTO Language_list ("id", "value") VALUES (E'goh', E'Old High German');
INSERT INTO Language_list ("id", "value") VALUES (E'sga', E'Old Irish');
INSERT INTO Language_list ("id", "value") VALUES (E'non', E'Old Norse');
INSERT INTO Language_list ("id", "value") VALUES (E'peo', E'Old Persian');
INSERT INTO Language_list ("id", "value") VALUES (E'pro', E'Old Provençal');
INSERT INTO Language_list ("id", "value") VALUES (E'or', E'Oriya');
INSERT INTO Language_list ("id", "value") VALUES (E'om', E'Oromo');
INSERT INTO Language_list ("id", "value") VALUES (E'osa', E'Osage');
INSERT INTO Language_list ("id", "value") VALUES (E'os', E'Ossetic');
INSERT INTO Language_list ("id", "value") VALUES (E'ota', E'Ottoman Turkish');
INSERT INTO Language_list ("id", "value") VALUES (E'pal', E'Pahlavi');
INSERT INTO Language_list ("id", "value") VALUES (E'pfl', E'Palatine German');
INSERT INTO Language_list ("id", "value") VALUES (E'pau', E'Palauan');
INSERT INTO Language_list ("id", "value") VALUES (E'pi', E'Pali');
INSERT INTO Language_list ("id", "value") VALUES (E'pam', E'Pampanga');
INSERT INTO Language_list ("id", "value") VALUES (E'pag', E'Pangasinan');
INSERT INTO Language_list ("id", "value") VALUES (E'pap', E'Papiamento');
INSERT INTO Language_list ("id", "value") VALUES (E'ps', E'Pashto');
INSERT INTO Language_list ("id", "value") VALUES (E'pdc', E'Pennsylvania German');
INSERT INTO Language_list ("id", "value") VALUES (E'fa', E'Persian');
INSERT INTO Language_list ("id", "value") VALUES (E'phn', E'Phoenician');
INSERT INTO Language_list ("id", "value") VALUES (E'pcd', E'Picard');
INSERT INTO Language_list ("id", "value") VALUES (E'pms', E'Piedmontese');
INSERT INTO Language_list ("id", "value") VALUES (E'pdt', E'Plautdietsch');
INSERT INTO Language_list ("id", "value") VALUES (E'pon', E'Pohnpeian');
INSERT INTO Language_list ("id", "value") VALUES (E'pl', E'Polish');
INSERT INTO Language_list ("id", "value") VALUES (E'pnt', E'Pontic');
INSERT INTO Language_list ("id", "value") VALUES (E'pt', E'Portuguese');
INSERT INTO Language_list ("id", "value") VALUES (E'prg', E'Prussian');
INSERT INTO Language_list ("id", "value") VALUES (E'pa', E'Punjabi');
INSERT INTO Language_list ("id", "value") VALUES (E'qu', E'Quechua');
INSERT INTO Language_list ("id", "value") VALUES (E'raj', E'Rajasthani');
INSERT INTO Language_list ("id", "value") VALUES (E'rap', E'Rapanui');
INSERT INTO Language_list ("id", "value") VALUES (E'rar', E'Rarotongan');
INSERT INTO Language_list ("id", "value") VALUES (E'rif', E'Riffian');
INSERT INTO Language_list ("id", "value") VALUES (E'rgn', E'Romagnol');
INSERT INTO Language_list ("id", "value") VALUES (E'ro', E'Romanian');
INSERT INTO Language_list ("id", "value") VALUES (E'rm', E'Romansh');
INSERT INTO Language_list ("id", "value") VALUES (E'rom', E'Romany');
INSERT INTO Language_list ("id", "value") VALUES (E'rof', E'Rombo');
INSERT INTO Language_list ("id", "value") VALUES (E'root', E'Root');
INSERT INTO Language_list ("id", "value") VALUES (E'rtm', E'Rotuman');
INSERT INTO Language_list ("id", "value") VALUES (E'rug', E'Roviana');
INSERT INTO Language_list ("id", "value") VALUES (E'rn', E'Rundi');
INSERT INTO Language_list ("id", "value") VALUES (E'ru', E'Russian');
INSERT INTO Language_list ("id", "value") VALUES (E'rue', E'Rusyn');
INSERT INTO Language_list ("id", "value") VALUES (E'rwk', E'Rwa');
INSERT INTO Language_list ("id", "value") VALUES (E'ssy', E'Saho');
INSERT INTO Language_list ("id", "value") VALUES (E'sah', E'Sakha');
INSERT INTO Language_list ("id", "value") VALUES (E'sam', E'Samaritan Aramaic');
INSERT INTO Language_list ("id", "value") VALUES (E'saq', E'Samburu');
INSERT INTO Language_list ("id", "value") VALUES (E'sm', E'Samoan');
INSERT INTO Language_list ("id", "value") VALUES (E'sgs', E'Samogitian');
INSERT INTO Language_list ("id", "value") VALUES (E'sad', E'Sandawe');
INSERT INTO Language_list ("id", "value") VALUES (E'sg', E'Sango');
INSERT INTO Language_list ("id", "value") VALUES (E'sbp', E'Sangu');
INSERT INTO Language_list ("id", "value") VALUES (E'sa', E'Sanskrit');
INSERT INTO Language_list ("id", "value") VALUES (E'sat', E'Santali');
INSERT INTO Language_list ("id", "value") VALUES (E'sc', E'Sardinian');
INSERT INTO Language_list ("id", "value") VALUES (E'sas', E'Sasak');
INSERT INTO Language_list ("id", "value") VALUES (E'sdc', E'Sassarese Sardinian');
INSERT INTO Language_list ("id", "value") VALUES (E'stq', E'Saterland Frisian');
INSERT INTO Language_list ("id", "value") VALUES (E'saz', E'Saurashtra');
INSERT INTO Language_list ("id", "value") VALUES (E'sco', E'Scots');
INSERT INTO Language_list ("id", "value") VALUES (E'gd', E'Scottish Gaelic');
INSERT INTO Language_list ("id", "value") VALUES (E'sly', E'Selayar');
INSERT INTO Language_list ("id", "value") VALUES (E'sel', E'Selkup');
INSERT INTO Language_list ("id", "value") VALUES (E'seh', E'Sena');
INSERT INTO Language_list ("id", "value") VALUES (E'see', E'Seneca');
INSERT INTO Language_list ("id", "value") VALUES (E'sr', E'Serbian');
INSERT INTO Language_list ("id", "value") VALUES (E'sh', E'Serbo-Croatian');
INSERT INTO Language_list ("id", "value") VALUES (E'srr', E'Serer');
INSERT INTO Language_list ("id", "value") VALUES (E'sei', E'Seri');
INSERT INTO Language_list ("id", "value") VALUES (E'ksb', E'Shambala');
INSERT INTO Language_list ("id", "value") VALUES (E'shn', E'Shan');
INSERT INTO Language_list ("id", "value") VALUES (E'sn', E'Shona');
INSERT INTO Language_list ("id", "value") VALUES (E'ii', E'Sichuan Yi');
INSERT INTO Language_list ("id", "value") VALUES (E'scn', E'Sicilian');
INSERT INTO Language_list ("id", "value") VALUES (E'sid', E'Sidamo');
INSERT INTO Language_list ("id", "value") VALUES (E'bla', E'Siksika');
INSERT INTO Language_list ("id", "value") VALUES (E'szl', E'Silesian');
INSERT INTO Language_list ("id", "value") VALUES (E'zh_Hans', E'Simplified Chinese');
INSERT INTO Language_list ("id", "value") VALUES (E'sd', E'Sindhi');
INSERT INTO Language_list ("id", "value") VALUES (E'si', E'Sinhala');
INSERT INTO Language_list ("id", "value") VALUES (E'sms', E'Skolt Sami');
INSERT INTO Language_list ("id", "value") VALUES (E'den', E'Slave');
INSERT INTO Language_list ("id", "value") VALUES (E'sk', E'Slovak');
INSERT INTO Language_list ("id", "value") VALUES (E'sl', E'Slovenian');
INSERT INTO Language_list ("id", "value") VALUES (E'xog', E'Soga');
INSERT INTO Language_list ("id", "value") VALUES (E'sog', E'Sogdien');
INSERT INTO Language_list ("id", "value") VALUES (E'so', E'Somali');
INSERT INTO Language_list ("id", "value") VALUES (E'snk', E'Soninke');
INSERT INTO Language_list ("id", "value") VALUES (E'azb', E'South Azerbaijani');
INSERT INTO Language_list ("id", "value") VALUES (E'nr', E'South Ndebele');
INSERT INTO Language_list ("id", "value") VALUES (E'alt', E'Southern Altai');
INSERT INTO Language_list ("id", "value") VALUES (E'sma', E'Southern Sami');
INSERT INTO Language_list ("id", "value") VALUES (E'st', E'Southern Sotho');
INSERT INTO Language_list ("id", "value") VALUES (E'es', E'Spanish');
INSERT INTO Language_list ("id", "value") VALUES (E'srn', E'Sranan Tongo');
INSERT INTO Language_list ("id", "value") VALUES (E'zgh', E'Standard Moroccan Tamazight');
INSERT INTO Language_list ("id", "value") VALUES (E'suk', E'Sukuma');
INSERT INTO Language_list ("id", "value") VALUES (E'sux', E'Sumerian');
INSERT INTO Language_list ("id", "value") VALUES (E'su', E'Sundanese');
INSERT INTO Language_list ("id", "value") VALUES (E'sus', E'Susu');
INSERT INTO Language_list ("id", "value") VALUES (E'sw', E'Swahili');
INSERT INTO Language_list ("id", "value") VALUES (E'ss', E'Swati');
INSERT INTO Language_list ("id", "value") VALUES (E'sv', E'Swedish');
INSERT INTO Language_list ("id", "value") VALUES (E'fr_CH', E'Swiss French');
INSERT INTO Language_list ("id", "value") VALUES (E'gsw', E'Swiss German');
INSERT INTO Language_list ("id", "value") VALUES (E'de_CH', E'Swiss High German');
INSERT INTO Language_list ("id", "value") VALUES (E'syr', E'Syriac');
INSERT INTO Language_list ("id", "value") VALUES (E'shi', E'Tachelhit');
INSERT INTO Language_list ("id", "value") VALUES (E'tl', E'Tagalog');
INSERT INTO Language_list ("id", "value") VALUES (E'ty', E'Tahitian');
INSERT INTO Language_list ("id", "value") VALUES (E'dav', E'Taita');
INSERT INTO Language_list ("id", "value") VALUES (E'tg', E'Tajik');
INSERT INTO Language_list ("id", "value") VALUES (E'tly', E'Talysh');
INSERT INTO Language_list ("id", "value") VALUES (E'tmh', E'Tamashek');
INSERT INTO Language_list ("id", "value") VALUES (E'ta', E'Tamil');
INSERT INTO Language_list ("id", "value") VALUES (E'trv', E'Taroko');
INSERT INTO Language_list ("id", "value") VALUES (E'twq', E'Tasawaq');
INSERT INTO Language_list ("id", "value") VALUES (E'tt', E'Tatar');
INSERT INTO Language_list ("id", "value") VALUES (E'te', E'Telugu');
INSERT INTO Language_list ("id", "value") VALUES (E'ter', E'Tereno');
INSERT INTO Language_list ("id", "value") VALUES (E'teo', E'Teso');
INSERT INTO Language_list ("id", "value") VALUES (E'tet', E'Tetum');
INSERT INTO Language_list ("id", "value") VALUES (E'th', E'Thai');
INSERT INTO Language_list ("id", "value") VALUES (E'bo', E'Tibetan');
INSERT INTO Language_list ("id", "value") VALUES (E'tig', E'Tigre');
INSERT INTO Language_list ("id", "value") VALUES (E'ti', E'Tigrinya');
INSERT INTO Language_list ("id", "value") VALUES (E'tem', E'Timne');
INSERT INTO Language_list ("id", "value") VALUES (E'tiv', E'Tiv');
INSERT INTO Language_list ("id", "value") VALUES (E'tli', E'Tlingit');
INSERT INTO Language_list ("id", "value") VALUES (E'tpi', E'Tok Pisin');
INSERT INTO Language_list ("id", "value") VALUES (E'tkl', E'Tokelau');
INSERT INTO Language_list ("id", "value") VALUES (E'to', E'Tongan');
INSERT INTO Language_list ("id", "value") VALUES (E'fit', E'Tornedalen Finnish');
INSERT INTO Language_list ("id", "value") VALUES (E'zh_Hant', E'Traditional Chinese');
INSERT INTO Language_list ("id", "value") VALUES (E'tkr', E'Tsakhur');
INSERT INTO Language_list ("id", "value") VALUES (E'tsd', E'Tsakonian');
INSERT INTO Language_list ("id", "value") VALUES (E'tsi', E'Tsimshian');
INSERT INTO Language_list ("id", "value") VALUES (E'ts', E'Tsonga');
INSERT INTO Language_list ("id", "value") VALUES (E'tn', E'Tswana');
INSERT INTO Language_list ("id", "value") VALUES (E'tcy', E'Tulu');
INSERT INTO Language_list ("id", "value") VALUES (E'tum', E'Tumbuka');
INSERT INTO Language_list ("id", "value") VALUES (E'aeb', E'Tunisian Arabic');
INSERT INTO Language_list ("id", "value") VALUES (E'tr', E'Turkish');
INSERT INTO Language_list ("id", "value") VALUES (E'tk', E'Turkmen');
INSERT INTO Language_list ("id", "value") VALUES (E'tru', E'Turoyo');
INSERT INTO Language_list ("id", "value") VALUES (E'tvl', E'Tuvalu');
INSERT INTO Language_list ("id", "value") VALUES (E'tyv', E'Tuvinian');
INSERT INTO Language_list ("id", "value") VALUES (E'tw', E'Twi');
INSERT INTO Language_list ("id", "value") VALUES (E'kcg', E'Tyap');
INSERT INTO Language_list ("id", "value") VALUES (E'udm', E'Udmurt');
INSERT INTO Language_list ("id", "value") VALUES (E'uga', E'Ugaritic');
INSERT INTO Language_list ("id", "value") VALUES (E'uk', E'Ukrainian');
INSERT INTO Language_list ("id", "value") VALUES (E'umb', E'Umbundu');
INSERT INTO Language_list ("id", "value") VALUES (E'und', E'Unknown Language');
INSERT INTO Language_list ("id", "value") VALUES (E'hsb', E'Upper Sorbian');
INSERT INTO Language_list ("id", "value") VALUES (E'ur', E'Urdu');
INSERT INTO Language_list ("id", "value") VALUES (E'ug', E'Uyghur');
INSERT INTO Language_list ("id", "value") VALUES (E'uz', E'Uzbek');
INSERT INTO Language_list ("id", "value") VALUES (E'vai', E'Vai');
INSERT INTO Language_list ("id", "value") VALUES (E've', E'Venda');
INSERT INTO Language_list ("id", "value") VALUES (E'vec', E'Venetian');
INSERT INTO Language_list ("id", "value") VALUES (E'vep', E'Veps');
INSERT INTO Language_list ("id", "value") VALUES (E'vi', E'Vietnamese');
INSERT INTO Language_list ("id", "value") VALUES (E'vo', E'Volapük');
INSERT INTO Language_list ("id", "value") VALUES (E'vro', E'Võro');
INSERT INTO Language_list ("id", "value") VALUES (E'vot', E'Votic');
INSERT INTO Language_list ("id", "value") VALUES (E'vun', E'Vunjo');
INSERT INTO Language_list ("id", "value") VALUES (E'wa', E'Walloon');
INSERT INTO Language_list ("id", "value") VALUES (E'wae', E'Walser');
INSERT INTO Language_list ("id", "value") VALUES (E'war', E'Waray');
INSERT INTO Language_list ("id", "value") VALUES (E'wbp', E'Warlpiri');
INSERT INTO Language_list ("id", "value") VALUES (E'was', E'Washo');
INSERT INTO Language_list ("id", "value") VALUES (E'guc', E'Wayuu');
INSERT INTO Language_list ("id", "value") VALUES (E'cy', E'Welsh');
INSERT INTO Language_list ("id", "value") VALUES (E'vls', E'West Flemish');
INSERT INTO Language_list ("id", "value") VALUES (E'fy', E'Western Frisian');
INSERT INTO Language_list ("id", "value") VALUES (E'mrj', E'Western Mari');
INSERT INTO Language_list ("id", "value") VALUES (E'wal', E'Wolaytta');
INSERT INTO Language_list ("id", "value") VALUES (E'wo', E'Wolof');
INSERT INTO Language_list ("id", "value") VALUES (E'wuu', E'Wu Chinese');
INSERT INTO Language_list ("id", "value") VALUES (E'xh', E'Xhosa');
INSERT INTO Language_list ("id", "value") VALUES (E'hsn', E'Xiang Chinese');
INSERT INTO Language_list ("id", "value") VALUES (E'yav', E'Yangben');
INSERT INTO Language_list ("id", "value") VALUES (E'yao', E'Yao');
INSERT INTO Language_list ("id", "value") VALUES (E'yap', E'Yapese');
INSERT INTO Language_list ("id", "value") VALUES (E'ybb', E'Yemba');
INSERT INTO Language_list ("id", "value") VALUES (E'yi', E'Yiddish');
INSERT INTO Language_list ("id", "value") VALUES (E'yo', E'Yoruba');
INSERT INTO Language_list ("id", "value") VALUES (E'zap', E'Zapotec');
INSERT INTO Language_list ("id", "value") VALUES (E'dje', E'Zarma');
INSERT INTO Language_list ("id", "value") VALUES (E'zza', E'Zaza');
INSERT INTO Language_list ("id", "value") VALUES (E'zea', E'Zeelandic');
INSERT INTO Language_list ("id", "value") VALUES (E'zen', E'Zenaga');
INSERT INTO Language_list ("id", "value") VALUES (E'za', E'Zhuang');
INSERT INTO Language_list ("id", "value") VALUES (E'gbz', E'Zoroastrian Dari');
INSERT INTO Language_list ("id", "value") VALUES (E'zu', E'Zulu');
INSERT INTO Language_list ("id", "value") VALUES (E'zun', E'Zuni');

--------------- triggers & functions

create or replace function monthToInt(m valid_month) returns smallint
    language plpgsql
    immutable as
$$
declare
    res smallint;
begin
    if m is null then
        raise exception 'null input field exception';
    end if;
    case upper(m)
        when 'JAN' then res = 1;
        when 'FEB' then res = 2;
        when 'MAR' then res = 3;
        when 'APR' then res = 4;
        when 'MAY' then res = 5;
        when 'JUN' then res = 6;
        when 'JUL' then res = 7;
        when 'AUG' then res = 8;
        when 'SEP' then res = 9;
        when 'OCT' then res = 10;
        when 'NOV' then res = 11;
        when 'DEC' then res = 12;
        else res = 0;
        end case;
    return res;
end;
$$;

create or replace function intToMonth(m integer) returns char(3)
    language plpgsql
    immutable as
$$
declare
    res char(3);
begin
    if m is null then
        raise exception 'null input field exception';
    end if;
    case m
        when 1 then res = 'JAN';
        when 2 then res = 'FEB';
        when 3 then res = 'MAR';
        when 4 then res = 'APR';
        when 5 then res = 'MAY';
        when 6 then res = 'JUN';
        when 7 then res = 'JUL';
        when 8 then res = 'AUG';
        when 9 then res = 'SEP';
        when 10 then res = 'OCT';
        when 11 then res = 'NOV';
        when 12 then res = 'DEC';
        else res = null;
        end case;
    return res;
end;
$$;

create or replace function isCrewAgeValid(by valid_year, bm valid_month, bd valid_day, dy valid_year, dm valid_month,
                                          dd valid_day) returns boolean as
$$
begin
    if by is not null and dy is not null and by > dy then
        return false;
    end if;
    if bm is not null and dm is not null and bm > dm then
        return false;
    end if;
    if bd is not null and dd is not null and bd > dd then
        return false;
    end if;
    return true;
end;
$$ language plpgsql;

create or replace function crewConstructor() returns trigger as
$crew_insert_init$
begin
    if new.name is NULL then
        raise exception 'crew name cannot be empty';
    end if;
    if new.cid is null then
        new.cid := uuid_generate_v3(uuid_ns_oid(), new.name);
    end if;
    if new.isdir is false and new.ispro is false and new.isact is false and new.iswrt is false then
        raise exception 'crew should have at least one job';
    end if;
    if not isCrewAgeValid(new.byear, new.bmon, new.bday, new.dyear, new.dmon, new.dday) then
        raise exception 'death date is sooner than birth date';
    end if;
    return new;
end;
$crew_insert_init$ language plpgsql;

create or replace function crewUpdateAge() returns trigger as
$crew_age_update$
begin
    if not isCrewAgeValid(new.byear, new.bmon, new.bday, new.dyear, new.dmon, new.dday) then
        raise exception 'death date is sooner than birth date';
    end if;
    return new;
end;
$crew_age_update$ language plpgsql;

create or replace function crewUpdateJob() returns trigger as
$crew_job_update$
begin
    if new.isdir is false and new.ispro is false and new.isact is false and new.iswrt is false then
        raise exception 'crew should have at least one job';
    end if;
    return new;
end;
$crew_job_update$ language plpgsql;

create or replace function crewIDModifying() returns trigger as
$user_id_changing$
begin
    raise exception 'you cannot modify crew ID';
end;
$user_id_changing$ language plpgsql;

drop trigger if exists insert_crew_initial on crew cascade;
drop trigger if exists update_crew_age on crew cascade;
drop trigger if exists update_crew_job on crew cascade;
drop trigger if exists update_crew_id on crew cascade;

create trigger insert_crew_initial
    before Insert
    on crew
    for each row
execute procedure crewConstructor();

create trigger update_crew_age
    before update of byear, bmon, bday, dyear, dmon, dday
    on crew
    for each row
execute procedure crewUpdateAge();

create trigger update_crew_job
    before update of isact, isdir, ispro, iswrt
    on crew
    for each row
execute procedure crewUpdateJob();

create trigger update_crew_id
    before update of cid
    on crew
    for each row
execute procedure crewIDModifying();

--------------------------------------------------------------

create or replace function userConstructor() returns trigger as
$insert_user_initial$
begin
    if new.name is NULL then
        raise exception 'username cannot be empty';
    end if;
    if new.pass is NULL then
        raise exception 'user password cannot be empty';
    end if;
    if new.uid is null then
        new.uid := uuid_generate_v3(uuid_ns_oid(), new.name);
    end if;
    new.pass := crypt(new.pass, gen_salt('bf'));
    return new;
end
$insert_user_initial$ language plpgsql;

create or replace function updatePassword() returns trigger as
$user_update_password$
begin
    if new.pass is NULL then
        raise exception 'user password cannot be empty';
    end if;
    if old.pass = crypt(new.pass, old.pass) then
        raise exception 'new password is repetitive';
    end if;
    new.pass := crypt(new.pass, gen_salt('bf'));
    return new;
end;
$user_update_password$ language plpgsql;

create or replace function promoteDemoteUser() returns trigger as
$make_user_pro_free$
begin
    if upper(old.utype) ~ upper(new.utype) then
        raise exception 'redundant promotion/demotion process';
    end if;
    new.utype = upper(new.utype);
    return new;
end;
$make_user_pro_free$ language plpgsql;

create or replace function userIDModifying() returns trigger as
$user_id_changing$
begin
    raise exception 'you cannot modify user ID';
end;
$user_id_changing$ language plpgsql;

-- todo find usage ???
create or replace function userEdit() returns trigger as
$can_user_edit$
begin
    if upper(new.utype) ~ 'P' then
        return new;
    end if;
    if new.elimit <= 0 then
        raise exception 'user cannot edit any movies';
    end if;
    new.elimit = new.elimit - 1;
    return new;
end;
$can_user_edit$ language plpgsql;

drop trigger if exists insert_user_initial on users cascade;
drop trigger if exists update_user_pass on users cascade;
drop trigger if exists promote_demote_user on users cascade;
drop trigger if exists update_user_id on users cascade;

create trigger insert_user_initial
    before Insert
    on users
    for each row
execute procedure userConstructor();

create trigger update_user_pass
    before update of pass
    on users
    for each row
execute procedure updatePassword();

create trigger promote_demote_user
    before update of utype
    on users
    for each row
execute procedure promoteDemoteUser();

create trigger update_user_id
    before update of uid
    on users
    for each row
execute procedure userIDModifying();

--------------------------------------------------------------

create or replace function isFilmYearsValid(start_year smallint, finish_year smallint) returns boolean
    language plpgsql
    immutable as
$$
begin
    if (start_year is not null and finish_year is not null and finish_year < start_year) then
        return false;
    end if;
    return true;
end;
$$;

create or replace function isFilmLanguageValid(lang varchar(64)) returns boolean
    language plpgsql
    immutable as
$$
begin
    if (lang is not null and
        not exists(select * from language_list where upper(id) = upper(lang) or upper(value) = upper(lang))) then
        return false;
    end if;
    return true;
end;
$$;

create or replace function isFilmCountryValid(country varchar(64)) returns boolean
    language plpgsql
    immutable as
$$
begin
    if (country is not null and
        not exists(select * from country_list where upper(id) = upper(country) or upper(value) = upper(country))) then
        return false;
    end if;
    return true;
end;
$$;

create or replace function filmConstructor() returns trigger as
$film_insert_init$
begin
    if not isFilmYearsValid(new.fyr, new.tyr) then
        raise exception 'the start year is more then finish year';
    end if;
    if not isFilmLanguageValid(new.lang) then
        raise exception 'the language doesnt exist';
    end if;
    if new.tstmp is not null then
        raise exception 'time stamp of film is read only field';
    end if;
    if new.fid is null then
        new.fid = uuid_generate_v1mc();
    end if;
    if new.isser is null then
        new.isser = false;
    end if;
    new.tstmp = to_char(current_timestamp, 'YYYY-MM-DD HH:MI:SS');
    return new;
end;
$film_insert_init$ language plpgsql;

create or replace function filmUpdateTimeStamp() returns trigger as
$film_update_timestamp$
begin
    if new.tstmp is not null and new.tstmp != old.tstmp then
        raise exception 'time stamp of film is read only field';
    end if;
    new.tstmp = to_char(current_timestamp, 'YYYY-MM-DD HH:MI:SS');
    return new;
end;
$film_update_timestamp$ language plpgsql;

create or replace function filmUpdateProductYears() returns trigger as
$film_update_product_year$
begin
    if not isFilmYearsValid(new.fyr, new.tyr) then
        raise exception 'the start year is more then finish year';
    end if;
    return new;
end;
$film_update_product_year$ language plpgsql;

create or replace function filmUpdateLanguage() returns trigger as
$film_update_language$
begin
    if not isFilmLanguageValid(new.lang) then
        raise exception 'the language doesnt exist';
    end if;
    return new;
end;
$film_update_language$ language plpgsql;

create or replace function filmAddUpdateCountry() returns trigger as
$film_update_country$
begin
    if not isFilmCountryValid(new.name) then
        raise exception 'the country doesnt exist';
    end if;
    return new;
end;
$film_update_country$ language plpgsql;

create or replace function filmIDModifying() returns trigger as
$user_id_changing$
begin
    raise exception 'you cannot modify film ID';
end;
$user_id_changing$ language plpgsql;

drop trigger if exists insert_film_initial on film cascade;
drop trigger if exists update_film_timestamp on film cascade;
drop trigger if exists update_film_fyr_tyr on film cascade;
drop trigger if exists update_film_language on film cascade;
drop trigger if exists insert_update_film_country on country cascade;
drop trigger if exists update_film_id on film cascade;

create trigger insert_film_initial
    before Insert
    on film
    for each row
execute procedure filmConstructor();

create trigger update_film_timestamp
    before update
    on film
    for each row
execute procedure filmUpdateTimeStamp();

create trigger update_film_fyr_tyr
    before update of fyr, tyr
    on film
    for each row
execute procedure filmUpdateProductYears();

create trigger update_film_language
    before update of lang
    on film
    for each row
execute procedure filmUpdateLanguage();

create trigger insert_update_film_country
    before insert or update
    on country
    for each row
execute procedure filmAddUpdateCountry();

create trigger update_film_id
    before update of fid
    on film
    for each row
execute procedure filmIDModifying();

--------------- views //todo

--------------- table filling data //todo