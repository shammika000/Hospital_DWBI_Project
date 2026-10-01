/*Create staging database*/
CREATE DATABASE Hospital_Staging;
GO

USE Hospital_Staging;
GO

/*create stg_CSV_Patient table*/
CREATE TABLE dbo.stg_CSV_Patient
(
    patient_id          VARCHAR(10),
    first_name          VARCHAR(50),
    last_name           VARCHAR(50),
    gender              VARCHAR(10),
    date_of_birth       VARCHAR(20),
    contact_number      VARCHAR(20),
    address             VARCHAR(200),
    registration_date   VARCHAR(20),
    insurance_provider  VARCHAR(100),
    insurance_number    VARCHAR(50),
    email               VARCHAR(150)
);
GO

SELECT *
FROM dbo.stg_CSV_Patient;

USE Hospital_Staging;
GO

SELECT COUNT(*) AS TotalPatients
FROM dbo.stg_CSV_Patient;

USE Hospital_Staging;
GO

CREATE TABLE dbo.stg_CSV_Doctor
(
    doctor_id          VARCHAR(10),
    first_name         VARCHAR(50),
    last_name          VARCHAR(50),
    specialization     VARCHAR(100),
    phone_number       VARCHAR(30),
    years_experience   VARCHAR(20),
    hospital_branch    VARCHAR(100),
    email              VARCHAR(150)
);
GO

CREATE TABLE dbo.stg_CSV_Appointment
(
    appointment_id      VARCHAR(20),
    patient_id          VARCHAR(10),
    doctor_id           VARCHAR(10),
    appointment_date    VARCHAR(20),
    appointment_time    VARCHAR(20),
    reason_for_visit    VARCHAR(200),
    status              VARCHAR(50)
);
GO

CREATE TABLE dbo.stg_CSV_Treatment
(
    treatment_id       VARCHAR(20),
    appointment_id     VARCHAR(20),
    treatment_type     VARCHAR(100),
    description        VARCHAR(300),
    cost               VARCHAR(30),
    treatment_date     VARCHAR(20)
);
GO

CREATE TABLE dbo.stg_CSV_Billing
(
    bill_id             VARCHAR(20),
    patient_id          VARCHAR(10),
    treatment_id        VARCHAR(20),
    bill_date           VARCHAR(20),
    amount              VARCHAR(30),
    payment_method      VARCHAR(50),
    payment_status      VARCHAR(50)
);
GO

SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME LIKE 'stg_CSV%';


/*Check stg_CSV_Doctor*/

SELECT COUNT(*) AS TotalDoctors
FROM dbo.stg_CSV_Doctor;

/*Check stg_CSV_Appointment*/
SELECT COUNT(*) AS TotalAppointments
FROM dbo.stg_CSV_Appointment;

/*Check stg_CSV_Treatment*/
SELECT COUNT(*) AS TotalTreatments
FROM dbo.stg_CSV_Treatment;

/*Check stg_CSV_Billing*/
SELECT COUNT(*) AS TotalBilling
FROM dbo.stg_CSV_Billing;

/*Final validation for Dataset 1*/
SELECT 'Patient' AS TableName, COUNT(*) AS RowsCount
FROM dbo.stg_CSV_Patient

UNION ALL

SELECT 'Doctor', COUNT(*)
FROM dbo.stg_CSV_Doctor

UNION ALL

SELECT 'Appointment', COUNT(*)
FROM dbo.stg_CSV_Appointment

UNION ALL

SELECT 'Treatment', COUNT(*)
FROM dbo.stg_CSV_Treatment

UNION ALL

SELECT 'Billing', COUNT(*)
FROM dbo.stg_CSV_Billing;


/*extract Excel dataset2*/

USE Hospital_Staging;
GO

CREATE TABLE dbo.stg_XLSX_Patient
(
    Patient_ID       INT,
    Patient_Name     NVARCHAR(100),
    Gender           NVARCHAR(20),
    Date_of_Birth    DATE,
    Blood_Group      NVARCHAR(10),
    Phone            NVARCHAR(30),
    City             NVARCHAR(100)
);
GO

CREATE TABLE dbo.stg_XLSX_Doctor
(
    Doctor_ID          INT,
    Doctor_Name        NVARCHAR(100),
    Department_ID      INT,
    Specialization     NVARCHAR(100),
    Consultation_Fee   DECIMAL(12,2)
);
GO

CREATE TABLE dbo.stg_XLSX_Department
(
    Department_ID      INT,
    Department_Name    NVARCHAR(100),
    Floor_Number       INT
);
GO

CREATE TABLE dbo.stg_XLSX_Admission
(
    Admission_ID       INT,
    Patient_ID         INT,
    Doctor_ID          INT,
    Admission_Date     DATE,
    Room_Type          NVARCHAR(50),
    Discharge_Date     DATE
);
GO

CREATE TABLE dbo.stg_XLSX_Treatment
(
    Treatment_ID       INT,
    Admission_ID       INT,
    Treatment_Type     NVARCHAR(100),
    Treatment_Cost     DECIMAL(12,2),
    Medicine_Cost      DECIMAL(12,2),
    Lab_Cost           DECIMAL(12,2)
);
GO

