/*create Hospital_DW*/

CREATE DATABASE Hospital_DW;
GO

USE Hospital_DW;
GO

/*Create all dimensions*/

CREATE TABLE dbo.DimHospitalSource
(
    HospitalSourceKey INT IDENTITY(1,1) PRIMARY KEY,
    SourceSystemCode VARCHAR(20) NOT NULL UNIQUE,
    SourceSystemName NVARCHAR(100) NOT NULL,
    SourceFormat NVARCHAR(20) NOT NULL
);
GO


CREATE TABLE dbo.DimPatient
(
    PatientKey INT IDENTITY(1,1) PRIMARY KEY,

    SourceSystemCode VARCHAR(20) NOT NULL,
    SourcePatientID NVARCHAR(50) NOT NULL,

    PatientName NVARCHAR(150) NULL,
    Gender NVARCHAR(20) NULL,
    DateOfBirth DATE NULL,
    ContactNumber NVARCHAR(50) NULL,
    City NVARCHAR(100) NULL,
    Address NVARCHAR(250) NULL,
    InsuranceProvider NVARCHAR(100) NULL,
    BloodGroup NVARCHAR(10) NULL,

    CONSTRAINT UQ_DimPatient_Source
        UNIQUE (SourceSystemCode, SourcePatientID)
);
GO


CREATE TABLE dbo.DimDoctor
(
    DoctorKey INT IDENTITY(1,1) PRIMARY KEY,

    SourceSystemCode VARCHAR(20) NOT NULL,
    SourceDoctorID NVARCHAR(50) NOT NULL,

    DoctorName NVARCHAR(150) NULL,
    Specialization NVARCHAR(100) NULL,
    YearsExperience INT NULL,
    ConsultationFee DECIMAL(14,2) NULL,
    HospitalBranch NVARCHAR(100) NULL,

    CONSTRAINT UQ_DimDoctor_Source
        UNIQUE (SourceSystemCode, SourceDoctorID)
);
GO


CREATE TABLE dbo.DimDepartment
(
    DepartmentKey INT IDENTITY(1,1) PRIMARY KEY,

    SourceSystemCode VARCHAR(20) NOT NULL,
    SourceDepartmentID NVARCHAR(50) NOT NULL,

    DepartmentName NVARCHAR(100) NULL,
    FloorNumber INT NULL,

    CONSTRAINT UQ_DimDepartment_Source
        UNIQUE (SourceSystemCode, SourceDepartmentID)
);
GO


CREATE TABLE dbo.DimTreatmentType
(
    TreatmentTypeKey INT IDENTITY(1,1) PRIMARY KEY,
    TreatmentType NVARCHAR(100) NOT NULL UNIQUE
);
GO


CREATE TABLE dbo.DimDate
(
    DateKey INT PRIMARY KEY,
    FullDate DATE NOT NULL UNIQUE,

    DayNumber TINYINT NOT NULL,
    MonthNumber TINYINT NOT NULL,
    MonthName NVARCHAR(20) NOT NULL,
    QuarterNumber TINYINT NOT NULL,
    YearNumber SMALLINT NOT NULL
);
GO


/*Create FactAppointment*/

CREATE TABLE dbo.FactAppointment
(
    AppointmentFactKey BIGINT IDENTITY(1,1) PRIMARY KEY,

    HospitalSourceKey INT NOT NULL,
    PatientKey INT NOT NULL,
    DoctorKey INT NOT NULL,
    AppointmentDateKey INT NOT NULL,

    SourceAppointmentID NVARCHAR(50) NOT NULL,
    AppointmentTime NVARCHAR(20) NULL,
    ReasonForVisit NVARCHAR(250) NULL,
    AppointmentStatus NVARCHAR(50) NULL,

    AppointmentCount INT NOT NULL DEFAULT 1,

    CONSTRAINT FK_Appointment_Source
        FOREIGN KEY (HospitalSourceKey)
        REFERENCES dbo.DimHospitalSource(HospitalSourceKey),

    CONSTRAINT FK_Appointment_Patient
        FOREIGN KEY (PatientKey)
        REFERENCES dbo.DimPatient(PatientKey),

    CONSTRAINT FK_Appointment_Doctor
        FOREIGN KEY (DoctorKey)
        REFERENCES dbo.DimDoctor(DoctorKey),

    CONSTRAINT FK_Appointment_Date
        FOREIGN KEY (AppointmentDateKey)
        REFERENCES dbo.DimDate(DateKey),

    CONSTRAINT UQ_FactAppointment_Source
        UNIQUE (HospitalSourceKey, SourceAppointmentID)
);
GO

/*Create FactAdmission*/

CREATE TABLE dbo.FactAdmission
(
    AdmissionFactKey BIGINT IDENTITY(1,1) PRIMARY KEY,

    HospitalSourceKey INT NOT NULL,
    PatientKey INT NOT NULL,
    DoctorKey INT NOT NULL,
    DepartmentKey INT NULL,

    AdmissionDateKey INT NOT NULL,
    DischargeDateKey INT NULL,

    SourceAdmissionID NVARCHAR(50) NOT NULL,
    RoomType NVARCHAR(50) NULL,

    LengthOfStay INT NULL,
    AdmissionCount INT NOT NULL DEFAULT 1,

    CONSTRAINT FK_Admission_Source
        FOREIGN KEY (HospitalSourceKey)
        REFERENCES dbo.DimHospitalSource(HospitalSourceKey),

    CONSTRAINT FK_Admission_Patient
        FOREIGN KEY (PatientKey)
        REFERENCES dbo.DimPatient(PatientKey),

    CONSTRAINT FK_Admission_Doctor
        FOREIGN KEY (DoctorKey)
        REFERENCES dbo.DimDoctor(DoctorKey),

    CONSTRAINT FK_Admission_Department
        FOREIGN KEY (DepartmentKey)
        REFERENCES dbo.DimDepartment(DepartmentKey),

    CONSTRAINT FK_Admission_Date
        FOREIGN KEY (AdmissionDateKey)
        REFERENCES dbo.DimDate(DateKey),

    CONSTRAINT FK_Discharge_Date
        FOREIGN KEY (DischargeDateKey)
        REFERENCES dbo.DimDate(DateKey),

    CONSTRAINT UQ_FactAdmission_Source
        UNIQUE (HospitalSourceKey, SourceAdmissionID)
);
GO


