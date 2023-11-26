-- Create historical database tables
CREATE TABLE HistoricalLesson (
    LessonID SERIAL PRIMARY KEY,
    LessonType CHAR(20) NOT NULL,
    Genre CHAR(10),
    Instrument CHAR(50),
    LessonPrice DECIMAL(10) NOT NULL,
    StudentName CHAR(50) NOT NULL,
    StudentEmail CHAR(100) NOT NULL
);

-- Copy data from present database to historical database
INSERT INTO HistoricalLesson (LessonType, Genre, Instrument, LessonPrice, StudentName, StudentEmail)
SELECT
    l.LessonType,
    CASE WHEN l.LessonType = 'ensemble' THEN l.TargetGenre ELSE NULL END,
    CASE WHEN l.LessonType != 'ensemble' THEN t.Name ELSE NULL END,
    ps.StudentPaying,
    s.Name,
    s.Email
FROM
    Lesson l
LEFT JOIN
    LessonInstruments li ON l.LessonID = li.LessonID
LEFT JOIN
    Teaching t ON li.InstrumentID = t.InstrumentID
LEFT JOIN
    PricingScheme ps ON l.PricingSchemeID = ps.PricingSchemeID
LEFT JOIN
    LessonAttendance la ON l.LessonID = la.LessonID
LEFT JOIN
    Student s ON la.StudentID = s.StudentID;
