USE Hospital_DW;
GO

SELECT *
FROM dbo.DimHospitalSource;

/*Load_DimDate*/
USE Hospital_DW;
GO

SELECT COUNT(*) AS DateRows
FROM dbo.DimDate;


SELECT TOP 10 *
FROM dbo.DimDate
ORDER BY FullDate;

SELECT
    MIN(FullDate) AS EarliestDate,
    MAX(FullDate) AS LatestDate
FROM dbo.DimDate;


/*Load DimPatient*/

USE Hospital_DW;
GO

SELECT COUNT(*) AS TotalPatients
FROM dbo.DimPatient;

SELECT
    SourceSystemCode,
    COUNT(*) AS PatientCount
FROM dbo.DimPatient
GROUP BY SourceSystemCode;


/*Check standardised gender*/
SELECT
    SourceSystemCode,
    Gender,
    COUNT(*) AS PatientCount
FROM dbo.DimPatient
GROUP BY
    SourceSystemCode,
    Gender
ORDER BY
    SourceSystemCode,
    Gender;


    /*Load_DimDoctor*/
SELECT
    SourceSystemCode,
    COUNT(*) AS DoctorCount
FROM dbo.DimDoctor
GROUP BY SourceSystemCode;

/*Load DimDepartmet*/
SELECT *
FROM dbo.DimDepartment
ORDER BY DepartmentKey;


/*Load DimTreatmentType*/
USE Hospital_DW;
GO

SELECT COUNT(*) AS TotalTreatmentTypes
FROM dbo.DimTreatmentType;


/*Check all dimensions*/

USE Hospital_DW;
GO

SELECT 'Hospital Source' AS DimensionName,
       COUNT(*) AS RowsCount
FROM dbo.DimHospitalSource

UNION ALL

SELECT 'Date',
       COUNT(*)
FROM dbo.DimDate

UNION ALL

SELECT 'Patient',
       COUNT(*)
FROM dbo.DimPatient

UNION ALL

SELECT 'Doctor',
       COUNT(*)
FROM   dbo.DimDoctor
UNION ALL
SELECT 'Department',
       COUNT(*)
FROM   dbo.DimDepartment
UNION ALL
SELECT 'Treatment Type',
       COUNT(*)
FROM   dbo.DimTreatmentType;