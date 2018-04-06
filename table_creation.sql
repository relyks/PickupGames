
DROP DATABASE IF EXISTS pickupgames;
CREATE DATABASE pickupgames;
USE pickupgames;
DROP TABLE IF EXISTS User;
DROP TABLE IF EXISTS Sport;
drop table if exists Game;
drop table if exists Location;
drop table if exists canHost;
drop table if exists Plays;

CREATE Table User (
    email varchar(50) primary key,
    password varchar(20),
    firstName varchar(20),
    lastName varchar(20),
    realUser boolean
);
create Table Sport (
    sportID varchar(50) primary key,
    sportType varchar(40),
    numberOfPlayers int
);
 create table Game(
        gameID varchar(50) primary key,
        skillLevel varchar(30),
        startTime datetime,
        finalGame boolean,
        sportID varchar(50) references Sport on delete cascade,
        locationID varchar(50) references Location
);
create Table Location(
        locationID varchar(50) primary key,
        locationName varchar(30)
);
create table canHost(
    locationID varchar(50) references Location,
    sportID varchar(50) references Sport,
    primary key(locationID, sportID)
);

create Table plays(
        gameID varchar(50) references Game on delete cascade,
        email varchar(50) references User on delete cascade,
        Primary key (gameID,email)
);
