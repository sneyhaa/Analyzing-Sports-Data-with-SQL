select Count(*) from OLYMPICS_HISTORY;
select * from OLYMPICS_HISTORY LIMIT 5;
--277116 rows

select * from OLYMPICS_HISTORY_NOC_REGIONS LIMIT 5;
select Count(*) from OLYMPICS_HISTORY_NOC_REGIONS;

-- 230 rows

/* Q1. How many olympics games have been held?
Problem Statement: Write a SQL query to find the total no of Olympic Games
held as per the dataset.*/

SELECT 
	COUNT(DISTINCT games) AS total_olympic_games 
	FROM olympics_history;
	

/* Q2. List down all Olympics games held so far.*/

SELECT
	DISTINCT season,
	year,
	city
	FROM olympics_history
	GROUP BY (year, season, city)
	ORDER BY year;
	
/* Q3. Mention the total no of nations who participated in each olympics game? */
-- total no of countries 
-- each game
	
WITH nations AS (SELECT 
	t1.games,
	t2.region
	FROM olympics_history t1
	JOIN olympics_history_noc_regions t2
	ON
	t1.noc = t2.noc
	)
	
	SELECT
	games,
	COUNT(DISTINCT region) AS countries
	FROM nations
	GROUP BY games
	ORDER BY games;

or
	SELECT 
	COUNT(DISTINCT t2.region) AS num_regions,
	t1.games
	FROM olympics_history t1
	JOIN olympics_history_noc_regions t2
	ON
	t1.noc = t2.noc
	GROUP BY games;



/* Q4. Which year saw the highest and lowest 
no of countries participating in olympics?*

-- to return the Olympic Games which had the highest participating countries
and the lowest participating countries.*/

WITH cte1 AS(
	SELECT 
	COUNT(DISTINCT t2.region) AS num_regions,
	t1.games
	FROM olympics_history t1
	JOIN olympics_history_noc_regions t2
	ON
	t1.noc = t2.noc
	GROUP BY t1.games
)  
SELECT 
	MAX(CASE WHEN cte1.num_regions = max_num_regions THEN CONCAT(cte1.games, ' - ', max_num_regions) END) AS games_with_highest_regions,
	MIN(CASE WHEN cte1.num_regions = min_num_regions THEN CONCAT(cte1.games, ' - ', mIN_num_regions) END) AS games_with_lowest_regions
	FROM cte1
	CROSS JOIN
	(SELECT 
	MAX(num_regions) AS max_num_regions,
	MIN(num_regions) AS min_num_regions
	FROM cte1);

--Q5 to return the list of countries who have been part of every Olympics games. 	
-- so to find that out we must return that country
-- which is present in every game


WITH cte1 AS(
	SELECT
	DISTINCT(t1.games),
	t2.region 
	FROM olympics_history_noc_regions t2 
	INNER JOIN 
	olympics_history t1
	ON
	t2.noc = t1.noc
	GROUP BY t1.games,region
	ORDER BY games
) 

SELECT region 
FROM
cte1 
WHERE games in (
          SELECT 
            DISTINCT games 
           FROM olympics_history );


/*Q6. Identify the sport which was played in 
all summer olympics.
1. we extract count of ALL summer olympics
2. then we find the count for each game
3. then we extract the sport which matches both
*/


WITH t1 AS(
	SELECT 
	COUNT(DISTINCT games) AS total_summer_games
	FROM olympics_history
	WHERE season = 'Summer'
),
	
t2 AS(
	SELECT 
	sport,
	COUNT(DISTINCT games) AS games_played
	FROM olympics_history
	GROUP BY sport
)

SELECT sport,
	t2.games_played,
	t1.total_summer_games
FROM t2 
	INNER JOIN t1
ON t2.games_played = t1.total_summer_games;
	
/* 7. Which Sports were just played only once in the olympics.

Problem Statement: Using SQL query, 
Identify the sport which were just played once in all of olympics.
1. Find a count of the number of times a sport was played.
2. Find the year in which that game was played once!

*/

