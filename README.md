# Readme

A bunch of MATLAB (and BASH/awk) scripts to transform MOLCAS orbital coefficients to MOLPRO and vice versa.
Requires MATLAB or OCTAVE.
HOW-TO transform orbitals:

1) *Generate orbital coefficients in MOLCAS. Let's assume they are called `molcas.ScfOrb`. For the MOLPRO to MOCAS transformation, this can be any set of orthogonal orbitals in the same basis and geometry as in MOLPRO.*

2a) *For MOLCAS-MOLPRO transformation: Generate an overlap matrix in MOLPRO (here `molpro.ovlp`) using the same basis and geometry as in MOLCAS*:

```
gdirect
geometry=...
basis=...
{matrop
load,S,S
write,S,molpro.ovlp,new,float
}
```
2b) *For MOLPRO-MOLCAS transformation: Store MOLPRO coefficients in a text file (here `molpro.orbdump`)*:

```
{matrop
load,ORB,...
write,ORB,molpro.orbdump,new,float
}
```

**Now one can either use scripts or do things manually **

<u>**Script for MOLCAS-MOLPRO**</u>

3) *Use script `molcaspro.sh` or `molcaspro_nosym.sh` for symmetric or non-symmetric orbitals, respectively.*
```
molcaspro.sh molpro.ovlp "<MOLPRO symmetry string>" molcas.ScfOrb "<MOLCAS symmetry string>" [auxmolcas.ScfOrb]
or
molcaspro_nosym.sh molpro.ovlp <number of basis functions> molcas.ScfOrb [auxmolcas.ScfOrb]
```
The resulting orbitals for MOLPRO will be in `<name>.orbdump` with `<name>` taken from the molcas-orbitals filename. Auxiliary MOLCAS orbitals can be provided for calculation of the AO overlap in the case if the molcas.ScfOrb have been altered.

For example, for a water molecule in the C2v symmetry it will be
```
molcaspro.sh h2o.ovlp "11A1  +   4B1  +   7B2  +   2A2" h2o.ScfOrb "a1  b1  a2  b2"
```
(the order of irreps differs in this case between MOLCAS and MOLPRO) with the final orbitals in h2o.orbdump.

<u>**Script for MOLPRO-MOLCAS**</u>

3) *Use script `molprocas.sh`.*
```
molprocas.sh molpro.orbdump "<MOLPRO symmetry string>" molcas.ScfOrb "<MOLCAS symmetry string>"
```
The resulting orbitals for MOLCAS will be in `<name>.MPOrb` with `<name>` taken from the molpro-orbitals filename.

For example, for a water molecule in the C2v symmetry it will be
```
molcaspro.sh h2o.orbdump "11A1  +   4B1  +   7B2  +   2A2" h2o.ScfOrb "a1  b1  a2  b2"
```
(the order of irreps differs in this case between MOLCAS and MOLPRO) with the final orbitals in h2o.MPOrb.

<u>**Manually**</u>

(Described only for MOLCAS-MOLPRO transformation)

3) *Delete lines before and after orbital coefficients in the MOLCAS file, and transform the coefficients and overlap to a MATLAB-readable format using script `joinorb`.*
```
joinorb molcas.ScfOrb "<list of dimensions of each symmetry>" > molcas.orbs
joinorb molpro.ovlp "<list of dimensions of each symmetry>" > overlap.molpro
```

The list of dimensions can be either a space-separated list of integers or the MOLPRO list of irreps (`NUMBER OF CONTRACTIONS`).
For example, for a water molecule in the C2v symmetry it will be

```
joinorb h2o.ScfOrb "11 4 2 7" > h2o.orbs
joinorb h2o.ovlp "11A1  +   4B1  +   7B2  +   2A2" > overlap.molpro
```

(the order of irreps differs in this case between MOLCAS and MOLPRO)

4) *Now start `matlab` in directory with the new files.*

5) *In `matlab` command line add the path to `molcaspro` scripts*:

```
addpath('~/projects/molcaspro/')
```

6) *Generate basis dimensions and order of irreps using `dimsym` function (here for the water example)*:

```
symmpro='11A1  +   4B1  +   7B2  +   2A2';
symmcas='a1  b1  a2  b2';
[dims,symord]=dimsym(symmpro,symmcas)
```

7) *Generate new orbitals in the MOLPRO order using 'molcaspro' function*:

```
molcaspro('molcas.orbs','molpro.orbdump',dims,symord);
```

`molcas.orbs` is the file with orbitals from step 5, and `dims` and `symord` are the arrays generated in step 6. Note that the `molcaspro` function expects the MOLPRO overlap in `overlap.molpro` file.
The MOLPRO orbital coefficients will be written to the file specified as the second argument (`molpro.orbdump` here).
One can also assign the coefficients to a variable as `coef=molcaspro(...`

For non-symmetric molecules one can use a simplified route skipping step 6 and calling `molcaspro` as
```
molcaspro('molcas.orbs',molpro.orbdump');
```

The tolerance in `molcaspro` can be changed according to the accuracy of the overlap matrices and coefficients (default is 1e-7).

8) *Split the orbital coefficients using provided script `splitorb`*:
```
splitorb molpro.orbdump > molpro.orbdump.tmp
mv molpro.orbdump.tmp molpro.orbdump
```

