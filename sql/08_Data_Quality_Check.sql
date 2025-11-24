-- Cek 1: Apakah jumlah baris di Source sama dengan Target?
SELECT 
    (SELECT COUNT(*) FROM TrAbsensi) AS Source_Absensi,
    (SELECT COUNT(*) FROM Fact_Attendance) AS Target_Absensi;

-- Cek 2: Apakah ada EmployeeKey yang -1 (Unknown)?
-- Jika ada, berarti NIP di transaksi tidak ada di Master Pegawai
SELECT * FROM Fact_Attendance WHERE EmployeeKey = -1;

-- Cek 3: Validasi Perhitungan Measure
-- Pastikan DurasiKerja masuk akal
SELECT TOP 5 * FROM Fact_Attendance ORDER BY DurasiKerja DESC;