WITH t1 AS(
	SELECT 
	sport,
	COUNT(DISTINCT games) AS games_played
	FROM olympics_history
	GROUP BY sport
),
t2 AS(
	SELECT 
	DISTINCT sport,
	games AS games_playedin
	FROM olympics_history
	GROUP BY sport, games_playedin
)

SELECT t1.sport,
	t1.games_played,
	t2.games_playedin
	FROM t1 
	JOIN t2 
	ON t1.sport = t2.sport
	WHERE t1.games_played = '1';


/* Q8. Fetch the total no of sports played in each olympic games.

Problem Statement: 
Write SQL query to fetch the total no of sports played in each olympics.
1. Filter the data by each olympic game.

*/

WITH t1 AS(SELECT
	DISTINCT games,
	sport 
	FROM olympics_history
	ORDER BY games
)
	SELECT COUNT(sport) AS num_sports_played,
	games
	FROM t1 
	GROUP BY games
	ORDER BY num_sports_played DESC;

	
/* Q9. Fetch oldest athletes to win a gold medal

Problem Statement: SQL Query to fetch the details of the oldest athletes 
to win a gold medal at the olympics. 
1. Filter data by athletes who have won Gold Medals
2. Then further filter it by the athletes age - PS some athletes
	have age = 'NA'
*/


	SELECT * 
	FROM olympics_history
	WHERE medal = 'Gold'
	AND age != 'NA'
	ORDER BY CAST(age AS int) 
	DESC LIMIT 10;

/*Q10. Find the Ratio of male and female athletes participated 
in all olympic games.

Problem Statement: Write a SQL query to get the ratio 
of male and female participants
1. Filter out the table with only male participants and female participants
2. Then extract the count of rows, then perform a division to get the ratio
*/
	
WITH t1 AS (
    SELECT
        COUNT(DISTINCT CASE WHEN sex = 'M' THEN ID END) AS male_participants, -- 196594
        COUNT(DISTINCT CASE WHEN sex = 'F' THEN ID END) AS female_participants -- 74522
    FROM olympics_history
)
SELECT 
    male_participants,
    female_participants,
    concat('1:',round(male_participants/female_participants,2)) AS male_to_female_ratio
FROM t1;


/* 
11. Fetch the top 5 athletes who have won the most gold medals.

Problem Statement: SQL query to fetch the top 5 athletes 
who have won the most gold medals.
1. We need to first extract all those players who have won Gold
2. Then we will filter them out by rank!
*/

WITH t1 AS(
	SELECT name,
	team,
	COUNT(1) AS no_of_medals
	FROM olympics_history
	WHERE medal = 'Gold'
	GROUP BY name,team
	ORDER BY COUNT(1) DESC

),
t2 AS 
( 
	SELECT *,
	DENSE_RANK()OVER(ORDER BY no_of_medals DESC) AS rnk
	FROM t1
)
SELECT *
	FROM t2 
	WHERE rnk <= 5;
	
/* 
Q12. Fetch the top 5 athletes who have won the most medals.
(gold/silver/bronze).

Problem Statement: SQL Query to fetch the top 5 athletes 
who have won the most medals (Medals include gold, silver and bronze).

1. Find out the number of medals won by each athlete
	for this we will not use distinct but group by name instead!
2. Then we will just rank the columns by nummedals!
*/

WITH t1 AS(
	SELECT name,
	COUNT(1) AS nummedals
	FROM olympics_history
	WHERE medal != 'NA'
	GROUP BY name
	ORDER BY nummedals DESC
),
t2 AS(
	SELECT *,
	DENSE_RANK()OVER(ORDER BY nummedals DESC) AS rnk
	FROM t1
)
SELECT * 
	FROM t2
	WHERE rnk <= 5;


