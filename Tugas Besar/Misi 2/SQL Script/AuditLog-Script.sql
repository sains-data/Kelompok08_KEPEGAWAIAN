USE Kepegawaian_DB;
GO

-- 1. Buat Tabel Penampung Log
CREATE TABLE Audit_Log_Kepegawaian (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    WaktuKejadian DATETIME DEFAULT GETDATE(),
    UserPelaku VARCHAR(100),
    Aksi VARCHAR(50),
    Keterangan VARCHAR(255)
);
GO

-- 2. Buat Trigger (CCTV Otomatis)
CREATE OR ALTER TRIGGER TR_Audit_Gaji_Change
ON Fact_EmployeeSnapshot
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Masukkan data ke log setiap ada update
    INSERT INTO Audit_Log_Kepegawaian (UserPelaku, Aksi, Keterangan)
    SELECT 
        SUSER_NAME(), -- Nama User Login
        'UPDATE', 
        'Perubahan data terdeteksi pada tabel Fact_EmployeeSnapshot'
END;
GO