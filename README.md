# 📊 Data Mart Kepegawaian - Institut Teknologi Sumatera

![Logo Tugas Besar Data Warehouse Gasal 2025](https://github.com/sains-data/Data-Warehouse-2025-Gasal/blob/main/Logo-DW-Gasal-2025.gif)

**Tugas Besar Pergudangan Data (SD25-31007)**  
**Program Studi Sains Data - Fakultas Sains**  
**Tahun Ajaran 2025**

---

# Data Mart - Kepegawaian
**Tugas Besar Pergudangan Data - Kelompok 8**

---

## 👥 Team Members
* **Fadhil Fitra Wijaya** — 122450082
* **Ali Aristo Muthahhari Parisi** — 123450088
* **Nobel Nizam Fathirizki** — 123450117
* **Nama Lengkap 4** — NIM

## 📘 Project Description

Data Mart Kepegawaian ini dirancang untuk mendukung analitik manajemen sumber daya manusia secara komprehensif di Institut Teknologi Sumatera. Fokus utama berada pada pemantauan **biaya pegawai, kedisiplinan harian, dan evaluasi kinerja berkala**. Sistem ini menggunakan arsitektur *Galaxy Schema* untuk mengintegrasikan berbagai proses bisnis ke dalam satu pusat data analitik.

Pendekatan **dimensional modeling (Kimball)** digunakan agar proses analisis cepat, konsisten, dan mudah diekspansi.

---

## 🏫 Business Domain

Domain yang diangkat adalah **pengelolaan kepegawaian**, mencakup:

1. **Profil & Biaya Pegawai** (HR Costing & Profiling)
2. **Kehadiran & Kedisiplinan** (Attendance)
3. **Penilaian Kinerja** (Performance Appraisal)

### Stakeholder Utama:
* **Bagian Kepegawaian ITERA**
* **Rektor & Wakil Rektor II (SDM)**
* **Kepala Unit/Fakultas**

## 🏗️ Architecture

* **Approach**: Galaxy Schema (Fact Constellation)
* **Platform**: SQL Server 2019 on Azure VM
* **ETL**: SQL Server Integration Services (SSIS)
* **Reporting**: Power BI Desktop

---

## 📐 Schema Design
![Schema Diagram](image_d262be.png)
*(Diagram skema fisik Data Mart)*

---

## ⭐ Key Features

### 🧮 Fact Tables (Tabel Fakta)
Menyimpan metrik (angka) dan foreign keys untuk analisis kuantitatif.

#### 1. **Fact_Employee_Snapshot**
**Fungsi**: Mencatat posisi, gaji, dan jumlah pegawai pada setiap akhir bulan.
* **Keys**: `SnapshotKey` (PK), `DateKey`, `EmployeeKey`, `PositionKey`, `UnitKey`, `RankKey`.
* **Measures**:
  * `GajiPokok` (IDR) — *Analisis beban biaya SDM.*
  * `JumlahOrang` (Int) — *Flag penghitung headcount (selalu bernilai 1).*

#### 2. **Fact_Attendance**
**Fungsi**: Mencatat transaksi kehadiran harian pegawai.
* **Keys**: `AttendanceKey` (PK), `DateKey`, `EmployeeKey`, `UnitKey`.
* **Measures**:
  * `DurasiKerja` (Jam/Decimal) — *Produktivitas waktu kerja.*
  * `MenitTerlambat` (Int) — *Indikator kedisiplinan.*
  * `StatusKehadiran` (Degenerate) — *Hadir/Sakit/Izin/Alpha.*

#### 3. **Fact_Performance**
**Fungsi**: Mencatat hasil evaluasi kinerja pegawai per periode.
* **Keys**: `PerformanceKey` (PK), `DateKey` (Tgl Evaluasi), `EmployeeKey`, `UnitKey`, `PositionKey`.
* **Measures**:
  * `Skor_Akhir` (Decimal) — *Nilai hasil evaluasi.*
  * `Grade` (Varchar) — *Predikat kinerja (A/B/C).*

---

### 🗂️ Dimension Tables (Tabel Dimensi)
Menyimpan konteks deskriptif untuk filtering dan grouping data.

#### 1. **Dim_Date**
*Dimensi waktu untuk analisis trend (Time Series).*
* **Attributes**: `DateKey` (PK), `FullDate`, `Year`, `Month`, `Quarter`, `Semester`.

#### 2. **Dim_Employee**
*Menyimpan profil detail individu pegawai.*
* **Attributes**: `EmployeeKey` (PK), `NIP`, `NamaPegawai`, `BirthDate`, `JenisKelamin`, `StatusPegawai`.

#### 3. **Dim_Unit**
*Menyimpan hierarki organisasi (Program Studi, Biro, Fakultas).*
* **Attributes**: `UnitKey` (PK), `KodeUnit`, `NamaUnit`, `Fakultas`, `Location`.

#### 4. **Dim_Position**
*Menyimpan jenis jabatan struktural maupun fungsional.*
* **Attributes**: `PositionKey` (PK), `KodePosition`, `NamaPosition`, `PositionType`, `DescPekerjaan`.

#### 5. **Dim_Rank**
*Menyimpan data kepangkatan dan golongan pegawai negeri/tetap.*
* **Attributes**: `RankKey` (PK), `KodeRank`, `NamaRank`, `Golongan`, `Rank`.

---
  
## 📊 Key Performance Indicators (KPIs)

Data Mart ini mampu menjawab pertanyaan bisnis berikut:

### 🎯 HR Cost & Profiling
* **Total Headcount**: `SUM(Fact_EmployeeSnapshot.JumlahOrang)`
* **Total Salary Cost**: `SUM(Fact_EmployeeSnapshot.GajiPokok)`
* **Salary per Unit**: Analisis sebaran gaji berdasarkan `Dim_Unit`.

### 📈 Discipline (Attendance)
* **Late Intensity**: `AVG(Fact_Attendance.MenitTerlambat)`
* **Total Jam Kerja**: `SUM(Fact_Attendance.DurasiKerja)`
* **Absenteeism Pattern**: Jumlah ketidakhadiran berdasarkan `StatusKehadiran`.

### ⭐ Performance Quality
* **Average Performance**: `AVG(Fact_Performance.Skor_Akhir)`
* **High Performer Ratio**: Persentase pegawai dengan `Grade = 'A'`.
* **Performance by Position**: Rata-rata skor berdasarkan `Dim_Position`.

---

## 📂 Documentation  
- **Business Requirements**  
  `/01-business-requirements/`

- **Design Documents**  
  `/02-data-modeling/`  

---

## ⏳ Timeline
- **Misi 1:** 10 November 2025  
- **Misi 2:** 17 November 2025  
- **Misi 3:** 24 November 2025  

---

# Data Mart - Kepegawaian  
Tugas Besar Pergudangan Data - Kelompok 8