CREATE TABLE dbo.stg_XLSX_Billing
(
    Admission_ID           INT,
    Total_Bill             DECIMAL(12,2),
    Insurance_Cover        DECIMAL(12,2),
    Final_Amount_Payable   DECIMAL(12,2),
    Payment_Mode           NVARCHAR(50),
    EMI_Months             INT,
    Monthly_EMI            DECIMAL(12,2),
    Payment_Status         NVARCHAR(50)
);
GO

CREATE TABLE dbo.stg_XLSX_Calendar
(
    [Date]       DATE,
    [Month]      NVARCHAR(20),
    Month_No     INT,
    [Quarter]    NVARCHAR(10),
    [Year]       INT
);
GO

SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME LIKE 'stg_XLSX%';

/*check stg_XLSX_Patient*/
USE Hospital_Staging;
GO

SELECT COUNT(*) AS TotalExcelPatients
FROM dbo.stg_XLSX_Patient;

SELECT TOP 5 *
FROM dbo.stg_XLSX_Patient;


/*Final validation for Dataset 2*/

SELECT 'XLSX Patient' AS TableName, COUNT(*) AS RowsCount
FROM dbo.stg_XLSX_Patient

UNION ALL

SELECT 'XLSX Doctor', COUNT(*)
FROM dbo.stg_XLSX_Doctor

UNION ALL

SELECT 'XLSX Department', COUNT(*)
FROM dbo.stg_XLSX_Department

UNION ALL

SELECT 'XLSX Admission', COUNT(*)
FROM dbo.stg_XLSX_Admission

UNION ALL

SELECT 'XLSX Treatment', COUNT(*)
FROM dbo.stg_XLSX_Treatment

UNION ALL

SELECT 'XLSX Billing', COUNT(*)
FROM dbo.stg_XLSX_Billing

UNION ALL

SELECT 'XLSX Calendar', COUNT(*)
FROM dbo.stg_XLSX_Calendar;

/*fix repeated data issue*/

USE Hospital_Staging;
GO

TRUNCATE TABLE dbo.stg_XLSX_Patient;
TRUNCATE TABLE dbo.stg_XLSX_Doctor;
TRUNCATE TABLE dbo.stg_XLSX_Department;
TRUNCATE TABLE dbo.stg_XLSX_Admission;
TRUNCATE TABLE dbo.stg_XLSX_Treatment;
TRUNCATE TABLE dbo.stg_XLSX_Billing;
TRUNCATE TABLE dbo.stg_XLSX_Calendar;
GO


SELECT 'XLSX Patient' AS TableName, COUNT(*) AS RowsCount
FROM dbo.stg_XLSX_Patient

UNION ALL
SELECT 'XLSX Doctor', COUNT(*) FROM dbo.stg_XLSX_Doctor

UNION ALL
SELECT 'XLSX Department', COUNT(*) FROM dbo.stg_XLSX_Department

UNION ALL
SELECT 'XLSX Admission', COUNT(*) FROM dbo.stg_XLSX_Admission

UNION ALL
SELECT 'XLSX Treatment', COUNT(*) FROM dbo.stg_XLSX_Treatment

UNION ALL
SELECT 'XLSX Billing', COUNT(*) FROM dbo.stg_XLSX_Billing

UNION ALL
SELECT 'XLSX Calendar', COUNT(*) FROM dbo.stg_XLSX_Calendar;


/*After fixing issue, Final validation for Dataset 2*/

SELECT 'XLSX Patient' AS TableName, COUNT(*) AS RowsCount
FROM dbo.stg_XLSX_Patient

UNION ALL

SELECT 'XLSX Doctor', COUNT(*)
FROM dbo.stg_XLSX_Doctor

UNION ALL

SELECT 'XLSX Department', COUNT(*)
FROM dbo.stg_XLSX_Department

UNION ALL

SELECT 'XLSX Admission', COUNT(*)
FROM dbo.stg_XLSX_Admission

UNION ALL

SELECT 'XLSX Treatment', COUNT(*)
FROM dbo.stg_XLSX_Treatment

UNION ALL

SELECT 'XLSX Billing', COUNT(*)
FROM dbo.stg_XLSX_Billing

UNION ALL

SELECT 'XLSX Calendar', COUNT(*)
FROM dbo.stg_XLSX_Calendar;

/*fix repeated data issue for dataset1*/

USE Hospital_Staging;
GO

TRUNCATE TABLE dbo.stg_CSV_Patient;
TRUNCATE TABLE dbo.stg_CSV_Doctor;
TRUNCATE TABLE dbo.stg_CSV_Appointment;
TRUNCATE TABLE dbo.stg_CSV_Treatment;
TRUNCATE TABLE dbo.stg_CSV_Billing;
GO

/*after fix*/
SELECT 'Patient' AS TableName, COUNT(*) AS RowsCount
FROM dbo.stg_CSV_Patient

UNION ALL
SELECT 'Doctor', COUNT(*)
FROM dbo.stg_CSV_Doctor

UNION ALL
SELECT 'Appointment', COUNT(*)
FROM dbo.stg_CSV_Appointment

UNION ALL
SELECT 'Treatment', COUNT(*)
FROM dbo.stg_CSV_Treatment

UNION ALL
SELECT 'Billing', COUNT(*)
FROM dbo.stg_CSV_Billing;





