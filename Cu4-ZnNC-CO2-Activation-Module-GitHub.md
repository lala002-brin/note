# DFT Workflow: CO2 Activation on Cu4/Zn-N-C

## 1. Tujuan

Modul ini merupakan workflow komputasi berbasis Density Functional Theory (DFT) menggunakan Quantum ESPRESSO (QE) untuk mempelajari:

1. Stabilitas struktur N-doped carbon dengan pusat Zn.
2. Stabilitas cluster Cu4 pada Zn-N-C.
3. Adsorpsi CO2 pada Cu4/Zn-N-C.
4. Penentuan konfigurasi adsorpsi CO2 yang paling stabil.
5. Aktivasi CO2 melalui transfer elektron.
6. Kemungkinan pembentukan COOH jika tersedia sumber H.
7. Kemungkinan dissociation CO2 menjadi CO + O.
8. Penentuan transition state menggunakan NEB.
9. Perhitungan activation energy dan reaction energy.
10. Analisis electronic structure, charge transfer, Bader charge, DOS/PDOS, dan COHP/ICOHP.

Target utama:

```text
Cu4/Zn-N-C + CO2
```

Kemungkinan jalur reaksi:

```text
CO2* -> CO2-*
CO2* + H -> COOH*
CO2* -> CO* + O*
```

---

# 2. Sistem Model

Sistem utama:

```text
Cu4/Zn-N-C
```

Sistem dengan CO2 teradsorpsi:

```text
Cu4/Zn-N-C-CO2
```

Secara konseptual:

```text
                         CO2
                          |
                          v
                       Cu4
                    /   |   \
                   N    N    N
                   |    |    |
                  Zn - N-doped C
```

> **Catatan penting:** XYZ yang tersedia saat ini mengandung atom `Ni` pada koordinat:
>
> ```text
> Ni   3.087500   3.921655   10.395000
> ```
>
> Jika sistem penelitian memang `Zn-N-C`, pastikan terlebih dahulu apakah `Ni` merupakan kesalahan penulisan atau memang sistem yang digunakan adalah `Ni-N-C`.
>
> Jangan mengganti Ni menjadi Zn secara otomatis. Perbedaan Ni dan Zn dapat mengubah struktur elektronik, magnetisasi, charge transfer, energi adsorpsi, dan reaction barrier.

---

# 3. Repository Structure

```text
Cu4-ZnNC-CO2-Activation/
│
├── README.md
│
├── 00_model_verification/
│   ├── model.xyz
│   ├── atom_list.txt
│   ├── cell_parameters.txt
│   └── notes.md
│
├── 01_ZnNC/
│   ├── initial/
│   ├── relax/
│   └── scf/
│
├── 02_Cu4_ZnNC/
│   ├── initial/
│   ├── relax/
│   └── scf/
│
├── 03_CO2/
│   ├── initial/
│   ├── relax/
│   └── scf/
│
├── 04_CO2_adsorption/
│   ├── P1A/
│   ├── P1B/
│   ├── P1C/
│   └── P1D/
│
├── 05_CO2_activation/
│   ├── 01_CO2_minus/
│   │   └── P1A_minus/
│   │
│   ├── 02_COOH/
│   │   ├── COOH_A/
│   │   ├── COOH_B/
│   │   └── COOH_C/
│   │
│   └── 03_CO_O/
│       ├── CO_O_A/
│       ├── CO_O_B/
│       └── CO_O_C/
│
├── 06_NEB/
│   ├── P1A_to_CO_O_A/
│   ├── P1A_to_CO_O_B/
│   └── P1A_to_CO_O_C/
│
├── 07_analysis/
│   ├── geometry/
│   ├── energy/
│   ├── charge/
│   ├── bader/
│   ├── dos/
│   ├── pdos/
│   └── charge_density/
│
├── 08_results/
│   ├── structures/
│   ├── tables/
│   ├── figures/
│   └── final/
│
└── scripts/
    ├── extract_energy.py
    ├── geometry_analysis.py
    ├── adsorption_energy.py
    └── reaction_energy.py
```

