-- Question 1
-- (a)
/*
    Answer:
          +------------------------+
          | unkown_birthdate_count |
          +------------------------+
          |                    449 |
          +------------------------+
*/
SELECT count(*) AS unkown_birthdate_count
FROM Master
WHERE birthYear = 0
  OR birthMonth = 0
  OR birthDay = 0;


-- (b)
/*
    Answer:  
          +--------------+
          | Alive - Dead |
          +--------------+
          |          -47 |
          +--------------+
*/
SELECT
(
    (SELECT count(alive.playerID) FROM 
        (SELECT distinct (HallOfFame.playerID) FROM HallOfFame inner join Master on HallOfFame.playerID = Master.playerID where Master.deathYear = 0) 
    AS alive)
-
    (SELECT count(dead.playerID) FROM 
        (SELECT distinct (HallOfFame.playerID) FROM HallOfFame inner join Master on HallOfFame.playerID = Master.playerID where Master.deathYear > 0) 
    AS dead)
)
AS 'Alive - Dead';


-- (c)
/*
    Answer:  
          +-----------+-----------+--------------+
          | nameFirst | nameLast  | total_salary |
          +-----------+-----------+--------------+
          | Alex      | Rodriguez |    398416252 |
          +-----------+-----------+--------------+
*/
SELECT nameFirst,
       nameLast,
       temp.total_salary
FROM Master
INNER JOIN
  (SELECT playerID,
          sum(salary) AS total_salary
   FROM Salaries
   GROUP BY playerID) AS temp ON Master.playerID = temp.playerID
ORDER BY temp.total_salary DESC
LIMIT 1;


-- (d)
/*
    Answer:
          +---------+
          | avg_HR  |
          +---------+
          | 15.2938 |
          +---------+
*/
SELECT avg(total) AS avg_HR
FROM
  (SELECT sum(HR) AS total
   FROM Batting
   GROUP BY playerID) AS temp;


-- (e)
/*
    Answer:
          +---------+
          | avg_HR  |
          +---------+
          | 37.3944 |
          +---------+
*/
SELECT avg(total) AS avg_HR
FROM
  (SELECT sum(HR) AS total
   FROM Batting
   GROUP BY playerID
   HAVING total >= 1) AS temp;


-- (f)
/*
    Answer:
          +-------------------+
          | good_player_count |
          +-------------------+
          |                39 |
          +-------------------+
*/
SELECT count(*) AS good_player_count
FROM
  (SELECT playerID,
          sum(HR) AS total
   FROM Batting
   GROUP BY playerID
   HAVING total >
     (SELECT avg(total)
      FROM
        (SELECT sum(HR) AS total
         FROM Batting
         GROUP BY playerID) AS temp)) AS good_batter
INNER JOIN
  (SELECT playerID,
          sum(SHO) AS total
   FROM Pitching
   GROUP BY playerID
   HAVING total >
     (SELECT avg(total)
      FROM
        (SELECT sum(SHO) AS total
         FROM Pitching
         GROUP BY playerID) AS temp)) AS good_pitcher ON good_batter.playerID = good_pitcher.playerID;

-- Question 2
LOAD DATA LOCAL INFILE '/Users/zhidongzhang/Desktop/3B/ECE 356 - Database Systems/Lab/Fielding.csv' 
INTO TABLE Fielding 
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(playerID, yearID, stint, teamID, lgID, POS, G, GS, InnOuts, @PO, @A, @E, @DP, PB, WP, SB, CS, ZR)
SET PO = nullif(@PO,''),
    A = nullif(@A,''),
    E = nullif(@E,''),
    DP = nullif(@DP,'');

