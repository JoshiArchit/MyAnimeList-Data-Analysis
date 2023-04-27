------------------------------------------------------------
-- CSCI-620: INTRO TO BIG DATA
-- PROJECT PHASE 2
-- FILENAME: exportToMongo.sql
-- AUTHORS: ATHINA STEWART  as1986
--          ARCHIT JOSHI    aj6082
--          PARIJAT KAWALE  pk7145
--          CHENGZI CAO     cc3773
------------------------------------------------------------

------------------------------------------------------------
-- THIS SCRIPT EXPORTS DATA FOR USERS AND ANIMES TO JSON
------------------------------------------------------------
-- Export users data from postgres to json
COPY (SELECT json_agg(row_to_json(new_user)) from
    (SELECT Users.user_id as "_id", Users.username as username , Users.gender as gender,
            Users.birth as "birthdate", Users.user_watching as "current_watch_anime",
            Users.user_completed as "completed_anime", Users.user_onhold as "anime_onhold",
            Users.user_dropped as "dropped_anime", Users.user_plantowatch as "anime_plannedtowacth",
            Users.user_days_spent_watching as "days_spent_on_anime", Users.access_rank as "access_rank",
            Users.join_date as "site_join_date", Users.stats_mean_score as "mean_score",
            Users.stats_rewatched as "rewatched_stats", Users.stats_episodes as "episodes_stats"
     FROM Users limit 1000) as new_user) TO 'E:\users.json';


-- Export anime data from postgres to json
COPY(SELECT json_agg(row_to_json(anime)) from (SELECT a.anime_id as "_id",a.title as title, a.title_english as english_title,
                                                      a.title_japanese as japanese_title,a.title_synonyms as alternate_titles,
                                                      a.title_episodes as episodes, a.aired as date_aired,
                                                      a.aired_from_to as start_end_date, a.duration as duration,
                                                      a.is_airing as currently_airing, a.rank as rank,
                                                      a.popularity as popularity, a.members as members,
                                                      a.favourites as favourites, a.background as background_music,
                                                      a.premiered as premiered, a.broadcast as broadcase,
                                                      a.related_to as related_titles, a.opening_theme as opening_theme,
                                                      a.ending_theme as ending_theme, a.score as score, a.num_votes as num_votes,
                                                      a.related_as as related_as, string_agg(DISTINCT g.genre, ',') as genre,
       string_agg(DISTINCT s.studio , ',') as studio,
       string_agg(DISTINCT l.licensor, ',') as licensor,
       string_agg(DISTINCT p.producer, ',') as producer,
       string_agg(DISTINCT CAST(w.user_id as text), ',') as users
    from anime a
    inner join has_genre hg on a.anime_id = hg.anime_id
    inner join genre g on hg.genre_id = g.genre_id
    left join created_by cb on a.anime_id = cb.anime_id
    left join studio s on cb.studio_id = s.studio_id
    left join licensed_by lb on a.anime_id = lb.anime_id
    left join licensor l on lb.licensor_id = l.licensor_id
    left join produced_by pb on a.anime_id = pb.anime_id
    left join producer p on pb.producer_id = p.producer_id
    left join watches w on a.anime_id = w.anime_id
group by a.anime_id order by a.anime_id) as anime) TO 'E:\animes.json';