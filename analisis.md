# Computational Chemistry Workflow Guide

Panduan ini berisi workflow untuk berbagai analisis kimia komputasi yang sering digunakan, meliputi:

* Akses ke superkomputer Fugaku
* BSSE (Basis Set Superposition Error)
* ESP (Electrostatic Surface Potential)
* MEP (Molecular Electrostatic Potential)
* HOMO/LUMO Visualization
* QTAIM Analysis
* Charge Density Difference (CDD)
* Visualisasi menggunakan VMD
* Analisis Molecular Dynamics (MD)

---

# 1. Accessing Fugaku

Login ke superkomputer Fugaku menggunakan SSH:

```bash
ssh l00038@login.fugaku.r-ccs.riken.jp
```

Pastikan:

* Akun Fugaku aktif
* SSH key sudah terdaftar (jika diperlukan)
* Koneksi jaringan memungkinkan akses ke server

---

# 2. BSSE (Basis Set Superposition Error)

## Overview

BSSE digunakan untuk mengoreksi error yang muncul akibat overlap basis set antar fragmen pada sistem intermolekuler.

Contoh aplikasi:

* Adsorpsi molekul pada permukaan
* Interaksi host–guest
* Kompleks donor–akseptor
* Molecular sensing

---

## Step 1 – Defining Fragments

Buka file output Gaussian (`.log`) menggunakan GaussView.

### Create Fragments

```text
Edit → Atom Groups
```

Pilih atom yang termasuk ke dalam masing-masing fragmen.

Contoh:

Fragment 1:

```text
TMA
```

Fragment 2:

```text
TiO2 cluster
```

Klik:

```text
OK
```

---

## Step 2 – Set Fragment Tags

```text
Edit → Set Atom Tags and Fragmentation
```

Simpan struktur hasil fragmentasi.

---

## Step 3 – Prepare Gaussian Input

Tambahkan keyword:

```text
Counterpoise=2
```

untuk sistem yang terdiri dari dua fragmen.

Contoh:

```text
# wb97xd/def2svp Counterpoise=2
```

---

## Step 4 – Run Gaussian

Jalankan kalkulasi BSSE seperti biasa.

---

## Step 5 – Extract BSSE Energy

Cari nilai BSSE dari file output:

```bash
grep "BSSE energy" BSSE-TMA-Ti.log
```

Output biasanya dalam satuan Hartree.

---

## Step 6 – Convert Hartree to eV

```bash
grep "BSSE energy" BSSE-TMA-Ti.log | awk '{print $4*27.2114}'
```

Konversi:

```text
1 Hartree = 27.2114 eV
```

---

## Troubleshooting

Jika BSSE menghasilkan nilai negatif atau terdapat indikasi wavefunction tidak stabil:

Tambahkan:

```text
Stable=Opt
```

Contoh:

```text
# wb97xd/def2svp Counterpoise=2 Stable=Opt
```

---

# 3. Electrostatic Surface Potential (ESP) Using Multiwfn

## Overview

ESP digunakan untuk:

* Mengidentifikasi daerah elektrofilik
* Mengidentifikasi daerah nukleofilik
* Mempelajari distribusi muatan
* Analisis situs adsorpsi

---

## Step 1 – Generate Formatted Checkpoint File

Pastikan tersedia:

```text
file.fchk
```

Jika file berada di server:

```bash
scp user@login2.hpc.brin.go.id:/path/file.fchk .
```

---

## Step 2 – Run Multiwfn

```bash
./Multiwfn file.fchk < ESPiso.txt
```

Output:

```text
density.cub
totesp.cub
```

---

## Step 3 – Organize Files

```bash
mkdir ESP
```

Salin file yang diperlukan:

```bash
cp density.cub density1.cub
cp totesp.cub ESP1.cub
```

---

## Step 4 – Visualization

Salin file VMD:

```bash
cp examples/drawESP/ESPiso.vmd .
```

Buka menggunakan:

```text
VMD → Load Visualization State
```

---

# 4. Molecular Electrostatic Potential (MEP)

## Generate Electron Density Cube

```bash
cubegen 16 density=scf molecule.fchk density.cub
```

---

## Generate Potential Cube

```bash
cubegen 1 potential=scf molecule.fchk potential.cub
```

---

## Output Files

| File          | Description             |
| ------------- | ----------------------- |
| density.cub   | Electron density        |
| potential.cub | Electrostatic potential |

---

# 5. HOMO/LUMO Visualization

## Determine Orbital Number

Lihat orbital HOMO/LUMO pada output Gaussian.

---

## Generate HOMO Cube

