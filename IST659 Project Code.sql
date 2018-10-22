-- IST659 DATA ADMINISTRATION CONCEPTS AND DATABASE MANAGEMENT
-- FINAL PROJECT CODE
-- Summer 17
-- David Forteguerre




-- IMPORTANT:
-- Please note that all the student data that was in the original project was removed from this code due to confidentiality issues.




-- TO DROP EXISTING TABLES
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Student')
BEGIN
	DROP TABLE Student
END
GO
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Languages')
BEGIN
	DROP TABLE Languages
END
GO
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Course')
BEGIN
	DROP TABLE Course
END
GO
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Student_Course')
BEGIN
	DROP TABLE Student_Course
END
GO
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Student_Languages')
BEGIN
	DROP TABLE Student_Languages
END
GO
GO

-- TABLE CREATION: STUDENT
CREATE TABLE Student (
	SUID char(9) primary key,
	SUemail varchar(30) NOT NULL,
	FirstName varchar(30) NOT NULL,
	LastName varchar(30) NOT NULL,
	StudentYear varchar(30) NOT NULL,
	Program varchar(60) NOT NULL,
	City varchar(30),
	StateProvince varchar(30),
	Country varchar(30) NOT NULL,
	Age tinyint ,
	Disability bit DEFAULT '0' NOT NULL,
	ReligiousObservance bit DEFAULT '0' NOT NULL
	) ;

-- TABLE CREATION: LANGUAGES
CREATE TABLE Languages (
	LanguageID int identity primary key,
	LanguageName varchar(30) NOT NULL,
	) ;

-- TABLE CREATION: COURSE
CREATE TABLE Course (
	CourseID char(6) primary key,
	CourseName char(6) NOT NULL,
	SectionNumber char(4) NOT NULL,
	Credits char(1) NOT NULL,
	EnrollmentTotal tinyint NOT NULL,
	Semester varchar(10) NOT NULL,
	TimeMoWe varchar(30),
	TimeTuTh varchar(30),
	LocationMoWe varchar(30),
	LocationTuTh varchar(30),
	TextbookName varchar(30) NOT NULL,
	TextbookPublisher varchar(30) NOT NULL,
	CoordinatorLastName varchar(30) NOT NULL,
	CoordinatorSUemail varchar(30) NOT NULL
	) ;

-- TABLE CREATION: STUDENT_COURSE
CREATE TABLE Student_Course (
	Course_CourseID char(6) FOREIGN KEY REFERENCES Course(CourseID),
	Student_SUID char(9) FOREIGN KEY REFERENCES Student(SUID),
	Requirement bit NOT NULL,
	CourseFailure bit DEFAULT '0' NOT NULL,
	NoUnexcusedAbsences tinyint NOT NULL,
	NoUnexcusedTardiness tinyint NOT NULL,
	FinalGrade varchar(2) NOT NULL,
	OverallGrade decimal(12,4),
	AttendanceParticipation decimal(12,4),
	OnlineHomework decimal(12,4),
	Redaction_Essays decimal(12,4),
	Controle_Exams decimal(12,4),
	Interro_Quizzes decimal(12,4),
	OralAssessments decimal(12,4),
	FinalExam decimal(12,4),
	Presentation1 decimal(12,4),
	Presentation2 decimal(12,4),
	CONSTRAINT PK_Student_Course PRIMARY KEY (Course_CourseID, Student_SUID)
	) ;