-- Question 3
-- Set up primary key
/*
    Set up (composite) primary key for each table based on uniqueness, not-null constraint and brevity (minimal)
*/
ALTER TABLE Master ADD PRIMARY KEY (playerID);
ALTER TABLE Batting ADD PRIMARY KEY (yearID, playerID, stint);
ALTER TABLE Pitching ADD PRIMARY KEY (yearID, playerID, stint);
ALTER IGNORE TABLE Fielding ADD PRIMARY KEY (yearID, playerID, stint, POS); -- Use IGNORE to remove duplicates caused by question 2
ALTER TABLE AllstarFull ADD PRIMARY KEY (playerID, yearID, gameID);
ALTER TABLE HallOfFame ADD PRIMARY KEY (playerID, yearid, votedBy);
ALTER TABLE Managers ADD PRIMARY KEY (teamID, yearID, inseason);
ALTER TABLE Teams ADD PRIMARY KEY (teamID, lgID, yearID);
ALTER TABLE BattingPost ADD PRIMARY KEY (yearID, playerID, round);
ALTER TABLE PitchingPost ADD PRIMARY KEY (yearID, playerID, round);
ALTER TABLE TeamsFranchises ADD PRIMARY KEY (franchID);
ALTER TABLE FieldingOF ADD PRIMARY KEY (yearID, playerID, stint);
ALTER TABLE FieldingPost ADD PRIMARY KEY (yearID, playerID, POS, round);
ALTER TABLE FieldingOFsplit ADD PRIMARY KEY (yearID, playerID, stint, POS);
ALTER TABLE ManagersHalf ADD PRIMARY KEY (yearID, playerID, teamID, half);
ALTER TABLE TeamsHalf ADD PRIMARY KEY (yearID, lgID, teamID, Half);
ALTER TABLE Salaries ADD PRIMARY KEY (yearID, lgID, teamID, playerID);
ALTER TABLE SeriesPost ADD PRIMARY KEY (yearID, round);
ALTER TABLE AwardsManagers ADD PRIMARY KEY (awardID, yearID, playerID, lgID);
ALTER TABLE AwardsPlayers ADD PRIMARY KEY (awardID, yearID, playerID, lgID);
ALTER TABLE AwardsShareManagers ADD PRIMARY KEY (awardID, yearID, playerID, lgID);
ALTER TABLE AwardsSharePlayers ADD PRIMARY KEY (awardID, yearID, playerID, lgID);
ALTER TABLE Appearances ADD PRIMARY KEY (playerID, yearID, teamID);
ALTER TABLE Schools ADD PRIMARY KEY (schoolID);
ALTER TABLE CollegePlaying ADD PRIMARY KEY (playerID, schoolID, yearID);
ALTER TABLE Parks ADD PRIMARY KEY (`park.key`);
ALTER TABLE HomeGames ADD PRIMARY KEY (`year.key`, `league.key`, `team.key`, `park.key`);

-- Set up foreign key
/*
    Set up foreign key for each table based on the relationship:
        1. Clean up the redundant data in the child table which does not have a reference to the corresonding primary key of the parent table
        2. Set up foreign key constraint 
*/

/* 
    AllStarFull
        -- FOREIGN KEY `fk_AllstarFull_Teams` 
        -- FOREIGN KEY `fk_AllstarFull_Master`
*/
DELETE FROM AllstarFull WHERE playerID NOT IN (select playerID FROM Master);
DELETE FROM AllstarFull WHERE (teamID, lgID, yearID) NOT IN (select teamID, lgID, yearID FROM Teams);

ALTER TABLE AllstarFull
  ADD CONSTRAINT fk_AllstarFull_Teams FOREIGN KEY AllstarFull(teamID, lgID, yearID) REFERENCES Teams(teamID, lgID, yearID) ON DELETE CASCADE,
  ADD CONSTRAINT fk_AllstarFull_Master FOREIGN KEY AllstarFull(playerID) REFERENCES Master(playerID) ON DELETE CASCADE;


/* 
    HallofFame 
        -- FOREIGN KEY `fk_HallOfFame_Master`
*/
DELETE FROM HallOfFame WHERE playerID NOT IN (select playerID FROM Master);

ALTER TABLE HallOfFame
  ADD CONSTRAINT fk_HallOfFame_Master FOREIGN KEY HallOfFame(playerID) REFERENCES Master(playerID) ON DELETE CASCADE;


/* 
    Manager
        -- FOREIGN KEY `fk_Managers_Teams`
        -- FOREIGN KEY `fk_Managers_Master`
*/
DELETE FROM Managers WHERE playerID NOT IN (select playerID FROM Master);
DELETE FROM Managers WHERE (teamID, lgID, yearID) NOT IN (select teamID, lgID, yearID FROM Teams);

ALTER TABLE Managers
  ADD CONSTRAINT fk_Managers_Teams FOREIGN KEY Managers(teamID, lgID, yearID) REFERENCES Teams(teamID, lgID, yearID) ON DELETE CASCADE,
  ADD CONSTRAINT fk_Managers_Master FOREIGN KEY Managers(playerID) REFERENCES Master(playerID) ON DELETE CASCADE;


