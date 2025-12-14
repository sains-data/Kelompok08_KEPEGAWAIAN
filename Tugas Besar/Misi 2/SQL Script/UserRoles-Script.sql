USE Kepegawaian_DB;
GO

-- 1. Membuat Login & User Baru (Simulasi User Kampus)
-- Login ini bernama 'User_Itera' dengan password 'Mahasiswa123!'
CREATE LOGIN User_Itera WITH PASSWORD = 'Mahasiswa123!';
CREATE USER User_Itera FOR LOGIN User_Itera;
GO

-- 2. Membuat Role Khusus (Role: ReportViewer)
CREATE ROLE ReportViewer;
GO

-- 3. Memberi Izin (Permissions)
-- Hanya boleh SELECT (Baca) di semua tabel schema 'dbo'
GRANT SELECT ON SCHEMA::dbo TO ReportViewer;
-- Tolak izin DELETE/UPDATE (Opsional, untuk penegasan)
DENY DELETE, UPDATE, INSERT ON SCHEMA::dbo TO ReportViewer;
GO

-- 4. Memasukkan User ke dalam Role
ALTER ROLE ReportViewer ADD MEMBER User_Itera;
GO