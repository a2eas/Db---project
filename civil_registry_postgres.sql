-- =====================================================
-- Civil Registry Database — PostgreSQL Version
-- (Converted from T-SQL / SQL Server)
-- =====================================================

DROP TABLE IF EXISTS FamilyMember CASCADE;
DROP TABLE IF EXISTS Family CASCADE;
DROP TABLE IF EXISTS MarriageRecord CASCADE;
DROP TABLE IF EXISTS DeathRecord CASCADE;
DROP TABLE IF EXISTS BirthRecord CASCADE;
DROP TABLE IF EXISTS NationalIDCard CASCADE;
DROP TABLE IF EXISTS Address CASCADE;
DROP TABLE IF EXISTS Citizen CASCADE;

-- =====================================================
-- 1. Citizen table
-- =====================================================

CREATE TABLE Citizen (
    CitizenID      SERIAL PRIMARY KEY,
    NationalID     VARCHAR(20)  NOT NULL,
    FirstName      VARCHAR(50)  NOT NULL,
    LastName       VARCHAR(50)  NOT NULL,
    Gender         CHAR(1)      NOT NULL CHECK (Gender IN ('M','F')),
    DateOfBirth    DATE         NOT NULL,
    PlaceOfBirth   VARCHAR(100),
    BloodType      VARCHAR(5),
    Religion       VARCHAR(30),
    MaritalStatus  VARCHAR(20),
    Occupation     VARCHAR(100),
    PhoneNumber    VARCHAR(20),
    Email          VARCHAR(100),

    CONSTRAINT UQ_Citizen_NationalID UNIQUE (NationalID)
);

-- =====================================================
-- 2. Address table
-- =====================================================

CREATE TABLE Address (
    AddressID      SERIAL PRIMARY KEY,
    CitizenID      INT NOT NULL,
    Governorate    VARCHAR(50),
    City           VARCHAR(50) NOT NULL,
    District       VARCHAR(50),
    Street         VARCHAR(100),
    BuildingNumber VARCHAR(10),
    PostalCode     VARCHAR(10),
    IsCurrent      BOOLEAN DEFAULT TRUE,

    FOREIGN KEY (CitizenID)
        REFERENCES Citizen(CitizenID)
        ON DELETE CASCADE
);

-- =====================================================
-- 3. National ID Card table
-- =====================================================

CREATE TABLE NationalIDCard (
    CardID         SERIAL PRIMARY KEY,
    CitizenID      INT NOT NULL,
    IssueDate      DATE NOT NULL,
    ExpiryDate     DATE NOT NULL,
    CardStatus     VARCHAR(20) NOT NULL DEFAULT 'Active',

    FOREIGN KEY (CitizenID)
        REFERENCES Citizen(CitizenID)
        ON DELETE CASCADE
);

-- =====================================================
-- 4. Birth Record table
-- =====================================================

CREATE TABLE BirthRecord (
    BirthRecordID    SERIAL PRIMARY KEY,
    CitizenID        INT NOT NULL UNIQUE,
    RegistrationDate DATE NOT NULL,
    HospitalName     VARCHAR(100),
    DoctorName       VARCHAR(100),
    FatherID         INT,
    MotherID         INT,

    FOREIGN KEY (CitizenID)
        REFERENCES Citizen(CitizenID)
        ON DELETE CASCADE,

    FOREIGN KEY (FatherID)
        REFERENCES Citizen(CitizenID),

    FOREIGN KEY (MotherID)
        REFERENCES Citizen(CitizenID)
);

-- =====================================================
-- 5. Death Record table
-- =====================================================

CREATE TABLE DeathRecord (
    DeathRecordID   SERIAL PRIMARY KEY,
    CitizenID       INT NOT NULL UNIQUE,
    DeathDate       DATE NOT NULL,
    CauseOfDeath    VARCHAR(200),
    PlaceOfDeath    VARCHAR(200),
    CertificateNo   VARCHAR(50) UNIQUE,

    FOREIGN KEY (CitizenID)
        REFERENCES Citizen(CitizenID)
        ON DELETE CASCADE
);

