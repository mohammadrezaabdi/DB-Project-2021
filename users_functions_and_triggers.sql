
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
