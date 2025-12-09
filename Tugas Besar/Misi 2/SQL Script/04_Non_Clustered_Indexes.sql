-- =============================================================
-- MEMBUAT NON-CLUSTERED INDEXES (PERFORMANCE TUNING)
-- =============================================================

-- 1. Index untuk Fact_Attendance
-- Mempercepat query filter berdasarkan Waktu, Pegawai, dan Unit
CREATE NONCLUSTERED INDEX IX_FactAttendance_DateKey ON Fact_Attendance(DateKey);
CREATE NONCLUSTERED INDEX IX_FactAttendance_EmployeeKey ON Fact_Attendance(EmployeeKey);
CREATE NONCLUSTERED INDEX IX_FactAttendance_UnitKey ON Fact_Attendance(UnitKey);

-- 2. Index untuk Fact_Performance
-- Mempercepat query evaluasi kinerja
CREATE NONCLUSTERED INDEX IX_FactPerformance_DateKey ON Fact_Performance(DateKey);
CREATE NONCLUSTERED INDEX IX_FactPerformance_EmployeeKey ON Fact_Performance(EmployeeKey);
CREATE NONCLUSTERED INDEX IX_FactPerformance_UnitKey ON Fact_Performance(UnitKey);
CREATE NONCLUSTERED INDEX IX_FactPerformance_PositionKey ON Fact_Performance(PositionKey);

-- 3. Index untuk Fact_EmployeeSnapshot
-- Mempercepat query gaji dan headcount
CREATE NONCLUSTERED INDEX IX_FactSnapshot_DateKey ON Fact_EmployeeSnapshot(DateKey);
CREATE NONCLUSTERED INDEX IX_FactSnapshot_EmployeeKey ON Fact_EmployeeSnapshot(EmployeeKey);
CREATE NONCLUSTERED INDEX IX_FactSnapshot_UnitKey ON Fact_EmployeeSnapshot(UnitKey);
CREATE NONCLUSTERED INDEX IX_FactSnapshot_PositionKey ON Fact_EmployeeSnapshot(PositionKey);
CREATE NONCLUSTERED INDEX IX_FactSnapshot_RankKey ON Fact_EmployeeSnapshot(RankKey);

GO
