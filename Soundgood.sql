CREATE TYPE Levels AS ENUM ('beginner', 'intermediate', 'advanced');
CREATE TYPE LessonTypes AS ENUM ('individual', 'group', 'ensemble');

CREATE TABLE Instructor (
 InstructorID SERIAL NOT NULL,
 Name CHAR(50) NOT NULL,
 PersonNumber INT UNIQUE NOT NULL,
 Phone CHAR(15) NOT NULL,
 Email CHAR(100) NOT NULL,
 CanTeachEnsembles BOOLEAN NOT NULL
);

ALTER TABLE Instructor ADD CONSTRAINT PK_Instructor PRIMARY KEY (InstructorID);


CREATE TABLE Instrument (
 InstrumentID SERIAL NOT NULL,
 Name CHAR(50) NOT NULL,
 Type CHAR(50) NOT NULL,
 Brand CHAR(50),
 Quantity INT NOT NULL
);

ALTER TABLE Instrument ADD CONSTRAINT PK_Instrument PRIMARY KEY (InstrumentID);


CREATE TABLE PricingScheme (
 PricingSchemeID SERIAL NOT NULL,
 LessonType CHAR(20) NOT NULL,
 Level CHAR(20) NOT NULL,
 StudentPaying DECIMAL(10) NOT NULL,
 TeacherReceiving DECIMAL(10) NOT NULL,
 Discount DECIMAL(10),
 ValidFrom DATE NOT NULL,
 ValidTo DATE NOT NULL
);

ALTER TABLE PricingScheme ADD CONSTRAINT PK_PricingScheme PRIMARY KEY (PricingSchemeID);


CREATE TABLE RentalPricing (
 RentalPricingID SERIAL NOT NULL,
 InstrumentID SERIAL,
 Amount DECIMAL(10) NOT NULL,
 ValidFrom DATE NOT NULL,
 ValidTo DATE NOT NULL
);

ALTER TABLE RentalPricing ADD CONSTRAINT PK_RentalPricing PRIMARY KEY (RentalPricingID);


CREATE TABLE Student (
 StudentID SERIAL NOT NULL,
 Name CHAR(50) NOT NULL,
 PersonNumber INT UNIQUE NOT NULL,
 Phone CHAR(15) NOT NULL,
 Email CHAR(100) NOT NULL,
 NumberOfRentedInstruments INT NOT NULL
 CHECK (NumberOfRentedInstruments >= 0 AND NumberOfRentedInstruments <= 2)
);

ALTER TABLE Student ADD CONSTRAINT PK_Student PRIMARY KEY (StudentID);


CREATE TABLE StudentContactPerson (
 StudentID SERIAL NOT NULL,
 Name CHAR(50) NOT NULL,
 Phone CHAR(15) NOT NULL,
 Email CHAR(100) NOT NULL
);

ALTER TABLE StudentContactPerson ADD CONSTRAINT PK_StudentContactPerson PRIMARY KEY (StudentID);


CREATE TABLE StudentRentals (
 RentalID SERIAL NOT NULL,
 InstrumentID SERIAL NOT NULL,
 RentalStartDate DATE NOT NULL,
 RentalEndDate DATE NOT NULL,
 StudentID SERIAL NOT NULL,
 RentalPricingID SERIAL NOT NULL
);

ALTER TABLE StudentRentals ADD CONSTRAINT PK_StudentRentals PRIMARY KEY (RentalID);

-- Trigger function to check the number of available instruments before insertion
CREATE OR REPLACE FUNCTION check_instrument_availability()
    RETURNS TRIGGER AS $$
BEGIN
    -- Check if the instrument has enough quantity available for rental
    IF (
        SELECT COUNT(*)
        FROM StudentRentals
        WHERE InstrumentID = NEW.InstrumentID
          AND RentalEndDate >= NEW.RentalStartDate
          AND RentalStartDate <= NEW.RentalEndDate
    ) >= (
        SELECT Quantity
        FROM Instrument
        WHERE InstrumentID = NEW.InstrumentID
    ) THEN
        RAISE EXCEPTION 'Not enough quantity available for the selected instrument during the specified period';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to call the trigger function before each insert on StudentRentals
CREATE TRIGGER check_instrument_availability_trigger
    BEFORE INSERT
    ON StudentRentals
    FOR EACH ROW
    EXECUTE FUNCTION check_instrument_availability();



CREATE TABLE StudentSiblings (
 StudentID SERIAL NOT NULL,
 SiblingStudentID SERIAL NOT NULL
);

ALTER TABLE StudentSiblings ADD CONSTRAINT PK_StudentSiblings PRIMARY KEY (StudentID,SiblingStudentID);


CREATE TABLE Teaching (
 InstructorID SERIAL NOT NULL,
 InstrumentID SERIAL NOT NULL
);

ALTER TABLE Teaching ADD CONSTRAINT PK_Teaching PRIMARY KEY (InstructorID,InstrumentID);


CREATE TABLE Availability (
 InstructorID SERIAL NOT NULL,
 Time TIMESTAMP(10) NOT NULL
);

