/*
   FILENAME: 10_Security_Implementation.sql
   DESCRIPTION: Implementasi keamanan (User, Roles, Permissions, Data Masking)
*/

USE Kepegawaian_DB;
GO

PRINT '=== MULAI IMPLEMENTASI SECURITY ===';

-- =============================================================
-- 1. MEMBUAT LOGIN DAN USER (Simulasi)
-- =============================================================
PRINT '1. Membuat Login & User...';

-- A. Login untuk Proses ETL (System Account)
-- User ini butuh akses tulis (INSERT/UPDATE/DELETE)
IF NOT EXISTS (SELECT name FROM sys.server_principals WHERE name = 'User_ETL')
BEGIN
    CREATE LOGIN User_ETL WITH PASSWORD = 'StrongPassword123!';
END

IF NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'User_ETL')
BEGIN
    CREATE USER User_ETL FOR LOGIN User_ETL;
END

-- B. Login untuk Data Analyst (Reporting)
-- User ini HANYA boleh baca (SELECT) dan tidak boleh lihat Gaji asli
IF NOT EXISTS (SELECT name FROM sys.server_principals WHERE name = 'User_Analyst')
BEGIN
    CREATE LOGIN User_Analyst WITH PASSWORD = 'AnalystPassword123!';
END

IF NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'User_Analyst')
BEGIN
    CREATE USER User_Analyst FOR LOGIN User_Analyst;
END
GO

-- =============================================================
-- 2. ROLE-BASED ACCESS CONTROL (RBAC)
-- =============================================================
PRINT '2. Mengatur Role & Permission...';

-- A. Buat Role Khusus
CREATE ROLE Role_ETL_Processor;
CREATE ROLE Role_Data_Viewer;

-- B. Beri Akses ke Role ETL (Full Access ke Staging & DWH untuk Load Data)
-- Izinkan Eksekusi Stored Procedure ETL
GRANT EXECUTE ON OBJECT::dbo.ETL_Master_Load TO Role_ETL_Processor;
-- Izinkan Akses Schema Staging
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON SCHEMA::Staging TO Role_ETL_Processor;
-- Izinkan Insert/Update ke Tabel Fakta & Dimensi
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::dbo TO Role_ETL_Processor;

-- C. Beri Akses ke Role Analyst (Hanya Read Only)
GRANT SELECT ON SCHEMA::dbo TO Role_Data_Viewer;
-- Deny akses ke Staging (Analyst tidak perlu lihat data mentah)
DENY SELECT ON SCHEMA::Staging TO Role_Data_Viewer;

-- D. Masukkan User ke Role
ALTER ROLE Role_ETL_Processor ADD MEMBER User_ETL;
ALTER ROLE Role_Data_Viewer ADD MEMBER User_Analyst;
GO

-- =============================================================
-- 3. DYNAMIC DATA MASKING (Perlindungan Data Sensitif)
-- =============================================================
PRINT '3. Menerapkan Data Masking pada Gaji & NIP...';

-- Skenario: Data Analyst boleh lihat tren, tapi tidak boleh lihat angka gaji spesifik per orang.

-- A. Masking NIP di Dim_Employee (Tampilkan 3 huruf awal saja, sisanya XXX)
-- Contoh: '199001...' menjadi '199XXXXXX'
ALTER TABLE Dim_Employee
ALTER COLUMN NIP ADD MASKED WITH (FUNCTION = 'partial(3, "XXXXXX", 0)');

-- B. Masking GajiPokok di Fact_EmployeeSnapshot (User biasa lihat angka 0 atau default)
ALTER TABLE Fact_EmployeeSnapshot
ALTER COLUMN GajiPokok ADD MASKED WITH (FUNCTION = 'default()');

-- C. Masking Email/Nama jika perlu (Opsional - contoh Nama)
-- ALTER TABLE Dim_Employee
-- ALTER COLUMN NamaPegawai ADD MASKED WITH (FUNCTION = 'partial(1, "....", 1)');

PRINT '   -> Data Masking diterapkan. User tanpa hak UNMASK akan melihat data sensor.';
GO

-- =============================================================
-- 4. DATABASE AUDIT (Mencatat Akses)
-- =============================================================
PRINT '4. Membuat Audit Specification...';

-- Pastikan Server Audit sudah ada (Biasanya level server), ini contoh level Database
-- Note: Fitur ini tergantung edisi SQL Server, script ini standar untuk Enterprise/Developer/Standard terbaru.

IF EXISTS (SELECT * FROM sys.database_audit_specifications WHERE name = 'Audit_Gaji_Access')
BEGIN
    ALTER DATABASE AUDIT SPECIFICATION Audit_Gaji_Access WITH (STATE = OFF);
    DROP DATABASE AUDIT SPECIFICATION Audit_Gaji_Access;
END

-- Buat Server Audit (Simpan log di file sistem)
USE master;
GO
IF NOT EXISTS (SELECT * FROM sys.server_audits WHERE name = 'Kepegawaian_Audit_Log')
BEGIN
    CREATE SERVER AUDIT Kepegawaian_Audit_Log
    TO FILE (FILEPATH = 'C:\Temp\AuditLogs\'); -- Pastikan folder ini ada atau ubah path-nya!
    
    ALTER SERVER AUDIT Kepegawaian_Audit_Log WITH (STATE = ON);
END
GO

USE Kepegawaian_DB;
GO

-- Buat Database Audit Spec: Catat setiap kali 'User_Analyst' melakukan SELECT pada tabel Gaji
CREATE DATABASE AUDIT SPECIFICATION Audit_Gaji_Access
FOR SERVER AUDIT Kepegawaian_Audit_Log
ADD (SELECT ON dbo.Fact_EmployeeSnapshot BY User_Analyst), -- Audit User Analyst
ADD (SELECT ON dbo.TrGaji BY User_Analyst)
WITH (STATE = ON);

PRINT '=== SECURITY SETUP SELESAI ===';
GO

-- =============================================================
-- 5. TEST SECURITY (UNCOMMENT UNTUK MENCOBA)
-- =============================================================
/*
    -- Test sebagai User Analyst (Harusnya Gaji tertutup/Masked)
    EXECUTE AS USER = 'User_Analyst';
    
    SELECT TOP 5 EmployeeKey, GajiPokok FROM Fact_EmployeeSnapshot;
    -- Hasil GajiPokok harusnya 0 atau tertutup, NIP tertutup.
    
    REVERT;
    
    -- Test sebagai Admin/Owner (Harusnya terlihat semua)
    SELECT TOP 5 EmployeeKey, GajiPokok FROM Fact_EmployeeSnapshot;
*/