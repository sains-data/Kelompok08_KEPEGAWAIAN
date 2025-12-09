-- =============================================================
-- MEMBUAT SCRIPTS ETL
-- =============================================================

CREATE OR ALTER PROCEDURE ETL_Master_Load
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @StartTime DATETIME = GETDATE();
    
    PRINT '=== MULAI PROSES ETL ===';

    -- ==========================================
    -- STEP 1: EXTRACT TO STAGING (TRUNCATE & INSERT)
    -- ==========================================
    PRINT '1. Loading Staging Tables...';
    
    TRUNCATE TABLE Staging.MsPegawai;
    INSERT INTO Staging.MsPegawai SELECT NIP, NamaLengkap, TglLahir, JenisKelamin, StatusPegawai, KodeUnit, KodeJabatan, KodeGolongan FROM MsPegawai;

    TRUNCATE TABLE Staging.TrAbsensi;
    INSERT INTO Staging.TrAbsensi SELECT NIP, Tanggal, JamMasuk, JamKeluar, StatusKehadiran FROM TrAbsensi;

    TRUNCATE TABLE Staging.TrGaji;
    INSERT INTO Staging.TrGaji SELECT NIP, Bulan, Tahun, GajiPokok FROM TrGaji;

    TRUNCATE TABLE Staging.TrPenilaian;
    INSERT INTO Staging.TrPenilaian SELECT NIP_Dinilai, TglEvaluasi, TotalSkor, Grade FROM TrPenilaianKinerja;

    -- ==========================================
    -- STEP 2: LOAD DIMENSIONS
    -- ==========================================
    PRINT '2. Loading Dimensions...';

    -- Dim_Unit
    INSERT INTO Dim_Unit (KodeUnit, NamaUnit, Fakultas, Location)
    SELECT s.KodeUnit, s.NamaUnit, s.Fakultas, s.Lokasi
    FROM MsUnit s
    WHERE NOT EXISTS (SELECT 1 FROM Dim_Unit d WHERE d.KodeUnit = s.KodeUnit);

    -- Dim_Position
    INSERT INTO Dim_Position (KodePosition, NamaPosition, PositionType, DescPekerjaan)
    SELECT s.KodeJabatan, s.NamaJabatan, s.TipeJabatan, s.Deskripsi
    FROM MsJabatan s
    WHERE NOT EXISTS (SELECT 1 FROM Dim_Position d WHERE d.KodePosition = s.KodeJabatan);

    -- Dim_Rank
    INSERT INTO Dim_Rank (KodeRank, NamaRank, Golongan)
    SELECT s.KodeGolongan, s.NamaPangkat, s.Golongan
    FROM MsGolongan s
    WHERE NOT EXISTS (SELECT 1 FROM Dim_Rank d WHERE d.KodeRank = s.KodeGolongan);

    -- Dim_Employee (SCD Type 1)
    MERGE Dim_Employee AS Target
    USING Staging.MsPegawai AS Source ON Target.NIP = Source.NIP
    WHEN MATCHED THEN
        UPDATE SET NamaPegawai = Source.NamaLengkap, StatusPegawai = Source.StatusPegawai
    WHEN NOT MATCHED THEN
        INSERT (NIP, NamaPegawai, BirthDate, JenisKelamin, StatusPegawai)
        VALUES (Source.NIP, Source.NamaLengkap, Source.TglLahir, Source.JenisKelamin, Source.StatusPegawai);

    -- ==========================================
    -- STEP 3: LOAD FACTS
    -- ==========================================
    PRINT '3. Loading Facts...';

    -- Fact_Attendance
    -- Hapus data tanggal yang sama agar tidak duplikat (Idempotency)
    DELETE FROM Fact_Attendance WHERE DateKey IN (SELECT CAST(CONVERT(VARCHAR(8), Tanggal, 112) AS INT) FROM Staging.TrAbsensi);
    
    INSERT INTO Fact_Attendance (DateKey, EmployeeKey, UnitKey, DurasiKerja, MenitTerlambat, StatusKehadiran)
    SELECT 
        CAST(CONVERT(VARCHAR(8), s.Tanggal, 112) AS INT) AS DateKey,
        ISNULL(e.EmployeeKey, -1),
        ISNULL(u.UnitKey, -1),
        -- Transformasi Durasi Kerja
        ISNULL(DATEDIFF(MINUTE, s.JamMasuk, s.JamKeluar) / 60.0, 0),
        -- Transformasi Keterlambatan (> 07:30)
        CASE WHEN s.JamMasuk > '07:30:00' THEN DATEDIFF(MINUTE, '07:30:00', s.JamMasuk) ELSE 0 END,
        s.StatusKehadiran
    FROM Staging.TrAbsensi s
    LEFT JOIN Dim_Employee e ON s.NIP = e.NIP
    LEFT JOIN MsPegawai mp ON s.NIP = mp.NIP -- Join ke OLTP MsPegawai untuk ambil KodeUnit
    LEFT JOIN Dim_Unit u ON mp.KodeUnit = u.KodeUnit;

    -- Fact_Performance
    INSERT INTO Fact_Performance (DateKey, EmployeeKey, UnitKey, PositionKey, Skor_Akhir, Grade)
    SELECT 
        CAST(CONVERT(VARCHAR(8), s.TglEvaluasi, 112) AS INT),
        ISNULL(e.EmployeeKey, -1),
        ISNULL(u.UnitKey, -1),
        ISNULL(p.PositionKey, -1),
        s.TotalSkor,
        s.Grade
    FROM Staging.TrPenilaian s
    LEFT JOIN Dim_Employee e ON s.NIP = e.NIP
    LEFT JOIN MsPegawai mp ON s.NIP = mp.NIP
    LEFT JOIN Dim_Unit u ON mp.KodeUnit = u.KodeUnit
    LEFT JOIN Dim_Position p ON mp.KodeJabatan = p.KodePosition
    -- Cek duplikasi
    WHERE NOT EXISTS (
        SELECT 1 FROM Fact_Performance f 
        WHERE f.DateKey = CAST(CONVERT(VARCHAR(8), s.TglEvaluasi, 112) AS INT) 
        AND f.EmployeeKey = e.EmployeeKey
    );

    -- Fact_EmployeeSnapshot
    INSERT INTO Fact_EmployeeSnapshot (DateKey, EmployeeKey, PositionKey, UnitKey, RankKey, GajiPokok, JumlahOrang)
    SELECT 
        CAST(CONCAT(s.Tahun, RIGHT('0'+CAST(s.Bulan AS VARCHAR),2), '01') AS INT), -- DateKey Awal Bulan
        ISNULL(e.EmployeeKey, -1),
        ISNULL(p.PositionKey, -1),
        ISNULL(u.UnitKey, -1),
        ISNULL(r.RankKey, -1),
        s.GajiPokok,
        1 -- Headcount
    FROM Staging.TrGaji s
    LEFT JOIN Dim_Employee e ON s.NIP = e.NIP
    LEFT JOIN MsPegawai mp ON s.NIP = mp.NIP
    LEFT JOIN Dim_Position p ON mp.KodeJabatan = p.KodePosition
    LEFT JOIN Dim_Unit u ON mp.KodeUnit = u.KodeUnit
    LEFT JOIN Dim_Rank r ON mp.KodeGolongan = r.KodeRank;

    PRINT '=== ETL SELESAI ===';
    PRINT 'Durasi: ' + CAST(DATEDIFF(MILLISECOND, @StartTime, GETDATE()) AS VARCHAR) + ' ms';
END;
GO
