# 📖 Data Dictionary
**Proyek:** Data Mart Kepegawaian - Institut Teknologi Sumatera  
**Platform:** SQL Server 2019 on Azure VM  
**Status:** 01 Requirements

---

## A. Tabel Dimensi (Dimension Tables)
Tabel ini menyimpan data referensi dan konteks deskriptif (Siapa, Kapan, Di mana).

### 1. Dim_Date
*Dimensi Waktu untuk navigasi periode analisis.*

| Nama Kolom | Tipe Data | Tipe Key | Deskripsi | Sumber Data (Source) |
| :--- | :--- | :--- | :--- | :--- |
| **DateKey** | `INT` | PK | Primary Key (Format: YYYYMMDD). | *System Generated* |
| **FullDate** | `DATE` | | Tanggal lengkap (YYYY-MM-DD). | *System Generated* |
| **Year** | `INT` | | Tahun (misal: 2025). | *System Generated* |
| **Month** | `INT` | | Bulan angka (1-12). | *System Generated* |
| **Quarter** | `INT` | | Kuartal (1, 2, 3, 4). | *System Generated* |
| **Semester** | `INT` | | Semester (1=Ganjil, 2=Genap). | *System Generated* |

### 2. Dim_Employee
*Dimensi Profil Pegawai.*

| Nama Kolom | Tipe Data | Tipe Key | Deskripsi | Sumber Data (Source) |
| :--- | :--- | :--- | :--- | :--- |
| **EmployeeKey** | `INT` | PK | Surrogate Key unik di DWH. | *System Identity* |
| **NIP** | `VARCHAR(20)` | BK | Nomor Induk Pegawai (Natural Key). | `MsPegawai.NIP` |
| **NamaPegawai** | `VARCHAR(150)`| | Nama lengkap pegawai. | `MsPegawai.NamaLengkap` |
| **BirthDate** | `DATE` | | Tanggal lahir. | `MsPegawai.TglLahir` |
| **JenisKelamin**| `CHAR(1)` | | Kode Gender (L/P). | `MsPegawai.JenisKelamin` |
| **StatusPegawai**| `VARCHAR(50)` | | Status (PNS/Tetap/Kontrak). | `MsPegawai.StatusPegawai` |

### 3. Dim_Unit
*Dimensi Struktur Organisasi.*

| Nama Kolom | Tipe Data | Tipe Key | Deskripsi | Sumber Data (Source) |
| :--- | :--- | :--- | :--- | :--- |
| **UnitKey** | `INT` | PK | Surrogate Key unik. | *System Identity* |
| **KodeUnit** | `VARCHAR(10)` | BK | Kode Unit dari sistem asal. | `MsUnit.KodeUnit` |
| **NamaUnit** | `VARCHAR(100)`| | Nama Program Studi atau Biro. | `MsUnit.NamaUnit` |
| **Fakultas** | `VARCHAR(100)`| | Nama Fakultas induk. | `MsUnit.Fakultas` |
| **Location** | `VARCHAR(100)`| | Lokasi gedung/kantor. | `MsUnit.Lokasi` |

### 4. Dim_Position
*Dimensi Jabatan.*

| Nama Kolom | Tipe Data | Tipe Key | Deskripsi | Sumber Data (Source) |
| :--- | :--- | :--- | :--- | :--- |
| **PositionKey** | `INT` | PK | Surrogate Key unik. | *System Identity* |
| **KodePosition**| `VARCHAR(10)` | BK | Kode Jabatan asal. | `MsJabatan.KodeJabatan` |
| **NamaPosition**| `VARCHAR(100)`| | Nama Jabatan (Dosen/Kabag). | `MsJabatan.NamaJabatan` |
| **PositionType**| `VARCHAR(50)` | | Tipe (Struktural/Fungsional). | `MsJabatan.TipeJabatan` |
| **DescPekerjaan**| `VARCHAR(255)`| | Deskripsi singkat tugas. | `MsJabatan.DeskripsiPekerjaan` |

### 5. Dim_Rank
*Dimensi Pangkat/Golongan.*

| Nama Kolom | Tipe Data | Tipe Key | Deskripsi | Sumber Data (Source) |
| :--- | :--- | :--- | :--- | :--- |
| **RankKey** | `INT` | PK | Surrogate Key unik. | *System Identity* |
| **KodeRank** | `VARCHAR(10)` | BK | Kode Golongan asal. | `MsGolongan.KodeGolongan` |
| **NamaRank** | `VARCHAR(50)` | | Nama Pangkat (Penata/Pembina). | `MsGolongan.NamaPangkat` |
| **Golongan** | `VARCHAR(10)` | | Kode Golongan (III/a, IV/b). | `MsGolongan.Golongan` |

