# Tutorial DFTB+ untuk Studi Adsorpsi Inhibitor Korosi pada Fe(110)
This repository provides a workflow for investigating the adsorption behavior of organic corrosion inhibitors on the Fe(110) surface using the SCC-DFTB method implemented in DFTB+.

## Workflow
```
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
```

## Computational Details
### DFT Calculations
Software: Gaussian 09

Functional: M06-2X

Basis set: 6-311++G(d,p)

Solvent model: CPCM (water)

Frequency analysis: performed for all optimized structures

### DFTB Calculations
Software: DFTB+

Method: SCC-DFTB

Slater-Koster set: matsci

Surface: Fe(110)

Number of layers: 5

Vacuum spacing: 50 Å

Force convergence criterion:

## Directory Structure
```
DFTB/
├── Fe/
│   ├── dftb_in.hsd
│   ├── geom_inp.gen
│   └── Fe.sh
│
├── 5hmf/
│   ├── dftb_in.hsd
│   ├── geom_inp.gen
│   ├── Fe.sh
│   └── outputs
│
├── Methyl_beta-D-glucopyranoside/
│   ├── dftb_in.hsd
│   ├── geom_inp.gen
│   ├── Fe.sh
│   └── outputs
│
├── Methyl_hexadecanoate/
│
└── 9_12_15_octadecatrienoate/
```

## DFTB+ Input File

Example dftb_in.hsd
```
Geometry = GenFormat {
<<< "geom_inp.gen"
}

Driver = GeometryOptimization{


}

Hamiltonian = DFTB {

  SCC = Yes
#  ReadInitialCharges = Yes
  MaxSCCIterations = 200
#  ShellResolvedSCC = Yes

  SlaterKosterFiles = Type2FileNames {
    Prefix = "/mgpfs/home/lala002/slako/trans3d-0-1/"
    Separator = "-"
    Suffix = ".skf"
    LowerCaseTypeName = No
  }


KPointsAndWeights = SupercellFolding {
  2 0 0
  0 2 0
  0 0 1
  0.0 0.0 0.0
  }



  MaxAngularMomentum {
    C   =  "p"
    H   = "s"
    O   = "p"
    Fe   = "d"
  }

  Filling = Fermi {
    Temperature [Kelvin] = 300.0
  }

}



Options {}



ParserOptions {
  ParserVersion = 12
}
```

