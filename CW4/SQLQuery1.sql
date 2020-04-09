Create Procedure PromoteStudentS @Studies Varchar(100), @Semester INT
AS


    BEGIN

        DECLARE @IdStudies INT
        DECLARE @IdEnrollment INT

        Select @IdStudies = IdStudy
        FROM Studies WHERE Name = @Studies;

     IF @IdStudies IS NULL
         
         BEGIN
             RAISERROR ('ERROR this record does not exist', 1, 2);

	    RETURN;

      END

        Select @IdEnrollment = IdEnrollment

                 FROM Enrollment WHERE Semester = @Semester + 1 AND IdStudy = @IdStudies;

        IF @IdEnrollment IS NULL

         BEGIN

                DECLARE @NewIdEnrollment INT = (Select NULLIF(MAX(IdEnrollment), 0) from Enrollment) + 1;
                
                INSERT INTO Enrollment VALUES(@NewIdEnrollment, @Semester + 1, @IdStudies, GETDATE());
                
                SET @IdEnrollment = (SELECT IdEnrollment FROM Enrollment WHERE Semester = @Semester + 1 AND IdStudy = @IdStudies);

         END


     DECLARE PromoteStudent_cursor CURSOR
        
        FOR SELECT IndexNumber FROM Student INNER JOIN Enrollment ON Enrollment.IdEnrollment = Student.IdEnrollment WHERE Semester = @Semester AND IdStudy = @IdStudies

    OPEN MY_Cursor;

        DECLARE @IndexNumber VARCHAR(150);

        FETCH NEXT FROM MY_Cursor INTO @IndexNumber;


    WHILE @@FETCH_STATUS = 0
        
    BEGIN

       UPDATE Student SET IdEnrollment = @IdEnrollment WHERE IndexNumber = @IndexNumber;

            FETCH NEXT FROM MY_Cursor

       INTO @IndexNumber;
       
       END




    CLOSE MY_Cursor;
    END;

  