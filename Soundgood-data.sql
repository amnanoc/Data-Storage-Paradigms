INSERT INTO Instructor (Name, PersonNumber, Phone, Email, CanTeachEnsembles)
VALUES 
  ('John Doe', 123456, '555-1234', 'john.doe@email.com', true),
  ('Jane Smith', 789012, '555-5678', 'jane.smith@email.com', false),
  ('Bob Johnson', 345678, '555-9012', 'bob.johnson@email.com', true),
  ('Alice Williams', 901234, '555-3456', 'alice.williams@email.com', false);

-- Inserting sample data into the Instrument table
INSERT INTO Instrument (Name, Type, Brand, Quantity)
VALUES 
  ('Guitar', 'String', 'Fender', 5),
  ('Piano', 'Keyboard', 'Yamaha', 3),
  ('Drums', 'Percussion', 'Pearl', 2),
  ('Violin', 'String', 'Stradivarius', 1);

-- Inserting sample data into the PricingScheme table
INSERT INTO PricingScheme (LessonType, Level, StudentPaying, TeacherReceiving, Discount, ValidFrom, ValidTo)
VALUES
  ('individual', 'beginner', 50.00, 30.00, 5.00, '2023-01-01', '2023-12-31'), 
  ('group', 'intermediate', 40.00, 25.00, 3.00, '2023-01-01', '2023-12-31'), 
  ('ensemble', 'advanced', 60.00, 40.00, 8.00, '2023-01-01', '2023-12-31'); 


-- Inserting sample data into the RentalPricing table
INSERT INTO RentalPricing (InstrumentID, Amount, ValidFrom, ValidTo)
VALUES
  (1, 20.00, '2023-01-01', '2023-12-31'), 
  (2, 30.00, '2023-01-01', '2023-12-31'), 
  (3, 25.00, '2023-01-01', '2023-12-31'); 


-- Inserting sample data into the Student table
INSERT INTO Student (Name, PersonNumber, Phone, Email, NumberOfRentedInstruments)
VALUES 
  ('Alice Johnson', 111111, '555-1111', 'alice@email.com', 1),
  ('Bob Smith', 222222, '555-2222', 'bob@email.com', 0),
  ('Charlie Brown', 333333, '555-3333', 'charlie@email.com', 2);

-- Inserting sample data into the StudentContactPerson table
INSERT INTO StudentContactPerson (StudentID, Name, Phone, Email)
VALUES 
  (1, 'Parent 1', '555-1234', 'parent1@email.com'),
  (2, 'Parent 2', '555-5678', 'parent2@email.com'),
  (3, 'Parent 3', '555-9012', 'parent3@email.com');

  -- Inserting data into StudentSiblings
INSERT INTO StudentSiblings (StudentID, SiblingStudentID)
VALUES
  (1, 2);  

-- Inserting data into StudentRentals
INSERT INTO StudentRentals (InstrumentID, RentalStartDate, RentalEndDate, StudentID, RentalPricingID)
VALUES
  (1, '2023-11-20', '2023-12-20', 1, 1),  
  (2, '2023-11-25', '2023-12-25', 2, 1),  
  (3, '2023-11-30', '2023-12-30', 3, 2);  


-- Inserting sample data into the Teaching table
INSERT INTO Teaching (InstructorID, InstrumentID)
VALUES 
  (1, 1),
  (2, 2),
  (3, 3);

-- Inserting sample data into the Availability table
INSERT INTO Availability (InstructorID, Time)
VALUES 
  (1, '2023-11-20 10:00:00'),
  (2, '2023-11-21 15:30:00'),
  (3, '2023-11-22 09:00:00');

-- Inserting sample data into the Lesson table
INSERT INTO Lesson (LessonType, Level, MaxStudents, MinStudents, TimeSlot, TargetGenre, PricingSchemeID, InstructorID)
VALUES 
  ('individual', 'beginner', 1, 1, '2023-11-23 12:00:00', 'Rock', 1, 1),
  ('group', 'intermediate', 5, 3, '2023-11-24 14:00:00', 'Jazz', 2, 2),
  ('ensemble', 'advanced', 8, 5, '2023-11-25 16:30:00', 'Classical', 3, 3);

-- Inserting sample data into the LessonAttendance table
INSERT INTO LessonAttendance (LessonID, StudentID)
VALUES 
  (1, 1),
  (2, 2),
  (3, 3);

-- Inserting sample data into the LessonInstruments table
INSERT INTO LessonInstruments (LessonID, InstrumentID)
VALUES 
  (1, 1),
  (2, 2),
  (3, 3);

