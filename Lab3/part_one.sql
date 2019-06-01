-- session A
set transaction isolation level READ UNCOMMITTED;

BEGIN;
update Offering set Enrollment = Enrollment - 20
       where courseID="ECE356" and section=2 and termCode=1191;


-- session B
set transaction isolation level READ UNCOMMITTED;

select * from Offering where courseID="ECE356" and section=2 and termCode=1191;