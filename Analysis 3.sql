-- 4. In-depth Bowling Analysis
-- Which bowlers have bowled the most maiden overs?
SELECT bowlername
	,sum(maiden) AS no_of_maidens
FROM bowling_summary
GROUP BY bowlerName
ORDER BY no_of_maidens DESC;

-- How many extras (wides and no-balls) has each team conceded?
SELECT bowlingteam
	,sum(wides) AS no_of_wides
	,sum(noballs) AS no_of_noballs
	,sum(wides) + sum(noballs) AS total_extras
FROM bowling_summary
GROUP BY bowlingteam
ORDER BY total_extras DESC;

-- Who are the most economical and expensive bowlers on different grounds?
WITH details
AS (
	SELECT b.match_id
		,b.bowlername
		,b.economy
		,b.runs
		,m.ground
		,row_number() OVER (
			PARTITION BY m.ground ORDER BY b.economy ASC
			) AS most_economical
		,row_number() OVER (
			PARTITION BY m.ground ORDER BY b.runs DESC
			) AS expensive_bowler
	FROM bowling_summary b
	INNER JOIN match_summary m ON b.match_id = m.match_id
	)
SELECT ground
	,bowlername
	,economy AS 'economy/runs'
	,'Most Economical' AS category
FROM details
WHERE most_economical = 1

UNION ALL

SELECT ground
	,bowlername
	,runs
	,'Most Expensive' AS category
FROM details
WHERE expensive_bowler = 1
ORDER BY ground
	,category;

-- 5. In-depth Batting Analysis
-- Which players have hit the most 4s and 6s in the tournament?
SELECT batsmanname
	,sum(6s) AS no_of_6s
	,sum(4s) AS no_of_4s
	,sum(6s) + sum(4s) AS total_boundaries
FROM bating_summary
GROUP BY batsmanName
ORDER BY total_boundaries DESC;

-- What is the average batting position for players scoring more than 30 runs in an innings?
SELECT batsmanname
	,ROUND(AVG(battingpos), 2) AS avg_batting_position
FROM bating_summary
WHERE runs > 30
GROUP BY batsmanname;

-- How do players’ batting performances vary by batting position (opening, middle, death)?
WITH roles
AS (
	SELECT NAME
		,team
		,playingrole
	FROM players
	)
	,performance
AS (
	SELECT batsmanname
		,teaminnings
		,SUM(runs) AS total_runs
		,SUM(6s) AS total_6s
		,SUM(4s) AS total_4s
		,ROUND(AVG(sr), 2) AS avg_strikerate
		,CASE 
			WHEN battingpos BETWEEN 1
					AND 2
				THEN 'Opener'
			WHEN battingpos BETWEEN 3
					AND 6
				THEN 'Middle Order'
			ELSE 'Lower Order'
			END AS batting_position -- Include the batting position in the performance
	FROM bating_summary
	GROUP BY batsmanname
		,teaminnings
		,batting_position
	)
SELECT r.NAME
	,r.team
	,r.playingrole
	,p.total_runs
	,p.total_6s
	,p.total_4s
	,p.avg_strikerate
	,p.batting_position -- Select the batting position
FROM roles r
LEFT JOIN performance p ON r.NAME = p.batsmanname
	AND r.team = p.teaminnings
ORDER BY p.total_runs DESC;

-- What is the average score per batting position across teams?
SELECT teaminnings
	,round(avg(runs), 2) AS total_runs
	,CASE 
		WHEN battingpos BETWEEN 1
				AND 2
			THEN 'opener'
		WHEN battingpos BETWEEN 3
				AND 6
			THEN 'middle order'
		ELSE 'lower order'
		END AS batting_position
FROM bating_summary
GROUP BY teaminnings
	,batting_position
ORDER BY teaminnings;

-- 6. Summary Statistics
-- What is the overall team batting and bowling performance summary in terms of average runs scored and conceded?
WITH batting_sum
AS (
	SELECT teaminnings AS team
		,round(avg(total_runs), 2) AS avg_runs
	FROM (
		SELECT match_id
			,teaminnings
			,sum(runs) AS total_runs
		FROM bating_summary
		GROUP BY match_id
			,teamInnings
		) AS avg_bat
	GROUP BY teaminnings
	)
	,bowling_sum
AS (
	SELECT bowlingteam AS team
		,avg(runs_conceded) AS avg_runs_conceded
		,sum(total_wickets) AS total_wickets
	FROM (
		SELECT match_id
			,bowlingteam
			,sum(runs) AS runs_conceded
			,sum(wickets) AS total_wickets
		FROM bowling_summary
		GROUP BY match_id
			,bowlingTeam
		) AS avg_bowl
	GROUP BY bowlingteam
	)
SELECT ba.team
	,ba.avg_runs
	,bo.avg_runs_conceded
	,bo.total_wickets
FROM batting_sum ba
INNER JOIN bowling_sum bo ON ba.team = bo.team
ORDER BY ba.team;

-- What is the distribution of match results by venue?
SELECT ground
	,winner
	,COUNT(*) AS match_count
FROM match_summary
GROUP BY ground
	,winner
ORDER BY ground
	,match_count DESC;

-- What is the average number of boundaries per innings?
SELECT round(avg(total_boundaries), 2) AS boundaries_per_innings
FROM (
	SELECT match_id
		,sum(6s) AS no_6
		,sum(4s) AS no_4
		,sum(6s) + sum(4s) AS total_boundaries
	FROM bating_summary
	GROUP BY match_id
	) AS details;

-- Which players have the most not out scores in the tournament?
SELECT batsmanname
	,count(*) AS no_of_notout
FROM bating_summary
WHERE STATUS = 'not_out'
GROUP BY batsmanName
ORDER BY no_of_notout DESC;
