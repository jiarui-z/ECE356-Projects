DROP DATABASE IF EXISTS `SocialNetwork`;
CREATE DATABASE  IF NOT EXISTS `SocialNetwork` /*!40100 DEFAULT CHARACTER SET utf8 */;
USE `SocialNetwork`;

CREATE TABLE `Gender` (
    genderID int NOT NULL AUTO_INCREMENT,
    genderType varchar(100),
    PRIMARY KEY (genderID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `Vocation` (
    vocationID int NOT NULL AUTO_INCREMENT,
    vocationType varchar(100),
    PRIMARY KEY (vocationID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `Religion` (
    religionID int NOT NULL AUTO_INCREMENT,
    religionType varchar(100),
    PRIMARY KEY (religionID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `User` (
    userID int NOT NULL AUTO_INCREMENT,
    userName varchar(100) NOT NULL UNIQUE,
    firstName varchar(100),
    middleName varchar(100),
    lastName varchar(100),
    genderID int,
    vocationID int,
    religionID int,
    birthday DATE,
    PRIMARY KEY (userID, userName),
    FOREIGN KEY (genderID) REFERENCES Gender(genderID) ON DELETE CASCADE,
    FOREIGN KEY (vocationID) REFERENCES Vocation(vocationID) ON DELETE CASCADE,
    FOREIGN KEY (religionID) REFERENCES Religion(religionID) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `User_Follower`(
    userID int NOT NULL,
    followerID int NOT NULL,
    PRIMARY KEY (userID, followerID),
    FOREIGN KEY (userID) REFERENCES User(userID) ON DELETE CASCADE,
    FOREIGN KEY (followerID) REFERENCES User(userID) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `Topic`(
    topicID int NOT NULL AUTO_INCREMENT,
    topicName varchar(100),
    PRIMARY KEY (topicID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `Sub_Topic`(
    topicID int NOT NULL,
    subTopicID int NOT NULL,
    PRIMARY KEY (topicID, subTopicID),
    FOREIGN KEY (topicID) REFERENCES Topic(topicID) ON DELETE CASCADE,
    FOREIGN KEY (subTopicID) REFERENCES Topic(topicID) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `Topic_Follower`(
    topicID int NOT NULL,
    userID int NOT NULL,
    PRIMARY KEY (topicID, userID),
    FOREIGN KEY (topicID) REFERENCES Topic(topicID) ON DELETE CASCADE,
    FOREIGN KEY (userID) REFERENCES User(userID) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `Post`(
    postID int NOT NULL AUTO_INCREMENT,
    userID int NOT NULL,
    textContent varchar(1000),
    thumbsUpCount int(11) DEFAULT 0,
    thumbsDownCount int(11) DEFAULT 0,
    createTime DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (postID),
    FOREIGN KEY (userID) REFERENCES User(userID) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `Post_Image` (
    postID int NOT NULL,
    imageLocation varchar(100) NOT NULL,
    PRIMARY KEY (postID, imageLocation),
    FOREIGN KEY (postID) REFERENCES Post(postID) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `Post_Link` (
    postID int NOT NULL,
    link varchar(100) NOT NULL,
    PRIMARY KEY (postID, link),
    FOREIGN KEY (postID) REFERENCES Post(postID) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `Post_Topic` (
    postID int NOT NULL,
    topicID int NOT NULL,
    PRIMARY KEY (postID, topicID),
    FOREIGN KEY (postID) REFERENCES Post(postID) ON DELETE CASCADE,
    FOREIGN KEY (topicID) REFERENCES Topic(topicID) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `Post_Respond` (
    postID int NOT NULL,
    respondID int NOT NULL,
    PRIMARY KEY (postID, respondID),
    FOREIGN KEY (postID) REFERENCES Post(postID) ON DELETE CASCADE,
    FOREIGN KEY (respondID) REFERENCES Post(postID) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `Groups` (
    groupID int NOT NULL AUTO_INCREMENT,
    groupName varchar(100) NOT NULL,
    memberCount int(11),
    PRIMARY KEY (groupID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `Group_Member` (
    groupID int NOT NULL,
    userID int NOT NULL,
    PRIMARY KEY (groupID, userID),
    FOREIGN KEY (groupID) REFERENCES `Groups`(groupID) ON DELETE CASCADE,
    FOREIGN KEY (userID) REFERENCES User(userID) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `Read_Post` (
    postID int NOT NULL,
    userID int NOT NULL,
    PRIMARY KEY (postID, userID),
    FOREIGN KEY (postID) REFERENCES Post(postID) ON DELETE CASCADE,
    FOREIGN KEY (userID) REFERENCES User(userID) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `Simple_Respond_Type` (
    respondTypeID int NOT NULL AUTO_INCREMENT,
    respondType varchar(100) NOT NULL,
    PRIMARY KEY (respondTypeID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `Simple_Respond` (
    postID int NOT NULL,
    userID int NOT NULL,
    respondTypeID int NOT NULL,
    PRIMARY KEY (postID, userID),
    FOREIGN KEY (postID) REFERENCES Post(postID) ON DELETE CASCADE,
    FOREIGN KEY (userID) REFERENCES User(userID) ON DELETE CASCADE,
    FOREIGN KEY (respondTypeID) REFERENCES Simple_Respond_Type(respondTypeID) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
--  Records of `Gender`
-- ----------------------------
BEGIN;
INSERT INTO `Gender` (genderType) VALUES ('Female'), ('Male'), ('Agender'), ('Androgyne'), ('Androgynous'), ('Bigender'), ('Cis'), ('Cisgender'), ('Cis Female'), ('Cisgender Male'), ('Female to Male'), ('Gender Fluid'), ('Other');
COMMIT;

-- ----------------------------
--  Records of `Vocation`
-- ----------------------------
BEGIN;
INSERT INTO `Vocation` (vocationType) VALUES ('Priesthood'), ('Religious life'), ('Marriage'), ('Single life'), ('Other');
COMMIT;

-- ----------------------------
--  Records of `Religion`
-- ----------------------------
BEGIN;
INSERT INTO `Religion` (religionType) VALUES ('Christianity'), ('Islam'), ('Nonreligious'), ('Hinduism'), ('Chinese traditional religion'), ('Buddhism'), ('Primal-indigenous'), ('African traditional and Diasporic'), ('Sikhism'), ('Juche'), ('Spiritism'), ('Judaism'), ('Bahai'), ('Jainism'), ('Shinto'), ('Cao Dai'), ('Zoroastrianism'), ('Tenrikyo'), ('Neo-Paganism'), ('Unitarian-Universalism'), ('Other');
COMMIT;

-- ----------------------------
--  Records of `User`
-- ----------------------------
BEGIN;
INSERT INTO `User` (userName, firstName, middleName,lastName,genderID,vocationID,religionID,birthday) VALUES
    ('Shirley123','shirley','Ha','Lyu',1,5,1,"2000-01-30"), 
    ('Eiston456','Eiston','Ho','Wei',2,5,1,"2001-02-03"),
    ('David789','David','He','Zhang',2,3,4,"2002-05-12"),
    ('Carol000','Carol','Hu','Yun',1,3,1,"2004-04-10"),
    ('Frank123','Frank','Hi','Chen',4,2,7,"2003-06-09");
COMMIT;

-- ----------------------------
--  Records of `User_Follower`
-- ----------------------------
INSERT INTO `User_Follower` (userID, followerID) VALUES
    (1,2),(1,3),(1,4),(1,5),(2,4),(2,5),(3,5),(4,2);
COMMIT;


-- ----------------------------
--  Records of `Topic`
-- ----------------------------
INSERT INTO `Topic` (topicName) VALUES
    ('politics'),('sports'),('business'),('finance'),('news'),('Canadian politics'),('oil business'),('Toronto politics'),('Alberta oil business');
COMMIT;

-- ----------------------------
--  Records of `Sub_Topic`
-- ----------------------------
INSERT INTO `Sub_Topic` (topicID, subTopicID) VALUES
    (1,6),(1,8),(3,7),(3,9);
COMMIT;

-- ----------------------------
--  Records of `Topic_Follower`
-- ----------------------------
INSERT INTO `Topic_Follower` (topicID, userID) VALUES
    (1,1),(1,2),(3,3),(3,4),(2,5),(4,3),(9,2),(8,3);
COMMIT;

-- ----------------------------
--  Records of `Post`
-- ----------------------------
BEGIN;
INSERT INTO `Post` (userID, textContent, thumbsUpCount,thumbsDownCount,createTime) VALUES
    (1,'comes with the following data types for storing a date or a date/time value in the database',0, 0,"2000-01-31 12:12:12"), 
    (2,'Note: The date types are chosen for a column when you create a new table in your database!',0,0,"2001-02-03 11:11:11"),
    (3,'You can compare two dates easily if there is no time component involved!', 0, 0,"2002-05-12 10:10:10"),
    (4,'Now we want to select the records with an OrderDate of "2008-11-11" from the table above.',0,0,"2004-04-10 09:09:09"),
    (5,'Now, assume that the "Orders" table looks like this (notice the time component in the "OrderDate" column)',0,0,"2003-06-09 08:08:08");
COMMIT;

-- ----------------------------
--  Records of `Post_Topic`
-- ----------------------------
INSERT INTO `Post_Topic` (postID, topicID) VALUES
    (1,1),(1,2),(3,3),(3,4),(2,5),(4,3),(5,2),(5,3);
COMMIT;

-- ----------------------------
--  Records of `Post_Respond`
-- ----------------------------
INSERT INTO `Post_Respond` (postID, respondID) VALUES
    (1,4),(2,5);
COMMIT;

-- ----------------------------
--  Records of `Groups`
-- ----------------------------
INSERT INTO `Groups` (groupName, memberCount) VALUES
    ('Naruto',2),('OnePiece',3);
COMMIT;

-- ----------------------------
--  Records of `Group_Member`
-- ----------------------------
INSERT INTO `Group_Member` (groupID, userID) VALUES
    (1,1),(1,2),(2,3),(2,4),(2,5);
COMMIT;

-- ----------------------------
--  Records of `Read_Post`
-- ----------------------------


-- ----------------------------
--  Records of `Simple_Respond_Type`
-- ----------------------------
INSERT INTO `Simple_Respond_Type` (respondType) VALUES
    ('ThumbUp'),('ThumbDown');
COMMIT;

-- ----------------------------
--  Records of `Simple_Respond`
-- ----------------------------