/*Create FactTreatment*/

CREATE TABLE dbo.FactTreatment
(
    TreatmentFactKey BIGINT IDENTITY(1,1) PRIMARY KEY,

    HospitalSourceKey INT NOT NULL,
    PatientKey INT NOT NULL,
    DoctorKey INT NOT NULL,
    DepartmentKey INT NULL,
    TreatmentTypeKey INT NOT NULL,

    EncounterDateKey INT NOT NULL,
    TreatmentDateKey INT NULL,

    SourceEncounterID NVARCHAR(50) NOT NULL,
    SourceTreatmentID NVARCHAR(50) NOT NULL,

    TreatmentCost DECIMAL(14,2) NULL,
    MedicineCost DECIMAL(14,2) NULL,
    LabCost DECIMAL(14,2) NULL,
    TotalTreatmentCost DECIMAL(14,2) NULL,

    TreatmentCount INT NOT NULL DEFAULT 1,

    CONSTRAINT FK_Treatment_Source
        FOREIGN KEY (HospitalSourceKey)
        REFERENCES dbo.DimHospitalSource(HospitalSourceKey),

    CONSTRAINT FK_Treatment_Patient
        FOREIGN KEY (PatientKey)
        REFERENCES dbo.DimPatient(PatientKey),

    CONSTRAINT FK_Treatment_Doctor
        FOREIGN KEY (DoctorKey)
        REFERENCES dbo.DimDoctor(DoctorKey),

    CONSTRAINT FK_Treatment_Department
        FOREIGN KEY (DepartmentKey)
        REFERENCES dbo.DimDepartment(DepartmentKey),

    CONSTRAINT FK_Treatment_Type
        FOREIGN KEY (TreatmentTypeKey)
        REFERENCES dbo.DimTreatmentType(TreatmentTypeKey),

    CONSTRAINT FK_Treatment_EncounterDate
        FOREIGN KEY (EncounterDateKey)
        REFERENCES dbo.DimDate(DateKey),

    CONSTRAINT FK_Treatment_TreatmentDate
        FOREIGN KEY (TreatmentDateKey)
        REFERENCES dbo.DimDate(DateKey),

    CONSTRAINT UQ_FactTreatment_Source
        UNIQUE (HospitalSourceKey, SourceTreatmentID)
);
GO


/*Create FactBilling*/

CREATE TABLE dbo.FactBilling
(
    BillingFactKey BIGINT IDENTITY(1,1) PRIMARY KEY,

    HospitalSourceKey INT NOT NULL,
    PatientKey INT NOT NULL,
    DoctorKey INT NOT NULL,
    DepartmentKey INT NULL,

    EncounterDateKey INT NOT NULL,
    BillingDateKey INT NULL,

    SourceEncounterID NVARCHAR(50) NOT NULL,
    SourceBillID NVARCHAR(50) NOT NULL,

    PaymentMethod NVARCHAR(50) NULL,
    PaymentStatus NVARCHAR(50) NULL,

    TotalBill DECIMAL(14,2) NULL,
    InsuranceCover DECIMAL(14,2) NULL,
    FinalAmountPayable DECIMAL(14,2) NULL,

    EMIMonths INT NULL,
    MonthlyEMI DECIMAL(14,2) NULL,

    BillingCount INT NOT NULL DEFAULT 1,

    CONSTRAINT FK_Billing_Source
        FOREIGN KEY (HospitalSourceKey)
        REFERENCES dbo.DimHospitalSource(HospitalSourceKey),

    CONSTRAINT FK_Billing_Patient
        FOREIGN KEY (PatientKey)
        REFERENCES dbo.DimPatient(PatientKey),

    CONSTRAINT FK_Billing_Doctor
        FOREIGN KEY (DoctorKey)
        REFERENCES dbo.DimDoctor(DoctorKey),

    CONSTRAINT FK_Billing_Department
        FOREIGN KEY (DepartmentKey)
        REFERENCES dbo.DimDepartment(DepartmentKey),

    CONSTRAINT FK_Billing_EncounterDate
        FOREIGN KEY (EncounterDateKey)
        REFERENCES dbo.DimDate(DateKey),

    CONSTRAINT FK_Billing_Date
        FOREIGN KEY (BillingDateKey)
        REFERENCES dbo.DimDate(DateKey),

    CONSTRAINT UQ_FactBilling_Source
        UNIQUE (HospitalSourceKey, SourceBillID)
);
GO


/*Check hospital DW*/

USE Hospital_DW;
GO

SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
ORDER BY TABLE_NAME;


SELECT COUNT(*) AS Patients FROM dbo.DimPatient;
SELECT COUNT(*) AS Doctors FROM dbo.DimDoctor;
SELECT COUNT(*) AS Appointments FROM dbo.FactAppointment;
SELECT COUNT(*) AS Admissions FROM dbo.FactAdmission;
SELECT COUNT(*) AS Treatments FROM dbo.FactTreatment;
SELECT COUNT(*) AS Billing FROM dbo.FactBilling;