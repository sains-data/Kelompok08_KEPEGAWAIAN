-- ==========================================================
-- BAGIAN B: STRUKTUR DATA WAREHOUSE (TARGET DATA MART)
-- Tabel ini sesuai dengan Galaxy Schema (Dim... & Fact...)
-- ==========================================================

-- 1. Tabel Dimensi (Dimensions)
CREATE TABLE Dim_Date (
    DateKey INT NOT NULL PRIMARY KEY, -- Format YYYYMMDD
    FullDate DATE,
    Year INT,
    Month INT,
    Quarter INT,
    Semester INT
);

CREATE TABLE Dim_Unit (
    UnitKey INT IDENTITY(1,1) PRIMARY KEY, -- Surrogate Key
    KodeUnit VARCHAR(10), -- Business Key
    NamaUnit VARCHAR(100),
    Fakultas VARCHAR(100),
    Location VARCHAR(100)
);

CREATE TABLE Dim_Position (
    PositionKey INT IDENTITY(1,1) PRIMARY KEY,
    KodePosition VARCHAR(10), -- Business Key
    NamaPosition VARCHAR(100),
    PositionType VARCHAR(50),
    DescPekerjaan VARCHAR(255)
);

CREATE TABLE Dim_Rank (
    RankKey INT IDENTITY(1,1) PRIMARY KEY,
    KodeRank VARCHAR(10), -- Business Key
    NamaRank VARCHAR(50),
    Golongan VARCHAR(10),
    Rank VARCHAR(50)
);

CREATE TABLE Dim_Employee (
    EmployeeKey INT IDENTITY(1,1) PRIMARY KEY,
    NIP VARCHAR(20), -- Business Key
    NamaPegawai VARCHAR(150),
    BirthDate DATE,
    JenisKelamin VARCHAR(10),
    StatusPegawai VARCHAR(50)
);

-- 2. Tabel Fakta (Facts)

-- Fact 1: Snapshot Bulanan (Gaji & Profil)
CREATE TABLE Fact_EmployeeSnapshot (
    SnapshotKey BIGINT IDENTITY(1,1) PRIMARY KEY,
    DateKey INT NOT NULL,
    EmployeeKey INT NOT NULL,
    PositionKey INT NOT NULL,
    UnitKey INT NOT NULL,
    RankKey INT NOT NULL,
    
    -- Measures
    GajiPokok DECIMAL(18, 2),
    JumlahOrang INT DEFAULT 1,
    
    -- Constraints
    CONSTRAINT FK_DWH_Snap_Date FOREIGN KEY (DateKey) REFERENCES Dim_Date(DateKey),
    CONSTRAINT FK_DWH_Snap_Emp FOREIGN KEY (EmployeeKey) REFERENCES Dim_Employee(EmployeeKey),
    CONSTRAINT FK_DWH_Snap_Pos FOREIGN KEY (PositionKey) REFERENCES Dim_Position(PositionKey),
    CONSTRAINT FK_DWH_Snap_Unit FOREIGN KEY (UnitKey) REFERENCES Dim_Unit(UnitKey),
    CONSTRAINT FK_DWH_Snap_Rank FOREIGN KEY (RankKey) REFERENCES Dim_Rank(RankKey)
);

-- Fact 2: Kinerja (Semesteran)
CREATE TABLE Fact_Performance (
    PerformanceKey BIGINT IDENTITY(1,1) PRIMARY KEY,
    DateKey INT NOT NULL,
    EmployeeKey INT NOT NULL,
    UnitKey INT NOT NULL,
    PositionKey INT NOT NULL,
    
    -- Measures
    Skor_Akhir DECIMAL(5, 2),
    Grade VARCHAR(5),
    
    CONSTRAINT FK_DWH_Perf_Date FOREIGN KEY (DateKey) REFERENCES Dim_Date(DateKey),
    CONSTRAINT FK_DWH_Perf_Emp FOREIGN KEY (EmployeeKey) REFERENCES Dim_Employee(EmployeeKey),
    CONSTRAINT FK_DWH_Perf_Unit FOREIGN KEY (UnitKey) REFERENCES Dim_Unit(UnitKey),
    CONSTRAINT FK_DWH_Perf_Pos FOREIGN KEY (PositionKey) REFERENCES Dim_Position(PositionKey)
);

-- Fact 3: Absensi (Harian)
CREATE TABLE Fact_Attendance (
    AttendanceKey BIGINT IDENTITY(1,1) PRIMARY KEY,
    DateKey INT NOT NULL,
    EmployeeKey INT NOT NULL,
    UnitKey INT NOT NULL,
    
    -- Measures
    DurasiKerja DECIMAL(4, 2),
    MenitTerlambat INT,
    StatusKehadiran VARCHAR(20),
    
    CONSTRAINT FK_DWH_Att_Date FOREIGN KEY (DateKey) REFERENCES Dim_Date(DateKey),
    CONSTRAINT FK_DWH_Att_Emp FOREIGN KEY (EmployeeKey) REFERENCES Dim_Employee(EmployeeKey),
    CONSTRAINT FK_DWH_Att_Unit FOREIGN KEY (UnitKey) REFERENCES Dim_Unit(UnitKey)
);
GO
