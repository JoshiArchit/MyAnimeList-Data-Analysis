/*
    CSCI-620: INTRO TO BIG DATA
    PROJECT PHASE 2
    FILENAME: interestingQueries.sql
    AUTHORS:    ATHINA STEWART  as1986
                ARCHIT JOSHI    aj6082
                PARIJAT KAWALE  pk7145
                CHENGZI CAO     cc3773

    This file contains a few interesting SQL queries over the data set.
*/

SET search_path TO anime;

/*
 How many drama animes has Animax produced ?
 */
SELECT a.anime_id, g.genre, p.producer
FROM anime a
    INNER JOIN has_genre hg ON a.anime_id = hg.anime_id
    INNER JOIN genre g ON hg.genre_id = g.genre_id
    INNER JOIN produced_by pb ON a.anime_id = pb.anime_id
    INNER JOIN producer p ON p.producer_id = pb.producer_id
AND p.producer = 'Animax'
AND g.genre = 'Drama';


/*
 Which users have been watching comedy genre animes in India
 */
SELECT DISTINCT (u.user_id, u.user_location, g.genre)
FROM users u
    INNER JOIN watches w ON u.user_id = w.user_id
    INNER JOIN has_genre hg ON w.anime_id = hg.anime_id
    INNER JOIN genre g ON g.genre_id = hg.genre_id
WHERE u.user_location LIKE '%India'
AND genre = 'Comedy';


/*
    Which licensor licensed the most anime's between post 2000s
 */
SELECT licensor.licensor_id AS ID, licensor.licensor, count(licensed_by.anime_id)
FROM licensor
    INNER JOIN licensed_by ON licensor.licensor_id = licensed_by.licensor_id
    INNER JOIN anime ON licensed_by.anime_id = anime.anime_id
WHERE cast(substr(aired_from_to,11,4) AS INT) > 2000 AND aired_from_to NOT LIKE '%None%'
GROUP BY licensor.licensor_id, licensor.licensor ORDER BY count(licensed_by.anime_id) DESC ;


/*
    A count of 9+ rated anime's produced by a studio
 */
SELECT studio.studio, count(anime.score)
FROM created_by INNER JOIN studio ON created_by.studio_id = studio.studio_id
                INNER JOIN anime ON created_by.anime_id = anime.anime_id
WHERE score > 9.0 GROUP BY studio.studio ORDER BY count(anime.score) DESC;


/*
 Ranking Genres by popularity across all anime's in a specific country

 "Hey, Im a famous producer. I want to make a new anime for my target audience
 in China ! What genre is most popular there ?"
 */
SELECT genre, sum(popularity)
FROM genre INNER JOIN has_genre ON genre.genre_id = has_genre.genre_id
           INNER JOIN anime ON has_genre.anime_id = anime.anime_id
           INNER JOIN watches  ON watches.anime_id = anime.anime_id
           INNER JOIN users ON watches.user_id = users.user_id
WHERE users.user_location LIKE '%China%'
GROUP BY genre ORDER BY sum(popularity) DESC;