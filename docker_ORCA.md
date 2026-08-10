# ORCA DOCKER Workflow Guide

Panduan penggunaan **DOCKER module pada ORCA** untuk melakukan docking
antara struktur **HOST** dan **GUEST** pada server/HPC Linux.

> **Note:** `HOST`, `GUEST`, `host.xyz`, dan `guest.xyz` adalah nama
> generik dan dapat diganti sesuai sistem yang digunakan.

------------------------------------------------------------------------

## Table of Contents

1.  [Overview](#1-overview)
2.  [HOST dan GUEST](#2-host-dan-guest)
3.  [Persiapan HOST](#3-persiapan-host)
4.  [Persiapan GUEST](#4-persiapan-guest)
5.  [Basic DOCKER Input](#5-basic-docker-input)
6.  [DOCKER Method](#6-docker-method)
7.  [NRepeatGuest](#7-nrepeatguest)
8.  [Cumulative Docking](#8-cumulative-docking)
9.  [Docking Level](#9-docking-level)
10. [Fixing HOST](#10-fixing-host)
11. [PES untuk Docking](#11-pes-untuk-docking)
12. [Output Files](#12-output-files)
13. [ORCA pada HPC](#13-orca-pada-hpc)
14. [SLURM Job Script](#14-slurm-job-script)
15. [Running Job](#15-running-job)
16. [Monitoring Job](#16-monitoring-job)
17. [Useful Commands](#17-useful-commands)
18. [Struktur Directory](#18-struktur-directory)
19. [Contoh Input](#19-contoh-input)
20. [Troubleshooting](#20-troubleshooting)
21. [Workflow Lengkap](#21-workflow-lengkap)
22. [References](#22-references)

------------------------------------------------------------------------

# 1. Overview

**ORCA DOCKER** digunakan untuk mencari konfigurasi atau pose interaksi
yang menguntungkan antara HOST dan GUEST.

Workflow umum:

``` text
HOST + GUEST
     |
     v
ORCA DOCKER
     |
     v
Generate docking configurations
     |
     v
Docking search
     |
     v
Energy evaluation
     |
     v
Low-energy candidates
     |
     v
Higher-level calculation
```

DOCKER dapat digunakan sebagai tahap awal untuk menemukan struktur
kandidat sebelum dilakukan optimasi dan analisis menggunakan metode yang
lebih tinggi.

------------------------------------------------------------------------

# 2. HOST dan GUEST

## HOST

HOST adalah struktur utama yang menjadi lokasi docking.

Contoh:

``` text
host.xyz
```

HOST dapat berupa:

-   Molekul
-   Cluster atom
-   Metal cluster
-   Surface model
-   Molecular cage
-   Framework
-   Nanostructure

## GUEST

GUEST adalah molekul yang akan ditempatkan pada HOST.

Contoh:

``` text
guest.xyz
```

GUEST dapat berupa:

-   Molekul kecil
-   Ion
-   Ligand
-   Adsorbate
-   Solvent molecule
-   Drug molecule
-   Donor molecule
-   Acceptor molecule

Konsep dasar:

``` text
HOST
  +
GUEST
  |
  v
DOCKING
  |
  v
HOST-GUEST COMPLEX
```

------------------------------------------------------------------------

# 3. Persiapan HOST

Siapkan struktur HOST dalam format XYZ.

Contoh:

``` text
host.xyz
```

Format XYZ:

``` text
20
HOST
C      x.xxxx    y.yyyy    z.zzzz
C      x.xxxx    y.yyyy    z.zzzz
H      x.xxxx    y.yyyy    z.zzzz
...
```

Pastikan:

-   Koordinat benar
-   Charge benar
-   Multiplicity benar
-   Tidak ada atom yang tidak diperlukan
-   Struktur sesuai dengan sistem penelitian

------------------------------------------------------------------------

# 4. Persiapan GUEST

Siapkan struktur GUEST dalam format XYZ.

Contoh:

``` text
guest.xyz
```

Format:

``` text
10
GUEST
C      x.xxxx    y.yyyy    z.zzzz
H      x.xxxx    y.yyyy    z.zzzz
N      x.xxxx    y.yyyy    z.zzzz
...
```

Pastikan:

-   Geometri masuk akal
-   Charge benar
-   Multiplicity benar
-   Struktur tidak memiliki atom yang tidak diinginkan

------------------------------------------------------------------------

# 5. Basic DOCKER Input

Input paling sederhana:

``` text
! DOCK(GFN2-XTB)

%DOCKER
    GUEST "guest.xyz"
END

*XYZFILE 0 1 host.xyz
```

Simpan sebagai:

``` text
dock.inp
```

Jalankan:

``` bash
orca dock.inp > dock.out
```

### Penjelasan

``` text
! DOCK(GFN2-XTB)
```

Menentukan metode docking.

``` text
GUEST "guest.xyz"
```

Menentukan file GUEST.

``` text
*XYZFILE 0 1 host.xyz
```

Menentukan file HOST.

Format:

``` text
*XYZFILE charge multiplicity filename
```

Contoh:

``` text
*XYZFILE 0 1 host.xyz
```

berarti:

``` text
Charge       = 0
Multiplicity = 1
HOST         = host.xyz
```

Sesuaikan charge dan multiplicity dengan sistem yang digunakan.

------------------------------------------------------------------------

# 6. DOCKER Method

Contoh metode:

## GFN2-xTB

``` text
! DOCK(GFN2-XTB)
```

## GFN1-xTB

``` text
! DOCK(GFN1-XTB)
```

## GFN0-xTB

``` text
! DOCK(GFN0-XTB)
```

## GFN-FF

``` text
! DOCK(GFN-FF)
```

Pemilihan metode bergantung pada sistem dan tujuan perhitungan.

Untuk workflow penelitian, hasil DOCKER sebaiknya divalidasi menggunakan
metode dengan level teori yang lebih tinggi.

------------------------------------------------------------------------

# 7. NRepeatGuest

Parameter:

``` text
NRepeatGuest
```

digunakan ketika GUEST ingin digunakan secara berulang.

Contoh:

``` text
! DOCK(GFN2-XTB)

%DOCKER
    GUEST "guest.xyz"
    NRepeatGuest 5
END

*XYZFILE 0 1 host.xyz
```

Secara konseptual:

``` text
HOST
 |
 +-- GUEST
 |
 +-- GUEST
 |
 +-- GUEST
 |
 +-- GUEST
 |
 +-- GUEST
```

Jumlah harus disesuaikan dengan kebutuhan sistem.

------------------------------------------------------------------------

# 8. Cumulative Docking

Untuk docking kumulatif:

``` text
! DOCK(GFN2-XTB)

%DOCKER
    GUEST "guest.xyz"
    NRepeatGuest 5
    CUMULATIVE TRUE
END

*XYZFILE 0 1 host.xyz
```

Konsep:

``` text
HOST
 |
 v
HOST + GUEST
 |
 v
HOST + 2 GUEST
 |
 v
HOST + 3 GUEST
 |
 v
HOST + 4 GUEST
 |
 v
HOST + 5 GUEST
```

Gunakan `CUMULATIVE TRUE` jika guest memang ingin ditambahkan secara
bertahap.

------------------------------------------------------------------------

# 9. Docking Level

Level pencarian dapat digunakan sesuai kebutuhan screening.

Contoh:

``` text
%DOCKER
    GUEST "guest.xyz"
    DOCKLEVEL SCREENING
END
```

Pilihan yang umum digunakan:

``` text
SCREENING
QUICK
NORMAL
COMPLETE
```

  Level         Tujuan
  ------------- ------------------------------
  `SCREENING`   Screening awal
  `QUICK`       Pencarian cepat
  `NORMAL`      Workflow umum
  `COMPLETE`    Pencarian lebih komprehensif

Level yang lebih tinggi umumnya membutuhkan computational cost yang
lebih besar.

------------------------------------------------------------------------

# 10. Fixing HOST

Jika HOST harus tetap selama docking:

``` text
! DOCK(GFN2-XTB)

%DOCKER
    GUEST "guest.xyz"
    FIXHOST TRUE
END

*XYZFILE 0 1 host.xyz
```

`FIXHOST TRUE` berguna untuk sistem seperti:

-   Surface
-   Metal cluster
-   Rigid framework
-   Molecular cage
-   Struktur HOST yang tidak ingin mengalami perubahan geometri

------------------------------------------------------------------------

# 11. PES untuk Docking

Potential Energy Surface dapat digunakan pada tahap pencarian.

Contoh:

``` text
! DOCK(GFN2-XTB)

%DOCKER
    GUEST "guest.xyz"
    EVPES GFN2XTB
END

*XYZFILE 0 1 host.xyz
```

Metode yang dapat digunakan bergantung pada versi ORCA dan dokumentasi
DOCKER yang tersedia pada instalasi:

``` text
GFN0XTB
GFN1XTB
GFN2XTB
GFNFF
```

------------------------------------------------------------------------

# 12. Output Files

Setelah perhitungan:

``` bash
orca dock.inp > dock.out
```

Output utama:

``` text
dock.out
```

File hasil docking dapat berupa:

``` text
dock.docker.xyz
dock.docker.struc1.xyz
dock.docker.struc2.xyz
...
```

File intermediate dapat berupa:

``` text
*.opt
*.xyz
*.xtb
*.xtberr
*.g.inp.tmp
*.gu.tmp
*.lastscf
```

Jumlah file bergantung pada:

-   Ukuran sistem
-   Jumlah kandidat
-   Docking level
-   Jumlah guest
-   Metode yang digunakan

> Jangan menghapus file intermediate selama job masih berjalan.

------------------------------------------------------------------------

# 13. ORCA pada HPC

Jika ORCA tersedia sebagai module:

``` bash
module load nuclear/orca/6.0.0
```

Periksa lokasi ORCA:

``` bash
which orca
```

Periksa module yang tersedia:

``` bash
module avail
```

Jika ingin melihat module ORCA:

``` bash
module avail orca
```

------------------------------------------------------------------------

# 14. SLURM Job Script

Contoh generic:

``` bash
#!/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --partition=short

#SBATCH --output=dock.out
#SBATCH --error=dock.err

ulimit -l unlimited

module load nuclear/orca/6.0.0

orca dock.inp > dock.out
```

Simpan sebagai:

``` text
dock.sh
```

Jika cluster menggunakan konfigurasi resource yang berbeda, sesuaikan:

``` text
#SBATCH --nodes
#SBATCH --ntasks
#SBATCH --partition
#SBATCH --mem
#SBATCH --time
```

dengan aturan HPC yang digunakan.

------------------------------------------------------------------------

# 15. Running Job

Berikan permission:

``` bash
chmod +x dock.sh
```

Submit:

``` bash
sbatch dock.sh
```

Periksa job:

``` bash
squeue -u $USER
```

------------------------------------------------------------------------

# 16. Monitoring Job

Monitor output:

``` bash
tail -f dock.out
```

Monitor error:

``` bash
tail -f dock.err
```

Periksa status:

``` bash
squeue -u $USER
```

Detail job:

``` bash
scontrol show job JOBID
```

Setelah selesai:

``` bash
sacct -j JOBID
```

Batalkan job:

``` bash
scancel JOBID
```

------------------------------------------------------------------------

# 17. Useful Commands

## Check ORCA

``` bash
which orca
```

## Load ORCA

``` bash
module load nuclear/orca/6.0.0
```

## Check module

``` bash
module list
```

## Submit

``` bash
sbatch dock.sh
```

## Check running jobs

``` bash
squeue -u $USER
```

## Cancel job

``` bash
scancel JOBID
```

## Monitor output

``` bash
tail -f dock.out
```

## Monitor error

``` bash
tail -f dock.err
```

## Search error

``` bash
grep -i "error" dock.out
```

## Search warning

``` bash
grep -i "warning" dock.out
```

## Search interaction information

``` bash
grep -i "interaction" dock.out
```

------------------------------------------------------------------------

# 18. Struktur Directory

Untuk satu sistem:

``` text
docking/
├── host.xyz
├── guest.xyz
├── dock.inp
├── dock.sh
├── dock.out
├── dock.err
└── analysis/
```

Untuk beberapa sistem:

``` text
docking/
├── system_01/
│   ├── host.xyz
│   ├── guest.xyz
│   ├── dock.inp
│   ├── dock.sh
│   ├── dock.out
│   └── dock.err
│
├── system_02/
│   ├── host.xyz
│   ├── guest.xyz
│   ├── dock.inp
│   ├── dock.sh
│   ├── dock.out
│   └── dock.err
│
└── system_03/
    ├── host.xyz
    ├── guest.xyz
    ├── dock.inp
    ├── dock.sh
    ├── dock.out
    └── dock.err
```

------------------------------------------------------------------------

# 19. Contoh Input

## Basic

``` text
! DOCK(GFN2-XTB)

%DOCKER
    GUEST "guest.xyz"
END

*XYZFILE 0 1 host.xyz
```

## Multiple Guest

``` text
! DOCK(GFN2-XTB)

%DOCKER
    GUEST "guest.xyz"
    NRepeatGuest 5
END

*XYZFILE 0 1 host.xyz
```

## Cumulative

``` text
! DOCK(GFN2-XTB)

%DOCKER
    GUEST "guest.xyz"
    NRepeatGuest 5
    CUMULATIVE TRUE
END

*XYZFILE 0 1 host.xyz
```

## Fixed HOST

``` text
! DOCK(GFN2-XTB)

%DOCKER
    GUEST "guest.xyz"
    FIXHOST TRUE
END

*XYZFILE 0 1 host.xyz
```

## Screening

``` text
! DOCK(GFN2-XTB)

%DOCKER
    GUEST "guest.xyz"
    DOCKLEVEL SCREENING
END

*XYZFILE 0 1 host.xyz
```

## Normal

``` text
! DOCK(GFN2-XTB)

%DOCKER
    GUEST "guest.xyz"
    DOCKLEVEL NORMAL
END

*XYZFILE 0 1 host.xyz
```

## Complete

``` text
! DOCK(GFN2-XTB)

%DOCKER
    GUEST "guest.xyz"
    DOCKLEVEL COMPLETE
END

*XYZFILE 0 1 host.xyz
```

------------------------------------------------------------------------

# 20. Troubleshooting

## ORCA command not found

Error:

``` text
orca: command not found
```

Cek module:

``` bash
module avail
```

Load ORCA:

``` bash
module load nuclear/orca/6.0.0
```

Kemudian:

``` bash
which orca
```

------------------------------------------------------------------------

## GUEST tidak ditemukan

Jika input:

``` text
GUEST "guest.xyz"
```

Pastikan file tersedia:

``` bash
ls -lh guest.xyz
```

Periksa current directory:

``` bash
pwd
```

Periksa seluruh file:

``` bash
ls -lh
```

------------------------------------------------------------------------

## HOST tidak ditemukan

Periksa:

``` bash
ls -lh host.xyz
```

Pastikan input menggunakan nama yang sama:

``` text
*XYZFILE 0 1 host.xyz
```

Linux bersifat case-sensitive.

Contoh:

``` text
host.xyz
Host.xyz
HOST.xyz
```

adalah tiga nama file berbeda.

------------------------------------------------------------------------

## Job FAILED

Periksa:

``` bash
cat dock.err
```

Kemudian:

``` bash
tail -100 dock.out
```

Cari error:

``` bash
grep -i "error" dock.out
```

------------------------------------------------------------------------

## Job terlalu lama

Gunakan workflow bertahap:

``` text
SCREENING
    |
    v
QUICK
    |
    v
NORMAL
    |
    v
COMPLETE
```

Untuk screening awal, gunakan level yang lebih ringan sebelum
menjalankan pencarian yang lebih komprehensif.

------------------------------------------------------------------------

# 21. Workflow Lengkap

``` text
                 HOST
               host.xyz
                   |
                   |
                   v
             GUEST
            guest.xyz
                   |
                   v
          +----------------+
          |   ORCA DOCKER   |
          +----------------+
                   |
                   v
        Generate Initial Poses
                   |
                   v
            Docking Search
                   |
                   v
            Energy Evaluation
                   |
                   v
          Low-Energy Candidates
                   |
                   v
          Select Best Structures
                   |
                   v
        Higher-Level Optimization
                   |
                   v
             Final Analysis
```

Workflow penelitian:

``` text
HOST + GUEST
      |
      v
ORCA DOCKER
      |
      v
Docking Candidates
      |
      v
Select Low-Energy Structures
      |
      v
Geometry Optimization
      |
      v
Frequency / Single Point
      |
      v
Interaction Energy
      |
      +----------+----------+
      |          |          |
      v          v          v
     BSSE      QTAIM      ESP/MEP
      |          |          |
      +----------+----------+
                 |
                 v
          Final Interpretation
```

------------------------------------------------------------------------

# 22. References

-   ORCA Manual
-   ORCA 6 Documentation
-   ORCA DOCKER Documentation
-   ORCA Tutorials
-   GFN-xTB Documentation

------------------------------------------------------------------------

# Quick Start

## 1. Prepare files

``` text
host.xyz
guest.xyz
dock.inp
dock.sh
```

## 2. Create `dock.inp`

``` text
! DOCK(GFN2-XTB)

%DOCKER
    GUEST "guest.xyz"
END

*XYZFILE 0 1 host.xyz
```

## 3. Create `dock.sh`

``` bash
#!/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --partition=short

#SBATCH --output=dock.out
#SBATCH --error=dock.err

ulimit -l unlimited

module load nuclear/orca/6.0.0

orca dock.inp > dock.out
```

## 4. Make executable

``` bash
chmod +x dock.sh
```

## 5. Submit

``` bash
sbatch dock.sh
```

## 6. Monitor

``` bash
squeue -u $USER
```

## 7. Check output

``` bash
tail -f dock.out
```

## 8. Check error

``` bash
tail -f dock.err
```

------------------------------------------------------------------------

# Important Note

DOCKER sebaiknya diposisikan sebagai tahap **structure screening /
structure searching**.

Struktur hasil docking dapat digunakan sebagai starting structure untuk:

-   Geometry optimization
-   Frequency calculation
-   Single-point energy
-   Interaction energy
-   BSSE
-   QTAIM
-   ESP / MEP
-   HOMO/LUMO
-   Charge analysis
-   Charge density difference

Workflow utama:

``` text
HOST + GUEST
      |
      v
ORCA DOCKER
      |
      v
Docking Candidates
      |
      v
Low-Energy Structures
      |
      v
Higher-Level Optimization
      |
      v
Electronic Structure Analysis
      |
      v
Final Results
```
