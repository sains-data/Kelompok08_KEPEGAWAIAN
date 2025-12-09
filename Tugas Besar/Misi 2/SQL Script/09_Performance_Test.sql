USE Kepegawaian_DB;
GO

PRINT '--- START PERFORMANCE TEST: ETL PROCESS ---';
DECLARE @StartTime DATETIME = GETDATE();

-- Jalankan Proses ETL Utama
EXEC ETL_Master_Load;

DECLARE @EndTime DATETIME = GETDATE();
DECLARE @DurationMs INT = DATEDIFF(MILLISECOND, @StartTime, @EndTime);

PRINT '-------------------------------------------';
PRINT 'Waktu Mulai   : ' + CONVERT(VARCHAR, @StartTime, 121);
PRINT 'Waktu Selesai : ' + CONVERT(VARCHAR, @EndTime, 121);
PRINT 'Total Durasi  : ' + CAST(@DurationMs AS VARCHAR) + ' milidetik';
PRINT '-------------------------------------------';