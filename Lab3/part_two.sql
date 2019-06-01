DELIMITER $$
DROP PROCEDURE IF EXISTS `switchSection`;
CREATE PROCEDURE `switchSection`(
                            IN courseID char(8), 
                            IN section1 int(11),
                            IN section2 int(11),
                            IN termCode decimal(4,0),
                            IN quantity int(11),
                            OUT errorCode INT)
    BEGIN
        START TRANSACTION;
            SET errorCode = 0;

            SELECT "Validate input paramenter" AS "Step 1";

            IF NOT EXISTS (SELECT * FROM Offering WHERE Offering.courseID = courseID AND Offering.section = section1 AND Offering.termCode = termCode) THEN
                SET errorCode = -1;
            ELSEIF NOT EXISTS (SELECT * FROM Offering WHERE Offering.courseID = courseID AND Offering.section = section2 AND Offering.termCode = termCode) THEN
                SET errorCode = -1;
            ELSEIF section1 = section2 THEN
                SET errorCode = -1;
            ELSE
                SELECT "Attempt to switch section" AS "Step 2";
                UPDATE Offering SET Enrollment = Enrollment - quantity WHERE Offering.courseID = courseID AND Offering.section = section1 AND Offering.termCode = termCode;
                UPDATE Offering SET Enrollment = Enrollment + quantity WHERE Offering.courseID = courseID AND Offering.section = section2 AND Offering.termCode = termCode;

                SELECT @section1_enrollment := Enrollment FROM Offering WHERE Offering.courseID = courseID AND Offering.section = section1 AND Offering.termCode = termCode;
                SELECT @section2_enrollment := Enrollment FROM Offering WHERE Offering.courseID = courseID AND Offering.section = section2 AND Offering.termCode = termCode;
                SELECT @section2_room_capacity := Capacity FROM Offering INNER JOIN Classroom USING (roomID) WHERE Offering.courseID = courseID AND Offering.section = section2 AND Offering.termCode = termCode;

                SELECT "Validate section switching result" AS "Step 3";
                IF @section1_enrollment < 0 THEN
                    SET errorCode = -2;
                ELSEIF @section2_enrollment > @section2_room_capacity THEN
                    SET errorCode = -3;
                END IF;
            END IF;

            IF errorCode = 0 THEN
                COMMIT;
                SELECT 'Successfully switch section' AS 'Completed switch section'; 
            ELSE
                ROLLBACK;
                SELECT 'Fail to switch section. Rollbacked!!!' AS 'Failed switch section'; 
            END IF;
    END $$
DELIMITER ;


-- Test case 1 : courseID not found => errorCode = -1
SELECT "courseID not found => errorCode = -1" AS "Test case 1";
SET @courseID = "N/A"; -- Not found course ID
SET @section1 = 1;
SET @section2 = 2;
SET @termCode = 1191;
SET @quantity = 20;
SET @errorCode = 0;

CALL switchSection(
    @courseID,
    @section1,
    @section2,
    @termCode,
    @quantity,
    @errorCode);

SELECT @errorCode AS errorCode; -- errorCode should be -1



-- Test case 2 : section number not found => errorCode = -1
SELECT "section number not found => errorCode = -1" AS "Test case 2";
SET @courseID = "ECE390";
SET @section1 = 3; -- Not found section #
SET @section2 = 2;
SET @termCode = 1191;
SET @quantity = 20;
SET @errorCode = 0;

CALL switchSection(
    @courseID,
    @section1,
    @section2,
    @termCode,
    @quantity,
    @errorCode);

SELECT @errorCode AS errorCode; -- errorCode should be -1



-- Test case 3 : termCode not found => errorCode = -1
SELECT "termCode not found => errorCode = -1" AS "Test case 3";
SET @courseID = "ECE390";
SET @section1 = 1;
SET @section2 = 2;
SET @termCode = 0000; -- Not found section #
SET @quantity = 20;
SET @errorCode = 0;

CALL switchSection(
    @courseID,
    @section1,
    @section2,
    @termCode,
    @quantity,
    @errorCode);

SELECT @errorCode AS errorCode; -- errorCode should be -1



-- Test case 4: section1 = section2 => errorCode = -1
SELECT "section1 = section2 => errorCode = -1" AS "Test case 4";
SET @courseID = "ECE390";
SET @section1 = 1;
SET @section2 = 1; -- same section number as section 1
SET @termCode = 1191;
SET @quantity = 20;
SET @errorCode = 0;

CALL switchSection(
    @courseID,
    @section1,
    @section2,
    @termCode,
    @quantity,
    @errorCode);

SELECT @errorCode AS errorCode; -- errorCode should be -1



-- Test case 5: negative enrollment in section 1 => errorCode = -2
SELECT "negative enrollment in section 1 => errorCode = -2" AS "Test case 5";
SET @courseID = "ECE356";
SET @section1 = 1;
SET @section2 = 2;
SET @termCode = 1191;
SET @quantity = 1000;
SET @errorCode = 0;

CALL switchSection(
    @courseID,
    @section1,
    @section2,
    @termCode,
    @quantity,
    @errorCode);

SELECT @errorCode AS errorCode; -- errorcode should be -2

-- Enrollment should not change since the rollback
SELECT Enrollment AS section1_enrollment FROM Offering WHERE Offering.courseID = @courseID AND Offering.section = @section1 AND Offering.termCode = @termCode;
SELECT Enrollment AS section2_enrollment FROM Offering WHERE Offering.courseID = @courseID AND Offering.section = @section2 AND Offering.termCode = @termCode;



-- Test case 6: enrollment in section 2 exceeds room capacity => errorCode = -3
SELECT "enrollment in section 2 exceeds room capacity => errorCode = -3" AS "Test case 6";
SET @courseID = "ECE356";
SET @section1 = 1;
SET @section2 = 2;
SET @termCode = 1191;
SET @quantity = 60;
SET @errorCode = 0;

CALL switchSection(
    @courseID,
    @section1,
    @section2,
    @termCode,
    @quantity,
    @errorCode);

SELECT @errorCode AS errorCode; -- errorcode should be -3

-- Enrollment should not change since the rollback
SELECT Enrollment AS section1_enrollment FROM Offering WHERE Offering.courseID = @courseID AND Offering.section = @section1 AND Offering.termCode = @termCode;
SELECT Enrollment AS section2_enrollment FROM Offering WHERE Offering.courseID = @courseID AND Offering.section = @section2 AND Offering.termCode = @termCode;



-- Test case 7: Successfully switch section
SELECT "Successfully switch section" AS "Test case 7";
SET @courseID = "ECE356";
SET @section1 = 1;
SET @section2 = 2;
SET @termCode = 1191;
SET @quantity = 10;
SET @errorCode = 0;

CALL switchSection(
    @courseID,
    @section1,
    @section2,
    @termCode,
    @quantity,
    @errorCode);

SELECT @errorCode AS errorCode; -- errocode should be 0

-- Enrollment should be updated.
SELECT Enrollment AS section1_enrollment FROM Offering WHERE Offering.courseID = @courseID AND Offering.section = @section1 AND Offering.termCode = @termCode;
SELECT Enrollment AS section2_enrollment FROM Offering WHERE Offering.courseID = @courseID AND Offering.section = @section2 AND Offering.termCode = @termCode;
