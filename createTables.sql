SET search_path to anime;

CREATE table Genre (
    genre_id SERIAL PRIMARY KEY,
    genre text
);

INSERT INTO Genre(genre)
SELECT DISTINCT(genre) FROM
(SELECT unnest(string_to_array(genre, ', '))  as genre FROM animelist) as distinctgenre;

CREATE table Source (
    source_id SERIAL PRIMARY KEY,
    source text
);

INSERT INTO Source(source)
SELECT DISTINCT(source) FROM
(SELECT unnest(string_to_array(source, ', '))  as source FROM animelist) as distinctsource;

CREATE table Type (
    type_id SERIAL PRIMARY KEY,
    anime_type text
);

INSERT INTO Type(anime_type)
SELECT distinct(anime_type) FROM animelist;

CREATE table Producer (
    producer_id SERIAL PRIMARY KEY,
    producer text
);

INSERT INTO Producer(producer)
SELECT DISTINCT(producer) FROM
(SELECT unnest(string_to_array(producer, ', '))  as producer FROM animelist) as distinctproducer;

CREATE table Licensor (
    licensor_id SERIAL PRIMARY KEY,
    licensor text
);

INSERT INTO Licensor(licensor)
SELECT DISTINCT(licensor) FROM
(SELECT unnest(string_to_array(licensor, ', '))  as licensor FROM animelist) as distinctlicensor;

CREATE table Studio (
    studio_id SERIAL PRIMARY KEY,
    studio text
);

INSERT INTO Studio(studio)
SELECT DISTINCT(studio) FROM
(SELECT unnest(string_to_array(studio, ', '))  as studio FROM animelist) as distinctstudio;

CREATE TABLE Anime_Attributes_Only(
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


INSERT INTO Anime_Attributes_Only (anime_id, title, title_english, title_japanese, title_synonyms,
                                   title_episodes, aired, aired_from_to, duration, is_airing,
                                   rank, popularity, members, favourites, background, premiered,
                                   broadcast, related_to, opening_theme, ending_theme, score, num_votes)
SELECT anime_id, title, title_english, title_japanese, title_synonyms, episodes, aired_string, aired,
       duration, airing, rank, popularity, members, favourites, background, premiered, broadcast, related,
       opening_theme, ending_theme, score, scored_by
FROM animelist;

drop table users_attributes_only;
CREATE table Users_Attributes_Only(
    user_id int PRIMARY KEY,
    username text,
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
    stats_mean_score float,
    stats_rewatched int,
    stats_episodes int
);

INSERT INTO Users_Attributes_Only (user_id, username, user_watching, user_completed,
                                   user_onhold, user_dropped, user_plantowatch,
                                   user_days_spent_watching, gender, user_location,
                                   birth, access_rank, join_date, stats_mean_score,
                                   stats_rewatched, stats_episodes)
SELECT user_id, username, user_watching, user_completed,
                                   user_onhold, user_dropped, user_plantowatch,
                                   user_days_spent_watching, gender, user_location,
                                   birth, access_rank, join_date, stats_mean_score,
                                   stats_rewatched, stats_episodes
FROM users
ON CONFLICT DO NOTHING;

CREATE table UserWatches(
    user_id int,
    FOREIGN KEY (user_id) REFERENCES users_attributes_only(user_id),
    anime_id int,
    FOREIGN KEY (anime_id) REFERENCES anime_attributes_only(anime_id),
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

INSERT INTO UserWatches(user_id, anime_id, my_watched_episodes, my_start_date,
                        my_finish_date, my_score, my_status, my_rewatching,
                        my_rewatching_ep, my_last_updated, my_tags)
SELECT UAO.user_id,
    useranime.anime_id,
    my_watched_episodes int,
    my_start_date text,
    my_finish_date	text,
    my_score float,
    my_status int,
    my_rewatching int,
    my_rewatching_ep int,
    my_last_updated int,
    my_tags text
    FROM useranime
INNER JOIN Users_Attributes_Only UAO on useranime.username = UAO.username;

CREATE table Anime_Genre(
    anime_id int,
    FOREIGN KEY (anime_id) REFERENCES anime_attributes_only(anime_id),
    genre_id int,
    FOREIGN KEY (genre_id) REFERENCES genre(genre_id),
    PRIMARY KEY (anime_id, genre_id)
);

SELECT *
FROM Anime_Attributes_Only AAO
INNER JOIN Genre g on AAO.anime_id = a.anime_id


CREATE table Anime_Producer(
    anime_id int,
    FOREIGN KEY (anime_id) REFERENCES anime_attributes_only(anime_id),
    producer_id int,
    FOREIGN KEY (producer_id) REFERENCES producer(producer_id),
    PRIMARY KEY (anime_id, producer_id)
);

CREATE table Anime_Licensor(
    anime_id int,
    FOREIGN KEY (anime_id) REFERENCES anime_attributes_only(anime_id),
    licensor_id int,
    FOREIGN KEY (licensor_id) REFERENCES licensor(licensor_id),
    PRIMARY KEY (anime_id, licensor_id)
);

CREATE table Anime_Studio(
    anime_id int,
    FOREIGN KEY (anime_id) REFERENCES anime_attributes_only(anime_id),
    studio_id int,
    FOREIGN KEY (studio_id) REFERENCES studio(studio_id),
    PRIMARY KEY (anime_id, studio_id)
);