/* 
    Teams
        -- FOREIGN KEY `fk_Teams_TeamsFranchises`
*/
DELETE FROM Teams WHERE franchID NOT IN (select franchID FROM TeamsFranchises);

ALTER TABLE Teams
  ADD CONSTRAINT fk_Teams_TeamsFranchises FOREIGN KEY Teams(franchID) REFERENCES TeamsFranchises(franchID) ON DELETE CASCADE;


/* 
    Batting 
        -- FOREIGN KEY `fk_Batting_Teams` 
        -- FOREIGN KEY `fk_Batting_Master`
*/
DELETE FROM Batting WHERE (teamID, lgID, yearID) NOT IN (select teamID, lgID, yearID FROM Teams);
DELETE FROM Batting WHERE playerID NOT IN (select playerID FROM Master);

ALTER TABLE Batting
  ADD CONSTRAINT fk_Batting_Teams FOREIGN KEY Batting(teamID, lgID, yearID) REFERENCES Teams(teamID, lgID, yearID) ON DELETE CASCADE,
  ADD CONSTRAINT fk_Batting_Master FOREIGN KEY Batting(playerID) REFERENCES Master(playerID) ON DELETE CASCADE;


/* 
    Pitching
        -- FOREIGN KEY `fk_Pitching_Teams` 
        -- FOREIGN KEY `fk_Pitching_Master`
*/
DELETE FROM Pitching WHERE (teamID, lgID, yearID) NOT IN (select teamID, lgID, yearID FROM Teams);
DELETE FROM Pitching WHERE playerID NOT IN (select playerID FROM Master);

ALTER TABLE Pitching
  ADD CONSTRAINT fk_Pitching_Teams FOREIGN KEY Pitching(teamID, lgID, yearID) REFERENCES Teams(teamID, lgID, yearID) ON DELETE CASCADE,
  ADD CONSTRAINT fk_Pitching_Master FOREIGN KEY Pitching(playerID) REFERENCES Master(playerID) ON DELETE CASCADE;


/* 
    BattingPost 
        -- FOREIGN KEY `fk_BattingPost_Teams` 
        -- FOREIGN KEY `fk_BattingPost_Master`
*/
DELETE FROM BattingPost WHERE (teamID, lgID, yearID) NOT IN (select teamID, lgID, yearID FROM Teams);
DELETE FROM BattingPost WHERE playerID NOT IN (select playerID FROM Master);

ALTER TABLE BattingPost
  ADD CONSTRAINT fk_BattingPost_Teams FOREIGN KEY BattingPost(teamID, lgID, yearID) REFERENCES Teams(teamID, lgID, yearID) ON DELETE CASCADE,
  ADD CONSTRAINT fk_BattingPost_Master FOREIGN KEY BattingPost(playerID) REFERENCES Master(playerID) ON DELETE CASCADE;


/* 
    PitchingPost 
        -- FOREIGN KEY `fk_PitchingPost_Teams` 
        -- FOREIGN KEY `fk_PitchingPost_Master` 
*/
DELETE FROM PitchingPost WHERE (teamID, lgID, yearID) NOT IN (select teamID, lgID, yearID FROM Teams);
DELETE FROM PitchingPost WHERE playerID NOT IN (select playerID FROM Master);

ALTER TABLE PitchingPost
  ADD CONSTRAINT fk_PitchingPost_Teams FOREIGN KEY PitchingPost(teamID, lgID, yearID) REFERENCES Teams(teamID, lgID, yearID) ON DELETE CASCADE,
  ADD CONSTRAINT fk_PitchingPost_Master FOREIGN KEY PitchingPost(playerID) REFERENCES Master(playerID) ON DELETE CASCADE;


/* 
    Fielding 
        -- FOREIGN KEY `fk_Fielding_Teams`
        -- FOREIGN KEY `fk_Fielding_Master`
        -- FOREIGN KEY `fk_Fielding_Pitching`
        -- FOREIGN KEY `fk_Fielding_Batting`
        -- FOREIGN KEY `fk_Fielding_FieldingOFsplit`
        -- FOREIGN KEY `fk_Fielding_FieldingOF`
*/
DELETE FROM Fielding WHERE (teamID, lgID, yearID) NOT IN (select teamID, lgID, yearID FROM Teams);
DELETE FROM Fielding WHERE playerID NOT IN (select playerID FROM Master);
DELETE FROM Fielding WHERE (yearID, playerID, stint) NOT IN (select yearID, playerID, stint FROM Pitching);
DELETE FROM Fielding WHERE (yearID, playerID, stint) NOT IN (select yearID, playerID, stint FROM Batting);
DELETE FROM Fielding WHERE (yearID, playerID, stint, POS) NOT IN (select yearID, playerID, stint, POS FROM FieldingOFsplit);
DELETE FROM Fielding WHERE (yearID, playerID, stint) NOT IN (select yearID, playerID, stint FROM FieldingOF);

