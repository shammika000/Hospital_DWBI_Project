CREATE DATABASE Hospital_Finance_DM;
GO

USE Hospital_Finance_DM;
GO

/*Create the Finance Data Mart tables*/
CREATE TABLE dbo.DimHospitalSource
(
    HospitalSourceKey INT NOT NULL PRIMARY KEY,
    SourceSystemCode VARCHAR(20) NOT NULL,
    SourceSystemName NVARCHAR(100),
    SourceFormat NVARCHAR(30)
);
GO


CREATE TABLE dbo.DimDate
(
    DateKey INT NOT NULL PRIMARY KEY,
    FullDate DATE NOT NULL,
    DayNumber INT,
    MonthNumber INT,
    MonthName NVARCHAR(20),
    QuarterNumber INT,
    YearNumber INT
);
GO


CREATE TABLE dbo.DimPatientFinance
(
    PatientKey INT NOT NULL PRIMARY KEY,
    Gender NVARCHAR(20),
    City NVARCHAR(100),
    InsuranceProvider NVARCHAR(150)
);
GO


CREATE TABLE dbo.DimDoctorFinance
(
    DoctorKey INT NOT NULL PRIMARY KEY,
    DoctorName NVARCHAR(200),
    Specialization NVARCHAR(150)
);
GO


CREATE TABLE dbo.DimDepartmentFinance
(
    DepartmentKey INT NOT NULL PRIMARY KEY,
    DepartmentName NVARCHAR(150),
    FloorNumber INT
);
GO


CREATE TABLE dbo.FactFinanceBilling
(
    BillingFactKey INT NOT NULL PRIMARY KEY,

    HospitalSourceKey INT NOT NULL,
    PatientKey INT NOT NULL,
    DoctorKey INT NOT NULL,
    DepartmentKey INT NULL,

    EncounterDateKey INT NOT NULL,
    BillingDateKey INT NULL,

    -- Common date used later for integrated trend reporting
    ReportingDateKey INT NOT NULL,

    SourceBillID NVARCHAR(50),

    PaymentMethod NVARCHAR(50),
    PaymentStatus NVARCHAR(50),

    TotalBill DECIMAL(14,2),
    InsuranceCover DECIMAL(14,2),
    FinalAmountPayable DECIMAL(14,2),

    EMIMonths INT,
    MonthlyEMI DECIMAL(14,2),

    BillingCount INT,

    CONSTRAINT FK_Finance_Source
        FOREIGN KEY (HospitalSourceKey)
        REFERENCES dbo.DimHospitalSource(HospitalSourceKey),

    CONSTRAINT FK_Finance_Patient
        FOREIGN KEY (PatientKey)
        REFERENCES dbo.DimPatientFinance(PatientKey),

    CONSTRAINT FK_Finance_Doctor
        FOREIGN KEY (DoctorKey)
        REFERENCES dbo.DimDoctorFinance(DoctorKey),

    CONSTRAINT FK_Finance_Department
        FOREIGN KEY (DepartmentKey)
        REFERENCES dbo.DimDepartmentFinance(DepartmentKey),

    CONSTRAINT FK_Finance_EncounterDate
        FOREIGN KEY (EncounterDateKey)
        REFERENCES dbo.DimDate(DateKey),

    CONSTRAINT FK_Finance_BillingDate
        FOREIGN KEY (BillingDateKey)
        REFERENCES dbo.DimDate(DateKey),

    CONSTRAINT FK_Finance_ReportingDate
        FOREIGN KEY (ReportingDateKey)
        REFERENCES dbo.DimDate(DateKey)
);
GO

/*Validate the Finance Data Mart*/
USE Hospital_Finance_DM;
GO

SELECT 'DimHospitalSource' AS TableName, COUNT(*) AS RowsCount
FROM dbo.DimHospitalSource

UNION ALL

SELECT 'DimDate', COUNT(*)
FROM dbo.DimDate

UNION ALL

SELECT 'DimPatientFinance', COUNT(*)
FROM dbo.DimPatientFinance

UNION ALL

