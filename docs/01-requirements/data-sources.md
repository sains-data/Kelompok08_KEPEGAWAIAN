# Analisis Sumber Data (Data Source Analysis)

Analisis ini memetakan bagaimana data dari sistem operasional (sumber) akan diekstraksi dan ditempatkan ke dalam arsitektur Data Warehouse yang telah dirancang.

## Identifikasi Sumber Data Utama
Satu-satunya sumber data untuk Data Mart ini adalah sistem informasi kepegawaian terpusat yang dikelola oleh ITERA.

| Informasi | Detail |
| :--- | :--- |
| **Nama Sistem** | Sistem Informasi Kepegawaian ITERA (SIMPEG) |
| **URL Akses** | `https://kepegawaian.itera.ac.id/` |
| **Tipe Sumber** | Web Application (Backend Database: MySQL/PostgreSQL) |
| **Target System** | SQL Server 2019 (Data Warehouse) |
| **ETL Tool** | SQL Server Integration Services (SSIS) |

---

## Tabel Pemetaan Sumber Data (Source-to-Target Mapping)

Berikut adalah matriks pemetaan dari modul-modul yang ada di Website Kepegawaian menuju Tabel ERD (OLTP Staging) dan Tabel Data Mart (Target).

| No | Modul Data Source (Web) | Deskripsi Data | Mapping ke ERD (OLTP) | Mapping ke Data Mart (Target) | Frekuensi Update | Strategi Ekstraksi (SSIS) |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **1** | **Master Pegawai** | Data profil lengkap Dosen dan Tenaga Kependidikan (Tendik). | `MsPegawai` | `Dim_Employee` | Mingguan | **Incremental Load:** Update data jika ada perubahan status/biodata. |
| **2** | **Referensi Unit Kerja** | Daftar Fakultas, Jurusan, Program Studi, dan Biro. | `MsUnit` | `Dim_Unit` | Bulanan | **Full Load:** Data referensi master jarang berubah. |
| **3** | **Referensi Jabatan** | Katalog jabatan fungsional dan struktural. | `MsJabatan` | `Dim_Position` | Tahunan | **Full Load:** Memuat ulang seluruh katalog jabatan. |
| **4** | **Referensi Pangkat** | Standar golongan gaji dan kepangkatan. | `MsGolongan` | `Dim_Rank` | Tahunan | **Full Load:** Jarang berubah, kecuali ada regulasi baru. |
| **5** | **Log Presensi (E-Absensi)** | Rekam jejak kehadiran harian (Fingerprint/Online). | `TrAbsensi` | `Fact_Attendance` | Harian | **Incremental Load:** Mengambil data berdasarkan `Tanggal = H-1`. |
| **6** | **E-Kinerja (Penilaian)** | Rekapitulasi nilai SKP dan Perilaku kerja. | `TrPenilaianKinerja` | `Fact_Performance` | Semesteran | **Incremental Load:** Mengambil data saat periode penilaian ditutup. |
| **7** | **Payroll (Remunerasi)** | Data nominal gaji pokok dan tunjangan. | `TrGaji` | `Fact_Employee_Snapshot` | Bulanan | **Incremental Load:** Mengambil data setiap tanggal 1 bulan berikutnya. |
| **8** | **System Generated (SQL Script)** | Data referensi kalender (Hari, Bulan, Tahun, Semester, Hari Libur). | *- (Tidak butuh staging)* | `Dim_Date` | Sekali (One-time Load) | **Script Generation:** Dibuat menggunakan T-SQL Stored Procedure (Looping tanggal misal: 2020-2030). |
---
