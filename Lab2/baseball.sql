-- Question 1
-- (a)
/*
    Explain Result:
            +----+-------------+--------+------+---------------+------+---------+------+-------+-------------+
            | id | select_type | table  | type | possible_keys | key  | key_len | ref  | rows  | Extra       |
            +----+-------------+--------+------+---------------+------+---------+------+-------+-------------+
            |  1 | SIMPLE      | Master | ALL  | NULL          | NULL | NULL    | NULL | 18993 | Using where |
            +----+-------------+--------+------+---------------+------+---------+------+-------+-------------+
*/
EXPLAIN SELECT count(*) AS unkown_birthdate_count
FROM Master
WHERE birthYear = 0
  OR birthMonth = 0
  OR birthDay = 0;

CREATE INDEX birthYear ON Master (birthYear) USING BTREE;
CREATE INDEX birthMonth ON Master (birthMonth) USING BTREE;
CREATE INDEX birthDay ON Master (birthDay) USING BTREE;

EXPLAIN SELECT count(*) AS unkown_birthdate_count
FROM Master
WHERE birthYear = 0
  OR birthMonth = 0
  OR birthDay = 0;

-- (b)
/*
    Explain Result:  
            +----+-------------+------------+--------+---------------+---------+---------+------------------------------------+------+------------------------------+
            | id | select_type | table      | type   | possible_keys | key     | key_len | ref                                | rows | Extra                        |
            +----+-------------+------------+--------+---------------+---------+---------+------------------------------------+------+------------------------------+
            |  1 | PRIMARY     | NULL       | NULL   | NULL          | NULL    | NULL    | NULL                               | NULL | No tables used               |
            |  4 | SUBQUERY    | <derived5> | ALL    | NULL          | NULL    | NULL    | NULL                               | 4155 | NULL                         |
            |  5 | DERIVED     | HallOfFame | index  | PRIMARY       | PRIMARY | 1538    | NULL                               | 4155 | Using index; Using temporary |
            |  5 | DERIVED     | Master     | eq_ref | PRIMARY       | PRIMARY | 767     | db356_z498zhan.HallOfFame.playerID |    1 | Using where; Distinct        |
            |  2 | SUBQUERY    | <derived3> | ALL    | NULL          | NULL    | NULL    | NULL                               | 4155 | NULL                         |
            |  3 | DERIVED     | HallOfFame | index  | PRIMARY       | PRIMARY | 1538    | NULL                               | 4155 | Using index; Using temporary |
            |  3 | DERIVED     | Master     | eq_ref | PRIMARY       | PRIMARY | 767     | db356_z498zhan.HallOfFame.playerID |    1 | Using where; Distinct        |
            +----+-------------+------------+--------+---------------+---------+---------+------------------------------------+------+------------------------------+
*/
EXPLAIN SELECT
(
    (SELECT COUNT(distinct HallOfFame.playerID) FROM HallOfFame inner join Master on HallOfFame.playerID = Master.playerID where Master.deathYear = 0)
-
    (SELECT COUNT(distinct HallOfFame.playerID) FROM HallOfFame inner join Master on HallOfFame.playerID = Master.playerID where Master.deathYear > 0)
)
AS 'Alive - Dead';

CREATE INDEX deathYear_index ON Master (deathYear) USING BTREE;
CREATE INDEX playerID_index ON HallOfFame (playerID) USING BTREE;

EXPLAIN SELECT
(
    (SELECT COUNT(distinct HallOfFame.playerID) FROM HallOfFame inner join Master on HallOfFame.playerID = Master.playerID where Master.deathYear = 0)
-
    (SELECT COUNT(distinct HallOfFame.playerID) FROM HallOfFame inner join Master on HallOfFame.playerID = Master.playerID where Master.deathYear > 0)
)
AS 'Alive - Dead';

