# Packmol Installation and Usage

## Download Packmol

Download Packmol from:

Packmol v21.2.1 Release (https://github.com/m3g/packmol/releases/tag/v21.2.1)

## Installation
1. Enter the Packmol directory
```
cd ~/Downloads/packmol-21.2.1
```

2. Configure
```
./configure
```
3. Compile
```
make
```
4. Add Packmol to PATH

This allows packmol to be executed from anywhere in the terminal.

```
sudo ln -s ~/Downloads/packmol-21.2.1/packmol /usr/local/bin
```
## Running Packmol

Run Packmol using:
```
packmol < Cs-AHA.inp
```
Explanation:

- Cs-AHA.inp → input configuration file
- Packmol reads this file and generates the molecular structure based on the settings.
- Example Input File

File: `Cs-AHA.inp`

```
# minimum distance between atoms
tolerance 2.0

# output file format
filetype xyz

# output filename
output cs-aha_5-10_unit.xyz

# first molecule
structure Cs_final_1_unit.xyz
  number 5
  inside box 0. 0. 0. 100. 100. 100.
end structure

# second molecule
structure aha_final_1_unit.xyz
  number 10
  inside box 0. 0. 0. 100. 100. 100.
end structure
```

## Input File Explanation
- tolerance
`tolerance 2.0`

Defines the minimum allowed distance between atoms/molecules.

In this example:

minimum distance = `2.0 Å`

- filetype
`filetype xyz`

Specifies the output file format.

Output will be saved as an `.xyz` file.

- output
output `cs-aha_5-10_unit.xyz`
Name of the generated output file.

- structure
structure `Cs_final_1_unit.xyz`
Specifies the molecular structure file to insert into the simulation box.

- number
`number 5`
Defines how many copies of the molecule will be added.
Example:


5 molecules of `Cs_final_1_unit.xyz`



inside box
inside box 0. 0. 0. 100. 100. 100.
Defines the simulation box dimensions.
Box range:


 x = 0 → 100


 y = 0 → 100


 z = 0 → 100


Simulation box size:


`100 × 100 × 100 Å`



- Output
After execution, Packmol generates:
`cs-aha_5-10_unit.xyz`
This file contains:

- 5 Cs molecules


- 10 AHA molecules


- randomized molecular positions inside the box


- no atomic overlap according to the defined tolerance value




