# DFT Workflow: CO₂ Activation on Cu₄/Zn–N–C

## 1. Tujuan

Modul ini merupakan workflow komputasi berbasis **Density Functional Theory (DFT)** menggunakan **Quantum ESPRESSO (QE)** untuk mempelajari:

1. stabilitas struktur N-doped carbon dengan pusat Zn;
2. stabilitas cluster Cu₄ pada Zn–N–C;
3. adsorpsi CO₂ pada Cu₄/Zn–N–C;
4. penentuan konfigurasi adsorpsi paling stabil;
5. aktivasi CO₂ melalui transfer elektron;
6. kemungkinan pembentukan COOH jika tersedia sumber H;
7. kemungkinan dissociation CO₂ menjadi CO + O;
8. penentuan transition state menggunakan NEB;
9. perhitungan activation energy dan reaction energy;
10. analisis electronic structure, charge transfer, Bader charge, DOS/PDOS, dan COHP/ICOHP.

Target utama:

\[
\mathrm{Cu_4/Zn-N-C + CO_2}
\]

dan kemungkinan jalur:

\[
\mathrm{CO_2^* \rightarrow CO_2^{-*}}
\]

\[
\mathrm{CO_2^* + H \rightarrow COOH^*}
\]

\[
\mathrm{CO_2^* \rightarrow CO^* + O^*}
\]

---

# 2. Sistem Model

Sistem yang dipelajari adalah:

\[
\mathrm{Cu_4/Zn-N-C}
\]

dengan CO₂ yang teradsorpsi:

\[
\mathrm{Cu_4/Zn-N-C-CO_2}
\]

Secara konseptual:

```text
                         CO₂
                          |
                          v
                       Cu₄
                    /   |   \
                   N    N    N
                   |    |    |
                  Zn - N-doped C
```

**Catatan penting:** XYZ yang saat ini tersedia mengandung atom:

```text
Ni   3.087500   3.921655   10.395000
```

Jika model penelitian memang **Zn–N–C**, pastikan terlebih dahulu apakah `Ni` tersebut merupakan kesalahan penulisan atau memang sistem yang digunakan adalah **Ni–N–C**.

Jangan mengganti Ni menjadi Zn secara otomatis. Perbedaan Ni dan Zn akan memengaruhi struktur elektronik, magnetisasi, charge transfer, energi adsorpsi, dan reaction barrier.

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
Zn–N–C
   |
   v
RELAX
   |
   v
Zn–N–C relaxed
   |
   + Cu₄
   |
   v
RELAX
   |
   v
Cu₄/Zn–N–C
   |
   + CO₂
   |
   v
P1A / P1B / P1C / P1D
   |
   v
RELAX
   |
   v
P1A = most stable
   |
   +-----------------------------+
   |                             |
   v                             v
CO₂⁻                         COOH / CO + O
   |                             |
RELAX                           RELAX
   |                             |
   +-------------+---------------+
                 |
                 v
          Select final state
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

# 5. Tahap 0 — Model Verification

Sebelum menjalankan DFT, periksa:

- jumlah atom;
- jenis atom;
- koordinat;
- cell parameters;
- vacuum;
- periodic boundary conditions;
- posisi Zn;
- posisi N;
- posisi Cu₄;
- posisi CO₂;
- pseudopotential;
- exchange-correlation functional.

Buat file:

```text
00_model_verification/atom_list.txt
```

Isi minimal:

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

# 6. Tahap 1 — Relax Zn–N–C

Tujuan:

- mendapatkan support yang stabil;
- menghilangkan gaya awal yang besar;
- memperoleh referensi energi support.

Workflow:

```text
Zn–N–C initial
      |
      v
    relax
      |
      v
Zn–N–C relaxed
      |
      v
     SCF
      |
      v
E(Zn–N–C)
```

Simpan:

```text
01_ZnNC/
├── initial/
├── relax/
└── scf/
```

---

# 7. Tahap 2 — Cu₄/Zn–N–C

Gunakan Zn–N–C relaxed.

Tambahkan Cu₄ pada posisi situs aktif.

Workflow:

```text
Zn–N–C relaxed
       +
      Cu₄
       |
       v
initial Cu₄/Zn–N–C
       |
       v
     RELAX
       |
       v
relaxed Cu₄/Zn–N–C
       |
       v
      SCF
```

Simpan:

\[
E_{\mathrm{Cu_4/ZnNC}}
\]

---

# 8. Stabilitas Cu₄

Setelah relaxation, periksa:

- Cu–Cu distances;
- Cu–N distances;
- Cu–Zn distance jika relevan;
- perubahan geometri Cu₄;
- migrasi Cu;
- perubahan koordinasi;
- apakah Cu₄ tetap menjadi cluster.

