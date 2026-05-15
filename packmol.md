
## Packmol.

Download https://github.com/m3g/packmol/releases/tag/v21.2.1

```
./configure
```
```
make
```
```
sudo ln -s ~/Downloads/packmol-21.2.1/packmol /usr/local/bin
```

### running
```
packmol < Cs-AHA.inp
```

### Input file
```
#jarak aman
tolerance 2.0
filetype xyz
output cs-aha_5-10_unit.xyz

structure Cs_final_1_unit.xyz
  number 5
  inside box 0. 0. 0. 100. 100. 100.
end structure

structure aha_final_1_unit.xyz
  number 10
  inside box 0. 0. 0. 100. 100. 100.
end structure
```
