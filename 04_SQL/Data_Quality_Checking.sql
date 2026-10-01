/*Data Quality Checking*/

/*1. Check for NULL values*/

USE Hospital_Staging;
GO

--dataset1
SELECT
    SUM(CASE WHEN patient_id IS NULL THEN 1 ELSE 0 END) AS NullPatientIDs
FROM dbo.stg_CSV_Patient;

SELECT
    SUM(CASE WHEN doctor_id IS NULL THEN 1 ELSE 0 END) AS NullDoctorIDs
FROM dbo.stg_CSV_Doctor;

SELECT
    SUM(CASE WHEN appointment_id IS NULL THEN 1 ELSE 0 END) AS NullAppointmentIDs
FROM dbo.stg_CSV_Appointment;

SELECT
    SUM(CASE WHEN Treatment_ID IS NULL THEN 1 ELSE 0 END) AS NullTreatmentIDs
FROM dbo.stg_XLSX_Treatment;

SELECT
    SUM(CASE WHEN Admission_ID IS NULL THEN 1 ELSE 0 END) AS NullAdmissionIDs
FROM dbo.stg_XLSX_Admission;

--dataset2

SELECT
    SUM(CASE WHEN Patient_ID IS NULL THEN 1 ELSE 0 END) AS NullExcelPatientIDs
FROM dbo.stg_XLSX_Patient;

SELECT
    SUM(CASE WHEN Doctor_ID IS NULL THEN 1 ELSE 0 END) AS NullExcelDoctorIDs
FROM dbo.stg_XLSX_Doctor;

SELECT
    SUM(CASE WHEN Department_ID IS NULL THEN 1 ELSE 0 END) AS NullDepartmentIDs
FROM dbo.stg_XLSX_Department;

SELECT
    SUM(CASE WHEN Admission_ID IS NULL THEN 1 ELSE 0 END) AS NullAdmissionIDs
FROM dbo.stg_XLSX_Admission;

SELECT
    SUM(CASE WHEN Treatment_ID IS NULL THEN 1 ELSE 0 END) AS NullTreatmentIDs
FROM dbo.stg_XLSX_Treatment;

SELECT
    SUM(CASE WHEN Admission_ID IS NULL THEN 1 ELSE 0 END) AS NullBillingAdmissionIDs
FROM dbo.stg_XLSX_Billing;

SELECT
    SUM(CASE WHEN [Date] IS NULL THEN 1 ELSE 0 END) AS NullCalendarDates
FROM dbo.stg_XLSX_Calendar;

/*Check duplicate IDs*/

SELECT patient_id, COUNT(*) AS Occurrences
FROM dbo.stg_CSV_Patient
GROUP BY patient_id
HAVING COUNT(*) > 1;

SELECT doctor_id, COUNT(*) AS Occurrences
FROM dbo.stg_CSV_Doctor
GROUP BY doctor_id
HAVING COUNT(*) > 1;

SELECT appointment_id, COUNT(*) AS Occurrences
FROM dbo.stg_CSV_Appointment
GROUP BY appointment_id
HAVING COUNT(*) > 1;

SELECT Patient_ID, COUNT(*) AS Occurrences
FROM dbo.stg_XLSX_Patient
GROUP BY Patient_ID
HAVING COUNT(*) > 1;

SELECT Admission_ID, COUNT(*) AS Occurrences
FROM dbo.stg_XLSX_Admission
GROUP BY Admission_ID
HAVING COUNT(*) > 1;

/*Check relationships inside CSV source*/


/*Check appointment → patient (confirm there are no appointments referring to nonexistent patients)*/
SELECT a.*
FROM dbo.stg_CSV_Appointment a
LEFT JOIN dbo.stg_CSV_Patient p
    ON a.patient_id = p.patient_id
WHERE p.patient_id IS NULL;

/*Check appointment → doctor:*/
SELECT a.*
FROM dbo.stg_CSV_Appointment a
LEFT JOIN dbo.stg_CSV_Doctor d
    ON a.doctor_id = d.doctor_id
WHERE d.doctor_id IS NULL;

/*Treatment → appointment:*/
SELECT t.*
FROM dbo.stg_CSV_Treatment t
LEFT JOIN dbo.stg_CSV_Appointment a
    ON t.appointment_id = a.appointment_id
WHERE a.appointment_id IS NULL;

/*Billing → treatment*/
SELECT b.*
FROM dbo.stg_CSV_Billing b
LEFT JOIN dbo.stg_CSV_Treatment t
    ON b.treatment_id = t.treatment_id
WHERE t.treatment_id IS NULL;



/*Check relationships inside Excel source*/

/*Admission → Patient*/
SELECT a.*
FROM dbo.stg_XLSX_Admission a
LEFT JOIN dbo.stg_XLSX_Patient p
    ON a.Patient_ID = p.Patient_ID
WHERE p.Patient_ID IS NULL;

/*Admission → Doctor*/
SELECT a.*
FROM dbo.stg_XLSX_Admission a
LEFT JOIN dbo.stg_XLSX_Doctor d
    ON a.Doctor_ID = d.Doctor_ID
WHERE d.Doctor_ID IS NULL;

/*Doctor → Department*/
SELECT d.*
FROM dbo.stg_XLSX_Doctor d
LEFT JOIN dbo.stg_XLSX_Department dp
    ON d.Department_ID = dp.Department_ID
WHERE dp.Department_ID IS NULL;

/*Treatment → Admission*/
SELECT t.*
FROM dbo.stg_XLSX_Treatment t
LEFT JOIN dbo.stg_XLSX_Admission a
    ON t.Admission_ID = a.Admission_ID
WHERE a.Admission_ID IS NULL;

/*Billing → Admission*/
SELECT b.*
FROM dbo.stg_XLSX_Billing b
LEFT JOIN dbo.stg_XLSX_Admission a
    ON b.Admission_ID = a.Admission_ID
WHERE a.Admission_ID IS NULL;
