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
* **Nama Lengkap 2** — NIM
* **Nama Lengkap 3** — NIM
* **Nama Lengkap 4** — NIM

## 📘 Project Description

Data Mart Kepegawaian ini dirancang untuk mendukung analitik manajemen sumber daya manusia secara komprehensif di Institut Teknologi Sumatera. Fokus utama berada pada proses **rekrutmen, pengelolaan pegawai, pengembangan karir, penilaian kinerja, serta kesejahteraan pegawai**, sehingga dapat dipakai untuk memantau produktivitas pegawai, efektivitas program pelatihan, analisis headcount, serta perencanaan suksesi.

Pendekatan **dimensional modeling (Kimball)** digunakan agar proses analisis cepat, konsisten, dan mudah diekspansi.

---

## 🏫 Business Domain

Domain yang diangkat adalah **pengelolaan kepegawaian**, mencakup seluruh lifecycle pegawai:

1. **Rekrutmen & Seleksi** (Recruitment)
2. **Penempatan & Penugasan** (Assignment)
3. **Kehadiran & Produktivitas** (Attendance)
4. **Pelatihan & Pengembangan** (Training & Development)
5. **Penilaian Kinerja** (Performance Appraisal)
6. **Mutasi & Promosi** (Career Movement)

### Stakeholder Utama:
* **Bagian Kepegawaian ITERA**
* **Rektor & Wakil Rektor II (SDM)**
* **Kepala Unit/Fakultas**
* **Kepala Biro**

## 🏗️ Architecture

* **Approach**: Kimball Dimensional Modeling (Star Schema)
* **Platform**: SQL Server 2019 on Azure VM
* **ETL**: SQL Server Integration Services (SSIS) / T-SQL Stored Procedures
* **Orchestrator**: SQL Server Agent
* **Analytical Layer**: Power BI Desktop
* **Version Control**: GitHub

---


## ⭐ Key Features

### 🧮 Fact Tables

#### 1. **Fact_Employee_Snapshot**
**Grain**: Satu baris per pegawai per bulan (Monthly Snapshot)

* **SnapshotKey** (PK)
* **DateKey** (FK → Dim_Date)
* **EmployeeKey** (FK → Dim_Employee)
* **PositionKey** (FK → Dim_Position)
* **UnitKey** (FK → Dim_Unit)
* **RankKey** (FK → Dim_Rank)
* **Measures**:
  * IsActive
  * BaseSalary
  * TotalCompensation
  * TenureMonths
  * AgeYears

#### 2. **Fact_Attendance**
**Grain**: Satu baris per pegawai per hari

* **AttendanceKey** (PK)
* **DateKey** (FK → Dim_Date)
* **EmployeeKey** (FK → Dim_Employee)
* **UnitKey** (FK → Dim_Unit)
* **Measures**:
  * CheckInTime
  * CheckOutTime
  * WorkingHours
  * LateMinutes
  * IsPresent
  * IsLate

#### 3. **Fact_Performance**
**Grain**: Satu baris per pegawai per periode evaluasi

* **PerformanceKey** (PK)
* **EvaluationDateKey** (FK → Dim_Date)
* **PeriodStartDateKey** (FK → Dim_Date)
* **PeriodEndDateKey** (FK → Dim_Date)
* **EmployeeKey** (FK → Dim_Employee - *Dinilai*)
* **EvaluatorKey** (FK → Dim_Employee - *Penilai*)
* **Measures**:
  * SKPScore
  * BehaviorScore
  * TotalScore
  * PerformanceRating

  ---
  
## 📊 Key Performance Indicators (KPIs)

### 🎯 Strategic (HR Health & Cost)
* **Total Headcount** (Jumlah pegawai aktif per periode)
* **Turnover Rate** (% Pegawai keluar vs Total pegawai)
* **Cost Per Employee** (Rata-rata gaji & kompensasi)
* **Average Tenure** (Rata-rata lama bekerja)
* **Retirement Forecast** (Prediksi pensiun berdasarkan usia)

### 📈 Operational (Discipline)
* **Attendance Rate** (% Kehadiran vs Hari Kerja Efektif)
* **Punctuality Rate** (% Check-in tepat waktu)
* **Late Intensity** (Rata-rata menit keterlambatan per kejadian)

### ⭐ Quality (Performance)
* **Average Performance Score** (Rata-rata nilai SKP/Total Score)
* **High Performer Ratio** (% Pegawai dengan rating 'Sangat Baik' atau A)
* **Low Performer Ratio** (% Pegawai dengan rating 'Kurang' atau D/E)
* **Promotion Eligibility** (% Pegawai memenuhi syarat promosi)

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