ALTER TABLE Fielding
  ADD CONSTRAINT fk_Fielding_Teams FOREIGN KEY Fielding(teamID, lgID, yearID) REFERENCES Teams(teamID, lgID, yearID) ON DELETE CASCADE,
  ADD CONSTRAINT fk_Fielding_Master FOREIGN KEY Fielding(playerID) REFERENCES Master(playerID) ON DELETE CASCADE,
  ADD CONSTRAINT fk_Fielding_Pitching FOREIGN KEY Fielding(yearID, playerID, stint) REFERENCES Pitching(yearID, playerID, stint) ON DELETE CASCADE,
  ADD CONSTRAINT fk_Fielding_Batting FOREIGN KEY Fielding(yearID, playerID, stint) REFERENCES Batting(yearID, playerID, stint) ON DELETE CASCADE,
  ADD CONSTRAINT fk_Fielding_FieldingOFsplit FOREIGN KEY Fielding(yearID, playerID, stint, POS) REFERENCES FieldingOFsplit(yearID, playerID, stint, POS) ON DELETE CASCADE,
  ADD CONSTRAINT fk_Fielding_FieldingOF FOREIGN KEY Fielding(yearID, playerID, stint) REFERENCES FieldingOF(yearID, playerID, stint) ON DELETE CASCADE;


/* 
    FieldingOF
        -- FOREIGN KEY `fk_FieldingOF_Master` 
        -- FOREIGN KEY `fk_FieldingOF_Batting`
        -- FOREIGN KEY `fk_FieldingOF_Pitching`
*/
DELETE FROM FieldingOF WHERE playerID NOT IN (select playerID FROM Master);
DELETE FROM FieldingOF WHERE (yearID, playerID, stint) NOT IN (select yearID, playerID, stint FROM Batting);
DELETE FROM FieldingOF WHERE (yearID, playerID, stint) NOT IN (select yearID, playerID, stint FROM Pitching);

ALTER TABLE FieldingOF
  ADD CONSTRAINT fk_FieldingOF_Master FOREIGN KEY FieldingOF(playerID) REFERENCES Master(playerID) ON DELETE CASCADE,
  ADD CONSTRAINT fk_FieldingOF_Batting FOREIGN KEY FieldingOF(yearID, playerID, stint) REFERENCES Batting(yearID, playerID, stint) ON DELETE CASCADE,
  ADD CONSTRAINT fk_FieldingOF_Pitching FOREIGN KEY FieldingOF(yearID, playerID, stint) REFERENCES Pitching(yearID, playerID, stint) ON DELETE CASCADE;


/* 
    FieldingPost
        -- FOREIGN KEY `fk_FieldingPost_Teams` 
        -- FOREIGN KEY `fk_FieldingPost_Master` 
        -- FOREIGN KEY `fk_FieldingPost_BattingPost`
*/
DELETE FROM FieldingPost WHERE (teamID, lgID, yearID) NOT IN (select teamID, lgID, yearID FROM Teams);
DELETE FROM FieldingPost WHERE playerID NOT IN (select playerID FROM Master);
DELETE FROM FieldingPost WHERE (yearID, playerID, round) NOT IN (select yearID, playerID, round FROM BattingPost);

ALTER TABLE FieldingPost
  ADD CONSTRAINT fk_FieldingPost_Teams FOREIGN KEY FieldingPost(teamID, lgID, yearID) REFERENCES Teams(teamID, lgID, yearID) ON DELETE CASCADE,
  ADD CONSTRAINT fk_FieldingPost_Master FOREIGN KEY FieldingPost(playerID) REFERENCES Master(playerID) ON DELETE CASCADE,
  ADD CONSTRAINT fk_FieldingPost_BattingPost FOREIGN KEY FieldingPost(yearID, playerID, round) REFERENCES BattingPost(yearID, playerID, round) ON DELETE CASCADE;


