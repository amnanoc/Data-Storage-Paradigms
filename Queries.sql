--Query that counts the lessons given in a certain month during a year
CREATE VIEW LessonStatsByMonth AS
SELECT TO_CHAR(TimeSlot, 'Month') AS Month, EXTRACT(YEAR FROM TimeSlot) AS Year,
       COUNT(*) AS Total,
       SUM(CASE WHEN LessonType = 'individual' THEN 1 ELSE 0 END) AS Individual,
       SUM(CASE WHEN LessonType = 'group' THEN 1 ELSE 0 END) AS Group,
       SUM(CASE WHEN LessonType = 'ensemble' THEN 1 ELSE 0 END) AS Ensemble
FROM Lesson
GROUP BY Month, Year;

SELECT * FROM LessonStatsByMonth WHERE Year = 2023;


--Query that counts the number of students with 0, 1, 2 and more than 2 sibilings
CREATE VIEW StudentSiblingsCount AS
SELECT s.StudentID,
       CASE
           WHEN COALESCE(COUNT(DISTINCT ss.SiblingStudentID), 0) = 0 THEN 'No Sibling'
           WHEN COALESCE(COUNT(DISTINCT ss.SiblingStudentID), 0) = 1 THEN 'One Sibling'
           WHEN COALESCE(COUNT(DISTINCT ss.SiblingStudentID), 0) = 2 THEN 'Two Siblings'
           ELSE 'Three or More Siblings'
       END AS NoOfSiblings
FROM Student s
LEFT JOIN (
    SELECT StudentID, SiblingStudentID
    FROM StudentSiblings
    UNION ALL
    SELECT SiblingStudentID, StudentID
    FROM StudentSiblings
) ss ON s.StudentID = ss.StudentID
GROUP BY s.StudentID;

SELECT NoOfSiblings, COUNT(*) AS NoOfStudents
FROM StudentSiblingsCount
GROUP BY NoOfSiblings
ORDER BY NoOfSiblings;


--Query that counts how many lessons every instructor has given in the current month
--Currently set to check if the instructor has given any lessons but the number can be updated later
CREATE VIEW InstructorLessonCount AS
SELECT Instructor.InstructorID, Instructor.Name, COUNT(*) AS NoOfLessons
FROM Lesson
JOIN Instructor ON Lesson.InstructorID = Instructor.InstructorID
WHERE EXTRACT(MONTH FROM Lesson.TimeSlot) = EXTRACT(MONTH FROM CURRENT_DATE)
  AND EXTRACT(YEAR FROM Lesson.TimeSlot) = EXTRACT(YEAR FROM CURRENT_DATE)
GROUP BY Instructor.InstructorID, Instructor.Name
HAVING COUNT(*) > 0 --Here we change the number of lessons we consider "overworking"
ORDER BY COUNT(*) DESC;

SELECT * FROM InstructorLessonCount;

--Query that checks if an ensemble lesson next week has free seats left or fully booked
CREATE MATERIALIZED VIEW EnsembleAvailability AS
SELECT TO_CHAR(l.TimeSlot::DATE, 'Day') AS Day, l.TargetGenre AS Genre,
      CASE WHEN COALESCE(COUNT(la.StudentID), 0) >= l.MaxStudents THEN 'Full Booked'
           WHEN COALESCE(COUNT(la.StudentID), 0) < l.MaxStudents AND COALESCE(COUNT(la.StudentID), 0) >= l.MaxStudents - 2 THEN '1-2 Seats Left'
           ELSE 'More than 2 Seats Left' END AS "No of Free Seats"
FROM Lesson l
LEFT JOIN LessonAttendance la ON l.LessonID = la.LessonID
WHERE l.LessonType = 'ensemble'
AND l.TimeSlot::DATE >= (DATE_TRUNC('week', CURRENT_DATE) + INTERVAL '1 week')::DATE
AND l.TimeSlot::DATE <= (DATE_TRUNC('week', CURRENT_DATE) + INTERVAL '2 weeks' - INTERVAL '1 day')::DATE
GROUP BY l.LessonID, l.TimeSlot, l.TargetGenre, l.MaxStudents
ORDER BY l.TimeSlot::DATE, l.TargetGenre;

REFRESH MATERIALIZED VIEW EnsembleAvailability;
SELECT * FROM EnsembleAvailability;

