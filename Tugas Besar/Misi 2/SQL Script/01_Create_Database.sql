-- ==========================================================
-- 1. BUAT DATABASE
-- ==========================================================
CREATE DATABASE Kepegawaian_DB;
GO

USE Kepegawaian_DB;
GO

-- ==========================================================
-- BAGIAN A: STRUKTUR OLTP (SUMBER DATA OPERASIONAL)
-- Tabel ini sesuai dengan ERD Eraser (Ms... & Tr...)
-- ==========================================================

-- 1. Master Data OLTP
CREATE TABLE MsUnit (
    KodeUnit VARCHAR(10) NOT NULL PRIMARY KEY,
    NamaUnit VARCHAR(100),
    Fakultas VARCHAR(100),
    Lokasi VARCHAR(100)
);

CREATE TABLE MsJabatan (
    KodeJabatan VARCHAR(10) NOT NULL PRIMARY KEY,
    NamaJabatan VARCHAR(100),
    TipeJabatan VARCHAR(50), -- Struktural/Fungsional
    Deskripsi VARCHAR(255)
);

CREATE TABLE MsGolongan (
    KodeGolongan VARCHAR(10) NOT NULL PRIMARY KEY,
    NamaPangkat VARCHAR(50),
    Golongan VARCHAR(10), -- III/a, IV/b
    GajiDasar DECIMAL(18, 2)
);

-- 2. Profil Pegawai OLTP
CREATE TABLE MsPegawai (
    NIP VARCHAR(20) NOT NULL PRIMARY KEY,
    KodeUnit VARCHAR(10) NOT NULL,
    NamaLengkap VARCHAR(150),
    TglLahir DATE,
    JenisKelamin VARCHAR(10),
    StatusPegawai VARCHAR(50),
    TglMasuk DATE,
    IsActive BIT DEFAULT 1,
    KodeJabatan VARCHAR(10),
    KodeGolongan VARCHAR(10),
    
    -- Relasi ke Master
    CONSTRAINT FK_OLTP_Unit FOREIGN KEY (KodeUnit) REFERENCES MsUnit(KodeUnit),
    CONSTRAINT FK_OLTP_Jabatan FOREIGN KEY (KodeJabatan) REFERENCES MsJabatan(KodeJabatan),
    CONSTRAINT FK_OLTP_Golongan FOREIGN KEY (KodeGolongan) REFERENCES MsGolongan(KodeGolongan)
);

-- 3. Transaksi OLTP
CREATE TABLE TrAbsensi (
    AbsensiID BIGINT IDENTITY(1,1) PRIMARY KEY,
    Tanggal DATE,
    JamMasuk TIME(0),
    JamKeluar TIME(0),
    StatusKehadiran VARCHAR(20),
    Keterangan VARCHAR(255),
    NIP VARCHAR(20),
    
    CONSTRAINT FK_OLTP_Absen_Pegawai FOREIGN KEY (NIP) REFERENCES MsPegawai(NIP)
);

CREATE TABLE TrPenilaianKinerja (
    PenilaianID BIGINT IDENTITY(1,1) PRIMARY KEY,
    NIP_Dinilai VARCHAR(20),
    NIP_Penilai VARCHAR(20),
    TglEvaluasi DATE,
    PeriodeTahun INT,
    Semester INT,
    SkorSKP DECIMAL(5, 2),
    SkorPerilaku DECIMAL(5, 2),
    TotalSkor DECIMAL(5, 2),
    Grade VARCHAR(5),
    
    CONSTRAINT FK_OLTP_Nilai_Pegawai FOREIGN KEY (NIP_Dinilai) REFERENCES MsPegawai(NIP)
);

CREATE TABLE TrGaji (
    GajiID BIGINT IDENTITY(1,1) PRIMARY KEY,
    NIP VARCHAR(20),
    Bulan INT,
    Tahun INT,
    GajiPokok DECIMAL(18, 2),
    Tunjangan DECIMAL(18, 2),
    Potongan DECIMAL(18, 2),
    TotalDiterima DECIMAL(18, 2),
    
    CONSTRAINT FK_OLTP_Gaji_Pegawai FOREIGN KEY (NIP) REFERENCES MsPegawai(NIP)
);