---

# 4. Computational Workflow

```text
Zn-N-C
   |
   v
RELAX
   |
   v
Zn-N-C relaxed
   |
   + Cu4
   |
   v
RELAX
   |
   v
Cu4/Zn-N-C
   |
   + CO2
   |
   v
P1A / P1B / P1C / P1D
   |
   v
RELAX
   |
   v
P1A = Most Stable
   |
   +-----------------------------+
   |                             |
   v                             v
CO2-                         COOH / CO + O
   |                             |
RELAX                           RELAX
   |                             |
   +-------------+---------------+
                 |
                 v
          Select Final State
                 |
                 v
                NEB
                 |
                 v
        Transition State
                 |
                 v
        Activation Energy
                 |
                 v
     DOS / PDOS / Bader / COHP
```

---

# 5. Tahap 0 - Model Verification

Sebelum menjalankan DFT, periksa:

- jumlah atom;
- jenis atom;
- koordinat;
- cell parameters;
- vacuum;
- periodic boundary conditions;
- posisi Zn;
- posisi N;
- posisi Cu4;
- posisi CO2;
- pseudopotential;
- exchange-correlation functional.

Buat file:

```text
00_model_verification/atom_list.txt
```

Contoh:

```text
Element    Number
C          ...
N          ...
Zn         ...
Cu         4
CO2-C      1
O          2
```

---

# 6. Tahap 1 - Relax Zn-N-C

Tujuan:

- mendapatkan support yang stabil;
- menghilangkan gaya awal yang besar;
- memperoleh energi referensi.

Workflow:

```text
Zn-N-C initial
      |
      v
    RELAX
      |
      v
Zn-N-C relaxed
      |
      v
     SCF
      |
      v
E(Zn-N-C)
```

Simpan:

```text
01_ZnNC/
├── initial/
├── relax/
└── scf/
```

---

# 7. Tahap 2 - Cu4/Zn-N-C

Gunakan Zn-N-C relaxed.

Tambahkan Cu4 pada posisi situs aktif.

Workflow:

```text
Zn-N-C relaxed
       +
      Cu4
       |
       v
initial Cu4/Zn-N-C
       |
       v
     RELAX
       |
       v
relaxed Cu4/Zn-N-C
       |
       v
      SCF
```

Simpan energi:

```text
E_Cu4_ZnNC
```

---

# 8. Stabilitas Cu4

Setelah relaxation, periksa:

- Cu-Cu distances;
- Cu-N distances;
- Cu-Zn distance jika relevan;
- perubahan geometri Cu4;
- migrasi Cu;
- perubahan koordinasi;
- apakah Cu4 tetap menjadi cluster.

Jika Cu4 mengalami rearrangement selama relaxation, gunakan struktur hasil relaxation sebagai struktur dasar tahap berikutnya.

---

# 9. Tahap 3 - CO2 Isolated

Buat CO2 isolated di dalam cell yang sesuai.

Struktur awal:

```text
O = C = O
```

Workflow:

```text
CO2 initial
     |
     v
   RELAX
     |
     v
CO2 relaxed
     |
     v
    SCF
```

Simpan:

```text
E_CO2
```

dan parameter:

- C-O distance;
- O-C-O angle.

Untuk CO2 bebas, sudut O-C-O idealnya mendekati 180 derajat.

---

# 10. Tahap 4 - CO2 Adsorption

Gunakan Cu4/Zn-N-C relaxed.

Buat beberapa konfigurasi:

```text
Cu4/Zn-N-C
     |
     +-- P1A
     +-- P1B
     +-- P1C
     +-- P1D
```

Perbedaan konfigurasi dapat berupa:

- C-down;
- O-down;
- bridge;
- atop;
- orientasi paralel;
- orientasi miring;
- posisi terhadap Cu berbeda;
- posisi relatif terhadap Zn/N.

---

# 11. Relax P1A-P1D

Setiap konfigurasi:

```text
P1A initial
    |
    v
  RELAX
    |
    v
P1A relaxed
```

Lakukan hal yang sama untuk P1B, P1C, dan P1D.

Pastikan semua konfigurasi menggunakan parameter komputasi yang sama.

---

# 12. Menentukan Struktur Adsorpsi Terbaik

Bandingkan energi total:

```text
E_P1A
E_P1B
E_P1C
E_P1D
```

Struktur dengan energi terendah menjadi kandidat utama.

Dalam workflow ini diasumsikan:

```text
P1A = Most Stable
```

Maka:

```text
P1A = Initial State (IS)
```

untuk studi aktivasi CO2.

---

# 13. Energi Adsorpsi

Gunakan:

```text
E_ads =
E(Cu4/Zn-N-C + CO2)
- E(Cu4/Zn-N-C)
- E(CO2)
```

atau secara singkat:

```text
E_ads = E_system - E_support - E_CO2
```

Interpretasi:

- `E_ads < 0` : adsorpsi exothermic secara energi elektronik.
- Semakin negatif: interaksi adsorpsi semakin kuat, dengan catatan semua referensi dan parameter komputasi konsisten.

---

# 14. Analisis Geometri P1A

Hitung:

### Cu-C

```text
d_Cu-C
```

### Cu-O

```text
d_Cu-O
```

### C-O

```text
d_C-O
```

### O-C-O

```text
angle_O-C-O
```

Bandingkan seluruh parameter dengan CO2 isolated.

---

# 15. Indikator Aktivasi CO2

CO2 dapat dianggap mengalami indikasi aktivasi jika terdapat kombinasi:

- C-O elongation;
- O-C-O bending;
- charge transfer;
- Cu-C interaction;
- Cu-O interaction;
- perubahan DOS/PDOS;
- perubahan spin jika relevan.

Jangan menentukan aktivasi hanya dari satu parameter.

---

# 16. Tahap 5 - CO2-

Hipotesis:

```text
CO2 + e- -> CO2-
```

Gunakan XYZ P1A relaxed sebagai geometri awal.

Jangan membengkokkan CO2 secara manual.

Yang diubah adalah charge sistem.

Dalam Quantum ESPRESSO:

```text
tot_charge = -1.0
```

Workflow:

```text
P1A relaxed
     |
     v
Add 1 electron
     |
     v
tot_charge = -1
     |
     v
RELAX
     |
     v
P1A- relaxed
```

---

# 17. Analisis P1A-

Bandingkan:

| Parameter | P1A | P1A- |
|---|---:|---:|
| C-O 1 | ... | ... |
| C-O 2 | ... | ... |
| O-C-O | ... | ... |
| Cu-C | ... | ... |
| Cu-O | ... | ... |
| Charge CO2 | ... | ... |
| Magnetic moment | ... | ... |

Tujuan utama:

Menentukan apakah elektron tambahan menyebabkan:

- CO2 menjadi lebih bent;
- C-O menjadi lebih panjang;
- charge berpindah ke CO2;
- interaksi Cu-CO2 berubah.

---

# 18. Spin Treatment

Sistem Cu4 dan elektron tambahan dapat memerlukan spin-polarized calculation.

Jika relevan, bandingkan:

```text
nspin = 1
```

dengan perhitungan spin-polarized.

Periksa:

```text
M_total
```

dan distribusi spin.

Keadaan spin terbaik ditentukan berdasarkan energi dan hasil electronic structure.

---

# 19. Tahap 6 - COOH

Jalur:

```text
CO2* + H -> COOH*
```

**Hanya valid jika terdapat sumber H dalam model.**

Contoh sumber H:

- H;
- H2;
- H2O;
- proton donor;
- adsorbed H.

Jika tidak ada atom H, jangan membuat COOH sebagai produk dari sistem Cu4/Zn-N-C + CO2.

---

# 20. Kandidat COOH

Jika H tersedia, buat beberapa konfigurasi:

```text
COOH_A
COOH_B
COOH_C
```

Variasikan:

- O yang menerima H;
- posisi H;
- orientasi H;
- posisi COOH terhadap Cu.

Workflow:

```text
P1A + H
    |
    v
COOH candidates
    |
    v
RELAX
    |
    v
COOH relaxed
```

Pilih konfigurasi COOH dengan energi terendah.

---

# 21. Tahap 7 - CO2 -> CO + O

Jalur:

```text
CO2* -> CO* + O*
```

Initial State:

```text
P1A
```

Final State:

```text
CO* + O*
```

---

# 22. Kandidat CO + O

Jangan hanya membuat satu konfigurasi.

Buat:

```text
CO_O_A
CO_O_B
CO_O_C
```

Perbedaan utama adalah lokasi O* pada Cu4.

Contoh:

```text
CO_O_A -> O* dekat Cu1
CO_O_B -> O* dekat Cu2
CO_O_C -> O* dekat Cu3
```

Tujuannya mencari lokasi O yang paling stabil setelah relaxation.

---

# 23. Geometri Awal CO + O

Untuk membuat produk awal:

- pertahankan C pada daerah aktif;
- bentuk C-O sebagai CO;
- pindahkan O lainnya menjadi O*;
- letakkan O* dekat situs Cu yang diuji;
- hindari posisi atom yang terlalu dekat;
- jangan membuat struktur terlalu simetris jika tidak diperlukan.

Atomic/covalent radius hanya digunakan sebagai panduan awal.

Geometri final harus ditentukan melalui relaxation.

---

# 24. Relax CO + O

```text
CO_O_A
   |
   v
 RELAX
   |
   v
CO_O_A relaxed
```

Lakukan hal yang sama untuk B dan C.

Setelah relaxation, periksa:

- convergence;
- C-O;
- Cu-C;
- Cu-O;
- O* position;
- perubahan Cu4;
- apakah CO tetap terbentuk;
- apakah O tetap teradsorpsi;
- apakah struktur kembali menjadi CO2.

---

# 25. Final State

Bandingkan:

```text
E_CO_O_A
E_CO_O_B
E_CO_O_C
```

Pilih energi terendah:

```text
FS = Best CO + O
```

Kemudian:

```text
P1A -> FS
```

menjadi reaksi yang akan dipelajari menggunakan NEB.

---

# 26. Reaction Energy

Gunakan:

```text
Delta_E_reaction = E_FS - E_P1A
```

Interpretasi:

- `Delta_E_reaction < 0`: FS lebih stabil secara energi.
- `Delta_E_reaction > 0`: FS lebih tinggi energi.

Tetapi:

```text
Reaction energy != Activation energy
```

---

# 27. Tahap 8 - NEB

Setelah Initial State dan Final State valid:

```text
P1A -> CO + O
```

gunakan NEB.

Contoh:

```text
Image 00 = P1A
Image 01 = intermediate
Image 02 = intermediate
Image 03 = intermediate
Image 04 = intermediate
Image 05 = intermediate
Image 06 = CO + O
```

Workflow:

```text
P1A
 |
 v
Image 1
 |
 v
Image 2
 |
 v
Image 3
 |
 v
Image 4
 |
 v
Image 5
 |
 v
CO + O
```

---

# 28. Transition State

NEB memberikan minimum energy path.

Cari image dengan energi maksimum:

```text
E_TS
```

Kemudian:

```text
E_a = E_TS - E_P1A
```

dan:

```text
Delta_E = E_FS - E_P1A
```

---

# 29. Energy Profile

```text
Energy
  |
  |                     TS
  |                    /\
  |                   /  \
  |                  /    \
  |       P1A ______/      \______ CO + O
  |
  +---------------------------------------->
              Reaction coordinate
```

Parameter utama:

- Initial State energy;
- Transition State energy;
- Final State energy;
- Activation energy;
- Reaction energy.

---

# 30. Charge Transfer

Analisis aliran elektron pada:

1. Zn-N-C;
2. Cu4/Zn-N-C;
3. CO2;
4. Cu4/Zn-N-C-CO2.

Kemungkinan:

