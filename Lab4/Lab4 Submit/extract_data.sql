SELECT HallOfFame.playerID, 
    (SELECT COUNT(*) FROM AwardsPlayers WHERE AwardsPlayers.playerID = HallOfFame.playerID and awardID = "Most Valuable Player") AS MVP,
    (SELECT COUNT(*) FROM AwardsPlayers WHERE AwardsPlayers.playerID = HallOfFame.playerID and awardID = "Gold Glove") AS Gold_Glove,
    (SELECT COUNT(*) FROM AwardsPlayers WHERE AwardsPlayers.playerID = HallOfFame.playerID and awardID = "Cy Young Award") AS Cy_Young_Award,

    (SELECT SUM(GP) FROM AllstarFull WHERE AllstarFull.playerID = HallOfFame.playerID) AS All_Star_Game,

    (SELECT COUNT(DISTINCT yearID) FROM Batting WHERE Batting.playerID = HallOfFame.playerID) AS Batting_Seasons_Number,
    (SELECT MAX(DISTINCT yearID) FROM Batting WHERE Batting.playerID = HallOfFame.playerID) AS Batting_LastSeason,
    (SELECT SUM(G) FROM Batting WHERE Batting.playerID = HallOfFame.playerID) AS Batting_Games,
    (SELECT SUM(AB) FROM Batting WHERE Batting.playerID = HallOfFame.playerID) AS Batting_At_Bats,
    (SELECT SUM(R) FROM Batting WHERE Batting.playerID = HallOfFame.playerID) AS Batting_Runs,
    (SELECT SUM(H) FROM Batting WHERE Batting.playerID = HallOfFame.playerID) AS Batting_Hits,
    (SELECT SUM(2B) FROM Batting WHERE Batting.playerID = HallOfFame.playerID) AS Batting_Doubles,
    (SELECT SUM(3B) FROM Batting WHERE Batting.playerID = HallOfFame.playerID) AS Batting_Triples,
    (SELECT SUM(HR) FROM Batting WHERE Batting.playerID = HallOfFame.playerID) AS Batting_Homeruns,
    (SELECT SUM(RBI) FROM Batting WHERE Batting.playerID = HallOfFame.playerID) AS Batting_Runs_Batted_In,
    (SELECT SUM(SB) FROM Batting WHERE Batting.playerID = HallOfFame.playerID) AS Batting_Stolen_Bases,
    (SELECT SUM(CS) FROM Batting WHERE Batting.playerID = HallOfFame.playerID) AS Batting_Caught_Steading,
    (SELECT SUM(BB) FROM Batting WHERE Batting.playerID = HallOfFame.playerID) AS Batting_Base_on_Balls,
    (SELECT SUM(IBB) FROM Batting WHERE Batting.playerID = HallOfFame.playerID) AS Batting_Intentional_walks,
    (SELECT SUM(HBP) FROM Batting WHERE Batting.playerID = HallOfFame.playerID) AS Batting_Hit_by_pitch,
    (SELECT SUM(SH) FROM Batting WHERE Batting.playerID = HallOfFame.playerID) AS Batting_Sacrifice_hits,
    (SELECT SUM(GIDP) FROM Batting WHERE Batting.playerID = HallOfFame.playerID) AS Batting_Grounded_into_double_plays,

    (SELECT SUM(W) FROM Pitching WHERE Pitching.playerID = HallOfFame.playerID) AS Pitching_Wins,
    (SELECT SUM(G) FROM Pitching WHERE Pitching.playerID = HallOfFame.playerID) AS Pitching_Games,
    (SELECT SUM(SHO) FROM Pitching WHERE Pitching.playerID = HallOfFame.playerID) AS Pitching_Shutouts,
    (SELECT SUM(SV) FROM Pitching WHERE Pitching.playerID = HallOfFame.playerID) AS Pitching_Saves,
    (SELECT SUM(IPOuts) FROM Pitching WHERE Pitching.playerID = HallOfFame.playerID) AS Pitching_Outs_Pitched,
    (SELECT SUM(ER) FROM Pitching WHERE Pitching.playerID = HallOfFame.playerID) AS Pitching_Earned_Runs,
    (SELECT SUM(SO) FROM Pitching WHERE Pitching.playerID = HallOfFame.playerID) AS Pitching_Strikeouts, 
    (SELECT SUM(ERA) FROM Pitching WHERE Pitching.playerID = HallOfFame.playerID) AS Pitching_ERA, 
    (SELECT SUM(HBP) FROM Pitching WHERE Pitching.playerID = HallOfFame.playerID) AS Pitching_HBP, 
    (SELECT SUM(BK) FROM Pitching WHERE Pitching.playerID = HallOfFame.playerID) AS Pitching_BK, 
    (SELECT SUM(BFP) FROM Pitching WHERE Pitching.playerID = HallOfFame.playerID) AS Pitching_BFP, 
    (SELECT SUM(GF) FROM Pitching WHERE Pitching.playerID = HallOfFame.playerID) AS Pitching_GF, 
    (SELECT SUM(R) FROM Pitching WHERE Pitching.playerID = HallOfFame.playerID) AS Pitching_R, 
    (SELECT HOF.inducted FROM HallOfFame HOF WHERE HOF.playerID = HallOfFame.playerID ORDER BY yearID DESC LIMIT 1) AS inducted
FROM HallOfFame WHERE category = 'Player' GROUP BY playerID;