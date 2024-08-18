--Drop Table if already exist
DROP TABLE Student CASCADE CONSTRAINTS;  
DROP TABLE Lecturer CASCADE CONSTRAINTS;  
DROP TABLE Course CASCADE CONSTRAINTS;  
DROP TABLE Module CASCADE CONSTRAINTS; 
DROP TABLE Enroll CASCADE CONSTRAINTS; 
DROP TABLE Marking CASCADE CONSTRAINTS;
DROP TABLE UserLogin CASCADE CONSTRAINTS;

-- Create Tables
-- Student Table
CREATE TABLE Student
( 
  Student_ID NUMBER GENERATED by default on null as IDENTITY,
  Student_name varchar2(50) NOT NULL,
  Gender VARCHAR2(10),
  DOB DATE,
  email varchar2(50), 
  phone varchar2(12), 
  Address varchar2(100)
);

ALTER TABLE Student
ADD CONSTRAINT pk_student PRIMARY KEY (Student_ID);

-- Lecturer Table
CREATE TABLE Lecturer
( 
  Lecturer_ID NUMBER GENERATED by default on null as IDENTITY,
  Lecturer_name varchar2(50) NOT NULL, -- Assuming a single name field
  Gender VARCHAR2(10),
  DOB DATE,
  email varchar2(50), 
  phone varchar2(12), 
  Address varchar2(100)
);

ALTER TABLE Lecturer
ADD CONSTRAINT pk_Lecturer PRIMARY KEY (Lecturer_ID);

-- Course Table
CREATE TABLE Course (
    Course_ID NUMBER GENERATED by default on null as IDENTITY,
    Course_Name varchar2(25) NOT NULL,
    Start_Date DATE,
    End_Date DATE,
    Description varchar2(250)
);

ALTER TABLE Course
ADD CONSTRAINT pk_Course PRIMARY KEY (Course_ID);

-- Module Table
CREATE TABLE Module
( Module_ID NUMBER GENERATED by default on null as IDENTITY,
  module_code varchar2(25) NOT NULL, 
  module_name varchar2(50) NOT NULL, 
  Lecturer_ID NUMBER, 
  Course_ID NUMBER
);

ALTER TABLE Module
ADD CONSTRAINT pk_Module PRIMARY KEY (Module_ID);

-- Enroll Table
CREATE TABLE Enroll
( Enroll_ID NUMBER GENERATED by default on null as IDENTITY,
  Enroll_Date DATE, 
  Academic_year NUMBER,
  Student_ID NUMBER, 
  Course_ID NUMBER
)
PARTITION BY RANGE (Academic_year) (
    PARTITION p2020 VALUES LESS THAN (2021),
    PARTITION p2021 VALUES LESS THAN (2022),
    PARTITION p2022 VALUES LESS THAN (2023),
    PARTITION p2023 VALUES LESS THAN (2024),
    PARTITION p2024 VALUES LESS THAN (MAXVALUE)
);

ALTER TABLE Enroll
ADD CONSTRAINT pk_Enroll PRIMARY KEY (Enroll_ID);

-- Marking Table
CREATE TABLE Marking
( Result_ID NUMBER GENERATED by default on null as IDENTITY,
  Credits NUMBER,
  Mark_Date DATE,
  Status varchar2(25),
  Student_ID NUMBER, 
  Module_ID NUMBER
);

ALTER TABLE Marking
ADD CONSTRAINT pk_Marking PRIMARY KEY (Result_ID);

-- Users for Login 
CREATE TABLE UserLogin(
ID NUMBER GENERATED by default on null as IDENTITY,
EMAIL VARCHAR2(50),
USERNAME VARCHAR2(50),
USERPASSWORD VARCHAR2(50),
USERTYPE VARCHAR2(50)
);

ALTER TABLE UserLogin
ADD CONSTRAINT pk_userlogin PRIMARY KEY (ID);

ALTER TABLE userlogin
ADD userID NUMBER;

--  Foreign Keys Relationsihps

ALTER TABLE Module
ADD CONSTRAINT fk_Lecturer_Module
  FOREIGN KEY (Lecturer_ID)
  REFERENCES Lecturer(Lecturer_ID);

ALTER TABLE Module
ADD CONSTRAINT fk_Course_Module
  FOREIGN KEY (Course_ID)
  REFERENCES Course(Course_ID);
  
ALTER TABLE Enroll
ADD CONSTRAINT fk_Student_Enroll
  FOREIGN KEY (Student_ID)
  REFERENCES Student(Student_ID);  
     
ALTER TABLE Marking
ADD CONSTRAINT fk_Student_Marking
  FOREIGN KEY (Student_ID)
  REFERENCES Student(Student_ID);  
  
ALTER TABLE Enroll
ADD CONSTRAINT fk_Course_Enroll
  FOREIGN KEY (Course_ID)
  REFERENCES Course(Course_ID);

  COMMIT;