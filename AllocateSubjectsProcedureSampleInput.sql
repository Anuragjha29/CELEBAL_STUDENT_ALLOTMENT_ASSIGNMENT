
IF OBJECT_ID('Allotments') IS NOT NULL DROP TABLE Allotments;
IF OBJECT_ID('UnallotedStudents') IS NOT NULL DROP TABLE UnallotedStudents;
IF OBJECT_ID('StudentPreference') IS NOT NULL DROP TABLE StudentPreference;
IF OBJECT_ID('SubjectDetails') IS NOT NULL DROP TABLE SubjectDetails;
IF OBJECT_ID('StudentDetails') IS NOT NULL DROP TABLE StudentDetails;


CREATE TABLE StudentDetails (
    StudentId VARCHAR(20) PRIMARY KEY,
    StudentName VARCHAR(100),
    GPA DECIMAL(3,1),
    Branch VARCHAR(50),
    Section VARCHAR(10)
);


CREATE TABLE SubjectDetails (
    SubjectId VARCHAR(20) PRIMARY KEY,
    SubjectName VARCHAR(100),
    MaxSeats INT,
    RemainingSeats INT
);


CREATE TABLE StudentPreference (
    StudentId VARCHAR(20),
    SubjectId VARCHAR(20),
    Preference INT,
    FOREIGN KEY (StudentId) REFERENCES StudentDetails(StudentId),
    FOREIGN KEY (SubjectId) REFERENCES SubjectDetails(SubjectId)
);


CREATE TABLE Allotments (
    SubjectId VARCHAR(20),
    StudentId VARCHAR(20)
);


CREATE TABLE UnallotedStudents (
    StudentId VARCHAR(20)
);

INSERT INTO StudentDetails (StudentId, StudentName, GPA, Branch, Section) VALUES
('159103036', 'Mohit Agarwal', 8.9, 'CCE', 'A'),
('159103037', 'Rohit Agarwal', 5.2, 'CCE', 'A'),
('159103038', 'Shohit Garg', 7.1, 'CCE', 'B'),
('159103039', 'Mrinal Malhotra', 7.9, 'CCE', 'A'),
('159103040', 'Mehreet Singh', 5.6, 'CCE', 'A'),
('159103041', 'Arjun Tehlan', 9.2, 'CCE', 'B');
INSERT INTO SubjectDetails (SubjectId, SubjectName, MaxSeats, RemainingSeats) VALUES
('PO1491', 'Basics of Political Science', 60, 2),
('PO1492', 'Basics of Accounting', 120, 119),
('PO1493', 'Basics of Financial Markets', 90, 90),
('PO1494', 'Eco philosophy', 60, 50),
('PO1495', 'Automotive Trends', 60, 60);



INSERT INTO StudentPreference (StudentId, SubjectId, Preference) VALUES
('159103036', 'PO1491', 1),
('159103036', 'PO1492', 2),
('159103036', 'PO1493', 3),
('159103036', 'PO1494', 4),
('159103036', 'PO1495', 5);



GO

ALTER PROCEDURE AllocateSubjects

AS
BEGIN
    DECLARE @StudentId VARCHAR(20);
    DECLARE @SubjectId VARCHAR(20);
    DECLARE @Preference INT;
    DECLARE @RemainingSeats INT;

    DECLARE student_cursor CURSOR FOR
        SELECT StudentId
        FROM StudentDetails
        ORDER BY GPA DESC;

    OPEN student_cursor;
    FETCH NEXT FROM student_cursor INTO @StudentId;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @Preference = 1;
        DECLARE @Allocated BIT = 0;

        WHILE @Preference <= 5 AND @Allocated = 0
        BEGIN
            SELECT @SubjectId = SubjectId
            FROM StudentPreference
            WHERE StudentId = @StudentId AND Preference = @Preference;

            IF @SubjectId IS NULL
                BREAK;

            SELECT @RemainingSeats = RemainingSeats
            FROM SubjectDetails
            WHERE SubjectId = @SubjectId;

            IF @RemainingSeats > 0
            BEGIN
                INSERT INTO Allotments (SubjectId, StudentId)
                VALUES (@SubjectId, @StudentId);

                UPDATE SubjectDetails
                SET RemainingSeats = RemainingSeats - 1
                WHERE SubjectId = @SubjectId;

                SET @Allocated = 1;
            END
            ELSE
            BEGIN
                SET @Preference = @Preference + 1;
            END
        END

        IF @Allocated = 0
        BEGIN
            INSERT INTO UnallotedStudents (StudentId)
            VALUES (@StudentId);
        END

        FETCH NEXT FROM student_cursor INTO @StudentId;
    END

    CLOSE student_cursor;
    DEALLOCATE student_cursor;
END;

DELETE FROM Allotments;
DELETE FROM UnallotedStudents;
EXEC AllocateSubjects;

SELECT * FROM Allotments;
SELECT * FROM UnallotedStudents;
SELECT * FROM SubjectDetails;