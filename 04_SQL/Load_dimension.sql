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

/*load FactAppointment*/
SELECT TOP 10 *
FROM dbo.FactAppointment;


SELECT COUNT(*) AS StagingAppointments
FROM Hospital_Staging.dbo.stg_CSV_Appointment;

SELECT COUNT(*) AS DWAppointments
FROM Hospital_DW.dbo.FactAppointment;

/*Check actual dimensional relationships*/

SELECT TOP 10
    f.SourceAppointmentID,
    p.SourcePatientID,
    p.PatientName,
    d.SourceDoctorID,
    d.DoctorName,
    dt.FullDate AS AppointmentDate,
    f.AppointmentStatus
FROM dbo.FactAppointment f

INNER JOIN dbo.DimPatient p
    ON f.PatientKey = p.PatientKey

INNER JOIN dbo.DimDoctor d
    ON f.DoctorKey = d.DoctorKey

INNER JOIN dbo.DimDate dt
    ON f.AppointmentDateKey = dt.DateKey;



/*load FactAdmission*/

SELECT COUNT(*) AS StagingAdmissions
FROM Hospital_Staging.dbo.stg_XLSX_Admission;

SELECT COUNT(*) AS DWAdmissions
FROM Hospital_DW.dbo.FactAdmission;


/*Validate LengthOfStay*/
SELECT
    MIN(LengthOfStay) AS MinimumStay,
    MAX(LengthOfStay) AS MaximumStay,
    AVG(CAST(LengthOfStay AS DECIMAL(10,2))) AS AverageStay
FROM dbo.FactAdmission;


SELECT COUNT(*) AS NegativeLengthOfStay
FROM dbo.FactAdmission
WHERE LengthOfStay < 0;

/*Check dimensional relationships*/
SELECT TOP 10
    f.SourceAdmissionID,

    p.SourcePatientID,
    p.PatientName,

    d.SourceDoctorID,
    d.DoctorName,

    dp.DepartmentName,

    ad.FullDate AS AdmissionDate,
    dd.FullDate AS DischargeDate,

    f.RoomType,
    f.LengthOfStay

FROM dbo.FactAdmission f

INNER JOIN dbo.DimPatient p
    ON f.PatientKey = p.PatientKey

INNER JOIN dbo.DimDoctor d
    ON f.DoctorKey = d.DoctorKey

LEFT JOIN dbo.DimDepartment dp
    ON f.DepartmentKey = dp.DepartmentKey

INNER JOIN dbo.DimDate ad
    ON f.AdmissionDateKey = ad.DateKey

LEFT JOIN dbo.DimDate dd
    ON f.DischargeDateKey = dd.DateKey;


/*Load FactTreatment*/
SELECT
    h.SourceSystemCode,
    COUNT(*) AS TreatmentCount
FROM dbo.FactTreatment f

INNER JOIN dbo.DimHospitalSource h
    ON f.HospitalSourceKey = h.HospitalSourceKey

GROUP BY h.SourceSystemCode;


/*Validate treatment costs*/
SELECT
    h.SourceSystemCode,

    COUNT(*) AS TreatmentRows,

    SUM(f.TreatmentCost) AS TreatmentCost,

    SUM(f.MedicineCost) AS MedicineCost,

    SUM(f.LabCost) AS LabCost,

    SUM(f.TotalTreatmentCost) AS TotalTreatmentCost

FROM dbo.FactTreatment f

INNER JOIN dbo.DimHospitalSource h
    ON f.HospitalSourceKey = h.HospitalSourceKey

GROUP BY h.SourceSystemCode;


/*load FactBilling*/
SELECT
    h.SourceSystemCode,
    COUNT(*) AS BillingRows
FROM dbo.FactBilling f
INNER JOIN dbo.DimHospitalSource h
    ON f.HospitalSourceKey = h.HospitalSourceKey
GROUP BY h.SourceSystemCode;

/*check financial measures*/
SELECT
    h.SourceSystemCode,

    COUNT(*) AS BillingRows,

    SUM(f.TotalBill) AS TotalBillingAmount,

    SUM(f.InsuranceCover) AS TotalInsuranceCover,

    SUM(f.FinalAmountPayable) AS TotalFinalPayable

FROM dbo.FactBilling f

INNER JOIN dbo.DimHospitalSource h
    ON f.HospitalSourceKey = h.HospitalSourceKey

GROUP BY h.SourceSystemCode;



/*Final ETL pipeline validation*/

USE Hospital_DW;
GO

SELECT 'DimHospitalSource' AS TableName, COUNT(*) AS RowsCount
FROM dbo.DimHospitalSource

UNION ALL
SELECT 'DimDate', COUNT(*) FROM dbo.DimDate

UNION ALL
SELECT 'DimPatient', COUNT(*) FROM dbo.DimPatient

UNION ALL
SELECT 'DimDoctor', COUNT(*) FROM dbo.DimDoctor

UNION ALL
SELECT 'DimDepartment', COUNT(*) FROM dbo.DimDepartment

UNION ALL
SELECT 'DimTreatmentType', COUNT(*) FROM dbo.DimTreatmentType

UNION ALL
SELECT 'FactAppointment', COUNT(*) FROM dbo.FactAppointment

UNION ALL
SELECT 'FactAdmission', COUNT(*) FROM dbo.FactAdmission

UNION ALL
SELECT 'FactTreatment', COUNT(*) FROM dbo.FactTreatment

UNION ALL
SELECT 'FactBilling', COUNT(*) FROM dbo.FactBilling;