-- (c)
/*
    Explain Result:
            +----+-------------+------------+--------+----------------------------------------------+--------------------+---------+---------------+-------+----------------+
            | id | select_type | table      | type   | possible_keys                                | key                | key_len | ref           | rows  | Extra          |
            +----+-------------+------------+--------+----------------------------------------------+--------------------+---------+---------------+-------+----------------+
            |  1 | PRIMARY     | <derived2> | ALL    | NULL                                         | NULL               | NULL    | NULL          | 26110 | Using filesort |
            |  1 | PRIMARY     | Master     | eq_ref | PRIMARY                                      | PRIMARY            | 767     | temp.playerID |     1 | NULL           |
            |  2 | DERIVED     | Salaries   | index  | PRIMARY,fk_Salaries_Teams,fk_Salaries_Master | fk_Salaries_Master | 767     | NULL          | 26110 | NULL           |
            +----+-------------+------------+--------+----------------------------------------------+--------------------+---------+---------------+-------+----------------+
*/
EXPLAIN SELECT nameFirst,
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
    Explain Result:
            +----+-------------+------------+-------+--------------------------------------------+-------------------+---------+------+--------+-------+
            | id | select_type | table      | type  | possible_keys                              | key               | key_len | ref  | rows   | Extra |
            +----+-------------+------------+-------+--------------------------------------------+-------------------+---------+------+--------+-------+
            |  1 | PRIMARY     | <derived2> | ALL   | NULL                                       | NULL              | NULL    | NULL | 102321 | NULL  |
            |  2 | DERIVED     | Batting    | index | PRIMARY,fk_Batting_Teams,fk_Batting_Master | fk_Batting_Master | 767     | NULL | 102321 | NULL  |
            +----+-------------+------------+-------+--------------------------------------------+-------------------+---------+------+--------+-------+
*/
EXPLAIN SELECT avg(total) AS avg_HR
FROM
  (SELECT sum(HR) AS total
   FROM Batting
   GROUP BY playerID) AS temp;


-- (e)
/*
    Explain Result:
            +----+-------------+------------+-------+--------------------------------------------+-------------------+---------+------+--------+-------+
            | id | select_type | table      | type  | possible_keys                              | key               | key_len | ref  | rows   | Extra |
            +----+-------------+------------+-------+--------------------------------------------+-------------------+---------+------+--------+-------+
            |  1 | PRIMARY     | <derived2> | ALL   | NULL                                       | NULL              | NULL    | NULL | 102321 | NULL  |
            |  2 | DERIVED     | Batting    | index | PRIMARY,fk_Batting_Teams,fk_Batting_Master | fk_Batting_Master | 767     | NULL | 102321 | NULL  |
            +----+-------------+------------+-------+--------------------------------------------+-------------------+---------+------+--------+-------+
*/
EXPLAIN SELECT avg(total) AS avg_HR
FROM
  (SELECT sum(HR) AS total
   FROM Batting
   GROUP BY playerID
   HAVING total >= 1) AS temp;

CREATE INDEX HR_playerID_index ON Batting (HR, playerID) USING BTREE;

EXPLAIN SELECT avg(total) AS avg_HR
FROM
  (SELECT sum(HR) AS total
   FROM Batting
   GROUP BY playerID
   HAVING total >= 1) AS temp;


-- (f)
/*
    Explain Result:
            +----+-------------+------------+-------+-----------------------------------------------------+--------------------+---------+-----------------------+--------+-------+
            | id | select_type | table      | type  | possible_keys                                       | key                | key_len | ref                   | rows   | Extra |
            +----+-------------+------------+-------+-----------------------------------------------------+--------------------+---------+-----------------------+--------+-------+
            |  1 | PRIMARY     | <derived5> | ALL   | NULL                                                | NULL               | NULL    | NULL                  |  44668 | NULL  |
            |  1 | PRIMARY     | <derived2> | ref   | <auto_key0>                                         | <auto_key0>        | 767     | good_pitcher.playerID |     10 | NULL  |
            |  5 | DERIVED     | Pitching   | index | PRIMARY,fk_Pitching_Teams,fk_Pitching_Master        | fk_Pitching_Master | 767     | NULL                  |  44668 | NULL  |
            |  6 | SUBQUERY    | <derived7> | ALL   | NULL                                                | NULL               | NULL    | NULL                  |  44668 | NULL  |
            |  7 | DERIVED     | Pitching   | index | PRIMARY,fk_Pitching_Teams,fk_Pitching_Master        | fk_Pitching_Master | 767     | NULL                  |  44668 | NULL  |
            |  2 | DERIVED     | Batting    | index | PRIMARY,fk_Batting_Teams,fk_Batting_Master,HR_index | fk_Batting_Master  | 767     | NULL                  | 102321 | NULL  |
            |  3 | SUBQUERY    | <derived4> | ALL   | NULL                                                | NULL               | NULL    | NULL                  | 102321 | NULL  |
            |  4 | DERIVED     | Batting    | index | PRIMARY,fk_Batting_Teams,fk_Batting_Master,HR_index | fk_Batting_Master  | 767     | NULL                  | 102321 | NULL  |
            +----+-------------+------------+-------+-----------------------------------------------------+--------------------+---------+-----------------------+--------+-------+
*/
EXPLAIN SELECT count(*) AS good_player_count
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

CREATE INDEX SHO_playerID_index ON Pitching (SHO, playerID) USING BTREE;
CREATE INDEX HR_playerID_index ON Batting (HR, playerID) USING BTREE;

EXPLAIN SELECT count(*) AS good_player_count
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