Jika Cu₄ mengalami rearrangement selama relaxation, gunakan struktur hasil relaxation sebagai struktur dasar tahap berikutnya.

---

# 9. Tahap 3 — CO₂ Isolated

Buat CO₂ isolated di dalam cell yang sesuai.

Struktur awal:

```text
O = C = O
```

Workflow:

```text
CO₂ initial
     |
     v
   RELAX
     |
     v
CO₂ relaxed
     |
     v
    SCF
```

Simpan:

\[
E_{\mathrm{CO_2}}
\]

dan:

- C–O distance;
- O–C–O angle.

Untuk CO₂ bebas, sudut O–C–O idealnya mendekati 180°.

---

# 10. Tahap 4 — CO₂ Adsorption

Gunakan Cu₄/Zn–N–C relaxed.

Buat beberapa konfigurasi:

```text
Cu₄/Zn–N–C
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

# 11. Relax P1A–P1D

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

\[
E_{P1A}, E_{P1B}, E_{P1C}, E_{P1D}
\]

Struktur dengan energi terendah menjadi kandidat utama.

Dalam workflow ini diasumsikan:

\[
\boxed{P1A=\text{struktur paling stabil}}
\]

Maka:

\[
P1A = \mathrm{Initial\ State\ (IS)}
\]

untuk studi aktivasi CO₂.

---

# 13. Energi Adsorpsi

Untuk sistem supported cluster:

\[
\boxed{
E_{\mathrm{ads}}
=
E_{\mathrm{Cu_4/ZnNC+CO_2}}
-
E_{\mathrm{Cu_4/ZnNC}}
-
E_{\mathrm{CO_2}}
}
\]

Interpretasi:

- \(E_{\mathrm{ads}} < 0\): adsorpsi exothermic secara energi elektronik;
- semakin negatif: interaksi adsorpsi semakin kuat, dengan catatan referensi dan metode konsisten.

---

# 14. Analisis Geometri P1A

Hitung:

### Cu–C

\[
d_{\mathrm{Cu-C}}
\]

### Cu–O

\[
d_{\mathrm{Cu-O}}
\]

### C–O

\[
d_{\mathrm{C-O}}
\]

### O–C–O

\[
\theta_{\mathrm{OCO}}
\]

Bandingkan dengan CO₂ isolated.

---

# 15. Indikator Aktivasi CO₂

CO₂ dapat dianggap mengalami indikasi aktivasi jika terdapat kombinasi:

- C–O elongation;
- O–C–O bending;
- charge transfer;
- Cu–C/Cu–O interaction;
- perubahan DOS/PDOS;
- perubahan spin jika relevan.

Jangan menentukan aktivasi hanya dari satu parameter.

---

# 16. Tahap 5 — CO₂⁻

Hipotesis:

\[
CO_2 + e^- \rightarrow CO_2^-
\]

Gunakan **XYZ P1A relaxed persis** sebagai geometri awal.

Jangan membengkokkan CO₂ secara manual.

Yang diubah adalah charge sistem:

```text
tot_charge = -1.0
```

Workflow:

```text
P1A relaxed
     |
     v
add 1 electron
     |
     v
tot_charge = -1
     |
     v
RELAX
     |
     v