---

## B. Tabel Fakta (Fact Tables)
Tabel yang menyimpan metrik numerik dan Foreign Keys untuk analisis kuantitatif.

### 1. Fact_Attendance
*Fakta Transaksi Harian Absensi.*

| Nama Kolom | Tipe Data | Tipe Key | Deskripsi | Logika ETL / Formula |
| :--- | :--- | :--- | :--- | :--- |
| **AttendanceKey** | `BIGINT` | PK | Primary Key Fakta. | *Identity (Auto Increment)* |
| **DateKey** | `INT` | FK | FK ke Dim_Date. | `CONVERT(TrAbsensi.Tanggal)` |
| **EmployeeKey** | `INT` | FK | FK ke Dim_Employee. | `Lookup(TrAbsensi.NIP)` |
| **UnitKey** | `INT` | FK | FK ke Dim_Unit. | `Lookup(MsPegawai.KodeUnit)` |
| **DurasiKerja** | `DECIMAL(4,2)`| Measure | Durasi kerja dalam jam. | `JamKeluar - JamMasuk` |
| **MenitTerlambat**| `INT` | Measure | Keterlambatan dalam menit. | `IF(JamMasuk > 07:30) THEN ...` |
| **StatusKehadiran**| `VARCHAR(20)` | Attribute | Status (Hadir/Sakit/Izin). | `TrAbsensi.StatusKehadiran` |

### 2. Fact_Performance
*Fakta Transaksi Penilaian Berkala.*

| Nama Kolom | Tipe Data | Tipe Key | Deskripsi | Logika ETL / Formula |
| :--- | :--- | :--- | :--- | :--- |
| **PerformanceKey**| `BIGINT` | PK | Primary Key Fakta. | *Identity (Auto Increment)* |
| **DateKey** | `INT` | FK | FK ke Dim_Date (Tgl Evaluasi).| `CONVERT(TrPenilaian.TglEvaluasi)`|
| **EmployeeKey** | `INT` | FK | FK ke Dim_Employee. | `Lookup(TrPenilaian.NIP_Dinilai)`|
| **UnitKey** | `INT` | FK | FK ke Dim_Unit. | `Lookup` via History Pegawai |
| **PositionKey** | `INT` | FK | FK ke Dim_Position. | `Lookup` via History Pegawai |
| **Skor_Akhir** | `DECIMAL(5,2)`| Measure | Nilai akhir evaluasi. | `TrPenilaian.SkorAkhir` |
| **Grade** | `VARCHAR(2)` | Measure | Predikat kinerja (A/B/C). | `TrPenilaian.Grade` |

### 3. Fact_Employee_Snapshot
*Fakta Snapshot Bulanan (Gaji & Profil).*

| Nama Kolom | Tipe Data | Tipe Key | Deskripsi | Logika ETL / Formula |
| :--- | :--- | :--- | :--- | :--- |
| **SnapshotKey** | `BIGINT` | PK | Primary Key Fakta. | *Identity (Auto Increment)* |
| **DateKey** | `INT` | FK | FK ke Dim_Date (Akhir Bulan).| `TrGaji.Bulan` & `TrGaji.Tahun` |
| **EmployeeKey** | `INT` | FK | FK ke Dim_Employee. | `Lookup(TrGaji.NIP)` |
| **UnitKey** | `INT` | FK | FK ke Dim_Unit. | `Lookup(MsPegawai.KodeUnit)` |
| **PositionKey** | `INT` | FK | FK ke Dim_Position. | `Lookup(MsPegawai.KodeJabatan)`|
| **RankKey** | `INT` | FK | FK ke Dim_Rank. | `Lookup(MsPegawai.KodeGolongan)`|
| **GajiPokok** | `DECIMAL(18,2)`| Measure | Gaji pokok dibayarkan. | `TrGaji.GajiPokok` |
| **JumlahOrang** | `INT` | Measure | Flag penghitung headcount. | `Default Value: 1` |

---

## C. Keterangan Singkatan

| Kode | Kepanjangan | Penjelasan |
| :--- | :--- | :--- |
| **PK** | Primary Key | Kunci utama yang unik untuk setiap baris. |
| **FK** | Foreign Key | Kunci tamu yang menghubungkan fakta ke tabel dimensi. |
| **BK** | Business Key | Kunci asli dari sistem operasional (misal: NIP, KodeUnit). |
| **Measure** | Measure | Atribut angka yang bisa dihitung (Sum/Avg). |
