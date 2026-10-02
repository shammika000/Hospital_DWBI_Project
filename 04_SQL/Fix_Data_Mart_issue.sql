USE Hospital_DW;
GO

SELECT
    h.SourceSystemCode,
    COUNT(*) AS TotalRows,
    SUM(CASE WHEN f.DepartmentKey IS NULL THEN 1 ELSE 0 END)
        AS NullDepartmentRows,
    SUM(CASE WHEN f.DepartmentKey IS NOT NULL THEN 1 ELSE 0 END)
        AS DepartmentAvailableRows
FROM dbo.FactBilling f

INNER JOIN dbo.DimHospitalSource h
    ON f.HospitalSourceKey = h.HospitalSourceKey

GROUP BY h.SourceSystemCode;


/*check that the warehouse dimension itself*/
USE Hospital_DW;
GO

SELECT COUNT(*) AS DepartmentCount
FROM dbo.DimDepartment;

SELECT TOP 20 *
FROM dbo.DimDepartment;

/*check whether the Excel source can actually obtain a department through Doctor*/
SELECT TOP 20
    a.Admission_ID,
    a.Doctor_ID,
    d.Department_ID
FROM Hospital_Staging.dbo.stg_XLSX_Admission a
LEFT JOIN Hospital_Staging.dbo.stg_XLSX_Doctor d
    ON a.Doctor_ID = d.Doctor_ID;


/*delete incorrect rows*/
USE Hospital_DW;
GO

DELETE f
FROM dbo.FactBilling f
INNER JOIN dbo.DimHospitalSource h
    ON f.HospitalSourceKey = h.HospitalSourceKey
WHERE h.SourceSystemCode = 'XLSX';

SELECT COUNT(*) AS RemainingBillingRows
FROM dbo.FactBilling;

/*check again*/
SELECT
    h.SourceSystemCode,
    COUNT(*) AS TotalRows,
    SUM(CASE WHEN f.DepartmentKey IS NULL THEN 1 ELSE 0 END)
        AS NullDepartmentRows,
    SUM(CASE WHEN f.DepartmentKey IS NOT NULL THEN 1 ELSE 0 END)
        AS DepartmentAvailableRows

FROM dbo.FactBilling f

INNER JOIN dbo.DimHospitalSource h
    ON f.HospitalSourceKey = h.HospitalSourceKey

GROUP BY h.SourceSystemCode;