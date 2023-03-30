/*
    CSCI-620: INTRO TO BIG DATA
    PROJECT PHASE 2
    FILENAME: interestingQueries.sql
    AUTHORS:    ATHINA STEWART  as1986
                ARCHIT JOSHI    aj6082
                PARIJAT KAWALE  pk7145
                CHENGZI CAO     cc3773

    This file adds indexes to the relational tables.
*/

create index score_index on anime(score);
create index popularity_index on anime(popularity);
create index location_index on users(user_location);
create index aired_from_to_index on anime(aired_from_to);