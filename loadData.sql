create schema anime;
set search_path to anime;

drop table USERS;

CREATE table USERS(
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

COPY anime."users" FROM '/Users/Athina/Public/UserList.csv' DELIMITER ',' CSV HEADER;

CREATE table AnimeList(
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

COPY anime."animelist" FROM '/Users/Athina/Public/AnimeList.csv' DELIMITER ',' CSV HEADER;

CREATE table UserAnime(
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

COPY anime."useranime" FROM '/Users/Athina/Public/UserAnimeList.csv' DELIMITER ',' CSV HEADER;