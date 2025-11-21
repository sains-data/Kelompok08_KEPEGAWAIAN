# Spesifikasi Profiling Data (Data Profiling Plan)

**Tujuan:** Menetapkan standar kualitas data yang harus dipenuhi oleh sistem sumber (OLTP) sebelum data ditarik (ETL) ke dalam *Galaxy Schema* Data Warehouse. Profiling ini bertujuan meminimalisir kegagalan saat proses transformasi data.

**Target Sumber Data:** Database OLTP (Sesuai ERD Eraser)
**Alat Bantu:** SSIS Data Profiling Task / SQL Queries

---

## Lingkup Profiling (Profiling Scope)

Analisis difokuskan pada 7 tabel utama yang teridentifikasi dalam ERD Sumber:

| Nama Tabel Sumber | Tipe | Kolom Kritis (Fokus Pemeriksaan) | Target Data Warehouse |
| :--- | :--- | :--- | :--- |
| **MsPegawai** | Master | `NIP`, `IsActive`, `KodeUnit`, `KodeJabatan` | `Dim_Employee` |
| **MsUnit** | Master | `KodeUnit`, `NamaUnit` | `Dim_Unit` |
| **MsJabatan** | Master | `KodeJabatan`, `TipeJabatan` | `Dim_Position` |
| **MsGolongan** | Master | `KodeGolongan`, `GajiDasar` | `Dim_Rank` |
| **TrAbsensi** | Transaksi | `Tanggal`, `JamMasuk`, `JamKeluar`, `StatusKehadiran` | `Fact_Attendance` |
| **TrGaji** | Transaksi | `NIP`, `Bulan`, `Tahun`, `GajiPokok` | `Fact_EmployeeSnapshot` |
| **TrPenilaianKinerja** | Transaksi | `TotalSkor`, `Grade`, `TglEvaluasi` | `Fact_Performance` |

---

## Parameter Pemeriksaan Kualitas (Quality Rules)

Berikut adalah aturan validasi spesifik berdasarkan struktur tabel ERD:

### A. Completeness (Kelengkapan Data)
*Memastikan kolom wajib tidak bernilai NULL untuk mendukung Primary Key dan Foreign Key di Data Warehouse.*

| Tabel Sumber | Kolom | Aturan Validasi | Dampak di DWH |
| :--- | :--- | :--- | :--- |
| **MsPegawai** | `NIP`, `NamaLengkap` | Tidak boleh NULL. | `Dim_Employee` tidak bisa terbentuk. |
| **TrAbsensi** | `JamMasuk`, `JamKeluar` | Boleh NULL **hanya jika** `StatusKehadiran` != 'Hadir'. | Perhitungan `DurasiKerja` dan `MenitTerlambat` di `Fact_Attendance` akan error. |
| **TrGaji** | `GajiPokok`, `TotalDiterima` | Tidak boleh NULL. | Analisis *Cost* di `Fact_EmployeeSnapshot` tidak akurat. |
| **TrPenilaianKinerja** | `TotalSkor`, `Grade` | Tidak boleh NULL. | `Fact_Performance` kehilangan metrik utama. |

### B. Referential Integrity (Integritas Relasi)
*Memastikan semua kode referensi di tabel transaksi ada induknya di tabel master.*

| Tabel Transaksi | Kolom FK | Tabel Master Acuan | Aturan |
| :--- | :--- | :--- | :--- |
| **MsPegawai** | `KodeUnit` | `MsUnit` | Semua KodeUnit pegawai harus terdaftar di MsUnit. |
| **MsPegawai** | `KodeJabatan` | `MsJabatan` | Semua KodeJabatan pegawai harus terdaftar di MsJabatan. |
| **TrAbsensi** | `NIP` | `MsPegawai` | Absensi tidak boleh ada untuk NIP yang tidak dikenal. |
| **TrPenilaianKinerja**| `NIP_Dinilai` | `MsPegawai` | Penilaian kinerja harus merujuk ke pegawai valid. |

### C. Validity & Consistency (Logika Bisnis)
*Memastikan nilai data masuk akal secara logika.*

| Tabel Sumber | Kolom | Aturan Logika |
| :--- | :--- | :--- |
| **MsPegawai** | `IsActive` | Harus bernilai Boolean (`1` / `0` atau `True` / `False`). |
| **MsPegawai** | `JenisKelamin` | Konsisten format (misal: 'L'/'P' atau 'Laki-laki'/'Perempuan'). |
| **TrAbsensi** | `JamKeluar` | `JamKeluar` harus lebih besar (>) dari `JamMasuk`. |
| **TrGaji** | `Bulan` | Nilai harus antara 1 sampai 12. |
| **TrPenilaianKinerja**| `TotalSkor` | Nilai harus numerik (decimal) antara 0.00 s.d 100.00. |

---

    * Pastikan format `Tanggal` di semua tabel transaksi seragam (YYYY-MM-DD) agar konversi ke `DateKey` (YYYYMMDD) di DWH berjalan mulus.
