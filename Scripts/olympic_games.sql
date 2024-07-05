-- Analyzing Olympics Data with SQL 

-- Query 1: Total Olympic Games Held 

SELECT 
	COUNT(DISTINCT games) AS total_olympic_games 
	FROM olympics_history;

-- Query 2: List All Olympic Games 

SELECT
	DISTINCT season,
	year,
	city
	FROM olympics_history
	GROUP BY (year, season, city)
	ORDER BY year;

-- Query 3: Total Nations Participated per Game

	SELECT 
	COUNT(DISTINCT t2.region) AS num_regions,
	t1.games
	FROM olympics_history t1
	JOIN olympics_history_noc_regions t2
	ON
	t1.noc = t2.noc
	GROUP BY games;

-- Query 4: Years with Highest and Lowest Participation

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

-- Query 5: Countries Participating in Every Olympic Games

WITH cte1 AS (
    SELECT DISTINCT t1.games, t2.region
    FROM olympics_history t1
    JOIN olympics_history_noc_regions t2 ON t1.noc = t2.noc
)
SELECT region
FROM cte1
WHERE games IN (
    SELECT DISTINCT games FROM olympics_history
);

-- Query 6: Sports Played in All Summer Olympics

WITH t1 AS(
	SELECT 
	COUNT(DISTINCT games) AS total_summer_games
	FROM olympics_history
	WHERE season = 'Summer'
),
t2 AS(
	SELECT sport,
	COUNT(DISTINCT games) AS games_played
	FROM olympics_history
	GROUP BY sport
)
SELECT sport, t2.games_played,
	t1.total_summer_games
FROM t2 INNER JOIN t1
ON t2.games_played = t1.total_summer_games;

-- Query 7: Sports Played Only Once in the Olympics

WITH t1 AS(
	SELECT sport,
	COUNT(DISTINCT games) AS games_played
	FROM olympics_history
	GROUP BY sport
),
t2 AS(
	SELECT DISTINCT sport,
	games AS games_playedin
	FROM olympics_history
	GROUP BY sport, games_playedin
)
SELECT t1.sport, t1.games_played,
	t2.games_playedin
	FROM t1 JOIN t2 
	ON t1.sport = t2.sport
	WHERE t1.games_played = '1';

-- Query 8: Total Sports Played in Each Olympic Game

WITH t1 AS(SELECT
	DISTINCT games,sport 
	FROM olympics_history
	ORDER BY games
)
	SELECT COUNT(sport) AS num_sports_played,
	games
	FROM t1 
	GROUP BY games
	ORDER BY num_sports_played DESC;

-- Query 9: Oldest Athletes to Win Gold Medals

SELECT * 
	FROM olympics_history
	WHERE medal = 'Gold'
	AND age != 'NA'
	ORDER BY CAST(age AS int) 
	DESC LIMIT 10;


-- Query 10: Ratio of Male to Female Athletes Participated

/*Problem Statement: Write a SQL query to get the ratio 
of male and female participants
1. Filter out the table with only male participants and female participants
2. Then extract the count of rows, then perform a division to get the ratio */
	
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

-- Query 11: Top 5 Athletes with Most Gold Medals

WITH t1 AS(
	SELECT name,
	team,COUNT(1) AS no_of_medals
	FROM olympics_history
	WHERE medal = 'Gold'
	GROUP BY name, team
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

-- Query 12: Top 5 Athletes with Most Medals (Gold/Silver/Bronze)

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

-- Query 13: Top 5 Countries with Most Medals

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

-- Query 14: Total Medals (Gold/Silver/Bronze) by Country

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

-- Query 15: Medals (Gold/Silver/Bronze) by Country and Olympic Games

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


-- Query 16


-- Query 17


-- Query 18: Countries with Silver or Bronze Medals but No Gold Medals

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

-- Query 19: In which Sport/event, India has won the highest number of medals.t

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

-- Query 20: Break down all Olympic games where India won medals for Hockey and how many medals in each Olympic game.

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

