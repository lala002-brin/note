# Tutorial DFTB+ untuk Studi Adsorpsi Inhibitor Korosi pada Fe(110)
This repository provides a workflow for investigating the adsorption behavior of organic corrosion inhibitors on the Fe(110) surface using the SCC-DFTB method implemented in DFTB+.

## Workflow
GC-MS Identification
        ↓
DFT Optimization (Gaussian 09)
        ↓
Electronic Descriptor Analysis
(EHOMO, ELUMO, ΔE, μ, ΔN)
        ↓
Fe(110) Surface Construction
        ↓
SCC-DFTB Adsorption Simulation
        ↓
Adsorption Energy Calculation
        ↓
Adsorption Mechanism Analysis

## Computational Details
DFT Calculations
Software: Gaussian 09
Functional: M06-2X
Basis set: 6-311++G(d,p)
Solvent model: SMD (water)
Frequency analysis: performed for all optimized structures
DFTB Calculations
Software: DFTB+
Method: SCC-DFTB
Slater-Koster set: matsci
Surface: Fe(110)
Number of layers: 5
Vacuum spacing: 50 Å
Force convergence criterion:
