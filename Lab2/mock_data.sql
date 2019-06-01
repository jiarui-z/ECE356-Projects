-- Insert some data for fun
-- But the inserting order is not fun...
insert into PostalCode(postalCode, city, province) values (1, "Waterloo", "Ontario"), (2, "Toronto", "Ontario");
insert into Employee(empID, salary)values (1, 1000), (2, 2000), (3, 3000), (4, 4000);
insert into Department(deptID, deptName) values (1, "ECE"), (2, "CS");
insert into EmployeeDepartment(empID, deptID) values (1, 1), (2, 1), (3, 2), (4, 2);
insert into DepartmentLocation(deptID, postalCode) values (1, 1), (2, 2);