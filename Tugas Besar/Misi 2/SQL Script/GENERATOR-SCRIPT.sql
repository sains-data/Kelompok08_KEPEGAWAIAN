USE Kepegawaian_DB;
GO

SET NOCOUNT ON;
PRINT '=== MULAI GENERATE DATA: 50 PEGAWAI (NAMA PANJANG & BERSIH) + ABSENSI REALISTIS ===';

-- ==========================================================
-- 1. BERSIHKAN DATA LAMA
-- ==========================================================
DELETE FROM TrAbsensi WHERE NIP LIKE 'AUTO-%';
DELETE FROM TrGaji WHERE NIP LIKE 'AUTO-%';
DELETE FROM TrPenilaianKinerja WHERE NIP_Dinilai LIKE 'AUTO-%';
DELETE FROM MsPegawai WHERE NIP LIKE 'AUTO-%';

-- ==========================================================
-- 2. GENERATE 50 PEGAWAI (NAMA 3 KATA)
-- ==========================================================
PRINT '2. Mendaftarkan 50 Pegawai dengan Nama Panjang...';

DECLARE @Depan TABLE (V VARCHAR(50));
DECLARE @Tengah TABLE (V VARCHAR(50));
DECLARE @Belakang TABLE (V VARCHAR(50));

-- Bank Nama (Campuran umum di Indonesia)
INSERT INTO @Depan VALUES ('Muhammad'),('Ahmad'),('Budi'),('Citra'),('Dewi'),('Eko'),('Fajar'),('Gita'),('Hendra'),('Indah'),('Joko'),('Kurnia'),('Lestari'),('Nur'),('Oki'),('Putri'),('Rizky'),('Siti'),('Tio'),('Utami'),('Vina'),('Wahyu'),('Yusuf'),('Zainal'),('Agus'),('Rina'),('Dinda'),('Satria'),('Bagas'),('Ratna');
INSERT INTO @Tengah VALUES ('Dwi'),('Tri'),('Nur'),('Eka'),('Putra'),('Bayu'),('Aji'),('Wira'),('Kusuma'),('Sari'),('Ayu'),('Bagus'),('Cahya'),('Dian'),('Feri'),('Gilang'),('Hadi'),('Indra'),('Jaya'),('Kiki'),('Reza'),('Akbar'),('Setia'),('Bunga'),('Lia');
INSERT INTO @Belakang VALUES ('Santoso'),('Pratama'),('Wijaya'),('Saputra'),('Hidayat'),('Nugroho'),('Kusuma'),('Siregar'),('Nasution'),('Pohan'),('Wibowo'),('Susanto'),('Permana'),('Lesmana'),('Wahyudi'),('Sihombing'),('Simanjuntak'),('Utama'),('Ramadhan'),('Setiawan');

;WITH KombinasiNama AS (
    -- Cross Join untuk menghasilkan ribuan kombinasi nama 3 kata
    SELECT 
        D.V + ' ' + T.V + ' ' + B.V AS NamaLengkap, 
        ABS(CHECKSUM(NEWID())) AS Rnd
    FROM @Depan D, @Tengah T, @Belakang B
),
FinalPegawai AS (
    SELECT TOP 50 -- Ambil 50 saja
        ROW_NUMBER() OVER (ORDER BY Rnd) AS ID,
        NamaLengkap, Rnd
    FROM KombinasiNama
)
INSERT INTO MsPegawai (NIP, NamaLengkap, TglLahir, JenisKelamin, StatusPegawai, TglMasuk, IsActive, KodeUnit, KodeJabatan, KodeGolongan)
SELECT 
    'AUTO-' + RIGHT('00000' + CAST(ID AS VARCHAR), 5), -- NIP Urut AUTO-00001 s/d AUTO-00050
    NamaLengkap,
    DATEADD(YEAR, - (23 + (Rnd % 30)), GETDATE()),
    CASE WHEN Rnd % 2 = 0 THEN 'L' ELSE 'P' END,
    'Tetap',
    DATEADD(MONTH, - (12 + (Rnd % 60)), GETDATE()),
    1,
    CASE (Rnd % 5) WHEN 0 THEN 'SD' WHEN 1 THEN 'IF' WHEN 2 THEN 'BIO' WHEN 3 THEN 'TIP' ELSE 'HUM' END,
    CASE (Rnd % 5) WHEN 0 THEN 'LEC' WHEN 1 THEN 'AA' WHEN 2 THEN 'STF' WHEN 3 THEN 'KBG' ELSE 'LBR' END,
    CASE (Rnd % 5) WHEN 0 THEN 'III-A' WHEN 1 THEN 'III-B' WHEN 2 THEN 'III-C' WHEN 3 THEN 'IV-A' ELSE 'IV-B' END
FROM FinalPegawai;

PRINT '   -> 50 Pegawai Nama Panjang berhasil dibuat.';

-- ==========================================================
-- 3. GENERATE ABSENSI (LOGIKA PERSONA TERSEMBUNYI)
-- ==========================================================
PRINT '3. Generate History Absensi (Logic Persona Hidden by NIP ID)...';

