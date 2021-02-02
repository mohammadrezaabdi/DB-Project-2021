drop domain if exists multi_word_name cascade;
create domain multi_word_name as text
    check ( value ~ '([a-zA-Z]+\s)*[a-zA-Z]+$');

drop domain if exists set_of_words cascade;
create domain set_of_words as text
    check ( value ~ '([a-zA-Z\s]+(\s*,\s*))*[a-zA-Z\s]+$');

drop domain if exists phone_number cascade;
create domain phone_number as text
    check ( value ~ '^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$' );

drop domain if exists email_address cascade;
create domain email_address as text
    check ( value ~
            '^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$' );

drop domain if exists user_name cascade;
create domain user_name as text -- just with letters, numbers, _, -
    check ( value ~ '^[A-Za-z0-9]+(?:[ _-][A-Za-z0-9]+)*$');

drop domain if exists link cascade;
create domain link as text
    check ( value ~
            '^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$');

drop domain if exists valid_password cascade;
create domain valid_password as text -- Minimum eight characters, at least one letter and one number
    check ( value ~ '^(?=.*\d)((?=.*[a-z])|(?=.*[A-Z]))(?=.*[a-zA-Z]).{8,}$');

drop domain if exists valid_year cascade;
create domain valid_year as smallint
    check (value >= 1888 and value <= date_part('year', now()));

drop domain if exists valid_month cascade;
create domain valid_month as char(3)
    check (upper(value) in ('JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'));

drop domain if exists valid_day cascade;
create domain valid_day as smallint
    check (value <= 31 and value >= 1);

drop domain if exists sex cascade;
create domain sex as char(1)
    check (upper(value) in ('M', 'F'));

drop domain if exists user_type cascade;
create domain user_type as char(1) default 'F'
    check (upper(value) in ('P', 'F'));

drop domain if exists user_edit_number_limitation cascade;
create domain user_edit_number_limitation as smallint default 5
    check (value <= 5 and value >= 0);

drop domain if exists normal_number cascade;
create domain normal_number as smallint
    check (value > 0);

drop domain if exists mpa_film_rating cascade;
create domain mpa_film_rating as varchar(5) -- The Motion Picture Association (MPA) film rating system
    check (value in ('G', 'GP', 'PG', 'PG-13', 'R', 'NC-17', 'X', 'M'));

drop domain if exists million_dollar cascade;
create domain million_dollar as numeric(10, 5)
    check (value >= 0.0);

drop domain if exists modify_date cascade;
create domain modify_date as text
    check (value ~ '^\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2}$');

drop domain if exists rate cascade;
create domain rate as numeric(3, 1)
    check (value >= 0.0 and value <= 10.0);

drop domain if exists movie_name cascade;
create domain movie_name as text
    check (value ~ '[a-zA-Z0-9_\-:\s@\(\)]*$');

drop domain if exists genre cascade;
create domain genre as text
    check (upper(value) in
           ('ACTION', 'ADVENTURE', 'COMEDY', 'DRAMA', 'CRIME', 'THRILLER', 'SCI-FI', 'HORROR', 'ROMANCE',
            'SCIENCE FICTION', 'CRIME', 'WESTERN', 'MUSIC', 'FICTION', 'MYSTERY', 'DOCUMENTARY', 'EPIC',
            'MATERIAL ARTS', 'SCIENCE', 'FANTASY', 'ANIMATION', 'SPORTS', 'BIOGRAPHICAL', 'EXPERIMENTAL', 'SILENT',
            'SPY', 'COMEDY-DRAMA', 'MONSTER', 'ZOMBIE', 'CARTOON', 'GORE', 'HEIST', 'SLASHER'));
