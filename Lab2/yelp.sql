-- (a)
/*
    Answer:
            +----+-------------+-------+------+---------------+------+---------+------+---------+----------------+
            | id | select_type | table | type | possible_keys | key  | key_len | ref  | rows    | Extra          |
            +----+-------------+-------+------+---------------+------+---------+------+---------+----------------+
            |  1 | SIMPLE      | user  | ALL  | NULL          | NULL | NULL    | NULL | 1021667 | Using filesort |
            +----+-------------+-------+------+---------------+------+---------+------+---------+----------------+
            1 row in set (0.00 sec)
*/
EXPLAIN SELECT user_id,
       name
FROM user
ORDER BY review_count DESC
LIMIT 1;

CREATE INDEX review_count_index ON user (review_count) USING BTREE;



-- (b)
/*
    Answer:
            +----+-------------+----------+------+---------------+------+---------+------+--------+----------------+
            | id | select_type | table    | type | possible_keys | key  | key_len | ref  | rows   | Extra          |
            +----+-------------+----------+------+---------------+------+---------+------+--------+----------------+
            |  1 | SIMPLE      | business | ALL  | NULL          | NULL | NULL    | NULL | 142527 | Using filesort |
            +----+-------------+----------+------+---------------+------+---------+------+--------+----------------+
            1 row in set (0.01 sec)
*/
EXPLAIN SELECT business_id,
       name
FROM business
ORDER BY review_count DESC
LIMIT 1;

CREATE INDEX review_count_index ON business (review_count) USING BTREE;


-- (c)
/*
    Answer:
            +----+-------------+-------+------+---------------+------+---------+------+---------+-------+
            | id | select_type | table | type | possible_keys | key  | key_len | ref  | rows    | Extra |
            +----+-------------+-------+------+---------------+------+---------+------+---------+-------+
            |  1 | SIMPLE      | user  | ALL  | NULL          | NULL | NULL    | NULL | 1021667 | NULL  |
            +----+-------------+-------+------+---------------+------+---------+------+---------+-------+
            1 row in set (0.02 sec)
*/
EXPLAIN SELECT avg(review_count) AS avg_review_count
FROM user;

-- No index needed

-- (d)
/*
    Answer:
            +----+-------------+------------+--------+---------------+---------+---------+--------------+---------+---------------------------------+
            | id | select_type | table      | type   | possible_keys | key     | key_len | ref          | rows    | Extra                           |
            +----+-------------+------------+--------+---------------+---------+---------+--------------+---------+---------------------------------+
            |  1 | PRIMARY     | <derived2> | ALL    | NULL          | NULL    | NULL    | NULL         | 1655155 | NULL                            |
            |  1 | PRIMARY     | user       | eq_ref | PRIMARY       | PRIMARY | 22      | temp.user_id |       1 | Using where                     |
            |  2 | DERIVED     | review     | ALL    | NULL          | NULL    | NULL    | NULL         | 1655155 | Using temporary; Using filesort |
            +----+-------------+------------+--------+---------------+---------+---------+--------------+---------+---------------------------------+
            3 rows in set (0.01 sec)
*/
EXPLAIN SELECT count(*) AS avg_rating_diff_count
FROM user
INNER JOIN
  (SELECT user_id,
          avg(stars) AS avg_rating
   FROM review
   GROUP BY user_id) AS temp ON user.user_id = temp.user_id
WHERE abs(temp.avg_rating - user.average_stars) > 0.5;

-- No index needed

-- (e)
/* 
    Answer:
            +----+-------------+-------+------+---------------+------+---------+------+---------+-------+
            | id | select_type | table | type | possible_keys | key  | key_len | ref  | rows    | Extra |
            +----+-------------+-------+------+---------------+------+---------+------+---------+-------+
            |  1 | SIMPLE      | user  | ALL  | NULL          | NULL | NULL    | NULL | 1021667 | NULL  |
            +----+-------------+-------+------+---------------+------+---------+------+---------+-------+
            1 row in set (0.00 sec)
*/
EXPLAIN SELECT count(if(review_count > 10, 1, NULL))/count(*) AS more_than_ten_reviews_fraction
FROM user;

CREATE INDEX review_count_index ON user (review_count) USING BTREE;


-- (f)
/*
    Answer:
            +----+-------------+------------+------+---------------+-------------+---------+---------------------+---------+-------------+
            | id | select_type | table      | type | possible_keys | key         | key_len | ref                 | rows    | Extra       |
            +----+-------------+------------+------+---------------+-------------+---------+---------------------+---------+-------------+
            |  1 | PRIMARY     | review     | ALL  | NULL          | NULL        | NULL    | NULL                | 1655155 | NULL        |
            |  1 | PRIMARY     | <derived2> | ref  | <auto_key0>   | <auto_key0> | 22      | Yelp.review.user_id |      10 | Using index |
            |  2 | DERIVED     | user       | ALL  | NULL          | NULL        | NULL    | NULL                | 1021667 | Using where |
            +----+-------------+------------+------+---------------+-------------+---------+---------------------+---------+-------------+
            3 rows in set (0.01 sec)
*/
EXPLAIN SELECT avg(length(text)) AS avg_review_length
FROM review
INNER JOIN
  (SELECT user_id
  FROM user
  WHERE review_count > 10) AS temp on review.user_id = temp.user_id;

CREATE INDEX review_count_index ON user (review_count) USING BTREE;