-- Team Performance Analysis
-- Which team has the highest win percentage?
WITH total_match
AS (
	SELECT teaminnings
		,count(DISTINCT match_id) AS total_matches
	FROM bating_summary
	GROUP BY teaminnings
	)
	,total_wins
AS (
	SELECT winner
		,count(match_id) AS total_wins
	FROM match_summary
	GROUP BY winner
	)
SELECT m.teaminnings
	,m.total_matches
	,coalesce(w.total_wins, 0) AS total_wins
	,round(((coalesce(w.total_wins, 0) / m.total_matches) * 100), 2) AS win_percentage
FROM total_match m
LEFT JOIN total_wins w ON m.teaminnings = w.winner
ORDER BY win_percentage DESC;

-- How do teams perform when batting first compared to chasing?
SELECT winner
	,winner_innings
	,count(winner_innings) AS no_of_wins
FROM (
	SELECT match_id
		,team1
		,team2
		,winner
		,CASE 
			WHEN margin LIKE '%run%'
				THEN 'batted first'
			WHEN margin LIKE '%wicket%'
				THEN 'chased'
			ELSE 'no result'
			END AS winner_innings
	FROM match_summary
	) AS team_stats
WHERE winner_innings IS NOT NULL
GROUP BY winner
	,winner_innings
ORDER BY winner DESC;

-- What is the average score by each team, and how does it vary based on innings (first or second)?
SELECT r.teaminnings AS team
	,round(avg(r.total_runs), 2) AS avg_runs
	,CASE 
		WHEN m.margin LIKE '%run%'
			THEN 'batted first'
		WHEN m.margin LIKE '%wicket%'
			THEN 'chased'
		ELSE 'no result'
		END AS innings
FROM (
	SELECT match_id
		,b.match
		,teaminnings
		,round(sum(runs), 2) AS total_runs
	FROM bating_summary b
	GROUP BY match_id
		,b.match
		,teaminnings
	) AS r
INNER JOIN match_summary m ON r.match_id = m.match_id
GROUP BY team
	,innings
ORDER BY team;

-- Which team has hit the most boundaries (4s and 6s) in the tournament?
SELECT teaminnings
	,sum(6s) AS no_of_6s
	,sum(4s) AS no_of_4s
	,SUM(6s) + SUM(4s) AS total_boundaries
FROM bating_summary
GROUP BY teamInnings
ORDER BY total_boundaries DESC;

-- Which team’s bowlers have the best economy rates on average?
SELECT bowlingteam
	,round(avg(economy), 2) AS avg_economy
FROM bowling_summary
GROUP BY bowlingTeam
ORDER BY avg_economy ASC;
