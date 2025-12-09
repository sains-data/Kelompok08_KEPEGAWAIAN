-- =============================================================
-- MEMBUAT STAGING TABLES
-- =============================================================

-- Buat Schema khusus Staging agar rapi
CREATE SCHEMA Staging;
GO

-- Buat tabel Staging (Strukturnya mirip OLTP tapi tidak ada FK/Constraint ketat)
CREATE TABLE Staging.MsPegawai (
    NIP VARCHAR(20),
    NamaLengkap VARCHAR(150),
    TglLahir DATE,
    JenisKelamin VARCHAR(10),
    StatusPegawai VARCHAR(50),
    KodeUnit VARCHAR(10),
    KodeJabatan VARCHAR(10),
    KodeGolongan VARCHAR(10)
);

CREATE TABLE Staging.TrAbsensi (
    NIP VARCHAR(20),
    Tanggal DATE,
    JamMasuk TIME(0),
    JamKeluar TIME(0),
    StatusKehadiran VARCHAR(20)
);

CREATE TABLE Staging.TrGaji (
    NIP VARCHAR(20),
    Bulan INT,
    Tahun INT,
    GajiPokok DECIMAL(18,2)
);

CREATE TABLE Staging.TrPenilaian (
    NIP VARCHAR(20),
    TglEvaluasi DATE,
    TotalSkor DECIMAL(5,2),
    Grade VARCHAR(5)
);
GO
