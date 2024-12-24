# T20 Cricket World Cup Analytics

## Overview
This project analyzes the data from the T20 Cricket World Cup using SQL queries. The goal is to extract meaningful insights from various aspects of the matches, including team performances, player statistics, and match results by venue. The dataset used contains detailed information on players, matches, batting, and bowling performances.

## Dataset Description

### Tables

1. **Players Table**
   - `name`: text
   - `team`: text
   - `image`: text
   - `battingStyle`: text
   - `bowlingStyle`: text
   - `playingRole`: text
   - `description`: text

2. **Match Summary Table**
   - `team1`: text
   - `team2`: text
   - `winner`: text
   - `margin`: text
   - `ground`: text
   - `matchDate`: text
   - `match_id`: text

3. **Bowling Summary Table**
   - `match`: text
   - `bowlingTeam`: text
   - `bowlerName`: text
   - `overs`: int
   - `maiden`: int
   - `runs`: int
   - `wickets`: int
   - `economy`: double
   - `0s`: int
   - `4s`: int
   - `6s`: int
   - `wides`: int
   - `noBalls`: int
   - `match_id`: text

4. **Batting Summary Table**
   - `match`: text
   - `teamInnings`: text
   - `battingPos`: int
   - `batsmanName`: text
   - `runs`: int
   - `balls`: int
   - `4s`: int
   - `6s`: int
   - `SR`: int
   - `out/not_out`: text
   - `match_id`: text

With these tables, we can dive into multiple layers of cricket analytics, from individual player performance to team-level analysis. Here’s a set of popular cricket analytics questions that we could answer using these tables:

### 1. Player Performance Analysis
   - **What is the highest score achieved by each batsman in the tournament?**
   - **Who are the top run-scorers in the tournament?**
   - **Which bowlers have taken the most wickets, and what are their average and economy rates?**
   - **Who are the top all-rounders (based on both batting and bowling contributions) in the tournament?**
   - **Which batsmen have the highest strike rate?**

### 2. Match Analysis
   - **What is the win margin distribution for matches won by each team?**
   - **Which grounds have the highest win rate for teams batting first vs. chasing?**
   - **What are the average scores in the first and second innings across different grounds?**
   - **Who were the standout performers in each match (highest runs, wickets, etc.)?**
   - **Which matches had the closest finishes in terms of runs or wickets?**

### 3. Team Performance Analysis
   - **Which team has the highest win percentage?**
   - **How do teams perform when batting first compared to chasing?**
   - **What is the average score by each team, and how does it vary based on innings (first or second)?**
   - **Which team has hit the most boundaries (4s and 6s) in the tournament?**
   - **Which team’s bowlers have the best economy rates on average?**

### 4. In-depth Bowling Analysis
   - **Which bowlers have bowled the most maiden overs?**
   - **How many extras (wides and no-balls) has each team conceded?**
   - **Who are the most economical and expensive bowlers on different grounds?**

### 5. In-depth Batting Analysis
   - **Which players have hit the most 4s and 6s in the tournament?**
   - **What is the average batting position for players scoring more than 50 runs in an innings?**
   - **How do players’ performances vary by batting position (opening, middle, death)?**
   - **What is the average score per batting position across teams?**

### 6. Summary Statistics
   - **What is the overall team batting and bowling performance summary in terms of average runs scored and conceded?**
   - **What is the distribution of match results by venue?**
   - **What is the average number of boundaries per innings?**
   - **Which players have the most *not out* scores in the tournament?**

These questions cover a broad range of analyses that would make this project comprehensive.
