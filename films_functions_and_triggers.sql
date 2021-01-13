
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
