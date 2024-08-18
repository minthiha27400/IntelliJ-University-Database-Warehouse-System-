-- Insert Data into Warehouse 
--Student Dim
INSERT INTO Student_Dim (Student_ID, Student_name, Email)
SELECT Student_ID, Student_name, Email
FROM Student;

-- Lecturer Dim
INSERT INTO Lecturer_Dim (Lecturer_ID, Lecturer_name, Email)
SELECT Lecturer_ID, Lecturer_name, Email
FROM Lecturer;

-- Course Dim
INSERT INTO Course_Dim (Course_ID, Course_name, Start_Date, End_Date)
SELECT Course_ID, Course_name, Start_Date, End_Date
FROM Course;


-- Enroll Dim
INSERT INTO Enroll_Dim (Enroll_ID, Student_ID, Course_ID, academic_year)
SELECT Enroll_ID,Student_ID, Course_ID,academic_year
FROM Enroll;

-- Module Dim
INSERT INTO Module_Dim (Module_ID, Module_name, Lecturer_ID,Course_ID)
SELECT Module_ID, Module_name, Lecturer_ID,Course_ID
FROM Module;  

-- Fact Data
INSERT INTO University_Fact (Academic_year, Course_ID, no_of_students, no_of_passed_students, no_of_failed_students)
SELECT
    DE.ACADEMIC_YEAR,
    DE.COURSE_ID,
    COUNT(DISTINCT DE.STUDENT_ID) AS NO_OF_STUDENTS,
    COUNT(DISTINCT CASE
        WHEN NOT EXISTS (
            SELECT 1
            FROM MARKING MK_FAIL
            WHERE MK_FAIL.STUDENT_ID = E.STUDENT_ID
            AND MK_FAIL.STATUS = 'Fail'
        ) THEN E.STUDENT_ID
        ELSE NULL
    END) AS NO_OF_PASSED_STUDENTS,
    COUNT(DISTINCT CASE
        WHEN 'Fail' IN (
            SELECT MK.STATUS
            FROM MARKING MK
            WHERE MK.STUDENT_ID = E.STUDENT_ID
        ) THEN E.STUDENT_ID
        ELSE NULL
    END) AS NO_OF_FAILED_STUDENTS
FROM
    ENROLL DE
JOIN
    COURSE C ON DE.COURSE_ID = C.COURSE_ID
JOIN
    MODULE M ON C.COURSE_ID = M.COURSE_ID
JOIN
    ENROLL E ON C.COURSE_ID = E.COURSE_ID
GROUP BY
    DE.ACADEMIC_YEAR,
    DE.COURSE_ID,
    C.COURSE_ID;

COMMIT;