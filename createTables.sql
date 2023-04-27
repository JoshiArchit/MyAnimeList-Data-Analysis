------------------------------------------------------------
-- CSCI-620: INTRODUCTION TO BIG DATA
-- PROJECT PHASE 1
-- FILENAME: createTables.sql
-- AUTHORS: ATHINA STEWART  as1986
--          ARCHIT JOSHI    aj6082
--          PARIJAT KAWALE  pk7145
--          CHENGZI CAO     cc3773
------------------------------------------------------------

------------------------------------------------------------
-- THIS SCRIPT CREATES MAIN TABLES AND RELATION TABLES
------------------------------------------------------------

-- set search path to the anime schema

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

------------------------------------------------------------
-- CREATING RELATION TABLES
------------------------------------------------------------

-- created watches table (many:many relation between user and anime)

CREATE table Watches(
    user_id int,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    anime_id int,
    FOREIGN KEY (anime_id) REFERENCES anime (anime_id),
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

-- insert values into watches table
INSERT INTO Watches(user_id, anime_id, my_watched_episodes, my_start_date,
                    my_finish_date, my_score, my_status, my_rewatching,
                        my_rewatching_ep, my_last_updated, my_tags)
SELECT UAO.user_id,
    user_anime_raw.anime_id,
    my_watched_episodes int,
    my_start_date       text,
    my_finish_date      text,
    my_score            float,
    my_status           int,
    my_rewatching       int,
    my_rewatching_ep    int,
    my_last_updated     int,
    my_tags             text
    FROM user_anime_raw
INNER JOIN Users UAO on user_anime_raw.username = UAO.username;
------------------------------------------------------------

-- create has_genre table (many:many relation between anime and genre)
CREATE table has_genre(
    anime_id int,
    FOREIGN KEY (anime_id) REFERENCES anime (anime_id),
    genre_id int,
    FOREIGN KEY (genre_id) REFERENCES genre(genre_id),
    PRIMARY KEY (anime_id, genre_id)
);

-- create temp table with genre_id, genre and anime_id values
CREATE table Anime_Genre_Temp (
    genre_id int,
    genre text,
    anime int
);

-- unnest the genres rows to obtain the individual genres
INSERT INTO Anime_Genre_Temp(genre, anime)
SELECT unnest(string_to_array(genre, ', ')) as "genre", anime_id FROM animelist_raw;

-- update the temp table to include matching ids
UPDATE Anime_Genre_Temp
    SET genre_id = Genre.genre_id
    FROM genre
    WHERE genre.genre = Anime_Genre_Temp.genre;

-- insert genre_ids into main table
INSERT INTO has_genre(anime_id, genre_id)
SELECT anime, genre_id FROM anime_genre_temp;

-- drop temp table
drop table anime_genre_temp;
------------------------------------------------------------

-- create produced_by table (many:many relation between anime and producer)
CREATE table Produced_By(
    anime_id int,
    FOREIGN KEY (anime_id) REFERENCES anime (anime_id),
    producer_id int,
    FOREIGN KEY (producer_id) REFERENCES producer(producer_id),
    PRIMARY KEY (anime_id, producer_id)
);

-- create temp table with producer_id, producer and anime_id values
CREATE table Anime_Producer_Temp (
    producer_id int,
    producer text,
    anime int
);

-- unnest the producers rows to obtain the individual producers
INSERT INTO Anime_Producer_Temp(producer, anime)
SELECT unnest(string_to_array(producer, ', ')) as "producer", anime_id FROM animelist_raw;

-- update the temp table to include matching ids
UPDATE Anime_Producer_Temp
    SET producer_id = producer.producer_id
    FROM producer
    WHERE Producer.producer = anime_producer_temp.producer;

-- insert producer_ids into main table
INSERT INTO produced_by(anime_id, producer_id)
SELECT anime, producer_id FROM anime_producer_temp;

-- drop temp table
drop table anime_producer_temp;
------------------------------------------------------------

-- create licensed_by table (many:many relation between anime and licensor)
CREATE table Licensed_By(
    anime_id int,
    FOREIGN KEY (anime_id) REFERENCES anime (anime_id),
    licensor_id int,
    FOREIGN KEY (licensor_id) REFERENCES licensor(licensor_id),
    PRIMARY KEY (anime_id, licensor_id)
);

-- create temp table with licensor_id, licensor and anime_id values
CREATE table Anime_Licensor_Temp (
    licensor_id int,
    licensor text,
    anime int
);

-- unnest the licensors rows to obtain the individual licensors
INSERT INTO Anime_Licensor_Temp(licensor, anime)
SELECT unnest(string_to_array(licensor, ', ')) as "licensor", anime_id FROM animelist_raw;

-- update the temp table to include matching ids
UPDATE Anime_Licensor_Temp
    SET licensor_id = Licensor.licensor_id
    FROM licensor
    WHERE Licensor.licensor = anime_licensor_temp.licensor;

-- insert licensor_ids into main table
INSERT INTO licensed_by(anime_id, licensor_id)
SELECT anime, licensor_id FROM anime_licensor_temp;

-- drop temp table
drop table anime_licensor_temp;

------------------------------------------------------------

-- create has_genre table (many:many relation between anime and studio)
CREATE table created_by(
    anime_id int,
    FOREIGN KEY (anime_id) REFERENCES anime (anime_id),
    studio_id int,
    FOREIGN KEY (studio_id) REFERENCES studio(studio_id),
    PRIMARY KEY (anime_id, studio_id)
);

-- create temp table with studio_id, studio and anime_id values
CREATE table Anime_Studio_Temp (
    studio_id int,
    studio text,
    anime int
);

-- unnest the studio rows to obtain the individual studios
INSERT INTO Anime_Studio_Temp(studio, anime)
SELECT unnest(string_to_array(studio, ', ')) as "studio", anime_id FROM animelist_raw;

-- update the temp table to include matching ids
UPDATE Anime_Studio_Temp
    SET studio_id = studio.studio_id
    FROM studio
    WHERE studio.studio = anime_studio_temp.studio;

-- insert studio_ids into main table
INSERT INTO created_by(anime_id, studio_id)
SELECT anime, studio_id FROM anime_studio_temp;

-- drop temp table
drop table anime_studio_temp;

-- drop raw tables
drop table animelist_raw;
drop table user_anime_raw;
drop table users_raw;