/* 
    FieldingOFsplit
        -- FOREIGN KEY `fk_FieldingOFsplit_Teams` 
        -- FOREIGN KEY `fk_FieldingOFsplit_Master` 
        -- FOREIGN KEY `fk_FieldingOFsplit_Batting`
        -- FOREIGN KEY `fk_FieldingOFsplit_Pitching`
        -- FOREIGN KEY `fk_FieldingOFsplit_FieldingOF`
*/
DELETE FROM FieldingOFsplit WHERE (teamID, lgID, yearID) NOT IN (select teamID, lgID, yearID FROM Teams);
DELETE FROM FieldingOFsplit WHERE playerID NOT IN (select playerID FROM Master);
DELETE FROM FieldingOFsplit WHERE (yearID, playerID, stint) NOT IN (select yearID, playerID, stint FROM Pitching);
DELETE FROM FieldingOFsplit WHERE (yearID, playerID, stint) NOT IN (select yearID, playerID, stint FROM Batting);
DELETE FROM FieldingOFsplit WHERE (yearID, playerID, stint) NOT IN (select yearID, playerID, stint FROM FieldingOF);

ALTER TABLE FieldingOFsplit
  ADD CONSTRAINT fk_FieldingOFsplit_Batting FOREIGN KEY FieldingOFsplit(playerID ,yearID ,stint) REFERENCES Batting(playerID ,yearID ,stint),
  ADD CONSTRAINT fk_FieldingOFsplit_Pitching FOREIGN KEY FieldingOFsplit(playerID ,yearID ,stint) REFERENCES Pitching(playerID ,yearID ,stint),
  ADD CONSTRAINT fk_FieldingOFsplit_FieldingOF FOREIGN KEY FieldingOFsplit(playerID ,yearID ,stint) REFERENCES FieldingOF(playerID ,yearID ,stint),
  ADD CONSTRAINT fk_FieldingOFsplit_Teams FOREIGN KEY FieldingOFsplit(teamID, lgID, yearID) REFERENCES Teams(teamID, lgID, yearID) ON DELETE CASCADE,
  ADD CONSTRAINT fk_FieldingOFsplit_Master FOREIGN KEY FieldingOFsplit(playerID) REFERENCES Master(playerID) ON DELETE CASCADE;


/* 
    ManagersHalf
        -- FOREIGN KEY `fk_ManagersHalf_Teams` 
        -- FOREIGN KEY `fk_ManagersHalf_Master`
*/
DELETE FROM ManagersHalf WHERE (teamID, lgID, yearID) NOT IN (select teamID, lgID, yearID FROM Teams);
DELETE FROM ManagersHalf WHERE playerID NOT IN (select playerID FROM Master);

ALTER TABLE ManagersHalf
  ADD CONSTRAINT fk_ManagersHalf_Teams FOREIGN KEY ManagersHalf(teamID, lgID, yearID) REFERENCES Teams(teamID, lgID, yearID) ON DELETE CASCADE,
  ADD CONSTRAINT fk_ManagersHalf_Master FOREIGN KEY ManagersHalf(playerID) REFERENCES Master(playerID) ON DELETE CASCADE;


/* 
    TeamsHalf
        -- FOREIGN KEY `fk_TeamsHalf_Teams`
*/
DELETE FROM TeamsHalf WHERE (teamID, lgID, yearID) NOT IN (select teamID, lgID, yearID FROM Teams);

ALTER TABLE TeamsHalf
  ADD CONSTRAINT fk_TeamsHalf_Teams FOREIGN KEY TeamsHalf(teamID, lgID, yearID) REFERENCES Teams(teamID, lgID, yearID) ON DELETE CASCADE; 


/* 
    Salaries
        -- FOREIGN KEY `fk_Salaries_Teams` 
        -- FOREIGN KEY `fk_Salaries_Master`
*/
DELETE FROM Salaries WHERE playerID NOT IN (select playerID FROM Master);
DELETE FROM Salaries WHERE (teamID, lgID, yearID) NOT IN (select teamID, lgID, yearID FROM Teams);

ALTER TABLE Salaries
  ADD CONSTRAINT fk_Salaries_Teams FOREIGN KEY Salaries(teamID, lgID, yearID) REFERENCES Teams(teamID, lgID, yearID) ON DELETE CASCADE,
  ADD CONSTRAINT fk_Salaries_Master FOREIGN KEY Salaries(playerID) REFERENCES Master(playerID) ON DELETE CASCADE;