ALTER TABLE Availability ADD CONSTRAINT PK_Availability PRIMARY KEY (InstructorID,Time);


CREATE TABLE Lesson (
 LessonID SERIAL NOT NULL,
 LessonType CHAR(20) NOT NULL,
 Level CHAR(20) NOT NULL,
 MaxStudents INT NOT NULL,
 MinStudents INT NOT NULL,
 TimeSlot TIMESTAMP(10),
 TargetGenre CHAR(10),
 PricingSchemeID SERIAL,
 InstructorID SERIAL
);

ALTER TABLE Lesson ADD CONSTRAINT PK_Lesson PRIMARY KEY (LessonID);


CREATE TABLE LessonAttendance (
 LessonID SERIAL NOT NULL,
 StudentID SERIAL NOT NULL
);

ALTER TABLE LessonAttendance ADD CONSTRAINT PK_LessonAttendance PRIMARY KEY (LessonID,StudentID);

-- Trigger function to check the number of attendees before insertion
CREATE OR REPLACE FUNCTION check_max_students()
    RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT COUNT(*) FROM LessonAttendance WHERE LessonID = NEW.LessonID) >= (SELECT MaxStudents FROM Lesson WHERE LessonID = NEW.LessonID) THEN
        RAISE EXCEPTION 'Maximum number of students reached for this lesson';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to call the trigger function before each insert on LessonAttendance
CREATE TRIGGER check_max_students_trigger
    BEFORE INSERT
    ON LessonAttendance
    FOR EACH ROW
    EXECUTE FUNCTION check_max_students();


CREATE TABLE LessonInstruments (
 LessonID SERIAL NOT NULL,
 InstrumentID SERIAL NOT NULL
);

ALTER TABLE LessonInstruments ADD CONSTRAINT PK_LessonInstruments PRIMARY KEY (LessonID,InstrumentID);


ALTER TABLE RentalPricing ADD CONSTRAINT FK_RentalPricing_0 FOREIGN KEY (InstrumentID) REFERENCES Instrument (InstrumentID) ON DELETE SET NULL;


ALTER TABLE StudentContactPerson ADD CONSTRAINT FK_StudentContactPerson_0 FOREIGN KEY (StudentID) REFERENCES Student (StudentID) ON DELETE CASCADE;


ALTER TABLE StudentRentals ADD CONSTRAINT FK_StudentRentals_0 FOREIGN KEY (InstrumentID) REFERENCES Instrument (InstrumentID) ON DELETE SET NULL;
ALTER TABLE StudentRentals ADD CONSTRAINT FK_StudentRentals_1 FOREIGN KEY (StudentID) REFERENCES Student (StudentID) ON DELETE CASCADE;
ALTER TABLE StudentRentals ADD CONSTRAINT FK_StudentRentals_2 FOREIGN KEY (RentalPricingID) REFERENCES RentalPricing (RentalPricingID) ON DELETE SET NULL;


ALTER TABLE StudentSiblings ADD CONSTRAINT FK_StudentSiblings_0 FOREIGN KEY (StudentID) REFERENCES Student (StudentID) ON DELETE CASCADE;
ALTER TABLE StudentSiblings ADD CONSTRAINT FK_StudentSiblings_1 FOREIGN KEY (SiblingStudentID) REFERENCES Student (StudentID);


ALTER TABLE Teaching ADD CONSTRAINT FK_Teaching_0 FOREIGN KEY (InstructorID) REFERENCES Instructor (InstructorID) ON DELETE CASCADE;
ALTER TABLE Teaching ADD CONSTRAINT FK_Teaching_1 FOREIGN KEY (InstrumentID) REFERENCES Instrument (InstrumentID) ON DELETE CASCADE;


ALTER TABLE Availability ADD CONSTRAINT FK_Availability_0 FOREIGN KEY (InstructorID) REFERENCES Instructor (InstructorID) ON DELETE CASCADE;


ALTER TABLE Lesson ADD CONSTRAINT FK_Lesson_0 FOREIGN KEY (PricingSchemeID) REFERENCES PricingScheme (PricingSchemeID) ON DELETE SET NULL;
ALTER TABLE Lesson ADD CONSTRAINT FK_Lesson_1 FOREIGN KEY (InstructorID) REFERENCES Instructor (InstructorID) ON DELETE SET NULL;


ALTER TABLE LessonAttendance ADD CONSTRAINT FK_LessonAttendance_0 FOREIGN KEY (LessonID) REFERENCES Lesson (LessonID) ON DELETE CASCADE;
ALTER TABLE LessonAttendance ADD CONSTRAINT FK_LessonAttendance_1 FOREIGN KEY (StudentID) REFERENCES Student (StudentID) ON DELETE CASCADE;


ALTER TABLE LessonInstruments ADD CONSTRAINT FK_LessonInstruments_0 FOREIGN KEY (LessonID) REFERENCES Lesson (LessonID) ON DELETE CASCADE;
ALTER TABLE LessonInstruments ADD CONSTRAINT FK_LessonInstruments_1 FOREIGN KEY (InstrumentID) REFERENCES Instrument (InstrumentID) ON DELETE CASCADE;


