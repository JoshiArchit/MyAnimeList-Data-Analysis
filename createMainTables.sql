/*
------------------------------------------------------------
CSCI-620: INTRO TO BIG DATA
PROJECT PHASE 3
FILENAME: createMainTables.sql
AUTHORS: ATHINA STEWART  as1986
          ARCHIT JOSHI    aj6082
          PARIJAT KAWALE  pk7145
          CHENGZI CAO     cc3773
------------------------------------------------------------

------------------------------------------------------------
THIS SCRIPT LOADS DATA FROM RAW DATASETS INTO THE DATABASE
AND CREATES ALL MAIN TABLES
------------------------------------------------------------
 */

-- CREATE SCHEMA anime;
-- set search_path to anime;
--
--
-- create raw user data
CREATE table USERS_Raw(
    username text,
    user_id int,
    user_watching int,
    user_completed int,
    user_onhold int,
    user_dropped int,
    user_plantowatch int,
    user_days_spent_watching float,
    gender text,
    user_location text,
    birth text,
    access_rank int,
    join_date text,
    last_online text,
    stats_mean_score float,
    stats_rewatched int,
    stats_episodes int
);

-- copy raw user data from the file into the table
COPY users_raw FROM '/Users/Athina/Public/UserList.csv' DELIMITER ',' CSV HEADER;

------------------------------------------------------------

-- create raw anime data
CREATE table AnimeList_Raw(
    anime_id int,
    title text,
    title_english text,
    title_japanese text,
    title_synonyms text,
    image_url text,
    anime_type text,
    source text,
    episodes int,
    status text,
    airing text,
    aired_string text,
    aired text,
    duration text,
    rating text,
    score float,
    scored_by int,
    rank int,
    popularity int,
    members int,
    favourites int,
    background text,
    premiered text,
    broadcast text,
    related text,
    producer text,
    licensor text,
    studio text,
    genre text,
    opening_theme text,
    ending_theme text
);

-- copy raw anime data from the file into the table
COPY animelist_raw FROM '/Users/Athina/Public/AnimeList.csv' DELIMITER ',' CSV HEADER;

------------------------------------------------------------

-- create raw user-anime junction data
CREATE table User_Anime_Raw(
    username text,
    anime_id int,
    my_watched_episodes int,
    my_start_date text,
    my_finish_date	text,
    my_score float,
    my_status int,
    my_rewatching int,
    my_rewatching_ep int,
    my_last_updated int,
    my_tags text
);

-- copy raw user_anime data from the file into the table
COPY user_anime_raw FROM '/Users/Athina/Public/UserAnimeList.csv' DELIMITER ',' CSV HEADER;

------------------------------------------------------------
-- CREATING MAIN TABLES
------------------------------------------------------------

-- create anime table
CREATE TABLE Anime(
    anime_id int PRIMARY KEY,
    title text,
    title_english text,
    title_japanese text,
    title_synonyms text,
    title_episodes int,
    aired text,
    aired_from_to text,
    duration text,
    is_airing text,
    rank int,
    popularity int,
    members int,
    favourites int,
    background text,
    premiered text,
    broadcast text,
    related_to text,
    opening_theme text,
    ending_theme text,
    score float,
    num_votes int,
    related_as text
);

-- into data from raw dataset into main anime table
INSERT INTO anime (anime_id, title, title_english, title_japanese, title_synonyms,
                                   title_episodes, aired, aired_from_to, duration, is_airing,
                                   rank, popularity, members, favourites, background, premiered,
                                   broadcast, related_to, opening_theme, ending_theme, score, num_votes)
SELECT anime_id, title, title_english, title_japanese, title_synonyms, episodes, aired_string, aired,
       duration, airing, rank, popularity, members, favourites, background, premiered, broadcast, related,
       opening_theme, ending_theme, score, scored_by
FROM animelist_raw;
------------------------------------------------------------

-- create users table
CREATE table Users(
    user_id int PRIMARY KEY,
    username text,
    gender text,
    birth text,
    user_watching int,
    user_completed int,
    user_onhold int,
    user_dropped int,
    user_plantowatch int,
    user_days_spent_watching float,
    user_location text,
    access_rank int,
    join_date text,
    stats_mean_score float,
    stats_rewatched int,
    stats_episodes int
);

-- into data from raw dataset into main users table
INSERT INTO Users (user_id, username, gender, birth, user_watching, user_completed,
                                   user_onhold, user_dropped, user_plantowatch,
                                   user_days_spent_watching, user_location,
                                   access_rank, join_date, stats_mean_score,
                                   stats_rewatched, stats_episodes)
SELECT user_id, username, gender, birth, user_watching, user_completed,
                                   user_onhold, user_dropped, user_plantowatch,
                                   user_days_spent_watching, user_location,
                                   access_rank, join_date, stats_mean_score,
                                   stats_rewatched, stats_episodes
FROM USERS_RAW
ON CONFLICT DO NOTHING;
------------------------------------------------------------

-- create genre table
CREATE table Genre (
    genre_id SERIAL PRIMARY KEY,
    genre text
);

-- insert values into genre table
INSERT INTO Genre(genre)
SELECT DISTINCT(genre) FROM
(SELECT unnest(string_to_array(genre, ', '))  as genre FROM animelist_raw) as distinctgenre;
------------------------------------------------------------

-- create producer table
CREATE table Producer (
    producer_id SERIAL PRIMARY KEY,
    producer text
);

-- insert values into producer table
INSERT INTO Producer(producer)
SELECT DISTINCT(producer) FROM
(SELECT unnest(string_to_array(producer, ', '))  as producer FROM animelist_raw) as distinctproducer;
------------------------------------------------------------

-- create licensor table
CREATE table Licensor (
    licensor_id SERIAL PRIMARY KEY,
    licensor text
);

-- insert values into licensor table
INSERT INTO Licensor(licensor)
SELECT DISTINCT(licensor) FROM
(SELECT unnest(string_to_array(licensor, ', '))  as licensor FROM animelist_raw) as distinctlicensor;
------------------------------------------------------------

-- create studio table
CREATE table Studio (
    studio_id SERIAL PRIMARY KEY,
    studio text
);

-- insert values into studio table
INSERT INTO Studio(studio)
SELECT DISTINCT(studio) FROM
(SELECT unnest(string_to_array(studio, ', '))  as studio FROM animelist_raw) as distinctstudio;