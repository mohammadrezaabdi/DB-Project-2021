-- postgreSQL ver 42.2.5 stable
-- if you are using dataGrip first you should set Switch schema: Automatic in "Data Sources and Drivers/Options/Connection"
-- database & schema make instructions
drop database if exists ImdbDB;
create database ImdbDB;
set search_path to ImdbDB;
create schema if not exists public;