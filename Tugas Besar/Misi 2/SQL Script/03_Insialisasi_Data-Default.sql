-- ==========================================================
-- BAGIAN C: INISIALISASI DATA DEFAULT (WAJIB UNTUK ETL)
-- Mengisi baris 'Unknown' (-1) untuk menangani data error/null
-- ==========================================================

SET IDENTITY_INSERT Dim_Unit ON;
INSERT INTO Dim_Unit (UnitKey, NamaUnit, Fakultas) VALUES (-1, 'Unknown', 'Unknown');
SET IDENTITY_INSERT Dim_Unit OFF;

SET IDENTITY_INSERT Dim_Position ON;
INSERT INTO Dim_Position (PositionKey, NamaPosition) VALUES (-1, 'Unknown');
SET IDENTITY_INSERT Dim_Position OFF;

SET IDENTITY_INSERT Dim_Rank ON;
INSERT INTO Dim_Rank (RankKey, NamaRank) VALUES (-1, 'Unknown');
SET IDENTITY_INSERT Dim_Rank OFF;

SET IDENTITY_INSERT Dim_Employee ON;
INSERT INTO Dim_Employee (EmployeeKey, NamaPegawai, NIP) VALUES (-1, 'Unknown', '000');
SET IDENTITY_INSERT Dim_Employee OFF;

-- Insert 1 tanggal default 1900-01-01
INSERT INTO Dim_Date (DateKey, FullDate, Year, Month) VALUES (19000101, '1900-01-01', 1900, 1);
GO
