# Workflow Simulasi MD ReaxFF untuk CS-AHA

## 1. Convert XYZ Structure to LAMMPS Format

Run the conversion script:
```bash
~/Documents/Working_Files/RIIM_wound_Healing/CS_AHA/xyz2lammps.sh cs-aha_5_5_unit
```

```
cp cs-aha_5_5_unit.lammps data.cs-aha
```

Copy the generated file:
```
cp cs-aha_5_5_unit.lammps data.cs-aha
```

## 2. Add Header to `data.cs-aha`

Add the following header at the beginning of `data.cs-aha` :

```
LAMMPS data file for AHA (ReaxFF)

2315 atoms
4 atom types

0.0 100.0 xlo xhi
0.0 100.0 ylo yhi
0.0 100.0 zlo zhi

Masses

1 12.011   # C
2 1.008    # H
3 14.01    # N
4 15.999   # O

Atoms # id type charge x y z
```
Example atom coordinates:
```
1 2 0.0  33.024273 32.522017 40.093282
2 4 0.0  33.610910 32.169411 40.822347
3 1 0.0  33.449030 30.648053 41.010838
4 2 0.0  32.496709 30.379674 41.513752
5 4 0.0  34.527313 30.172424 41.793979
```

## 3. Simulation Directory Structure

Create the workflow directories:
```
mkdir 1_NVT_equil
mkdir 2_NPT_equil
mkdir 3_NPT_anneal
mkdir 4_NPT_production
mkdir 5_NVT_production
```

## 4. SLURM Job Submission Script

Create `MD_CS-AHA.sh`:
```
#!/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --mem=32GB
#SBATCH --partition=short

#SBATCH --output=cs-aha.log
#SBATCH --error=cs-aha.err

FILE_INPUT=in.cs-aha

module load gcc/12.2.0
module load impi/2021.11.0
module load materials/lammps/2023-impi

mpirun -np 16 lmp_mpi -in ${FILE_INPUT}
```

Submit the job:
```
sbatch MD_CS-AHA.sh
```

## 5. Simulation Workflow

#### Step 1 — NVT Equilibration
Directory:

`1_NVT_equil`

Purpose:

- Initial structural relaxation
- Temperature stabilization at 300 K

`in.cs-aha`

```
# ---------- Initialization ----------
units real
dimension 3
boundary p p p
atom_style charge

# ---------- Structure ----------
read_data data.cs-aha

# ---------- ReaxFF ----------
pair_style reax/c NULL safezone 2.0 mincap 200
pair_coeff * * ffield.reax C H N O

# Charge equilibration
fix 1 all qeq/reax 1 0.0 10.0 1e-6 reax/c

# ---------- Neighbor ----------
neighbor 2.0 bin
neigh_modify every 1 delay 0 check yes

# ---------- Timestep ----------
timestep 0.25

# ---------- Energy Minimization ----------
minimize 1e-6 1e-8 1000 10000

# ---------- NVT Dynamics ----------
fix 2 all nvt temp 300.0 300.0 100.0

thermo 100
thermo_style custom step temp etotal press vol density

dump 1 all custom 200 dump.cs-aha id type x y z q
dump 2 all xyz 200 trajectory.xyz

dump_modify 2 element C H N O

restart 10000 restart.reax

run 50000
```

#### Step 2 — NPT Equilibration
Directory:

`2_NPT_equil`

Purpose:

- Pressure and density equilibration

- Use restart file from previous stage:

`read_restart restart.reax.210000`

`in.cs-aha`
```
# ---------- Initialization ----------
units real
dimension 3
boundary p p p
atom_style charge

# ---------- Structure ----------
read_restart restart.reax.210000

# ---------- ReaxFF ----------
pair_style reax/c NULL safezone 3.0 mincap 200
pair_coeff * * ffield.reax C H N O

fix spec all reax/c/species 100 1 100 species.out element C H N O

# Charge equilibration
fix 1 all qeq/reax 1 0.0 10.0 1e-6 reax/c

# ---------- Neighbor ----------
neighbor 2.0 bin
neigh_modify every 1 delay 0 check yes

# ---------- Timestep ----------
timestep 0.25

# ---------- NPT Dynamics ----------
fix 2 all npt temp 300.0 300.0 100.0 iso 1.0 1.0 1000.0

thermo 100
thermo_style custom step temp press etotal vol density

dump 1 all custom 200 dump.cs-aha id type x y z q
dump 2 all xyz 200 trajectory.xyz

dump_modify 2 element C H N O

restart 10000 restart.reax

run 800000
```

