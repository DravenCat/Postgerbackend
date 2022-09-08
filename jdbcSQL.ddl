DROP SCHEMA IF EXISTS A2 CASCADE;
CREATE SCHEMA A2;
SET search_path TO A2;

DROP TABLE IF EXISTS LilmonInventory CASCADE;
DROP TABLE IF EXISTS PlayerRatings CASCADE;
DROP TABLE IF EXISTS GuildRatings CASCADE;
DROP TABLE IF EXISTS Lilmon CASCADE;
DROP TABLE IF EXISTS Player CASCADE;
DROP TABLE IF EXISTS Guild CASCADE;
DROP TABLE IF EXISTS Query1 CASCADE;
DROP TABLE IF EXISTS Query2 CASCADE;
DROP TABLE IF EXISTS Query3 CASCADE;
DROP TABLE IF EXISTS Query4 CASCADE;
DROP TABLE IF EXISTS Query5 CASCADE;
DROP TABLE IF EXISTS Query6 CASCADE;
DROP TABLE IF EXISTS Query7 CASCADE;
DROP TABLE IF EXISTS Query8 CASCADE;
DROP TABLE IF EXISTS Query9 CASCADE;
DROP TABLE IF EXISTS Query10 CASCADE;


/*
You are a developer for 'Lilmons: Monster Collector', a game where players collect monsters by spending coins and battle with them among other things.
You are in charge of writing reports that the higher-ups request in order get data on their players and make business decisions.
*/


-- The Lilmon table contains information about the different lilmons that players can collect.
-- 'id' is the id of the lilmon.
-- 'name' is the name of the lilmon.
-- 'element1' is the primary element of the lilmon.
-- 'element2' is the secondary element of the lilmon if they have one, NULL otherwise.
-- 'rarity' is the designated rarity of the lilmon.
-- Read the constraints below for more details on what values these columns can take on.
CREATE TABLE Lilmon(
    id INTEGER PRIMARY KEY,
    name VARCHAR UNIQUE NOT NULL,
    element1 VARCHAR NOT NULL,
    element2 VARCHAR,
    rarity INTEGER NOT NULL,
    CHECK (element1 IN ('Water', 'Fire', 'Air', 'Earth', 'Ice', 'Electric', 'Light', 'Dark')),
    CHECK (element2 IN ('Water', 'Fire', 'Air', 'Earth', 'Ice', 'Electric', 'Light', 'Dark')),
    CHECK (element2 != element1),
    CHECK (rarity BETWEEN 3 AND 5)
);

-- The Player table contains information about the players of the game.
-- 'id' is the id of the player.
-- 'playername' is the chosen playername of the player.
-- 'email' is the email of the player.
-- 'country_code' is the ISO 3166-1 alpha-3 code of the country that the player is in. See https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3 for more details.
-- 'coins' is the number of coins the player currently has. You can assume this is always >= 0.
-- 'rolls' is the number of times the player has spent coins to acquire a random lilmon. You can assume this is always >= 0.
-- 'wins' is the number of times the player has won a completed battle. You can assume this is always >= 0.
-- 'losses' is the number of times the player has lost a completed battle. You can assume this is always >= 0.
-- 'total_battles' is the number of times the player has participated in a (not necessarily completed) battle. You can assume this is always >= 0. The reason why wins plus losses is not necessarily equal to total_battles is that there may be some unforeseen circumstances that lead to a battle not being completed (eg: server or connection issues).
-- 'guild' is the id of the guild that the player belongs to (whether they are member or a leader) if they belong to one, NULL otherwise. A player can only belong to at most one guild. The constraint on this column can be found after the definition of the Guild table.
CREATE TABLE Player(
    id INTEGER PRIMARY KEY,
    playername VARCHAR UNIQUE NOT NULL,
    email VARCHAR UNIQUE NOT NULL,
    country_code CHAR(3) NOT NULL,
    coins INTEGER NOT NULL DEFAULT 0,
    rolls INTEGER NOT NULL DEFAULT 0,
    wins INTEGER NOT NULL DEFAULT 0,
    losses INTEGER NOT NULL DEFAULT 0,
    total_battles INTEGER NOT NULL DEFAULT 0,
    guild INTEGER
);

-- The Guild table contains information about a guild.
-- A guild must contain at least one member (namely, the guild leader) and a player can be in at most one guild (as previously mentioned in the Player table).
-- Hence, guild membership is tracked in the Player table.
-- 'id' is the id of the guild.
-- 'guildname' is the name of the guild.
-- 'tag' is the chosen tag of the guild (typically used to abbreviate the name of the guild).
-- 'leader' is the id of the player that leads the guild.
CREATE TABLE Guild(
    id INTEGER PRIMARY KEY,
    guildname VARCHAR UNIQUE NOT NULL,
    tag VARCHAR(5) UNIQUE NOT NULL,
    leader INTEGER NOT NULL REFERENCES Player(id) ON DELETE RESTRICT
);

-- Constraint for the 'guild' column in the Player table.
ALTER TABLE Player
ADD FOREIGN KEY (guild) REFERENCES Guild(id) ON DELETE SET NULL;