```text
Zn-N-C -> Cu4
```

dan/atau:

```text
Cu4 -> CO2
```

atau transfer langsung:

```text
Zn-N-C -> CO2
```

---

# 31. Charge Density Difference

Gunakan konsep:

```text
Delta_rho =
rho(Cu4/Zn-N-C + CO2)
- rho(Cu4/Zn-N-C)
- rho(CO2)
```

Tujuan:

- melihat electron accumulation;
- melihat electron depletion;
- mengidentifikasi area interaksi;
- menghubungkan charge transfer dengan C-O activation.

---

# 32. Bader Charge

Analisis:

- Cu;
- C pada CO2;
- O;
- Zn;
- N yang relevan.

Bandingkan:

```text
CO2 isolated
      |
      v
P1A
      |
      v
P1A-
      |
      v
CO + O
```

Parameter penting:

```text
q_C
q_O
q_Cu
q_Zn
q_N
```

dan perubahan:

```text
Delta_q
```

---

# 33. DOS dan PDOS

Untuk P1A lakukan:

### DOS

```text
DOS(E)
```

### PDOS

Analisis:

- Cu-d;
- C-p;
- O-p;
- Zn states;
- N states.

Fokus pada:

- daerah dekat Fermi level;
- perubahan electronic states setelah adsorpsi;
- kemungkinan hybridization.

---

# 34. Hybridization

Cari indikasi overlap antara:

```text
Cu-d
```

dan:

```text
C/O-p
```

Overlap yang berubah setelah adsorpsi dapat mendukung interpretasi adanya interaksi elektronik Cu-CO2.

---

# 35. COHP / ICOHP

Jika workflow tersedia, analisis:

- Cu-C;
- Cu-O;
- C-O.

Gunakan COHP/ICOHP untuk membantu mengevaluasi:

- bond strength;
- bonding/antibonding;
- weakening C-O;
- formation of Cu-O.

---

# 36. Vibrational Analysis

Untuk struktur minimum:

- P1A;
- CO2;
- CO + O;
- COOH jika digunakan;

minimum idealnya tidak memiliki imaginary frequency.

Untuk transition state:

Diharapkan terdapat satu imaginary mode yang sesuai dengan koordinat reaksi.

---

# 37. Kriteria Struktur Valid

Struktur relaxed harus memenuhi:

- SCF converged;
- ionic relaxation converged;
- force memenuhi threshold;
- tidak ada atom bergerak ke posisi tidak fisik;
- tidak ada adsorbate yang lepas secara tidak diinginkan;
- struktur sesuai dengan chemical model.

---

# 38. Tabel Hasil Utama

Gunakan tabel:

| System | Energy (eV) | Delta E (eV) | C-O (A) | O-C-O (deg) | Charge CO2 |
|---|---:|---:|---:|---:|---:|
| CO2 | ... | - | ... | ... | ... |
| Cu4/ZnNC | ... | - | - | - | - |
| P1A | ... | ... | ... | ... | ... |
| P1A- | ... | ... | ... | ... | ... |
| COOH | ... | ... | ... | ... | ... |
| CO+O-A | ... | ... | ... | ... | ... |
| CO+O-B | ... | ... | ... | ... | ... |
| CO+O-C | ... | ... | ... | ... | ... |

---

# 39. Tabel NEB

| Image | Reaction Coordinate | Energy (eV) | C-O (A) | Cu-O (A) |
|---|---:|---:|---:|---:|
| 0 | 0.00 | ... | ... | ... |
| 1 | ... | ... | ... | ... |
| 2 | ... | ... | ... | ... |
| 3 | ... | ... | ... | ... |
| 4 | ... | ... | ... | ... |
| 5 | ... | ... | ... | ... |
| 6 | 1.00 | ... | ... | ... |

---

# 40. Workflow Final