/* Q13. Fetch the top 5 most successful countries in olympics. 
Success is defined by no of medals won.

Problem Statement: Write a SQL query to fetch the top 5 most successful 
countries in olympics. (Success is defined by no of medals won).

1. Find the number of medals won fileterd/grouped by country.
-- now notice that we have to check if the noc matches with that of the regions
table first, so basically filter out by country!
2. After that we rank it using the window functions RANK()*/

WITH cteregion AS(
	SELECT t1.region, t2.medal
	FROM olympics_history_noc_regions t1
	JOIN olympics_history t2
	ON t1.noc = t2.noc
)
	SELECT region,
	COUNT(1) AS nummedals,
	RANK()OVER(ORDER BY COUNT(1) DESC)
	FROM cteregion
	WHERE medal != 'NA'
	GROUP BY region
	ORDER BY nummedals DESC
	LIMIT 5;

/*Q14.List down total gold, silver and bronze medals won by each country.

Problem Statement: Write a SQL query to list down the
total gold, silver and bronze medals won by each country.
Steps
1. First we need to filter out all the participating regions by joining
the two tables
2. Then we will get a count of medals using separate conditions for each 
category of medal
*/


WITH cteregion AS(
	SELECT t1.region, t2.medal
	FROM olympics_history_noc_regions t1
	JOIN olympics_history t2
	ON t1.noc = t2.noc
)
SELECT 
	region,
	COUNT(CASE WHEN medal = 'Gold' THEN 1 END) AS gold_count,
	COUNT(CASE WHEN medal = 'Silver' THEN 1 END) AS silver_count,
	COUNT(CASE WHEN medal = 'Bronze' THEN 1 END) AS bronze_count
	FROM cteregion
	WHERE medal != 'NA'
	GROUP BY region
	ORDER BY gold_count DESC;


/* 15. List down total gold, silver and bronze medals won 
by each country corresponding to each olympic games.

Problem Statement: Write a SQL query to list down the  total gold, 
silver and bronze medals won by each country corresponding to each 
olympic games.

1. Combine the two tables to get all the participating regions
2. Get a count of each category of medal won
3. but this time we will also need to filter it by each olympic game 
in addition to the country.
*/

WITH cte1 AS(
	SELECT t1.region, t2.medal,
	t2.games
	FROM olympics_history_noc_regions t1
	JOIN olympics_history t2
	ON t1.noc = t2.noc
)
SELECT 
	games,
	region,
	COUNT(CASE WHEN medal = 'Gold' THEN 1 END) AS gold_count,
	COUNT(CASE WHEN medal = 'Silver' THEN 1 END) AS silver_count,
	COUNT(CASE WHEN medal = 'Bronze' THEN 1 END) AS bronze_count
	FROM cte1
	WHERE medal != 'NA'
	GROUP BY games, region
	ORDER BY games, region;

/*Q16. Identify which country won the most gold, most silver 
and most bronze medals in each olympic games.

Problem Statement: Write SQL query to display for 
each Olympic Games, which country won the highest gold, silver and 
bronze medals.
1. First find out a list of gold, silver, bronze medals
won by country, per olympic game
2. 
*/


WITH cte1 AS(
	SELECT t1.region,
	t2.games,
	COUNT(CASE WHEN medal = 'Gold' THEN 1 END) AS gold_count,
	COUNT(CASE WHEN medal = 'Silver' THEN 1 END) AS silver_count,
	COUNT(CASE WHEN medal = 'Bronze' THEN 1 END) AS bronze_count
	FROM olympics_history_noc_regions t1
	JOIN olympics_history t2
	ON t1.noc = t2.noc
	WHERE medal != 'NA'
	GROUP BY games, region
	ORDER BY games
)
	SELECT games,
	MAX(gold_count),
	MAX(silver_count),
	MAX(bronze_count)
	FROM cte1
	GROUP BY games
)
-- I'll look at 16 again!

