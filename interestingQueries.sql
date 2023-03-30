------------------------------------------------------------
-- CSCI-620: INTRO TO BIG DATA
-- PROJECT PHASE 2
-- FILENAME: interestingQueries.sql
-- AUTHORS: ATHINA STEWART  as1986
--          ARCHIT JOSHI    aj6082
--          PARIJAT KAWALE  pk7145
--          CHENGZI CAO     cc3773
------------------------------------------------------------

SET search_path TO anime;

-- anime of genre Drama produced by Animax
SELECT a.anime_id, g.genre, p.producer
FROM anime a
INNER JOIN has_genre hg on a.anime_id = hg.anime_id
INNER JOIN genre g on hg.genre_id = g.genre_id
INNER JOIN produced_by pb on a.anime_id = pb.anime_id
INNER JOIN producer p on p.producer_id = pb.producer_id
AND p.producer = 'Animax'
AND g.genre = 'Drama';

-- users that watch comedy anime from India
SELECT DISTINCT (u.user_id, u.user_location, g.genre)
FROM users u
INNER JOIN watches w on u.user_id = w.user_id
INNER JOIN has_genre hg on w.anime_id = hg.anime_id
INNER JOIN genre g on g.genre_id = hg.genre_id
WHERE u.user_location like '%India'
AND genre = 'Comedy';

-- who licensed the most anime's between post 2000s


/*
count of 9+ rated anime's produced by a studio
 */
select studio.studio, count(anime.score)
from created_by inner join studio on created_by.studio_id = studio.studio_id
                inner join anime on created_by.anime_id = anime.anime_id
where score > 9.0 group by studio.studio order by count(anime.score) DESC;

/*
 Ranking Genres by popularity across all anime's in a specific country

 Admiral Brown : Hey, Im a famous producer. I want to make a new anime for my target audience
 in China ! What genre is most popular there ?
 */
select genre, sum(popularity)
from genre inner join has_genre on genre.genre_id = has_genre.genre_id
           inner join anime on has_genre.anime_id = anime.anime_id
           inner join watches on watches.anime_id = anime.anime_id
           inner join users on watches.user_id = users.user_id
where users.user_location like '%China%'
group by genre order by sum(popularity) DESC;

select producer
select cast(substr(aired_from_to,11,4) as int) from anime where aired_from_to not like '%None%';