-- =====================================================
-- 6. Family table
-- =====================================================

CREATE TABLE Family (
    FamilyID        SERIAL PRIMARY KEY,
    FamilyName      VARCHAR(100) NOT NULL,
    HeadCitizenID   INT NOT NULL,

    FOREIGN KEY (HeadCitizenID)
        REFERENCES Citizen(CitizenID)
);

-- =====================================================
-- 7. Family Member table
-- =====================================================

CREATE TABLE FamilyMember (
    FamilyID        INT,
    CitizenID       INT,
    Relationship    VARCHAR(30) NOT NULL,

    PRIMARY KEY (FamilyID, CitizenID),

    FOREIGN KEY (FamilyID)
        REFERENCES Family(FamilyID)
        ON DELETE CASCADE,

    FOREIGN KEY (CitizenID)
        REFERENCES Citizen(CitizenID)
        ON DELETE CASCADE
);

-- =====================================================
-- 8. Marriage Record table
-- =====================================================

CREATE TABLE MarriageRecord (
    MarriageID       SERIAL PRIMARY KEY,
    HusbandID        INT NOT NULL,
    WifeID           INT NOT NULL,
    MarriageDate     DATE NOT NULL,
    MarriageLocation VARCHAR(200),
    CertificateNo    VARCHAR(50) UNIQUE,

    FOREIGN KEY (HusbandID)
        REFERENCES Citizen(CitizenID),

    FOREIGN KEY (WifeID)
        REFERENCES Citizen(CitizenID)
);

-- =====================================================
-- INDEXES
-- =====================================================

CREATE INDEX idx_citizen_lastname ON Citizen(LastName);
CREATE INDEX idx_citizen_dob      ON Citizen(DateOfBirth);
CREATE INDEX idx_address_city     ON Address(City);
CREATE INDEX idx_marriage_date    ON MarriageRecord(MarriageDate);

-- =====================================================
-- SAMPLE DATA — Citizens
-- =====================================================

INSERT INTO Citizen
(NationalID, FirstName, LastName, Gender, DateOfBirth, PlaceOfBirth,
 BloodType, Religion, MaritalStatus, Occupation, PhoneNumber, Email)
VALUES
('EG00000000000002', 'Mohamed', 'Ali',     'M', '1965-03-10', 'Cairo',
 'A+',  'Muslim',    'Married', 'Engineer',   '01000000001', 'mohamed@gmail.com'),

('EG00000000000003', 'Fatma',   'Hassan',  'F', '1968-07-22', 'Giza',
 'O+',  'Muslim',    'Married', 'Teacher',    '01000000002', 'fatma@gmail.com'),

('EG12345678901234', 'Ahmed',   'Ali',     'M', '1990-05-15', 'Cairo',
 'B+',  'Muslim',    'Married', 'Programmer', '01000000003', 'ahmed@gmail.com'),

('EG11111111111111', 'Mona',    'Ali',     'F', '1992-08-11', 'Alexandria',
 'AB+', 'Muslim',    'Single',  'Doctor',     '01000000004', 'mona@gmail.com'),

('EG22222222222222', 'Omar',    'Mahmoud', 'M', '1988-03-19', 'Giza',
 'A-',  'Muslim',    'Married', 'Lawyer',     '01000000005', 'omar@gmail.com'),

('EG33333333333333', 'Khaled',  'Mostafa', 'M', '1985-04-10', 'Cairo',
 'A+',  'Muslim',    'Married', 'Engineer',   '01011111111', 'khaled@gmail.com'),

('EG44444444444444', 'Nour',    'Adel',    'F', '1995-06-22', 'Alexandria',
 'B+',  'Muslim',    'Single',  'Doctor',     '01022222222', 'nour@gmail.com'),