```text
Zn-N-C
  |
  v
RELAX
  |
  v
Zn-N-C relaxed
  |
  + Cu4
  |
  v
RELAX
  |
  v
Cu4/Zn-N-C
  |
  + CO2
  |
  v
P1A / P1B / P1C / P1D
  |
  v
RELAX
  |
  v
P1A = Most Stable
  |
  +-------------------------+
  |                         |
  v                         v
CO2-                    COOH / CO + O
  |                         |
RELAX                       RELAX
  |                         |
  +------------+------------+
               |
               v
        Best Final State
               |
               v
              NEB
               |
               v
       Transition State
               |
               v
       Activation Energy
               |
               v
 DOS / PDOS / Bader / COHP
               |
               v
       CO2 Activation Mechanism
```

---

# 41. Checklist Perhitungan

## Model

- [ ] Verifikasi atom Zn/Ni
- [ ] Verifikasi jumlah atom
- [ ] Verifikasi cell
- [ ] Verifikasi vacuum
- [ ] Verifikasi pseudopotential

## Support

- [ ] Zn-N-C initial
- [ ] Zn-N-C relax
- [ ] Zn-N-C SCF

## Cu4

- [ ] Cu4/Zn-N-C initial
- [ ] Cu4/Zn-N-C relax
- [ ] Cu4/Zn-N-C SCF

## CO2

- [ ] CO2 isolated relax
- [ ] CO2 isolated SCF

## Adsorption

- [ ] P1A initial
- [ ] P1B initial
- [ ] P1C initial
- [ ] P1D initial
- [ ] P1A relax
- [ ] P1B relax
- [ ] P1C relax
- [ ] P1D relax
- [ ] Determine most stable structure
- [ ] Calculate adsorption energy

## CO2-

- [ ] P1A- initial
- [ ] tot_charge = -1
- [ ] Relax
- [ ] SCF
- [ ] Geometry analysis
- [ ] Charge analysis
- [ ] Spin analysis

## COOH

- [ ] Confirm H source
- [ ] Create COOH-A
- [ ] Create COOH-B
- [ ] Create COOH-C
- [ ] Relax
- [ ] Determine best COOH

## CO + O

- [ ] Create CO_O-A
- [ ] Create CO_O-B
- [ ] Create CO_O-C
- [ ] Relax
- [ ] SCF
- [ ] Determine best final state
- [ ] Calculate reaction energy

## NEB

- [ ] Verify IS
- [ ] Verify FS
- [ ] Generate images
- [ ] Run NEB
- [ ] Convergence check
- [ ] Identify TS
- [ ] Calculate activation energy

## Electronic Analysis

- [ ] Charge density
- [ ] Charge density difference
- [ ] Bader
- [ ] DOS
- [ ] PDOS
- [ ] COHP/ICOHP
- [ ] Spin density
- [ ] Vibrational analysis

---

# 42. Final Scientific Questions

Pada akhir workflow, penelitian harus mampu menjawab:

1. Apakah Cu4/Zn-N-C mampu mengadsorpsi CO2 secara stabil?
2. Seberapa kuat adsorpsi CO2?
3. Apakah adsorpsi menyebabkan CO2 mengalami bending?
4. Apakah ikatan C-O mengalami elongation?
5. Apakah terdapat transfer elektron dari support/Cu4 menuju CO2?
6. Apakah karakter CO2- terbentuk?
7. Apakah COOH dapat terbentuk jika H tersedia?
8. Apakah CO2 dapat terdisosiasi menjadi CO + O?
9. Apa final state yang paling stabil?
10. Berapa reaction energy?
11. Berapa activation energy?
12. Struktur elektronik apa yang bertanggung jawab terhadap aktivasi CO2?
13. Apa peran Cu4?
14. Apa peran Zn-N-C sebagai support?
15. Bagaimana mekanisme keseluruhan aktivasi CO2?

---

# 43. Status Workflow Saat Ini

Berdasarkan struktur dan hasil yang sudah tersedia:

