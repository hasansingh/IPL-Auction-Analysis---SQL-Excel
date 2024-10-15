Create table ipl_ball (
	id int,
	inning int,
	over int,
	ball int,
	batsman varchar,
	non_striker varchar,
	bowler varchar,
	batsman_runs int,
	extra_runs int,
	total_runs int,
	is_wicket int,
	dismissal_kind varchar,
	player_dismissed varchar,
	feilder varchar,
	extras_type varchar,
	batting_team varchar,
	bowling_team varchar
);
select * from ipl_ball;
select * from ipl_matches;
SET datestyle TO "ISO,DMY";
copy ipl_ball from 'C:\Program Files\PostgreSQL\16\data\IPL Dataset\IPL_Ball.csv' delimiter ',' csv header;
copy ipl_matches from 'C:\Program Files\PostgreSQL\16\data\IPL Dataset\IPL_matches.csv' delimiter ',' csv header;
CREATE TABLE ipl_matches
(
    id int,
    city varchar,
     date date,
    player_of_match varchar(225),
    venue varchar(225),
    neutral_venue varchar(225),
    team1 varchar(225),
    team2 varchar(225),
    toss_winner varchar(225),
    toss_decision varchar(225),
    winner varchar(225),
    result varchar(225),
    result_margin int,
    eliminator varchar(225),
    method varchar(225),
    umpire1 varchar(225),
    umpire2 varchar(225)
); 
select * from ipl_matches;
select batsman (select ball, sum(ball) as total_balls from ipl_ball) frpm ipl_ball where total_balls > 500 group by batsman ;
--task 1 batsman strike rate
select batsman,sum(total_runs) as runs, count(ball) as balls,(sum(total_runs)*100/count(*)*1.0)as strike_rate
	 from ipl_ball where not (extras_type='wides')  
	group by batsman HAVING count(ball) >= 500 
	order by strike_rate desc limit 10;
--task 2 good average players
select batsman,count (distinct id)as matches,sum(total_runs) as runs,sum(is_wicket) as outs,
	(sum(total_runs)/sum(is_wicket)) as average
	from ipl_ball  group by batsman having count (distinct id) >=29 order by average desc limit 10 ;
--
select batsman,sum(b.total_runs) as runs,count(distinct extract(year from m.date)) as seasons_played,
count(b.is_wicket) as dismissal,(sum(b.total_runs)*1.0)/count(b.is_wicket) as average from ipl_ball b
join ipl_matches m on b.id=m.id where b.is_wicket is not null group by batsman 
having count(distinct extract(year from m.date)) > 2 and count(b.is_wicket) > 0 order by average desc limit 10;
 
--TASK 3
select batsman,count(distinct id) as matches,sum(batsman_runs) as total_runs,
sum(case when batsman_runs in (4,6) then batsman_runs  else 0 end) as runs_in_boundaries,
(sum(case when batsman_runs IN (4,6) then batsman_runs else 0 end)*100.0)/ sum(batsman_runs) as boundry_percentage
from ipl_ball Group by batsman having count (distinct id) >=29 order by runs_in_boundaries desc limit 10 ;

--TASK 4
select bowler,count(ball)/6 as overs,sum(total_runs) as runs_given,count(ball) as total_balls_bowled,
(sum(total_runs)/ (count(ball)/6.0)) as economy
from ipl_ball group by bowler 
having count(ball) >= 500
 order by economy limit 10 ;
--TASK 5 bowler strike rate
select bowler,sum(total_runs) as runs_given,
count(ball) as total_balls_bowled,sum(is_wicket) as total_wickets,
(count(ball)/sum(is_wicket)* 1.0) as strike_rate
from ipl_ball group by bowler 
having count(ball) >= 500
 order by total_wickets desc LIMIT 10;
/*Select bowler,sum(is_wicket) as total_wickets,count(*) * 100.0/ sum (case when is_wicket= 1 then 1 else 0 end) as bowling_strikerate,
count(*) as balls from ipl_ball group by bowler 
having count(ball) >= 500
 order by bowling_strikerate ;*/
--TASK 6
select a.all_rounder,runs,batting_strike_rate,total_wickets,bowling_strike_rate
from (select batsman as all_rounder,sum(total_runs) as runs, count(ball) as balls,(sum(total_runs)*100/count(*)*1.0)as batting_strike_rate
	 from ipl_ball where not (extras_type='wides')  
	group by batsman HAVING count(ball) >= 500 
	order by batting_strike_rate desc ) as a join (
	select bowler as all_rounder,sum(total_runs) as runs_given,
count(ball) as total_ball_bowled,sum(is_wicket) as total_wickets,
(count(ball)/sum(is_wicket)* 1.0) as bowling_strike_rate
from ipl_ball group by bowler 
having count(ball) >= 300
 order by total_wickets desc ) as b On a.all_rounder=b.all_rounder ORDER BY a.batting_strike_rate desc 
	limit 10;
	