('EG55555555555555', 'Youssef', 'Hassan',  'M', '2000-01-15', 'Giza',
 'O+',  'Muslim',    'Single',  'Student',    '01033333333', 'youssef@gmail.com'),

('EG66666666666666', 'Mariam',  'Samy',    'F', '1998-09-12', 'Mansoura',
 'AB+', 'Christian', 'Single',  'Teacher',    '01044444444', 'mariam@gmail.com'),

('EG77777777777777', 'Ibrahim', 'Tarek',   'M', '1979-11-03', 'Aswan',
 'A-',  'Muslim',    'Married', 'Lawyer',     '01055555555', 'ibrahim@gmail.com');

-- =====================================================
-- SAMPLE DATA — Addresses
-- =====================================================

INSERT INTO Address
(CitizenID, Governorate, City, District, Street, BuildingNumber, PostalCode, IsCurrent)
VALUES
(1,  'Cairo',    'Heliopolis', 'East',           'Omar St',       '5',  '11511', TRUE),
(2,  'Giza',     'Dokki',      'Central',         'Tahrir St',     '10', '12611', TRUE),
(3,  'Cairo',    'Nasr City',  'First District',  'El-Nasr St',    '12', '11765', TRUE),
(4,  'Alexandria','Smouha',    'East',            'Sea Road',      '7',  '21500', TRUE),
(5,  'Giza',     'Dokki',      'Central',         'Tahrir St',     '22', '12611', TRUE),
(6,  'Cairo',    'Heliopolis', 'East',            'Omar St',       '5',  '11511', TRUE),
(7,  'Alexandria','Miami',     'North',           'Sea St',        '10', '21500', TRUE),
(8,  'Giza',     'Haram',      'West',            'Pyramids Rd',   '7',  '12611', TRUE),
(9,  'Dakahlia', 'Mansoura',   'Center',          'University St', '14', '35516', TRUE),
(10, 'Aswan',    'Aswan City', 'South',           'Nile St',       '20', '81511', TRUE);

-- =====================================================
-- SAMPLE DATA — National ID Cards
-- =====================================================

INSERT INTO NationalIDCard (CitizenID, IssueDate, ExpiryDate, CardStatus)
VALUES
(1,  '2015-01-01', '2025-01-01', 'Expired'),
(2,  '2016-02-02', '2026-02-02', 'Active'),
(3,  '2016-01-01', '2026-01-01', 'Active'),
(4,  '2017-05-10', '2027-05-10', 'Active'),
(5,  '2018-03-15', '2028-03-15', 'Active'),
(6,  '2015-01-01', '2025-01-01', 'Expired'),
(7,  '2020-05-05', '2030-05-05', 'Active'),
(8,  '2021-07-07', '2031-07-07', 'Active'),
(9,  '2019-03-03', '2029-03-03', 'Active'),
(10, '2018-09-09', '2028-09-09', 'Active');

-- =====================================================
-- SAMPLE DATA — Birth Records
-- =====================================================

INSERT INTO BirthRecord
(CitizenID, RegistrationDate, HospitalName, DoctorName, FatherID, MotherID)
VALUES
(3, '1990-05-20', 'Cairo General Hospital', 'Dr. Samy', 1, 2),
(4, '1992-08-20', 'Alex Hospital',          'Dr. Adel', 1, 2);

-- =====================================================
-- SAMPLE DATA — Families
-- =====================================================

INSERT INTO Family (FamilyName, HeadCitizenID)
VALUES
('Ali Family',    1),
('Mostafa Family',6),
('Tarek Family',  10);

INSERT INTO FamilyMember (FamilyID, CitizenID, Relationship)
VALUES
(1, 1,  'Father'),
(1, 2,  'Mother'),
(1, 3,  'Son'),
(1, 4,  'Daughter'),
(2, 6,  'Father'),
(2, 7,  'Mother'),
(3, 10, 'Father'),
(3, 9,  'Daughter');

-- =====================================================
-- SAMPLE DATA — Marriages
-- =====================================================