P1A⁻ relaxed
```

---

# 17. Analisis P1A⁻

Bandingkan:

| Parameter | P1A | P1A⁻ |
|---|---:|---:|
| C–O 1 | ... | ... |
| C–O 2 | ... | ... |
| O–C–O | ... | ... |
| Cu–C | ... | ... |
| Cu–O | ... | ... |
| Charge CO₂ | ... | ... |
| Magnetic moment | ... | ... |

Tujuan utama:

menentukan apakah elektron tambahan menyebabkan CO₂ menjadi lebih bent dan C–O lebih panjang.

---

# 18. Spin Treatment

Sistem Cu₄ dan elektron tambahan dapat memerlukan spin-polarized calculation.

Jika relevan, bandingkan:

```text
nspin = 1
```

dengan perhitungan spin-polarized.

Periksa:

\[
M_{\mathrm{total}}
\]

dan distribusi spin.

Keadaan spin terbaik ditentukan berdasarkan energi dan hasil electronic structure.

---

# 19. Tahap 6 — COOH

Jalur:

\[
CO_2^* + H \rightarrow COOH^*
\]

**Hanya valid jika terdapat sumber H dalam model.**

Contoh sumber H:

- H;
- H₂;
- H₂O;
- proton donor;
- adsorbed H.

Jika tidak ada atom H, jangan membuat COOH sebagai produk dari sistem Cu₄/Zn–N–C + CO₂.

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

# 21. Tahap 7 — CO₂ → CO + O

Jalur:

\[
\boxed{
CO_2^* \rightarrow CO^* + O^*
}
\]

Initial state:

\[
P1A
\]

Final state:

\[
CO^* + O^*
\]

---

# 22. Kandidat CO + O

Jangan hanya membuat satu konfigurasi.

Buat:

```text
CO_O_A
CO_O_B
CO_O_C
```

Perbedaan utama adalah lokasi O* pada Cu₄.

Contoh:

```text
CO_O_A → O* dekat Cu1
CO_O_B → O* dekat Cu2
CO_O_C → O* dekat Cu3
```

Tujuannya mencari lokasi O yang paling stabil setelah relaxation.

---

# 23. Geometri Awal CO + O

Untuk membuat produk awal:

- pertahankan C pada daerah aktif;
- bentuk C–O sebagai CO;
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
- C–O;
- Cu–C;
- Cu–O;
- O* position;
- perubahan Cu₄;
- apakah CO tetap terbentuk;
- apakah O tetap teradsorpsi;
- apakah struktur kembali menjadi CO₂.

---

# 25. Final State

Bandingkan:

\[
E_{CO+O-A}
\]

\[
E_{CO+O-B}
\]

\[
E_{CO+O-C}
\]

Pilih energi terendah:

\[
\boxed{
FS=\mathrm{best\ CO+O}
}
\]

Kemudian:

\[
P1A \rightarrow FS
\]

menjadi reaksi yang akan dipelajari menggunakan NEB.

---

# 26. Reaction Energy

Hitung:

\[
\boxed{
\Delta E_{\mathrm{reaction}}
=
E_{FS}-E_{P1A}
}
\]

Interpretasi:

- \(\Delta E < 0\): FS lebih stabil;
- \(\Delta E > 0\): FS lebih tinggi energi.

Tetapi:

\[
\Delta E \neq E_a
\]

Reaction energy tidak sama dengan activation energy.

---

# 27. Tahap 8 — NEB

Setelah IS dan FS valid:

\[
P1A \rightarrow CO+O
\]

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

Struktur:

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

\[
E_{TS}
\]

Kemudian:

\[
\boxed{
E_a=E_{TS}-E_{P1A}
}
\]

dan:

\[
\boxed{
\Delta E=E_{FS}-E_{P1A}
}
\]

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
- activation energy;
- reaction energy.

---

# 30. Charge Transfer

Analisis aliran elektron pada:

1. Zn–N–C;
2. Cu₄/Zn–N–C;
3. CO₂;
4. Cu₄/Zn–N–C–CO₂.

Kemungkinan:

\[
ZnNC \rightarrow Cu_4
\]

dan/atau:

\[
Cu_4 \rightarrow CO_2
\]

atau transfer langsung:

\[
ZnNC \rightarrow CO_2
\]

---

# 31. Charge Density Difference

Gunakan:

\[
\Delta\rho =
\rho_{\mathrm{Cu_4/ZnNC+CO_2}}
-
\rho_{\mathrm{Cu_4/ZnNC}}
-
\rho_{\mathrm{CO_2}}
\]

Tujuan:

- melihat electron accumulation;
- melihat electron depletion;
- mengidentifikasi area interaksi;
- menghubungkan charge transfer dengan C–O activation.

---

# 32. Bader Charge

Analisis:

- Cu;
- C pada CO₂;
- O;
- Zn;
- N yang relevan.

Bandingkan:

```text
CO₂ isolated
      ↓
P1A
      ↓
P1A⁻
      ↓
