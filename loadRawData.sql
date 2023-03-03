------------------------------------------------------------
-- CSCI-620: INTRO TO BIG DATA
-- PROJECT PHASE 1
-- FILENAME: loadRawData.sql
-- AUTHORS: ATHINA STEWART  as1986
--          ARCHIT JOSHI    aj6082
--          PARIJAT KAWALE  pk7145
--          CHENGZI CAO     cc3773
------------------------------------------------------------

------------------------------------------------------------
-- THIS SCRIPT LOADS DATA FROM RAW DATASETS INTO THE DATABASE
------------------------------------------------------------

-- create anime schema
create schema anime;

-- set search path to anime schema
set search_path to anime;

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
COPY anime."users_raw" FROM '/Users/Athina/Public/UserList.csv' DELIMITER ',' CSV HEADER;

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
COPY anime."animelist_raw" FROM '/Users/Athina/Public/AnimeList.csv' DELIMITER ',' CSV HEADER;

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
COPY anime."user_anime_raw" FROM '/Users/Athina/Public/UserAnimeList.csv' DELIMITER ',' CSV HEADER;
