CREATE TABLE Instructor (
 InstructorID SERIAL NOT NULL,
 Name CHAR(50) NOT NULL,
 PersonNumber UNIQUE INT NOT NULL,
 Phone CHAR(15) NOT NULL,
 Email CHAR(100) NOT NULL,
 CanTeachEnsembles BIT(1) NOT NULL
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
 Discount DECIMAL(10)
);

ALTER TABLE PricingScheme ADD CONSTRAINT PK_PricingScheme PRIMARY KEY (PricingSchemeID);


CREATE TABLE RentalPricing (
 RentalPricingID SERIAL NOT NULL,
 InstrumentID SERIAL,
 Amount DECIMAL(10) NOT NULL
);

ALTER TABLE RentalPricing ADD CONSTRAINT PK_RentalPricing PRIMARY KEY (RentalPricingID);


CREATE TABLE Student (
 StudentID SERIAL NOT NULL,
 Name CHAR(50) NOT NULL,
 PersonNumber UNIQUE INT NOT NULL,
 Phone CHAR(15) NOT NULL,
 Email CHAR(100) NOT NULL,
 NumberOfRentedInsturments INT NOT NULL
 CHECK (NumberOfRentedInsturments >= 0 AND NumberOfRentedInsturments <= 2)
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


CREATE TABLE LessonInstruments (
 LessonID SERIAL NOT NULL,
 InstrumentID SERIAL NOT NULL
);

ALTER TABLE LessonInstruments ADD CONSTRAINT PK_LessonInstruments PRIMARY KEY (LessonID,InstrumentID);


ALTER TABLE RentalPricing ADD CONSTRAINT FK_RentalPricing_0 FOREIGN KEY (InstrumentID) REFERENCES Instrument (InstrumentID);


ALTER TABLE StudentContactPerson ADD CONSTRAINT FK_StudentContactPerson_0 FOREIGN KEY (StudentID) REFERENCES Student (StudentID);


ALTER TABLE StudentRentals ADD CONSTRAINT FK_StudentRentals_0 FOREIGN KEY (InstrumentID) REFERENCES Instrument (InstrumentID);
ALTER TABLE StudentRentals ADD CONSTRAINT FK_StudentRentals_1 FOREIGN KEY (StudentID) REFERENCES Student (StudentID);
ALTER TABLE StudentRentals ADD CONSTRAINT FK_StudentRentals_2 FOREIGN KEY (RentalPricingID) REFERENCES RentalPricing (RentalPricingID);


ALTER TABLE StudentSiblings ADD CONSTRAINT FK_StudentSiblings_0 FOREIGN KEY (StudentID) REFERENCES Student (StudentID);
ALTER TABLE StudentSiblings ADD CONSTRAINT FK_StudentSiblings_1 FOREIGN KEY (SiblingStudentID) REFERENCES Student (StudentID);


ALTER TABLE Teaching ADD CONSTRAINT FK_Teaching_0 FOREIGN KEY (InstructorID) REFERENCES Instructor (InstructorID);
ALTER TABLE Teaching ADD CONSTRAINT FK_Teaching_1 FOREIGN KEY (InstrumentID) REFERENCES Instrument (InstrumentID);


ALTER TABLE Availability ADD CONSTRAINT FK_Availability_0 FOREIGN KEY (InstructorID) REFERENCES Instructor (InstructorID);


ALTER TABLE Lesson ADD CONSTRAINT FK_Lesson_0 FOREIGN KEY (PricingSchemeID) REFERENCES PricingScheme (PricingSchemeID);
ALTER TABLE Lesson ADD CONSTRAINT FK_Lesson_1 FOREIGN KEY (InstructorID) REFERENCES Instructor (InstructorID);


ALTER TABLE LessonAttendance ADD CONSTRAINT FK_LessonAttendance_0 FOREIGN KEY (LessonID) REFERENCES Lesson (LessonID);
ALTER TABLE LessonAttendance ADD CONSTRAINT FK_LessonAttendance_1 FOREIGN KEY (StudentID) REFERENCES Student (StudentID);


ALTER TABLE LessonInstruments ADD CONSTRAINT FK_LessonInstruments_0 FOREIGN KEY (LessonID) REFERENCES Lesson (LessonID);
ALTER TABLE LessonInstruments ADD CONSTRAINT FK_LessonInstruments_1 FOREIGN KEY (InstrumentID) REFERENCES Instrument (InstrumentID);


