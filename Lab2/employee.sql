/* 
    Database Cleanup 
*/
DROP DATABASE IF EXISTS db356_z498zhan;
CREATE DATABASE db356_z498zhan;
USE db356_z498zhan;

/* 
    Question 4: 
        write the necessary SQL to create tables for this database, together with the necessary primary and foreign keys
*/
CREATE TABLE Employee(
    empID INT(11),
    firstName VARCHAR(100),
    lastName VARCHAR(100),
    job VARCHAR(100),
    salary INT(11),
    PRIMARY KEY (empID)
);

CREATE TABLE MiddleName(
    empID INT(11),
    middleName VARCHAR(100),
    PRIMARY KEY (empID)
);

CREATE TABLE Project(
    projID INT(11),
    title VARCHAR(100),
    budget INT(11),
    funds INT(11),
    PRIMARY KEY (projID)
);

CREATE TABLE Assigned(
    empID INT(11),
    projID INT(11),
    role VARCHAR(100),
    PRIMARY KEY (empID, projID, role),
    FOREIGN KEY (empID) REFERENCES Employee(empID),
    FOREIGN KEY (projID) REFERENCES Project(projID)
);

CREATE TABLE Department(
    deptID INT(11),
    deptName VARCHAR(100),
    PRIMARY KEY (deptID)
);

CREATE TABLE EmployeeDepartment(
    empID INT(11),
    deptID INT(11),
    PRIMARY KEY (empID, deptID),
    FOREIGN KEY (empID) REFERENCES Employee(empID),
    FOREIGN KEY (deptID) REFERENCES Department(deptID)
);

CREATE TABLE PostalCode(
    postalCode VARCHAR(100),
    city VARCHAR(100),
    province VARCHAR(100),
    PRIMARY KEY (postalCode)
);

CREATE TABLE DepartmentLocation(
    deptID INT(11),
    streetNumber VARCHAR(100),
    streetName VARCHAR(100),
    postalCode VARCHAR(100),
    PRIMARY KEY (deptID, streetNumber, streetName, postalCode),
    FOREIGN KEY (deptID) REFERENCES Department(deptID),
    FOREIGN KEY (postalCode) REFERENCES PostalCode(postalCode)
);

/* 
    Question 5: 
        if you decomposition has resulted in the loss of any of the above four tables, write the necessary SQL to create a view that correspond to that table 
        (note: in the case of the empName and department location you should use “concat” to create a single attribute from the atomic components)
*/
DROP VIEW IF EXISTS EmployeeView;
CREATE VIEW EmployeeView AS
    SELECT empID,
        CONCAT_WS(" ", firstName, middleName, lastName) AS empName,
        job,
        deptID,
        salary
    FROM Employee
        LEFT JOIN MiddleName USING (empID)
        INNER JOIN EmployeeDepartment USING (empID);

DROP VIEW IF EXISTS DepartmentView;
CREATE VIEW DepartmentView AS
    SELECT deptID,
        deptName,
        CONCAT_WS(" ", streetNumber, streetName, city, province, postalCode) AS location
    FROM Department
        INNER JOIN DepartmentLocation USING (deptID)
        INNER JOIN PostalCode USING (postalCode);


/* 
    Question 6: 
        A stored procedure “payRaise” that takes two input parameters “inEmpID” (Int) and “inPercentageRaise” (double 4,2) and one output parameter “errorCode” (int). 
        In normal operation the procedure should raise the salary of the associated employee by the input percentage and return an errorCode of 0. 
        However, if the payRaise is by more than 10% or less than 0% (i.e., it is a pay cut), it should return -1. 
        If the employee does not exist, it should return an errorCode of -2. 
        You should create the necessary query to increase the salary of all employees at the Waterloo location by 5%.
*/
DELIMITER $$
DROP PROCEDURE IF EXISTS `payRaise`;
CREATE PROCEDURE `payRaise` (IN inEmpID INT, IN inPercentageRaise DOUBLE(4, 2), OUT errorCode INT)
BEGIN
    IF inPercentageRaise > 0.10 OR inPercentageRaise < 0.00 THEN
        SET errorCode = -1;
    ELSEIF NOT EXISTS (SELECT * FROM Employee WHERE empID = inEmpID) THEN
        SET errorCode = -2;
    ELSE
        UPDATE Employee SET salary = salary * (1 + inPercentageRaise) WHERE empID = inEmpID;
        SET errorCode = 0;
    END IF;
END $$
DELIMITER ;

DELIMITER $$
DROP PROCEDURE IF EXISTS `raise_employee_pay_per_city`;
CREATE PROCEDURE `raise_employee_pay_per_city` (IN inPercentageRaise DOUBLE(4, 2), IN cityName VARCHAR(100))
BEGIN
    DECLARE finished BOOL DEFAULT FALSE;
    DECLARE employeeID INT(11);
    DECLARE errorCode INT(11) DEFAULT 0;

    DECLARE tableCursor CURSOR FOR 
        SELECT DISTINCT empID
        FROM Employee 
            INNER JOIN EmployeeDepartment using (empID)
            INNER JOIN DepartmentLocation using (deptID)
            INNER JOIN PostalCode using (postalCode)
        WHERE city = "Waterloo";
        
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = TRUE;
    
    OPEN tableCursor;

    MainLoop: LOOP
        FETCH tableCursor INTO employeeID;
        IF finished THEN
            LEAVE MainLoop;
        END IF;

        CALL payRaise(employeeID, inPercentageRaise, errorCode);

        IF errorCode = -1 THEN
	        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Invalid Percentage Raise.", MYSQL_ERRNO = 45000;
        END IF;

        IF errorCode = -2 THEN
	        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Employee does not exist.", MYSQL_ERRNO = 45000;
        END IF;
    END LOOP;
    
    CLOSE tableCursor;
END $$
DELIMITER ;

CALL raise_employee_pay_per_city(0.05, "Waterloo");
