CREATE DATABASE T20_WORLDCUP;

USE T20_WORLDCUP;

-- Data Wranggling
ALTER TABLE bating_summary CHANGE COLUMN `out / not_out` STATUS TEXT;

ALTER TABLE match_summary ADD INDEX (match_id(15));

ALTER TABLE bowling_summary ADD INDEX (match_id(15));

ALTER TABLE bating_summary ADD INDEX (match_id(15));

-- 1. Player Performance Analysis
-- What is the highest score achieved by each batsman in the tournament?
SELECT *
FROM PLAYERS;

SELECT *
FROM bating_summary;

SELECT p.NAME
	,p.team
	,count(b.match_id) AS no_of_matches
	,max(b.runs) AS Highest_score
FROM players p
LEFT JOIN bating_summary b ON p.NAME = b.batsmanname
	AND p.team = b.teaminnings
GROUP BY p.NAME
	,p.team
ORDER BY Highest_score DESC;

-- Who are the top run-scorers in the tournament?
SELECT p.NAME
	,p.team
	,count(b.match_id) AS no_of_matches
	,sum(b.runs) AS run_scored
FROM players p
LEFT JOIN bating_summary b ON p.NAME = b.batsmanname
	AND p.team = b.teaminnings
GROUP BY p.NAME
	,p.team
ORDER BY run_scored DESC;

-- Which bowlers have taken the most wickets, and what are their average and economy rates?
SELECT bowlername
	,bowlingteam
	,sum(wickets) AS total_wickets
	,round(avg(economy), 2) AS avg_economy
	,ROUND(SUM(runs) / NULLIF(SUM(wickets), 0), 2) AS Bowling_avg
FROM bowling_summary
GROUP BY bowlername
	,bowlingteam
ORDER BY total_wickets DESC;

-- Who are the top all-rounders (based on both batting and bowling contributions) in the tournament?
WITH allrounders
AS (
	SELECT NAME
		,team
		,playingrole
	FROM players
	WHERE playingrole = 'allrounder'
	)
	,batting_score
AS (
	SELECT batsmanname
		,teaminnings
		,sum(runs) AS runs_scored
	FROM bating_summary
	GROUP BY batsmanname
		,teaminnings
	)
	,bowling_stat
AS (
	SELECT bowlername
		,bowlingteam
		,sum(wickets) AS total_wickets
	FROM bowling_summary
	GROUP BY bowlername
		,bowlingteam
	)
SELECT p.NAME
	,p.team
	,b.runs_scored
	,bo.total_wickets
FROM allrounders p
INNER JOIN batting_score b ON p.NAME = b.batsmanname
	AND p.team = b.teaminnings
INNER JOIN bowling_stat bo ON p.NAME = bo.bowlername
	AND p.team = bo.bowlingteam
ORDER BY runs_scored DESC
	,total_wickets DESC;

-- Which batsmen have the highest strike rate?
WITH batsmans
AS (
	SELECT NAME
		,team
		,playingrole
	FROM players
	WHERE playingrole IN (
			'Top order Batter'
			,'Middle order Batter'
			,'Wicketkeeper Batter'
			,'Batting Allrounder'
			,'Batter'
			,'Opening Batter'
			)
	)
	,strike_rate
AS (
	SELECT batsmanname
		,teaminnings
		,max(sr) AS max_strike_rate
	FROM bating_summary
	GROUP BY batsmanname
		,teaminnings
	)
SELECT b.NAME
	,b.team
	,s.max_strike_rate
FROM batsmans b
INNER JOIN strike_rate s ON b.NAME = s.batsmanname
	AND b.team = s.teaminnings
ORDER BY max_strike_rate DESC;

-- 2. Match Analysis
-- What is the win margin distribution for matches won by each team?
SELECT *
FROM match_summary;

-- Which grounds have the highest win rate for teams batting first vs. chasing?
WITH win_type
AS (
	SELECT CASE 
			WHEN team1 = winner
				THEN 'first batting'
			WHEN team2 = winner
				THEN 'chaser'
			ELSE 'no result'
			END AS situation
		,ground
		,count(winner) AS no_of_wins
	FROM match_summary
	GROUP BY situation
		,ground
	ORDER BY ground
	)
	,total_match
AS (
	SELECT ground
		,count(*) AS total_matches
	FROM match_summary
	GROUP BY ground
	)
SELECT w.ground
	,w.situation
	,round(((w.no_of_wins / t.total_matches) * 100), 2) AS win_rate
FROM win_type w
INNER JOIN total_match t ON w.ground = t.ground
ORDER BY ground
	,win_rate DESC;

-- What are the average scores for bating position across different grounds?
WITH bating_pos
AS (
	SELECT match_id
		,battingpos
		,sum(runs) AS total_runs
	FROM bating_summary
	GROUP BY match_id
		,battingpos
	)
	,ground
AS (
	SELECT match_id
		,ground
	FROM match_summary
	)
SELECT g.ground
	,b.battingpos
	,round(avg(total_runs), 2) AS total_runs
FROM bating_pos b
INNER JOIN ground g ON g.match_id = b.match_id
GROUP BY g.ground
	,b.battingpos;

-- Who were the standout performers in each match (highest runs, wickets, etc.)?
WITH bating_performace
AS (
	SELECT match_id
		,bating_summary.match
		,batsmanname
		,sum(runs) AS runs_scored
		,row_number() OVER (
			PARTITION BY match_id ORDER BY sum(runs) DESC
			) AS ranks
	FROM bating_summary
	GROUP BY match_id
		,batsmanname
		,bating_summary.match
	)
	,bowling_performace
AS (
	SELECT match_id
		,bowlername
		,sum(wickets) AS total_wickets
		,sum(runs) AS runs_conceded
		,row_number() OVER (
			PARTITION BY match_id ORDER BY sum(wickets) DESC
			) AS ranks
	FROM bowling_summary
	GROUP BY match_id
		,bowlername
	)
SELECT b.match_id
	,b.match
	,b.batsmanname
	,b.runs_scored
	,bo.bowlername
	,bo.total_wickets
FROM bating_performace b
INNER JOIN bowling_performace bo ON b.match_id = bo.match_id
WHERE b.ranks = 1
	AND bo.ranks = 1
ORDER BY b.match_id;

-- Which matches had the closest finishes in terms of runs or wickets?
SELECT *
FROM match_summary;

WITH closest_finish
AS (
	SELECT match_id
		,team1
		,team2
		,winner
		,margin
		,ground
		,matchdate
		,CASE 
			WHEN margin LIKE '%wicket%'
				THEN CAST(SUBSTRING_INDEX(margin, ' ', 1) AS UNSIGNED)
			WHEN margin LIKE '%run%'
				THEN cast(substring_index(margin, ' ', 1) AS unsigned)
			ELSE NULL
			END AS margin_value
		,CASE 
			WHEN margin LIKE '%wicket%'
				THEN 'Wickets'
			WHEN margin LIKE '%run%'
				THEN 'Runs'
			END AS margin_type
	FROM match_summary
	)
SELECT match_id
	,matchdate
	,team1
	,team2
	,winner
	,margin_value
	,margin_type
FROM closest_finish
WHERE margin_type = 'runs'
	AND margin_value = (
		SELECT min(margin_value)
		FROM closest_finish
		WHERE margin_type = 'runs'
		)
	OR margin_type = 'wickets'
	AND margin_value = (
		SELECT min(margin_value)
		FROM closest_finish
		WHERE margin_type = 'wickets'
		);
