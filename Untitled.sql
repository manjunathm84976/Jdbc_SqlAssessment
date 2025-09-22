create table Student(
Student_id serial primary key,
First_name varchar,
Last_name varchar,
Gender CHAR(1) CHECK (Gender IN ('M','F')),
DOB date,
Email varchar unique,
Phone numeric,
Address varchar
);

insert into Student(First_name,Last_name,Gender,DOB,Email,Phone,Address)
values('Ashik','Achar','M','2003-08-18','ashik@gmail.com',9108077971,'Udupi'),
('Deepa','S','F','2001-09-16','deepa@gmail.com',1234567889,'Bengaluru'),
('Deepak','KC','M','2001-03-09','deepak@gmail.com',1234567789,'Kanakpura'),
('Akash','A','M','2001-03-19','akash@gmail.com',1234566789,'Bengaluru'),
('Chethu','D','F','2001-06-09','chethu@gmail.com',1234557789,'Tumakuru')
select * from Student

create table Course(
Course_id serial primary key,
CourseName varchar,
Credits numeric,
Department varchar
);

insert into Course(CourseName,Credits,Department)
values('Python',8.0,'CSE'),('Aiml',7.2,'AI'),('Sql',8.5,'CSE')
select * from Course

create table Professor(
ProfId serial primary key,
ProfName varchar,
Email varchar unique,
Department varchar
);
insert into Professor(ProfName,Email,Department)
values('Dr.Mehta','mehta@gmail.com','CSE'),
('Dr.Sowmya','sowmya@gmail.com','CSE'),
('Dr.Karunakar','karuna@gmail.com','AI'),
('Dr.Majnu','majnu@gmail.com','CSE')

select * from Professor

create table Enrollment(
EnrollId serial PRIMARY KEY,
Student_id integer,
Course_id integer,
ProfID integer,
EnrollmentDate DATE,
Grade varchar,
FOREIGN KEY (Student_id) REFERENCES Student(Student_id),
FOREIGN KEY (Course_id) REFERENCES Course(Course_id),
FOREIGN KEY (ProfID) REFERENCES Professor(ProfID)
);
insert into Enrollment(Student_id,Course_id,ProfID,EnrollmentDate,Grade)
values(2,2,1,'2025-07-16','B'),
(3,2,2,'2025-05-26','B'),
(4,3,3,'2025-09-22','A')

select * from Enrollment

-- 1
SELECT distinct p.ProfName
FROM Professor p
JOIN Enrollment e ON p.ProfID = e.ProfID
JOIN Course c ON e.Course_id = c.Course_id
WHERE c.Department = 'CSE';

-- 2
SELECT s.First_name, c.CourseName, e.Grade
FROM Enrollment e
JOIN Student s ON e.Student_id = s.Student_id
JOIN Course c ON e.Course_id = c.Course_id
WHERE e.Grade = (
    SELECT MAX(e2.Grade)
    FROM Enrollment e2
    WHERE e2.Course_id = e.Course_id
);

-- 3
SELECT s.First_name, s.Last_name, COUNT(e.EnrollID) AS TotalEnrollments
FROM Student s
JOIN Enrollment e ON s.Student_id = e.Student_id
GROUP BY s.Student_id, s.First_name, s.Last_name
HAVING COUNT(e.EnrollID) = (
    SELECT MAX(cnt)
    FROM (
        SELECT COUNT(*) AS cnt
        FROM Enrollment
        GROUP BY Student_id
    ) sub
);

-- 4
SELECT p.ProfName, COUNT(DISTINCT e.Student_id) AS TotalStudents
FROM Professor p
JOIN Enrollment e ON p.ProfID = e.ProfID
GROUP BY p.ProfID, p.ProfName
HAVING COUNT(DISTINCT e.Student_id) = (
    SELECT MAX(stu_count)
    FROM (
        SELECT COUNT(DISTINCT Student_id) AS stu_count
        FROM Enrollment
        GROUP BY ProfID
    ) sub
);

-- 5
SELECT s.First_name, s.Last_name
FROM Student s
WHERE NOT EXISTS (
    SELECT c.Course_id
    FROM Course c
    JOIN Enrollment e1 ON c.Course_id = e1.Course_id
    JOIN Professor p ON e1.ProfID = p.ProfID
    WHERE p.ProfName = 'Dr. Mehta'
    EXCEPT
    SELECT e2.Course_id
    FROM Enrollment e2
    WHERE e2.Student_id = s.Student_id
);

-- 6
SELECT s.First_name, s.Last_name, e.Grade
FROM Student s
JOIN Enrollment e ON s.Student_id = e.Student_id
JOIN Course c ON e.Course_id = c.Course_id
WHERE c.CourseName = 'Sql'
  AND e.Grade > (
      SELECT AVG(e.Grade)
      FROM Enrollment e2
      JOIN Course c2 ON e2.Course_id = c2.Course_id
      WHERE c2.CourseName = 'Sql'
  );
-- 7
SELECT s.First_name, s.Last_name, SUM(c.Credits) AS TotalCredits
FROM Student s
JOIN Enrollment e ON s.Student_id = e.Student_id
JOIN Course c ON e.Course_id = c.Course_id
GROUP BY s.Student_id, s.First_name, s.Last_name;

-- 8
SELECT s.First_name, s.Last_name, c.CourseName, p.ProfName, e.Grade
FROM Enrollment e
JOIN Student s ON e.Student_id = s.Student_id
JOIN Course c ON e.Course_id = c.Course_id
JOIN Professor p ON e.ProfID = p.ProfID;

-- 9
SELECT p.ProfName, COUNT(c.Course_id) AS TotalCourses
FROM Professor p
JOIN Enrollment e ON p.ProfID = e.ProfID
JOIN Course c ON e.Course_id = c.Course_id
GROUP BY p.ProfID, p.ProfName
HAVING COUNT(c.Course_id) > 1;

-- 10
SELECT s.First_name, s.Last_name, COUNT(DISTINCT c.Department) AS DeptCount
FROM Student s
JOIN Enrollment e ON s.Student_id = e.Student_id
JOIN Course c ON e.Course_id = c.Course_id
GROUP BY s.Student_id, s.First_name, s.Last_name
HAVING COUNT(DISTINCT c.Department) > 1;