SELECT 'DimDoctorFinance', COUNT(*)
FROM dbo.DimDoctorFinance

UNION ALL

SELECT 'DimDepartmentFinance', COUNT(*)
FROM dbo.DimDepartmentFinance

UNION ALL

SELECT 'FactFinanceBilling', COUNT(*)
FROM dbo.FactFinanceBilling;



/*Check data mart is correct */
SELECT
    h.SourceSystemCode,

    COUNT(*) AS TotalRows,

    SUM(
        CASE
            WHEN f.DepartmentKey IS NULL THEN 1
            ELSE 0
        END
    ) AS NullDepartmentRows,

    SUM(
        CASE
            WHEN f.DepartmentKey IS NOT NULL THEN 1
            ELSE 0
        END
    ) AS DepartmentAvailableRows

FROM dbo.FactFinanceBilling f

INNER JOIN dbo.DimHospitalSource h
    ON f.HospitalSourceKey = h.HospitalSourceKey

GROUP BY h.SourceSystemCode;



/*validate both sources*/

SELECT
    h.SourceSystemCode,
    COUNT(*) AS BillingRecords,
    SUM(f.TotalBill) AS TotalBill,
    SUM(f.InsuranceCover) AS InsuranceCover,
    SUM(f.FinalAmountPayable) AS FinalAmountPayable

FROM dbo.FactFinanceBilling f

INNER JOIN dbo.DimHospitalSource h
    ON f.HospitalSourceKey = h.HospitalSourceKey

GROUP BY h.SourceSystemCode;


/*test department-level financial analysis*/
SELECT
    COALESCE(d.DepartmentName, 'Not Available') AS Department,
    COUNT(*) AS BillingRecords,
    SUM(f.TotalBill) AS TotalBillingAmount,
    SUM(f.FinalAmountPayable) AS FinalPayable

FROM dbo.FactFinanceBilling f

LEFT JOIN dbo.DimDepartmentFinance d
    ON f.DepartmentKey = d.DepartmentKey

GROUP BY
    COALESCE(d.DepartmentName, 'Not Available')

ORDER BY TotalBillingAmount DESC;

/*Delete only the old XLSX rows from the Finance Data Mart*/
USE Hospital_Finance_DM;
GO

DELETE f
FROM dbo.FactFinanceBilling f
INNER JOIN dbo.DimHospitalSource h
    ON f.HospitalSourceKey = h.HospitalSourceKey
WHERE h.SourceSystemCode = 'XLSX';


SELECT COUNT(*) AS RemainingRows
FROM dbo.FactFinanceBilling;


/*now check again data mart work correctly*/
SELECT
    h.SourceSystemCode,
    COUNT(*) AS TotalRows,

    SUM(
        CASE
            WHEN f.DepartmentKey IS NULL THEN 1
            ELSE 0
        END
    ) AS NullDepartmentRows,

    SUM(
        CASE
            WHEN f.DepartmentKey IS NOT NULL THEN 1
            ELSE 0
        END
    ) AS DepartmentAvailableRows

FROM dbo.FactFinanceBilling f

INNER JOIN dbo.DimHospitalSource h
    ON f.HospitalSourceKey = h.HospitalSourceKey

GROUP BY h.SourceSystemCode;



/*Run your department-level financial analysis again*/

SELECT
    h.SourceSystemCode,

    COALESCE(
        d.DepartmentName,
        'Not Available'
    ) AS Department,

    COUNT(*) AS BillingRecords,

    SUM(f.TotalBill) AS TotalBillingAmount,

    SUM(f.FinalAmountPayable) AS FinalPayable

FROM dbo.FactFinanceBilling f

INNER JOIN dbo.DimHospitalSource h
    ON f.HospitalSourceKey = h.HospitalSourceKey

LEFT JOIN dbo.DimDepartmentFinance d
    ON f.DepartmentKey = d.DepartmentKey

GROUP BY
    h.SourceSystemCode,
    COALESCE(
        d.DepartmentName,
        'Not Available'
    )

ORDER BY
    h.SourceSystemCode,
    TotalBillingAmount DESC;