use football_sql ;

-- te nhat 
SELECT SQL_NO_CACHE * FROM matches 
WHERE YEAR(match_date) = 2023;


-- tot nhat 
SELECT SQL_NO_CACHE * FROM matches 
WHERE match_id = 150;