-- TABLE CREATION: STUDENT_LANGUAGES
CREATE TABLE Student_Languages (
	Student_SUID char(9) FOREIGN KEY REFERENCES Student(SUID),
	Languages_LanguageID int FOREIGN KEY REFERENCES Languages(LanguageID),
	NativeLanguage bit NOT NULL,
	CONSTRAINT PK_Student_Languages PRIMARY KEY (Student_SUID, Languages_LanguageID)
	) ;



	-- VIEW Creation: Return basic teacher stats
	IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'TeacherStatsView')
	BEGIN
		DROP VIEW TeacherStatsView
	END
	GO

	CREATE VIEW TeacherStatsView AS
	SELECT
	COUNT (CourseID) AS 'Total Number of Courses Taught',
	(SUM(Course.EnrollmentTotal)) AS 'Total Number of Students'
	FROM Course
	GO
	-- Test
	SELECT * FROM TeacherStatsView
	GO


	-- VIEW Creation: Roster for a specific course. Here, view creation for FRE201 taught in Fall16
	IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'RosterFRE201Fall16View')
	BEGIN
		DROP VIEW RosterFRE201Fall16View
	END
	GO

	CREATE VIEW RosterFRE201Fall16View AS
	SELECT
	Student.SUID, Student.FirstName, Student.LastName, Student.SUemail, Student.StudentYear, Student.Program, Student.Country, Student.Disability, Student.ReligiousObservance
	FROM Student
	JOIN Student_Course ON Student_Course.Student_SUID = Student.SUID
	JOIN Course ON Course.CourseID = Student_Course.Course_CourseID
	WHERE Course.CourseName = 'FRE201' AND Course.Semester = 'Fall16'
	GO
	-- Test:
	SELECT * FROM RosterFRE201Fall16View
	GO
	-- Note that this view only returns one student as we only entered one student in the STUDENT_COURSE table as an example.


	-- VIEW Creation: Return the number of languages students speak
	IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'StudentLanguagesView')
	BEGIN
		DROP VIEW StudentLanguagesView
	END
	GO

	CREATE VIEW StudentLanguagesView AS
	SELECT
	Student.SUID, Student.FirstName, Student.LastName, Student.Country,
	COUNT(Languages.LanguageName) AS "Number of languages spoken"
	FROM Student
	JOIN Student_Languages ON Student_Languages.Student_SUID = Student.SUID
	JOIN Languages ON Languages.LanguageID = Student_Languages.Languages_LanguageID
	GROUP BY Student.SUID, Student.FirstName, Student.LastName, Student.Country
	GO
	-- Test:
	SELECT * FROM StudentLanguagesView
	GO


	-- VIEW Creation: Return the number of courses students took
	IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'StudentCoursesView')
	BEGIN
		DROP VIEW StudentCoursesView
	END
	GO

	CREATE VIEW StudentCoursesView AS
	SELECT
	Student.SUID, Student.FirstName, Student.LastName, Student.Country,
	COUNT(Course.CourseID) AS "Number of courses taken"
	FROM Student
	JOIN Student_Course ON Student_Course.Student_SUID = Student.SUID
	JOIN Course ON Course.CourseID = Student_Course.Course_CourseID
	GROUP BY Student.SUID, Student.FirstName, Student.LastName, Student.Country
	GO
	-- Test:
	SELECT * FROM StudentCoursesView
	GO



	-- FUNCTION Creation: Return a student's First Name and Last Name thanks to SUID:
	IF OBJECT_ID (N'dbo.StudentLookUp', N'FN') IS NOT NULL
	DROP FUNCTION dbo.StudentLookUp ;
	GO

	CREATE FUNCTION dbo.StudentLookUp (@SUID char(9))
	RETURNS varchar(30)
	AS
	BEGIN
		RETURN (
		SELECT Student.FirstName + ' ' + Student.LastName
		FROM Student
		WHERE Student.SUID = @SUID
		)
	END
	GO
	-- Test (Adam YYYYY, SUID XXXXXXXXX)
	SELECT dbo.StudentLookUp(XXXXXXXXX) AS "Student Name"
	GO
	-- Test (Kyle YYYYY, SUID XXXXXXXXX)
	SELECT dbo.StudentLookUp(XXXXXXXXX) AS "Student Name"
	GO


	-- FUNCTION Creation: Return a student's SUID thanks to their first and last names
	IF OBJECT_ID (N'dbo.StudentSUID', N'FN') IS NOT NULL
	DROP FUNCTION dbo.StudentSUID ;
	GO

	CREATE FUNCTION dbo.StudentSUID (@FirstName varchar(30), @LastName varchar(30))
	RETURNS char(9)
	AS
	BEGIN
		RETURN (
		SELECT Student.SUID
		FROM Student
		WHERE Student.FirstName = @FirstName AND Student.LastName = @LastName
		)
	END
	GO
	-- Test (Adam YYYYY, SUID XXXXXXXXX)
	SELECT dbo.StudentSUID('Adam', 'YYYYY') AS "Student SUID"
	GO
	-- Test (Kyle YYYYY, SUID XXXXXXXXX)
	SELECT dbo.StudentSUID('Kyle', 'YYYYY') AS "Student SUID"
	GO




	-- FUNCTION Creation: Return a CourseID for a specific course.
	IF OBJECT_ID (N'dbo.CourseID', N'FN') IS NOT NULL
	DROP FUNCTION dbo.CourseID ;
	GO

	CREATE FUNCTION dbo.CourseID (@CourseName char(6), @Semester varchar(10))
	--Note that those two local variables are enough to return a specific course ID, since as stated in this project introduction (see first page), I only teach one course level per semester. I cannot teach two sections of the same course each semester. Therefore, those two variables are enough to retrieve the info of one single course.
	RETURNS char(6)
	AS
	BEGIN
		RETURN (
		SELECT Course.CourseID
		FROM Course
		WHERE Course.CourseName = @CourseName AND Course.Semester = @Semester
		)
	END
	GO
	-- Test (FRE101, Fall17, CourseID 005681)
	SELECT dbo.CourseID('FRE101', 'Fall17') AS "Course ID"
	GO
	-- Test (FRE201, Fall16, CourseID 005687)
	SELECT dbo.CourseID('FRE201', 'Fall16') AS "Course ID"
	GO




	-- DATA ENTRY

	-- STUDENT table:
	INSERT INTO Student(SUID, SUemail, FirstName, LastName, StudentYear, Program, Country)
	VALUES
	('XXXXXXXXX', 'YYYYY@syr.edu', 'Amie', 'YYYYY', 'Freshman', 'VPA-Music - Recording & Allied Ent. Indust', 'USA'),
	('XXXXXXXXX', 'YYYYY@syr.edu', 'Adam', 'YYYYY', 'Sophomore', 'Arts and Sciences - Forensic Science-U', 'USA'),
	('XXXXXXXXX', 'YYYYY@syr.edu', 'Kyle', 'YYYYY', 'Sophomore', 'Public Communications - Advertising', 'USA'),
	('XXXXXXXXX', 'YYYYY@syr.edu', 'Rachel', 'YYYYY', 'Freshman', 'Arts and Sciences - Psychology-U', 'USA'),
	('XXXXXXXXX', 'YYYYY@syr.edu', 'Zoe', 'YYYYY', 'Junior', 'Public Communications - Newspaper & Online Journalism', 'Australia'),
	('XXXXXXXXX', 'YYYYY@syr.edu', 'Daniel', 'YYYYY', 'Sophomore', 'Public Communications - Television, Radio and Film', 'Panama'),
	('XXXXXXXXX', 'YYYYY@syr.edu', 'Natalie', 'YYYYY', 'Senior', 'Public Communications - Television, Radio and Film', 'USA'),
	('XXXXXXXXX', 'YYYYY@syr.edu', 'Nora', 'YYYYY', 'Freshman', 'Arts and Sciences - Arts and Sciences (Undeclared)', 'USA')
	GO
	-- Note that the STUDENT table has two attributes that have DEFAULT values (Disability and ReligiousObservance have DEFAULT "0"; they have a binary datatype.)
	-- Adding a student to the database without specifying anything else for those attributes will automatically insert 0 in the right fields.
	-- You will be able to check that this is true at the end of this code in my USEFUL COMMANDS section (SELECT * FROM Student).
	-- We see that the two columns "Disability" and "ReligiousObservance" have 0 values.
	-- That is perfectly fine, since the type of information they target usually comes to us, instructors, a few days/weeks into the semester.
	-- Thus, the best way to modify those values (if need be) would be to update the student's data. See the "Data Manipulation" section for more info.
	GO

	-- COURSE table:
			-- For 101,102,201,202 courses only
	INSERT INTO Course(CourseID, CourseName, SectionNumber, Credits, EnrollmentTotal, Semester, TimeMoWe, TimeTuTh, LocationMoWe, LocationTuTh, TextbookName, TextbookPublisher, CoordinatorLastName, CoordinatorSUemail)
	VALUES
	('005681', 'FRE101', 'M001', '4', '19', 'Fall17', '12:45PM - 1:40PM', '12:30PM - 1:25PM', 'Link Hall 200', 'Marshall Square Mall 205C', 'Portails', 'VHL', 'YYYYY', 'YYYYY@syr.edu'),
	('005687', 'FRE201', 'M005', '4', '16', 'Fall16', '10:35AM - 11:30AM', '11:00AM - 12:20PM', 'Maxwell Hall 108', 'CH001', 'Imaginez', 'VHL', 'YYYYY', 'YYYYY@syr.edu')
			-- For 210 course only
	INSERT INTO Course(CourseID, CourseName, SectionNumber, Credits, EnrollmentTotal, Semester, TimeTuTh, LocationTuTh, TextbookName, TextbookPublisher, CoordinatorLastName, CoordinatorSUemail)
	VALUES
	('005689', 'FRE210', 'M005', '1', '7', 'Spring17', '11:00AM - 12:20PM', 'HB CROUSE 200 located on quad', 'No textbook', 'No textbook', 'YYYYY', 'YYYYY@syr.edu')
	GO

	-- LANGUAGES table:
	INSERT INTO Languages(LanguageName)
	VALUES
	('English'),
	('Spanish'),
	('Italian'),
	('Russian')
	GO

	-- STUDENT_COURSE table:
	INSERT INTO Student_Course(Course_CourseID, Student_SUID, Requirement, NoUnexcusedAbsences, NoUnexcusedTardiness, FinalGrade)
	VALUES('005687', 'XXXXXXXXX', '1', '1', '0', 'B+')
	GO
	-- I will only insert data for one student in this example, just to show the code.
	-- This step is very time-consuming, and I would rather use Microsoft Access to do it in the future.

	-- STUDENT_LANGUAGES
			-- Note that I am inserting data in a more complicated way down below with the SELECT statements inside the VALUES. It is more "human-friendly"
			-- as it does not involve any ID retrieval. However, it is always possible to enter the data after looking up the two ID's needed.
			-- An easier option is
	INSERT INTO Student_Languages(Student_SUID, Languages_LanguageID, NativeLanguage)
	VALUES
	((SELECT SUID FROM Student WHERE LastName = 'YYYYY'), (SELECT LanguageID FROM Languages WHERE LanguageName = 'Spanish'), '1'), -- Native Spanish speaker here
	((SELECT SUID FROM Student WHERE LastName = 'YYYYY'), (SELECT LanguageID FROM Languages WHERE LanguageName = 'English'), '0'),
	((SELECT SUID FROM Student WHERE LastName = 'YYYYY'), (SELECT LanguageID FROM Languages WHERE LanguageName = 'English'), '1'),
	((SELECT SUID FROM Student WHERE LastName = 'YYYYY'), (SELECT LanguageID FROM Languages WHERE LanguageName = 'Russian'), '0'),
	((SELECT SUID FROM Student WHERE LastName = 'YYYYY'), (SELECT LanguageID FROM Languages WHERE LanguageName = 'Italian'), '0'),
	((SELECT SUID FROM Student WHERE LastName = 'YYYYY'), (SELECT LanguageID FROM Languages WHERE LanguageName = 'English'), '1')
	GO
	-- Again, those are just a few representative examples.



	-- USEFUL COMMANDS TO TEST DATABASE
		-- View data
	SELECT * FROM Student
	SELECT * FROM Course
	SELECT * FROM Languages
	SELECT * FROM Student_Course
	SELECT * FROM Student_Languages
		-- Delete data (please disregard this)
	-- DELETE FROM Student_Course -- WHERE SUID='XYZ'
	-- DELETE FROM Student_Languages -- WHERE SUID='XYZ'
	-- DELETE FROM Languages -- WHERE SUID='XYZ'
	-- DELETE FROM Course -- WHERE SUID='XYZ'
	-- DELETE FROM Student -- WHERE SUID='XYZ'




	-- UPDATES (examples)
	-- We are now a few weeks into the semester, and students filled out their Personal Informatin Form.
	-- It is now time to update the STUDENT table. Please note that the data inserted below is fictitious.
	UPDATE Student SET ReligiousObservance = 1 WHERE Student.LastName = 'YYYYY'
	UPDATE Student SET ReligiousObservance = 1 WHERE Student.LastName = 'YYYYY'
	UPDATE Student SET Country = 'Ecuador' WHERE Student.LastName = 'YYYYY'  --After realizing I didn't enter the right country for this student
	UPDATE Student SET FirstName = 'Amy'  WHERE Student.LastName = 'YYYYY' --After realizing I mispelt her first name in the database
	UPDATE Student SET City = 'Melbourne', StateProvince = 'Victoria', Age = '20' WHERE Student.LastName = 'YYYYY' --After reading her personal information form
	GO


	-- DELETIONS (examples)
	-- One of my students decided to withdraw from the course at the last minute. Let's delete her from the database.
	DELETE FROM Student WHERE Student.LastName = 'YYYYY'
	-- One of the languages we recently added to the database isn't actually spoken by any of the students. Let's delete 'Bulgarian' from the database.
	DELETE FROM Languages WHERE Languages.LanguageName = 'Bulgarian'
	GO