```text
[✓] P1 relaxed
[✓] P1A relaxed
[✓] P1A dianggap struktur paling stabil

[!] Verifikasi Ni vs Zn pada support
[ ] Zn-N-C reference
[ ] Cu4/Zn-N-C reference
[ ] CO2 isolated reference
[ ] Adsorption energy
[ ] P1A- relaxation
[ ] COOH candidates, jika H tersedia
[ ] CO + O candidates
[ ] Final-state selection
[ ] NEB
[ ] Activation energy
[ ] Bader
[ ] DOS/PDOS
[ ] Charge density
[ ] COHP/ICOHP
[ ] Vibrational analysis
[ ] Final mechanism
```

---

# 44. Prinsip Utama Workflow

Urutan penelitian:

```text
Model
  ->
Relaxation
  ->
Adsorption
  ->
CO2 Activation
  ->
Products
  ->
NEB
  ->
Electronic Analysis
```

Jangan melakukan NEB sebelum:

1. Initial State valid.
2. Final State valid.
3. Kedua struktur telah relaxed.
4. Kedua endpoint merupakan minimum lokal yang masuk akal.
5. Chemical composition konsisten.

Target akhir:

```text
Structure
    ->
Charge Transfer
    ->
CO2 Activation
    ->
Reaction Pathway
    ->
Transition State
    ->
Activation Barrier
    ->
Mechanism
```

---

# 45. Catatan untuk Reproducibility

Setiap perhitungan wajib mencatat:

```text
Quantum ESPRESSO version
DFT functional
Pseudopotential
Plane-wave cutoff
Charge-density cutoff
k-point mesh
Smearing
Spin treatment
Convergence threshold
Force threshold
Cell parameters
Vacuum thickness
Total charge
Initial magnetic moment
Final magnetic moment
```

Semua data input dan output penting sebaiknya disimpan di repository.

Contoh:

```text
02_Cu4_ZnNC/relax/
├── cu4_znnc.in
├── cu4_znnc.out
└── final_structure.xyz
```

---

# 46. Prinsip Perbandingan Energi

Energi hanya boleh dibandingkan secara langsung jika:

- functional sama;
- pseudopotential sama;
- cutoff sama;
- cell konsisten;
- k-point konsisten;
- treatment spin konsisten;
- convergence criteria memadai;
- jumlah atom dan komposisi sesuai dengan definisi sistem.

Untuk charged system seperti P1A-, interpretasi energi harus memperhatikan bahwa perhitungan periodic charged system memerlukan treatment electrostatic yang konsisten.

---

# 47. Output Utama yang Diharapkan

Pada akhir penelitian, minimal tersedia:

```text
01. Optimized Zn-N-C
02. Optimized Cu4/Zn-N-C
03. Optimized CO2
04. Optimized P1A
05. Optimized P1B
06. Optimized P1C
07. Optimized P1D
08. CO2 adsorption energy
09. Optimized P1A-
10. Optimized COOH, jika relevan
11. Optimized CO + O candidates
12. Best final state
13. NEB pathway
14. Transition state
15. Activation energy
16. Reaction energy
17. Bader charge
18. Charge density difference
19. DOS
20. PDOS
21. COHP/ICOHP
22. Vibrational analysis
23. Final reaction mechanism
```

---

# 48. Final Research Logic

Workflow utama:

```text
Cu4/Zn-N-C
      |
      | + CO2
      v
Cu4/Zn-N-C-CO2
      |
      v
P1A = Most Stable
      |
      +---------------------+
      |                     |
      v                     v
   CO2-                  COOH*
      |                     |
      |                     |
      +----------+----------+
                 |
                 v
              CO* + O*
                 |
                 v
                NEB
                 |
                 v
                TS
                 |
                 v
        Activation Barrier
                 |
                 v
      CO2 Activation Mechanism
```

Tujuan akhirnya bukan sekadar mendapatkan struktur dengan energi rendah, tetapi menjelaskan hubungan:

```text
Support
   ->
Cu4 Electronic Structure
   ->
CO2 Adsorption
   ->
Charge Transfer
   ->
C-O Activation
   ->
Reaction Pathway
   ->
Transition State
   ->
Activation Barrier
   ->
Reaction Mechanism
```
