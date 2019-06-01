
select nameFirst,nameLast,max(RBI) from Batting
                 inner join Master using (playerID)
                 where HR = 0 limit 1;