-- ANSWERING QUESTIONS

	-- 1. What is the personal information of a student enrolled in a given course?
	-- Let's retrieve the information of Nora YYYYY who took FRE201.
	SELECT
	Student.*
	FROM Student
	JOIN Student_Course ON Student_Course.Student_SUID = Student.SUID
	JOIN Course ON Course.CourseID = Student_Course.Course_CourseID
	WHERE LastName = 'YYYYY' and Course.CourseName = 'FRE201'
	GO
	-- ANSWER: This student's SUID is XXXXXXXXX, her SUemail is YYYYY@syr.edu, her first name is Nora, she is in Arts and Science, and she's from the USA. She had a religious observance in the course.


	-- 2. What official grade did a specific student earn in a given course?
	-- Let's retrieve the grade Nora earned when she took FRE201.
	SELECT
	Student_Course.FinalGrade
	FROM Student_Course
	JOIN Student ON Student_Course.Student_SUID = Student.SUID
	JOIN Course ON Course.CourseID = Student_Course.Course_CourseID
	WHERE LastName = 'YYYYY' and Course.CourseName = 'FRE201'
	GO
	-- ANSWER: Nora earned a B+ when she took my FRE201 class.


	-- 3. When did a student take a given course?
	-- Let's retrieve the semester when Nora took FRE201.
	SELECT
	Course.Semester
	FROM Course
	JOIN Student_Course ON Course.CourseID = Student_Course.Course_CourseID
	JOIN Student ON Student_Course.Student_SUID = Student.SUID
	WHERE LastName = 'YYYYY' and Course.CourseName = 'FRE201'
	GO
	-- ANSWER: Nora took FRE201 in the Fall of 2016.


	-- 4. How was a given student’s attendance?
	-- Let's retrieve Nora's attendance information.
	SELECT
	Student_Course.NoUnexcusedAbsences,
	Student_Course.NoUnexcusedTardiness
	FROM Student_Course
	JOIN Student ON Student_Course.Student_SUID = Student.SUID
	JOIN Course ON Course.CourseID = Student_Course.Course_CourseID
	WHERE LastName = 'YYYYY' and Course.CourseName = 'FRE201'
	GO
	-- ANSWER: Nora had 1 unexcused absence, and she'd never been late to class.



	-- 5. How many students were there in a given course?
	-- Let's retrieve the number of students I have this semester (Fall17).
	SELECT
	EnrollmentTotal
	FROM Course
	WHERE CourseName = 'FRE101' AND Semester = 'Fall17'
	GO
	-- ANSWER: I have 19 students in my FRE101 course this semester.
