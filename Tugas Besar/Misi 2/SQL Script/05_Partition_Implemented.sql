USE [Kepegawaian_DB]; 
GO

PRINT '=== MEMULAI PROSES PARTISI ===';

-- ==========================================================
-- 1. SIAPKAN SKEMA & FUNGSI PARTISI (Tahun)
-- ==========================================================
PRINT '>>> 1. Membuat Function & Scheme...';

-- Range: Data < 2023, 2023, 2024, 2025, > 2025
IF NOT EXISTS (SELECT * FROM sys.partition_functions WHERE name = 'PF_TahunKepegawaian')
    CREATE PARTITION FUNCTION PF_TahunKepegawaian (INT)
    AS RANGE RIGHT FOR VALUES (20230101, 20240101, 20250101, 20260101);

IF NOT EXISTS (SELECT * FROM sys.partition_schemes WHERE name = 'PS_TahunKepegawaian')
    CREATE PARTITION SCHEME PS_TahunKepegawaian
    AS PARTITION PF_TahunKepegawaian
    ALL TO ([PRIMARY]);

GO

-- ==========================================================
-- 2. PARTISI TABEL: Fact_Attendance (Absensi)
-- ==========================================================
PRINT '>>> 2. Mempartisi Tabel Fact_Attendance...';

DECLARE @TableName_Att NVARCHAR(100) = 'dbo.Fact_Attendance';
DECLARE @OldPK_Att NVARCHAR(100);
DECLARE @SQL_Att NVARCHAR(MAX);

-- A. Hapus Duplikat (Jaga-jaga)
WITH CTE_Clean AS (
    SELECT AttendanceKey, DateKey, ROW_NUMBER() OVER (PARTITION BY AttendanceKey, DateKey ORDER BY (SELECT NULL)) AS RN
    FROM dbo.Fact_Attendance
) DELETE FROM CTE_Clean WHERE RN > 1;

-- B. Cari & Hapus PK Lama
SELECT TOP 1 @OldPK_Att = name FROM sys.key_constraints WHERE type = 'PK' AND parent_object_id = OBJECT_ID(@TableName_Att);

BEGIN TRY
    BEGIN TRANSACTION;
    IF @OldPK_Att IS NOT NULL
    BEGIN
        SET @SQL_Att = 'ALTER TABLE ' + @TableName_Att + ' DROP CONSTRAINT ' + @OldPK_Att;
        EXEC sp_executesql @SQL_Att;
    END

    -- C. Buat PK Baru Terpartisi (AttendanceKey + DateKey)
    ALTER TABLE dbo.Fact_Attendance
    ADD CONSTRAINT PK_Fact_Attendance_Partitioned 
    PRIMARY KEY CLUSTERED (AttendanceKey, DateKey)
    ON PS_TahunKepegawaian(DateKey);
    
    COMMIT TRANSACTION;
    PRINT '    -> Sukses: Fact_Attendance terpartisi.';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT '    -> ERROR Fact_Attendance: ' + ERROR_MESSAGE();
END CATCH

GO

-- ==========================================================
-- 3. PARTISI TABEL: Fact_Performance (Kinerja)
-- ==========================================================
PRINT '>>> 3. Mempartisi Tabel Fact_Performance...';

DECLARE @TableName_Perf NVARCHAR(100) = 'dbo.Fact_Performance';
DECLARE @OldPK_Perf NVARCHAR(100);
DECLARE @SQL_Perf NVARCHAR(MAX);

-- A. Hapus Duplikat
WITH CTE_Clean AS (
    SELECT PerformanceKey, DateKey, ROW_NUMBER() OVER (PARTITION BY PerformanceKey, DateKey ORDER BY (SELECT NULL)) AS RN
    FROM dbo.Fact_Performance
) DELETE FROM CTE_Clean WHERE RN > 1;

-- B. Cari & Hapus PK Lama
SELECT TOP 1 @OldPK_Perf = name FROM sys.key_constraints WHERE type = 'PK' AND parent_object_id = OBJECT_ID(@TableName_Perf);

BEGIN TRY
    BEGIN TRANSACTION;
    IF @OldPK_Perf IS NOT NULL
    BEGIN
        SET @SQL_Perf = 'ALTER TABLE ' + @TableName_Perf + ' DROP CONSTRAINT ' + @OldPK_Perf;
        EXEC sp_executesql @SQL_Perf;
    END

    -- C. Buat PK Baru Terpartisi (PerformanceKey + DateKey)
    ALTER TABLE dbo.Fact_Performance
    ADD CONSTRAINT PK_Fact_Performance_Partitioned 
    PRIMARY KEY CLUSTERED (PerformanceKey, DateKey)
    ON PS_TahunKepegawaian(DateKey);
    
    COMMIT TRANSACTION;
    PRINT '    -> Sukses: Fact_Performance terpartisi.';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT '    -> ERROR Fact_Performance: ' + ERROR_MESSAGE();
END CATCH

GO

-- ==========================================================
-- 4. VERIFIKASI HASIL
-- ==========================================================
PRINT '=== HASIL SEBARAN DATA ===';

SELECT 
    t.name AS [Nama Tabel],
    p.partition_number AS [No Partisi],
    rv.value AS [Batas Bawah Tanggal],
    p.rows AS [Jumlah Data]
FROM sys.partitions p
JOIN sys.tables t ON p.object_id = t.object_id
JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id
JOIN sys.partition_schemes ps ON i.data_space_id = ps.data_space_id
JOIN sys.partition_functions pf ON ps.function_id = pf.function_id
LEFT JOIN sys.partition_range_values rv ON pf.function_id = rv.function_id AND rv.boundary_id = p.partition_number - 1
WHERE t.name IN ('Fact_Attendance', 'Fact_Performance')
ORDER BY t.name, p.partition_number;
GO