CO + O
```

Hasil penting:

\[
q_C,\quad q_O,\quad q_{Cu}
\]

dan perubahan charge:

\[
\Delta q
\]

---

# 33. DOS dan PDOS

Untuk P1A lakukan:

### DOS

\[
DOS(E)
\]

### PDOS

Analisis:

- Cu-d;
- C-p;
- O-p;
- Zn states;
- N states.

Fokus pada daerah dekat Fermi level dan perubahan electronic states setelah adsorpsi.

---

# 34. Hybridization

Cari indikasi overlap antara:

\[
Cu-d
\]

dengan:

\[
C/O-p
\]

Overlap yang berubah setelah adsorpsi dapat mendukung interpretasi adanya interaksi elektronik Cu–CO₂.

---

# 35. COHP / ICOHP

Jika workflow tersedia, analisis:

- Cu–C;
- Cu–O;
- C–O.

Gunakan COHP/ICOHP untuk membantu mengevaluasi:

- bond strength;
- bonding/antibonding;
- weakening C–O;
- formation of Cu–O.

---

# 36. Vibrational Analysis

Untuk struktur minimum:

- P1A;
- CO₂;
- CO + O;
- COOH jika digunakan;

minimum idealnya tidak memiliki imaginary frequency.

Untuk transition state:

diharapkan terdapat satu imaginary mode yang sesuai dengan koordinat reaksi.

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

| System | Energy (eV) | ΔE (eV) | C–O (Å) | O–C–O (°) | Charge CO₂ |
|---|---:|---:|---:|---:|---:|
| CO₂ | ... | — | ... | ... | ... |
| Cu₄/ZnNC | ... | — | — | — | — |
| P1A | ... | ... | ... | ... | ... |
| P1A⁻ | ... | ... | ... | ... | ... |
| COOH | ... | ... | ... | ... | ... |
| CO+O-A | ... | ... | ... | ... | ... |
| CO+O-B | ... | ... | ... | ... | ... |
| CO+O-C | ... | ... | ... | ... | ... |

---

# 39. Tabel NEB

| Image | Reaction Coordinate | Energy (eV) | C–O (Å) | Cu–O (Å) |
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
Zn–N–C
  |
  v
RELAX
  |
  v
Zn–N–C relaxed
  |
  + Cu₄
  |
  v
RELAX
  |
  v
Cu₄/Zn–N–C
  |
  + CO₂
  |
  v
P1A / P1B / P1C / P1D
  |
  v
RELAX
  |
  v
P1A = most stable
  |
  +-------------------------+
  |                         |
  v                         v
CO₂⁻                    COOH / CO + O
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
       CO₂ Activation Mechanism
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

- [ ] Zn–N–C initial
- [ ] Zn–N–C relax
- [ ] Zn–N–C SCF

## Cu₄

- [ ] Cu₄/Zn–N–C initial
- [ ] Cu₄/Zn–N–C relax
- [ ] Cu₄/Zn–N–C SCF

## CO₂

- [ ] CO₂ isolated relax
- [ ] CO₂ isolated SCF

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

## CO₂⁻

- [ ] P1A⁻ initial
- [ ] `tot_charge = -1`
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

1. Apakah Cu₄/Zn–N–C mampu mengadsorpsi CO₂ secara stabil?
2. Seberapa kuat adsorpsi CO₂?
3. Apakah adsorpsi menyebabkan CO₂ mengalami bending?
4. Apakah ikatan C–O mengalami elongation?
5. Apakah terdapat transfer elektron dari support/Cu₄ menuju CO₂?
6. Apakah karakter CO₂⁻ terbentuk?
7. Apakah COOH dapat terbentuk jika H tersedia?
8. Apakah CO₂ dapat terdisosiasi menjadi CO + O?
9. Apa final state yang paling stabil?
10. Berapa reaction energy?
11. Berapa activation energy?
12. Struktur elektronik apa yang bertanggung jawab terhadap aktivasi CO₂?
13. Apa peran Cu₄?
14. Apa peran Zn–N–C sebagai support?
15. Bagaimana mekanisme keseluruhan aktivasi CO₂?

---

# 43. Status Saat Ini

Berdasarkan struktur dan hasil yang sudah tersedia:

```text
[✓] P1 relaxed
[✓] P1A relaxed
[✓] P1A dianggap struktur paling stabil

[!] Verifikasi Ni vs Zn pada support
[ ] Zn–N–C reference
[ ] Cu₄/Zn–N–C reference
[ ] CO₂ isolated reference
[ ] Adsorption energy
[ ] P1A⁻ relaxation
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

Urutan yang digunakan adalah:

\[
\boxed{
\text{Model}
\rightarrow
\text{Relaxation}
\rightarrow
\text{Adsorption}
\rightarrow
\text{Activation}
\rightarrow
\text{Products}
\rightarrow
\text{NEB}
\rightarrow
\text{Electronic Analysis}
}
\]

Jangan melakukan NEB sebelum:

1. initial state valid;
2. final state valid;
3. kedua struktur telah relaxed;
4. kedua endpoint merupakan minimum lokal yang masuk akal;
5. chemical composition konsisten.

Dengan workflow ini, hasil akhir tidak hanya menunjukkan bahwa CO₂ teradsorpsi, tetapi dapat menjelaskan:

\[
\boxed{
\text{Structure}
\rightarrow
\text{Charge Transfer}
\rightarrow
\text{CO₂ Activation}
\rightarrow
\text{Reaction Pathway}
\rightarrow
\text{Activation Barrier}
}
\]