/* 
    SeriesPost
        -- FOREIGN KEY `fk_SeriesPost_WinnersTeams`
        -- FOREIGN KEY `fk_SeriesPost_LoserTeams`
*/
DELETE FROM SeriesPost WHERE (teamIDwinner, lgIDwinner, yearID) NOT IN (select teamID, lgID, yearID FROM Teams);
DELETE FROM SeriesPost WHERE (teamIDloser, lgIDloser, yearID) NOT IN (select teamID, lgID, yearID FROM Teams);

ALTER TABLE SeriesPost
  ADD CONSTRAINT fk_SeriesPost_WinnersTeams FOREIGN KEY SeriesPost(teamIDwinner, lgIDwinner, yearID) REFERENCES Teams(teamID, lgID, yearID) ON DELETE CASCADE,
  ADD CONSTRAINT fk_SeriesPost_LoserTeams FOREIGN KEY SeriesPost(teamIDloser, lgIDloser, yearID) REFERENCES Teams(teamID, lgID, yearID) ON DELETE CASCADE;


/* 
    AwardsManagers
        -- FOREIGN KEY `fk_AwardsManagers_Master`
*/
DELETE FROM AwardsManagers WHERE playerID NOT IN (select playerID FROM Master);

ALTER TABLE AwardsManagers
  ADD CONSTRAINT fk_AwardsManagers_Master FOREIGN KEY AwardsManagers(playerID) REFERENCES Master(playerID) ON DELETE CASCADE;


/* 
    AwardsPlayers
        -- FOREIGN KEY `fk_AwardsPlayers_Master`
*/
DELETE FROM AwardsPlayers WHERE playerID NOT IN (select playerID FROM Master);

ALTER TABLE AwardsPlayers
  ADD CONSTRAINT fk_AwardsPlayers_Master FOREIGN KEY AwardsPlayers(playerID) REFERENCES Master(playerID) ON DELETE CASCADE;


/* 
    AwardsShareManagers
        -- FOREIGN KEY `fk_AwardsShareManagers_Master`
*/
DELETE FROM AwardsShareManagers WHERE playerID NOT IN (select playerID FROM Master);

ALTER TABLE AwardsShareManagers
  ADD CONSTRAINT fk_AwardsShareManagers_Master FOREIGN KEY AwardsShareManagers(playerID) REFERENCES Master(playerID) ON DELETE CASCADE;


/* 
    AwardsSharePlayers
        -- FOREIGN KEY `fk_AwardsSharePlayers_Master`
*/
DELETE FROM AwardsSharePlayers WHERE playerID NOT IN (select playerID FROM Master);

ALTER TABLE AwardsSharePlayers
  ADD CONSTRAINT fk_AwardsSharePlayers_Master FOREIGN KEY AwardsSharePlayers(playerID) REFERENCES Master(playerID) ON DELETE CASCADE;


/* 
    Appearances
        -- FOREIGN KEY `fk_Appearances_Teams`
        -- FOREIGN KEY `fk_Appearances_Master`
*/
DELETE FROM Appearances WHERE (teamID, lgID, yearID) NOT IN (select teamID, lgID, yearID FROM Teams);
DELETE FROM Appearances WHERE playerID NOT IN (select playerID FROM Master);

ALTER TABLE Appearances
  ADD CONSTRAINT fk_Appearances_Teams FOREIGN KEY Appearances(teamID, lgID, yearID) REFERENCES Teams(teamID, lgID, yearID) ON DELETE CASCADE,
  ADD CONSTRAINT fk_Appearances_Master FOREIGN KEY Appearances(playerID) REFERENCES Master(playerID) ON DELETE CASCADE;


/* 
    CollegePlaying
        -- FOREIGN KEY `fk_CollegePlaying_Master`
        -- FOREIGN KEY `fk_CollegePlaying_Schools`
*/
DELETE FROM CollegePlaying WHERE playerID NOT IN (select playerID FROM Master);
DELETE FROM CollegePlaying WHERE schoolID NOT IN (select schoolID FROM Schools);

ALTER TABLE CollegePlaying
  ADD CONSTRAINT fk_CollegePlaying_Schools FOREIGN KEY CollegePlaying(schoolID) REFERENCES Schools(schoolID) ON DELETE CASCADE,
  ADD CONSTRAINT fk_CollegePlaying_Master FOREIGN KEY CollegePlaying(playerID) REFERENCES Master(playerID) ON DELETE CASCADE;