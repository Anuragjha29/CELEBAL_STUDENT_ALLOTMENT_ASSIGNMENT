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
