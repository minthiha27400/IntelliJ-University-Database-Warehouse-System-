-- Decision Maker Queries
-- Query 1 = How many students are enrolled in each course for all academic years?
SELECT
    DE.ACADEMIC_YEAR,
    DE.COURSE_ID,
    COUNT(DE.STUDENT_ID) AS NO_OF_STUDENTS
FROM
    ENROLL DE
GROUP BY
    DE.ACADEMIC_YEAR,
    DE.COURSE_ID;

-- Query 2 = How many students have passed in each course? 
SELECT
    C.COURSE_ID,
    COUNT(DISTINCT
        CASE
            WHEN NOT EXISTS (
                SELECT
                    1
                FROM
                    MARKING MK_FAIL
                WHERE
                    MK_FAIL.STUDENT_ID = E.STUDENT_ID
                    AND MK_FAIL.STATUS = 'Fail'
            ) THEN
                E.STUDENT_ID
            ELSE
                NULL
        END) AS NO_OF_PASSED_STUDENTS
FROM
    COURSE  C
    JOIN MODULE M
    ON C.COURSE_ID = M.COURSE_ID JOIN ENROLL E
    ON C.COURSE_ID = E.COURSE_ID
    JOIN MARKING MK
    ON E.STUDENT_ID = MK.STUDENT_ID
GROUP BY
    C.COURSE_ID;

-- Query 3 = How many students have failed in each course?
SELECT
    C.COURSE_ID,
    COUNT(DISTINCT
        CASE
            WHEN 'Fail' IN (
                SELECT
                    MK.STATUS
                FROM
                    MARKING MK
                WHERE
                    MK.STUDENT_ID = E.STUDENT_ID
            ) THEN
                E.STUDENT_ID
            ELSE
                NULL
        END) AS NO_OF_FAILED_STUDENTS
FROM
    COURSE  C
    JOIN ENROLL E
    ON C.COURSE_ID = E.COURSE_ID
GROUP BY
    C.COURSE_ID;

-- Query 4 = How many courses are taught by each lecturer? 
SELECT
    L.LECTURER_ID,
    COALESCE(NUM_COURSES_TAUGHT, 0) AS NUM_COURSES_TAUGHT
FROM
    LECTURER L
    LEFT JOIN (
        SELECT
            LECTURER_ID,
            COUNT(DISTINCT COURSE_ID) AS NUM_COURSES_TAUGHT
        FROM
            MODULE
        GROUP BY
            LECTURER_ID
    ) SUBQ
    ON L.LECTURER_ID = SUBQ.LECTURER_ID;

-- Query 5 = What is the avaerage age of students in each course?
SELECT
    C.COURSE_ID,
    TRUNC(AVG(EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM S.DOB))) AS AVERAGE_AGE
FROM
    COURSE  C
    JOIN ENROLL E
    ON C.COURSE_ID = E.COURSE_ID JOIN STUDENT S
    ON E.STUDENT_ID = S.STUDENT_ID
GROUP BY
    C.COURSE_ID;

--Query 6 = How many students passed in a specific year (eg., 2022)?
SELECT
    E.ACADEMIC_YEAR,
    COUNT(DISTINCT
        CASE
            WHEN MK.STATUS IN ('Pass', 'Merit', 'Distinction') THEN
                E.STUDENT_ID
            ELSE
                NULL
        END)        AS NO_OF_PASSED_STUDENTS
FROM
    ENROLL  E
    JOIN MARKING MK
    ON E.STUDENT_ID = MK.STUDENT_ID
WHERE
    E.ACADEMIC_YEAR = 2022 -- Replace with the desired year
    AND E.STUDENT_ID NOT IN (
        SELECT
            DISTINCT E.STUDENT_ID
        FROM
            ENROLL  E
            JOIN MARKING MK
            ON E.STUDENT_ID = MK.STUDENT_ID
        WHERE
            MK.STATUS IN ('Fail')
    )
GROUP BY
    E.ACADEMIC_YEAR;

--Query 7 = How many students failed in a specific year (eg., 2023)?
SELECT
    E.ACADEMIC_YEAR,
    COUNT(DISTINCT
        CASE
            WHEN MK.STATUS IN ('Fail') THEN
                E.STUDENT_ID
            ELSE
                NULL
        END)        AS NO_OF_FAILED_STUDENTS
FROM
    ENROLL  E
    JOIN MARKING MK
    ON E.STUDENT_ID = MK.STUDENT_ID
WHERE
    E.ACADEMIC_YEAR = 2023 -- Replace with the desired year
GROUP BY
    E.ACADEMIC_YEAR;

-- Query 8 = Which course had the highest number of students across all the academic years?
WITH STUDENTCOUNTS AS (
    SELECT
        E.ACADEMIC_YEAR,
        C.COURSE_NAME,
        COUNT(DISTINCT E.STUDENT_ID)  AS NO_OF_STUDENTS,
        RANK() OVER (PARTITION BY E.ACADEMIC_YEAR ORDER BY COUNT(DISTINCT E.STUDENT_ID) DESC) AS STUDENT_RANK
    FROM
        ENROLL E
        JOIN COURSE C
        ON E.COURSE_ID = C.COURSE_ID
    GROUP BY
        E.ACADEMIC_YEAR, C.COURSE_NAME
)
SELECT
    ACADEMIC_YEAR,
    COURSE_NAME,
    NO_OF_STUDENTS
FROM
    STUDENTCOUNTS
WHERE
    STUDENT_RANK = 1;

-- Query 9 = How many Male and Female students are enrolled in each course?
SELECT
    E.COURSE_ID,
    E.ACADEMIC_YEAR,
    COUNT(
        CASE
            WHEN S.GENDER = 'Male' THEN
                1
        END)        AS NO_OF_MALE_STUDENTS,
    COUNT(
        CASE
            WHEN S.GENDER = 'Female' THEN
                1
        END)        AS NO_OF_FEMALE_STUDENTS
FROM
    ENROLL  E
    JOIN STUDENT S
    ON E.STUDENT_ID = S.STUDENT_ID
GROUP BY
    E.COURSE_ID, E.ACADEMIC_YEAR;

-- Query 10 = What is the average mark (credits) for each course across all the academic years?
SELECT
    E.ACADEMIC_YEAR,
    C.COURSE_ID,
    TRUNC(AVG(MK.CREDITS)) AS AVERAGE_CREDITS
FROM
    ENROLL  E
    JOIN COURSE C
    ON E.COURSE_ID = C.COURSE_ID JOIN MODULE M
    ON C.COURSE_ID = M.COURSE_ID
    JOIN MARKING MK
    ON M.MODULE_ID = MK.MODULE_ID
GROUP BY
    E.ACADEMIC_YEAR, C.COURSE_ID
ORDER BY
    E.ACADEMIC_YEAR, C.COURSE_ID;