```bash
cubegen 16 MO=120 file.fchk HOMO.cub
```

---

## Generate LUMO Cube

```bash
cubegen 16 MO=121 file.fchk LUMO.cub
```

---

## Visualization

Buka file cube menggunakan:

* VMD
* Multiwfn
* VESTA

---

# 6. QTAIM Analysis Using Multiwfn

## Overview

QTAIM (Quantum Theory of Atoms in Molecules) digunakan untuk:

* Bond Critical Point (BCP)
* Ring Critical Point (RCP)
* Cage Critical Point (CCP)
* Bond Path Analysis

---

## Load Wavefunction

```bash
./Multiwfn file.wfn
```

---

## Search Critical Points

Pilih menu:

```text
2 Topology analysis
```

---

### Search from Nuclear Positions

```text
2 Search CPs from nuclear positions
```

---

### Search from Midpoints

```text
3 Search CPs from midpoint of atom pairs
```

---

### Generate Bond Paths

```text
8 Generate paths connecting (3,-3) and (3,-1)
```

---

### Export Data

```text
0 Print and visualize all generated CPs
```

Kemudian:

```text
7 Export visualization files
```

---

# 7. QTAIM Visualization in VMD

## Generate Visualization Files

Salin script:

```bash
cp Multiwfn/script/AIM.txt .
cp Multiwfn/script/AIM.vmd .
```

---

## Create PDB Files

```bash
./Multiwfn file.wfn < AIM.txt
```

Output:

```text
CPs.pdb
paths.pdb
mol.pdb
```

---

## Edit AIM.vmd

Ubah path file menjadi path absolut atau relatif yang sesuai.

Contoh:

```tcl
mol new Work/graphene/CPs.pdb
```

Lakukan juga untuk:

```tcl
paths.pdb
mol.pdb
```

Hapus:

```tcl
mol off 2
```

---

## Visualize

Buka:

```text
VMD
```

Kemudian:

```text
File → Load Visualization State
```

Pilih:

```text
AIM.vmd
```

---

# 8. Charge Density Difference (CDD)

## Overview

CDD digunakan untuk memvisualisasikan perpindahan muatan setelah pembentukan kompleks.

Formula:

Δρ = ρcomplex − ρmonomer1 − ρmonomer2

---

## Required Calculations

Lakukan Gaussian untuk:

1. Complex
2. Monomer A
3. Monomer B

Gunakan geometri yang konsisten.

Tambahkan:

```text
Symmetry=None
```

pada semua input.

---

## Generate Complex Density Cube

Multiwfn:

```text
5 Output and plot specific property
1 Electron density
4 Input grid spacing
```

Contoh:

```text
100,100,100
```

Export:

```text
Gaussian cube file
```

Simpan sebagai:

```text
complex.cub
```

---

## Generate Monomer Density Cubes

Buka header dari:

```bash
vi complex.cub
```

Catat:

* Origin
* Translation vectors
* Grid dimensions

Gunakan nilai yang sama untuk semua monomer.

---

## Create CDD Cube

Multiwfn:

```text
13 Process grid data
11 Grid data calculation
4 Subtract a grid file
```

Urutan:

```text
complex.cub
− monomer1.cub
− monomer2.cub
```

Simpan hasil sebagai:

```text
CDD.cub
```

---

# 9. Molecular Dynamics (MD)

## Useful Vim Commands

Disable wrapping:

```bash
:set nowrap
```

Save and quit:

```bash
:wq!
```

---

## Extract RMSD Column

Contoh:

```bash
gawk '{print $106}' analysis.tab
```

Menampilkan kolom RMSD ke-106.

---

## Make Script Executable

```bash
chmod u+x plot-MD.sh
```

---

# Useful File Transfer Commands

## Copy WFN Files

```bash
scp user@login2.hpc.brin.go.id:/path/*.wfn .
```

## Copy LUMO Files

```bash
scp user@login2.hpc.brin.go.id:/path/*LUMO* .
```

## Copy FCHK Files

```bash
scp user@login2.hpc.brin.go.id:/path/*.fchk .
```

---

# Recommended Software

| Software  | Purpose                        |
| --------- | ------------------------------ |
| Gaussian  | Quantum chemistry calculations |
| GaussView | Structure preparation          |
| Multiwfn  | Wavefunction analysis          |
| VMD       | Visualization                  |
| VESTA     | Cube visualization             |
| Fugaku    | High-performance computing     |
| BRIN HPC  | Production calculations        |

---

# References

* Multiwfn Manual
* Gaussian User Reference
* Bader's Atoms in Molecules Theory
* VMD User Guide