-- Logic Tanggal (Senin-Jumat)
WITH AllDates AS (
    SELECT TOP 300 DATEADD(DAY, -ROW_NUMBER() OVER (ORDER BY object_id), CAST(GETDATE() AS DATE)) AS Tanggal
    FROM sys.all_columns
),
HariKerja AS (
    SELECT TOP 200 Tanggal FROM AllDates
    WHERE DATENAME(WEEKDAY, Tanggal) NOT IN ('Saturday', 'Sunday', 'Sabtu', 'Minggu')
),
SkenarioAbsen AS (
    SELECT 
        P.NIP,
        H.Tanggal,
        CAST(RIGHT(P.NIP, 3) AS INT) AS ID_Pegawai, -- Kita pakai ID NIP ini sebagai penentu nasib (invisible logic)
        ABS(CHECKSUM(NEWID())) % 100 AS Rnd 
    FROM MsPegawai P
    CROSS JOIN HariKerja H
    WHERE P.NIP LIKE 'AUTO-%'
)
INSERT INTO TrAbsensi (NIP, Tanggal, JamMasuk, JamKeluar, StatusKehadiran, Keterangan)
SELECT 
    NIP,
    Tanggal,
    
    -- === JAM MASUK ===
    CASE 
        -- NIP 1-10 (PERSONA TELADAN): Selalu Pagi (07:00-07:20)
        WHEN ID_Pegawai <= 10 THEN DATEADD(MINUTE, (Rnd % 20), '07:00:00') 
        
        -- NIP 11-35 (PERSONA NORMAL): Pagi wajar, kadang telat dikit
        WHEN ID_Pegawai BETWEEN 11 AND 35 AND Rnd < 95 THEN DATEADD(MINUTE, (Rnd % 45), '07:15:00') 
        
        -- NIP 36-45 (PERSONA RENTAN SAKIT): Sering masuk tapi mepet
        WHEN ID_Pegawai BETWEEN 36 AND 45 AND Rnd < 85 THEN DATEADD(MINUTE, (Rnd % 60), '07:30:00')
        
        -- NIP 46-50 (PERSONA BANDEL): Sering Telat Parah (>08:00)
        WHEN ID_Pegawai >= 46 AND Rnd < 70 THEN DATEADD(MINUTE, (Rnd % 120), '08:00:00') 
        
        ELSE NULL -- Tidak Masuk
    END,

    -- === JAM KELUAR ===
    CASE 
        WHEN (ID_Pegawai <= 10) OR 
             (ID_Pegawai BETWEEN 11 AND 35 AND Rnd < 95) OR 
             (ID_Pegawai BETWEEN 36 AND 45 AND Rnd < 85) OR 
             (ID_Pegawai >= 46 AND Rnd < 70)
        THEN '16:00:00' ELSE NULL 
    END,

    -- === STATUS KEHADIRAN ===
    CASE 
        -- TELADAN (0% Bolos)
        WHEN ID_Pegawai <= 10 THEN 'Hadir'
        
        -- NORMAL (5% Izin/Sakit)
        WHEN ID_Pegawai BETWEEN 11 AND 35 THEN 
            CASE WHEN Rnd < 95 THEN 'Hadir' WHEN Rnd < 98 THEN 'Sakit' ELSE 'Izin' END
            
        -- RENTAN (15% Sakit)
        WHEN ID_Pegawai BETWEEN 36 AND 45 THEN 
            CASE WHEN Rnd < 85 THEN 'Hadir' WHEN Rnd < 95 THEN 'Sakit' ELSE 'Izin' END
            
        -- BANDEL (30% Alpha/Bolos)
        WHEN ID_Pegawai >= 46 THEN 
            CASE WHEN Rnd < 70 THEN 'Hadir' WHEN Rnd < 80 THEN 'Sakit' ELSE 'Alpha' END
    END,

    -- === KETERANGAN ===
    CASE 
        WHEN ID_Pegawai <= 10 THEN 'Tepat Waktu'
        WHEN ID_Pegawai >= 46 AND Rnd < 70 THEN 'Terlambat' 
        WHEN ID_Pegawai >= 46 AND Rnd >= 80 THEN 'Tanpa Keterangan' -- Alpha
        WHEN ID_Pegawai BETWEEN 36 AND 45 AND Rnd >= 85 AND Rnd < 95 THEN 'Sakit (Surat Dokter)'
        ELSE 'Sesuai Jadwal'
    END
FROM SkenarioAbsen;

PRINT '   -> Data Absensi Realistis Selesai.';

-- ==========================================================
-- 4. PELENGKAP (GAJI & KINERJA)
-- ==========================================================
INSERT INTO TrGaji (NIP, Bulan, Tahun, GajiPokok, Tunjangan, Potongan, TotalDiterima)
SELECT NIP, MONTH(GETDATE()), YEAR(GETDATE()), 3000000, 1000000, 
    CASE WHEN CAST(RIGHT(NIP, 3) AS INT) >= 46 THEN 500000 ELSE 0 END, -- Si Bandel potongannya gede
    0 
FROM MsPegawai WHERE NIP LIKE 'AUTO-%';

UPDATE TrGaji SET TotalDiterima = GajiPokok + Tunjangan - Potongan WHERE NIP LIKE 'AUTO-%';

INSERT INTO TrPenilaianKinerja (NIP_Dinilai, NIP_Penilai, TglEvaluasi, PeriodeTahun, Semester, SkorSKP, SkorPerilaku, TotalSkor, Grade)
SELECT NIP, 'P001', GETDATE(), YEAR(GETDATE()), 1, 
    CASE WHEN CAST(RIGHT(NIP, 3) AS INT) >= 46 THEN 60 ELSE 85 END, -- Si Bandel nilainya jelek
    80, 0, '' 
FROM MsPegawai WHERE NIP LIKE 'AUTO-%';

UPDATE TrPenilaianKinerja SET TotalSkor = (SkorSKP+SkorPerilaku)/2, Grade = CASE WHEN SkorSKP < 70 THEN 'D' ELSE 'B' END WHERE NIP_Dinilai LIKE 'AUTO-%';

PRINT '=== SELESAI ===';
GO
