USE Kepegawaian_DB;
GO

-- Menerapkan Masking pada kolom GajiPokok
-- 'default()' akan mengubah angka menjadi 0 bagi user yang tidak berhak
ALTER TABLE Fact_EmployeeSnapshot
ALTER COLUMN GajiPokok ADD MASKED WITH (FUNCTION = 'default()');
GO

-- Opsional: Masking Email/NIP (menjadi xxxx@itera...)
-- ALTER TABLE Dim_Employee
-- ALTER COLUMN NIP ADD MASKED WITH (FUNCTION = 'partial(1, "xxx", 0)');