WITH cte1 AS (
    SELECT 
        t1.region,
        t2.games,
        COUNT(CASE WHEN medal = 'Gold' THEN 1 END) AS gold_count,
        COUNT(CASE WHEN medal = 'Silver' THEN 1 END) AS silver_count,
        COUNT(CASE WHEN medal = 'Bronze' THEN 1 END) AS bronze_count
    FROM 
        olympics_history_noc_regions t1
    JOIN 
        olympics_history t2 ON t1.noc = t2.noc
    WHERE 
        medal != 'NA'
    GROUP BY 
        games, region
)
, ranked_cte AS (
    SELECT
        region,
        games,
        gold_count,
        silver_count,
        bronze_count,
        RANK() OVER (PARTITION BY games ORDER BY gold_count DESC) AS gold_rank,
        RANK() OVER (PARTITION BY games ORDER BY silver_count DESC) AS silver_rank,
        RANK() OVER (PARTITION BY games ORDER BY bronze_count DESC) AS bronze_rank
    FROM
        cte1
)
SELECT
    games,
    MAX(CASE WHEN gold_rank = 1 THEN gold_count END) AS max_gold_count,
    MAX(CASE WHEN gold_rank = 1 THEN region END) AS max_gold_region,
    MAX(CASE WHEN silver_rank = 1 THEN silver_count END) AS max_silver_count,
    MAX(CASE WHEN silver_rank = 1 THEN region END) AS max_silver_region,
    MAX(CASE WHEN bronze_rank = 1 THEN bronze_count END) AS max_bronze_count,
    MAX(CASE WHEN bronze_rank = 1 THEN region END) AS max_bronze_region
FROM
    ranked_cte
GROUP BY
    games
ORDER BY
    games;

/* Q17. Related to Q16
I'll come back to it!*/


/* Q18. Which countries have never won gold medal 
but have won silver/bronze medals?

Problem Statement: Write a SQL Query to fetch 
details of countries which have won silver or 
bronze medal but never won a gold medal. 

-- so condition for this will be - medal = bronze or silver
but not NA or gold

*/

WITH cte1 AS(
	SELECT t1.region, t2.medal
	FROM olympics_history_noc_regions t1
	JOIN olympics_history t2
	ON t1.noc = t2.noc
	WHERE t2.medal != 'NA' 
) 
,cte2 AS(
SELECT 
	region,
	COUNT(CASE WHEN medal = 'Gold' THEN 1 END) AS gold_count,
    COUNT(CASE WHEN medal = 'Silver' THEN 1 END) AS silver_count,
	COUNT(CASE WHEN medal = 'Bronze' THEN 1 END) AS bronze_count
	FROM cte1
	GROUP BY region
	ORDER BY region
)
SELECT * FROM cte2
	WHERE gold_count = 0
	AND (silver_count > 0 OR bronze_count > 0)
	ORDER BY silver_count DESC;

/* Q19. In which Sport/event, India has won highest medals.
1. Filter the medals won by a specific country wrt a sport i.e. in this case USA 
*/

WITH cte1 AS (
    SELECT t1.region, t2.medal, t2.sport
    FROM olympics_history_noc_regions t1
    JOIN olympics_history t2 ON t1.noc = t2.noc
    WHERE t2.medal != 'NA' AND region = 'India'
), 
cte2 AS (
    SELECT sport,
	COUNT(medal) AS medals_won
    FROM cte1
    GROUP BY sport
)
SELECT sport, medals_won
FROM cte2
WHERE medals_won =(SELECT MAX(medals_won) FROM cte2);


/* 20. Break down all olympic games where 
India won medal for Hockey and how many medals in each olympic games. */

WITH cte1 AS (
    SELECT t1.region, 
	t2.medal, t2.sport, t2.games
    FROM olympics_history_noc_regions t1
    JOIN olympics_history t2 ON t1.noc = t2.noc
    WHERE t2.medal != 'NA' AND region = 'India'
	AND sport = 'Hockey'
)
    SELECT sport, 
	games,
	COUNT(medal) AS medals_won
    FROM cte1
    GROUP BY sport, games
	ORDER BY medals_won DESC;