-- The LilmonInventory table contains information about lilmons that players have collected.
-- 'id' is the unique id of the collected lilmon. This is because a player can collect multiple of the same lilmon and so this is to help distinguish between them.
-- 'l_id' is the id of the lilmon.
-- 'p_id' is the id of the player.
-- 'in_team' is a flag that indicates whether this specific lilmon is currently active in the player's team. You may assume a player can only have up to five (5) lilmons in their team at any given time.
-- 'fav' is a flag that indicates whether the player has favourited this specific lilmon.
CREATE TABLE LilmonInventory(
    id SERIAL PRIMARY KEY,
    l_id INTEGER NOT NULL REFERENCES Lilmon(id) ON DELETE RESTRICT,
    p_id INTEGER NOT NULL REFERENCES Player(id) ON DELETE CASCADE,
    in_team BOOLEAN NOT NULL DEFAULT FALSE,
    fav BOOLEAN NOT NULL DEFAULT FALSE
);

-- The PlayerRatings table contains information about a player's skill level in the game.
-- The way this table works is that at the end of every month, all players have their monthly and all-time ratings calculated and recorded in this table for this month.
-- You do not need to be concerned with how this value is calculated, you just need to know that a higher value means the player is more skilled at the game.
-- 'id' here does not mean much, it is arbitrary; mainly used just to uniquely identify a row in this table.
-- 'p_id' is the player associated to this rating record.
-- 'month' is the month associated to this rating record.
-- 'year' is the year associated to this rating record.
-- 'monthly_rating' is the player's monthly rating for the month-year on the record. You can assume this is always >= 0.
-- 'all-time_rating' is the player's all-time rating as of the month-year on the record. You can assume this is always >= 0.
CREATE TABLE PlayerRatings(
    id SERIAL PRIMARY KEY,
    p_id INTEGER NOT NULL REFERENCES Player(id) ON DELETE RESTRICT,
    month INTEGER NOT NULL,
    year INTEGER NOT NULL,
    monthly_rating INTEGER NOT NULL,
    all_time_rating INTEGER NOT NULL,
    CHECK (month BETWEEN 1 AND 12)
);

-- The GuildRatings table contains information about a guild's skill level in the game. It works almost identically to the PlayerRatings table but we will detail it out anyways.
-- The way this table works is that at the end of every month, all guilds have their monthly and all-time ratings calculated and recorded in this table for this month.
-- You do not need to be concerned with how this value is calculated, you just need to know that a higher value means the guild is more skilled at the game.
-- 'id' here does not mean much, it is arbitrary; mainly used just to uniquely identify a row in this table.
-- 'g_id' is the guild associated to this rating record.
-- 'month' is the month associated to this rating record.
-- 'year' is the year associated to this rating record.
-- 'monthly_rating' is the guild's monthly rating for the month-year on the record. You can assume this is always >= 0.
-- 'all_time_rating' is the guild's all-time rating as of the month-year on the record. You can assume this is always >= 0.
CREATE TABLE GuildRatings(
    id SERIAL PRIMARY KEY,
    g_id INTEGER NOT NULL REFERENCES Guild(id) ON DELETE RESTRICT,
    month INTEGER NOT NULL,
    year INTEGER NOT NULL,
    monthly_rating INTEGER NOT NULL,
    all_time_rating INTEGER NOT NULL,
    CHECK (month BETWEEN 1 AND 12)
);


-- The following tables will be used to store the results of your queries. 
-- Each of them should be populated by your last SQL statement that looks like:
-- "INSERT INTO QueryX (SELECT ...<complete your SQL query here> ... )"


CREATE TABLE Query1(
    p_id INTEGER,
    playername VARCHAR,
    email VARCHAR,
    classification VARCHAR
);

CREATE TABLE Query2(
    element VARCHAR,
    popularity_count INTEGER
);

CREATE TABLE Query3(
    avg_ig_per_month_per_player REAL
);

CREATE TABLE Query4(
    id INTEGER,
    name VARCHAR,
    rarity INTEGER,
    popularity_count INTEGER
);

CREATE TABLE Query5(
    p_id INTEGER,
    playername VARCHAR,
    email VARCHAR,
    min_mr INTEGER,
    max_mr INTEGER
);

CREATE TABLE Query6(
    g_id INTEGER,
    guildname VARCHAR,
    tag VARCHAR(5),
    leader_id INTEGER,
    leader_name VARCHAR,
    leader_country CHAR(3),
    size VARCHAR,
    classification VARCHAR
);

CREATE TABLE Query7(
    country_code CHAR(3),
    player_retention REAL
);

CREATE TABLE Query8(
    p_id INTEGER,
    playername VARCHAR,
    player_wr REAL,
    g_id INTEGER,
    guildname VARCHAR,
    tag VARCHAR(5),
    guild_aggregate_wr REAL
);

CREATE TABLE Query9(
    g_id INTEGER,
    guildname VARCHAR,
    monthly_rating INTEGER,
    all_time_rating INTEGER,
    country_pcount INTEGER,
    total_pcount INTEGER,
    country_code CHAR(3)
);

CREATE TABLE Query10(
    g_id INTEGER,
    guildname VARCHAR,
    avg_veteranness REAL
);
