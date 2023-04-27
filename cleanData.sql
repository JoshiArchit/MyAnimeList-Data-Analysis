/*
------------------------------------------------------------
CSCI-620: INTRO TO BIG DATA
PROJECT PHASE 3
FILENAME: cleanData.sql
AUTHORS: ATHINA STEWART  as1986
          ARCHIT JOSHI    aj6082
          PARIJAT KAWALE  pk7145
          CHENGZI CAO     cc3773
------------------------------------------------------------

------------------------------------------------------------
THIS SCRIPT CLEANS THE DATA IN THE ANIME, USERS AND
WATCHES TABLE
------------------------------------------------------------
 */

SET SEARCH_PATH to anime;

------------------------------------------------------------

-- FILTERING AND CLEANING ON USERS TABLE
-- original table count 302,673

-- drop access rank column
ALTER TABLE users DROP COLUMN access_rank;

-- remove days spent watching greater than 10950
DELETE FROM users WHERE user_days_spent_watching > 10950; -- 10950 days == 50 years

-- remove users with null values for gender, user_location and birth
DELETE FROM users WHERE gender IS NULL
OR user_location IS NULL
OR birth IS NULL;

-- convert date column values to datestamp
ALTER TABLE users ALTER COLUMN birth TYPE DATE
using to_date(birth, 'YYYY-MM-DD');

-- remove users too young and too old
DELETE FROM users WHERE birth > '2023-04-18'
OR birth < '1923-04-18';

-- remove stats episodes not greater than 0
DELETE FROM users WHERE stats_episodes = 0;

-- remove locations that are numbers (not [a-z] or [A-Za-z])
DELETE from users WHERE (users.user_location ~* '[[:alpha:]]') IS FALSE;


-- updated table count 114,609
------------------------------------------------------------

-- FILTERING AND CLEANING ON ANIME TABLE
-- original table count 14,478

-- remove related_as column
ALTER TABLE anime DROP COLUMN related_as;

-- remove 0 values from title episodes
DELETE FROM anime WHERE title_episodes < 1;

-- updated table count 13,974
------------------------------------------------------------

-- FILTERING AND CLEANING ON WATCHES TABLE

-- reload the watches table from the filtered and cleaned anime and users table

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
INNER JOIN Users UAO on user_anime_raw.username = UAO.username
INNER JOIN Anime A on A.anime_id = user_anime_raw.anime_id;

-- delete from watches table records where users watched more episodes of an
-- anime than there are episodes of that anime

DELETE FROM watches where watches.my_watched_episodes > (SELECT anime.title_episodes from anime where watches.anime_id = anime.anime_id);

ALTER TABLE watches
    ADD CONSTRAINT f_k_user_id FOREIGN KEY (user_id) REFERENCES users(user_id);

ALTER TABLE watches
    ADD CONSTRAINT f_k_anime_id FOREIGN KEY (anime_id) REFERENCES anime(anime_id);

-- final table count 34,973,574
------------------------------------------------------------
------------------------------------------------------------

-- Re-create relation tables
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
SELECT agt.anime, agt.genre_id
FROM anime_genre_temp agt
INNER JOIN anime a on agt.anime = a.anime_id;

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
SELECT apt.anime, apt.producer_id
FROM anime_producer_temp apt
INNER JOIN anime a on apt.anime = a.anime_id;

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
SELECT alt.anime, alt.licensor_id
FROM anime_licensor_temp alt
INNER JOIN anime a on alt.anime = a.anime_id;

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
SELECT ast.anime, ast.studio_id
FROM anime_studio_temp ast
INNER JOIN anime a on ast.anime = a.anime_id;

-- drop temp table
drop table anime_studio_temp;

-- COPY watches TO '/Users/Athina/Library/CloudStorage/GoogleDrive-as1896@g.rit.edu/My Drive/CSCI 620 Final Project/watches.csv';
-- COPY anime TO '/Users/Athina/Library/CloudStorage/GoogleDrive-as1896@g.rit.edu/My Drive/CSCI 620 Final Project/anime.csv';
-- COPY users TO '/Users/Athina/Library/CloudStorage/GoogleDrive-as1896@g.rit.edu/My Drive/CSCI 620 Final Project/users.csv';

drop table animelist_raw;
drop table users_raw;
drop table user_anime_raw;