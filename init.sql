-- postgreSQL ver 42.2.5 stable
-- if you are using dataGrip first you should set Switch schema: Automatic in "Data Sources and Drivers/Options/Connection"
drop database if exists Imdb;
create database Imdb;
set search_path to Imdb;
create schema if not exists public;
create extension if not exists "uuid-ossp";
create extension if not exists "pgcrypto";