#### Step 3 — NPT Annealing

Directory:

`3_NPT_anneal`

Purpose:

- Heating: 300 K → 600 K
- Cooling: 600 K → 300 K

`in.cs-aha`
```
# ---------- Initialization ----------
units real
dimension 3
boundary p p p
atom_style charge

# ---------- Structure ----------
read_restart restart.reax.800000

# ---------- ReaxFF ----------
pair_style reax/c NULL safezone 2.0 mincap 200
pair_coeff * * ffield.reax C H N O

# Charge equilibration
fix 1 all qeq/reax 1 0.0 10.0 1e-6 reax/c

# ---------- Neighbor ----------
neighbor 2.0 bin
neigh_modify every 1 delay 0 check yes

# ---------- Timestep ----------
timestep 0.25

# ---------- Thermodynamic Output ----------
thermo 100
thermo_style custom step temp press etotal vol density

# ---------- Dump ----------
dump xyzdump all xyz 1000 traj.xyz
dump_modify xyzdump element C H N O append yes

dump unwrap all custom 1000 traj_unwrapped.lammpstrj id type xu yu zu
dump_modify unwrap append yes

# ---------- Restart ----------
restart 10000 restart.reax

# ---------- Heating ----------
fix npt_heat all npt temp 300.0 600.0 100.0 iso 1.0 1.0 1000.0
run 200000
unfix npt_heat

# ---------- Cooling ----------
fix npt_cool all npt temp 600.0 300.0 100.0 iso 1.0 1.0 1000.0
run 200000
unfix npt_cool
```

#### Step 4 — NPT Production

Directory:

`4_NPT_production`

Purpose:

- Main production simulation under constant pressure

`in.cs-aha`
```
# ---------- Initialization ----------
units real
dimension 3
boundary p p p
atom_style charge

# ---------- Structure ----------
read_restart restart.reax.1200000

# ---------- ReaxFF ----------
pair_style reax/c NULL safezone 2.0 mincap 200
pair_coeff * * ffield.reax C H N O

fix spec all reax/c/species 100 1 100 species.out

# Charge equilibration
fix 1 all qeq/reax 1 0.0 10.0 1e-6 reax/c

# ---------- Neighbor ----------
neighbor 2.0 bin
neigh_modify every 1 delay 0 check yes

# ---------- Timestep ----------
timestep 0.25

# ---------- NPT Dynamics ----------
fix 2 all npt temp 300.0 300.0 100.0 iso 1.0 1.0 1000.0

thermo 100
thermo_style custom step temp press etotal vol density

dump 1 all custom 200 dump.cs-aha id type x y z q
dump 2 all xyz 200 trajectory.xyz

dump_modify 2 element C H N O

restart 10000 restart.reax

run 800000
```

#### Step 5 — NVT Production

Directory:

`5_NVT_production`

Purpose:

- Final production simulation at constant volume

`in.cs-aha`
```
# ---------- Initialization ----------
units real
dimension 3
boundary p p p
atom_style charge

# ---------- Structure ----------
read_restart restart.reax.2000000

# ---------- ReaxFF ----------
pair_style reax/c NULL
pair_coeff * * ffield.reax C H N O

# Charge equilibration
fix 1 all qeq/reax 1 0.0 10.0 1e-6 reax/c

# ---------- Neighbor ----------
neighbor 2.0 bin
neigh_modify every 1 delay 0 check yes

# ---------- Timestep ----------
timestep 0.25

# ---------- Energy Minimization ----------
minimize 1e-6 1e-8 1000 10000

# ---------- NVT Dynamics ----------
fix 2 all nvt temp 300.0 300.0 100.0

thermo 100
thermo_style custom step temp etotal press vol density

dump 1 all custom 200 dump.cs-aha id type x y z q
dump 2 all xyz 200 trajectory.xyz

dump_modify 2 element C H N O

restart 10000 restart.reax

run 400000
```

## 6. Overall Simulation Workflow
```
Initial Structure
        ↓
NVT Equilibration
        ↓
NPT Equilibration
        ↓
NPT Annealing
(Heating + Cooling)
        ↓
NPT Production
        ↓
NVT Production
        ↓
Trajectory Analysis
```
### 7. Required Files

The following files must exist in each simulation directory:
```
in.cs-aha
data.cs-aha
ffield.reax
MD_CS-AHA.sh
```
For continuation runs, include restart files from the previous stage:
```
restart.reax.*
```








