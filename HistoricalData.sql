-- Create historical database tables
CREATE TABLE HistoricalLesson (
    LessonID SERIAL NOT NULL,
    LessonType LessonTypes NOT NULL,
    Genre CHAR(10),
    Instrument CHAR(50),
    LessonPrice DECIMAL(10) NOT NULL,
    StudentName CHAR(50) NOT NULL,
    StudentEmail CHAR(100) NOT NULL,
    LessonDate DATE NOT NULL,
    PRIMARY KEY (LessonID)
);

-- Copy Lesson data to HistoricalLesson
INSERT INTO HistoricalLesson (LessonID, LessonType, Genre, Instrument, LessonPrice, StudentName, StudentEmail, LessonDate)
SELECT
    l.LessonID,
    l.LessonType,
    l.TargetGenre,
    i.Name AS Instrument,
    ps.StudentPaying AS LessonPrice,
    s.Name AS StudentName,
    s.Email AS StudentEmail,
    CURRENT_DATE AS LessonDate
FROM
    Lesson l
JOIN
    LessonInstruments li ON l.LessonID = li.LessonID
JOIN
    Instrument i ON li.InstrumentID = i.InstrumentID
JOIN
    LessonAttendance la ON l.LessonID = la.LessonID
JOIN
    Student s ON la.StudentID = s.StudentID
JOIN
    PricingScheme ps ON l.PricingSchemeID = ps.PricingSchemeID;