INSERT INTO MarriageRecord
(HusbandID, WifeID, MarriageDate, MarriageLocation, CertificateNo)
VALUES
(5,  4, '2020-06-01', 'Cairo Court', 'MR2020-001'),
(6,  7, '2018-08-08', 'Alex Court',  'MR2020-002'),
(10, 9, '2005-05-05', 'Aswan Court', 'MR2020-003');

-- =====================================================
-- SAMPLE DATA — Death Records
-- =====================================================

INSERT INTO DeathRecord
(CitizenID, DeathDate, CauseOfDeath, PlaceOfDeath, CertificateNo)
VALUES
(1, '2024-02-10', 'Natural Causes', 'Cairo', 'DC-100');

-- =====================================================
-- CRUD OPERATIONS
-- =====================================================

UPDATE Citizen
SET PhoneNumber   = '01001234567',
    MaritalStatus = 'Married'
WHERE CitizenID = 3;

UPDATE Address
SET IsCurrent = FALSE
WHERE CitizenID = 3;

INSERT INTO Address
(CitizenID, Governorate, City, District, Street, IsCurrent)
VALUES
(3, 'Giza', 'Dokki', 'Muhandiseen', 'Tahrir St', TRUE);

DELETE FROM FamilyMember
WHERE FamilyID = 1 AND CitizenID = 4;

DELETE FROM Address
WHERE CitizenID = 3 AND IsCurrent = FALSE;

-- =====================================================
-- VIEW
-- =====================================================

CREATE OR REPLACE VIEW ActiveNationalIDCards AS
SELECT
    c.FirstName,
    c.LastName,
    n.CardStatus,
    n.ExpiryDate
FROM Citizen c
JOIN NationalIDCard n ON c.CitizenID = n.CitizenID
WHERE n.CardStatus = 'Active';

-- =====================================================
-- FUNCTION  (replaces T-SQL scalar function)
-- =====================================================

CREATE OR REPLACE FUNCTION GetCitizenAge(dob DATE)
RETURNS INT
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN DATE_PART('year', AGE(dob))::INT;
END;
$$;

-- =====================================================
-- STORED PROCEDURE  (replaces T-SQL stored procedure)
-- =====================================================

CREATE OR REPLACE FUNCTION GetCitizenByCity(city_name VARCHAR)
RETURNS TABLE (
    FirstName VARCHAR,
    LastName  VARCHAR,
    City      VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT c.FirstName, c.LastName, a.City
    FROM   Citizen c
    JOIN   Address a ON c.CitizenID = a.CitizenID
    WHERE  a.City = city_name;
END;
$$;

-- =====================================================
-- TRIGGER  (replaces T-SQL trigger)
-- =====================================================

CREATE OR REPLACE FUNCTION fn_delete_citizen_address()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM Address WHERE CitizenID = OLD.CitizenID;
    RETURN OLD;
END;
$$;

CREATE TRIGGER trg_DeleteCitizenAddress
BEFORE DELETE ON Citizen
FOR EACH ROW
EXECUTE FUNCTION fn_delete_citizen_address();

-- =====================================================
-- TRANSACTION  (adds one extra citizen safely)
-- =====================================================

BEGIN;

INSERT INTO Citizen
(NationalID, FirstName, LastName, Gender, DateOfBirth, PlaceOfBirth)
VALUES
('EG88888888888888', 'Ali', 'Maher', 'M', '1993-12-12', 'Cairo');

INSERT INTO NationalIDCard (CitizenID, IssueDate, ExpiryDate, CardStatus)
VALUES
(11, '2024-01-01', '2034-01-01', 'Active');

COMMIT;

-- =====================================================
-- VERIFICATION QUERIES  (run these to confirm success)
-- =====================================================

SELECT * FROM Citizen;
SELECT * FROM ActiveNationalIDCards;
SELECT FirstName, LastName, GetCitizenAge(DateOfBirth) AS Age FROM Citizen;
SELECT * FROM GetCitizenByCity('Cairo');
