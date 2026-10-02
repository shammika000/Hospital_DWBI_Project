IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'ssas_hospital')
BEGIN
    CREATE LOGIN [ssas_hospital] WITH PASSWORD = N'HospitalSsas!2026', CHECK_POLICY = OFF;
END
ELSE
BEGIN
    ALTER LOGIN [ssas_hospital] WITH PASSWORD = N'HospitalSsas!2026', CHECK_POLICY = OFF;
END
GO
USE Hospital_Finance_DM;
GO
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'ssas_hospital')
BEGIN
    CREATE USER [ssas_hospital] FOR LOGIN [ssas_hospital];
END
ALTER ROLE db_datareader ADD MEMBER [ssas_hospital];
ALTER ROLE db_datawriter ADD MEMBER [ssas_hospital];
SELECT name FROM sys.database_principals WHERE name = N'ssas_hospital';
GO
