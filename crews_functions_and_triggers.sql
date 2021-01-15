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
    if by is not null and dy is not null and by < dy then
        return true;
    end if;
    if bm is not null and dm is not null and by = dy and monthToInt(bm) < monthToInt(dm) then
        return true;
    end if;
    if bd is not null and dd is not null and by = dy and monthToInt(bm) = monthToInt(dm) and bd <= dd then
        return true;
    end if;
    return false;
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
