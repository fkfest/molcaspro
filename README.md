# Readme

A bunch of MATLAB (and BASH) scripts to transform MOLCAS orbital coefficients to MOLPRO.
HOW-TO:

1) *Generate orbital coefficients in MOLCAS. Let's assume they are called `molcas.ScfOrb`.*

2) *Generate an overlap matrix in MOLPRO (here `molpro.ovlp`) using the same basis and geometry as in MOLCAS*:

```
gdirect
geometry=...
basis=...
{matrop
load,S,S
write,S,molpro.ovlp,new
}
```

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


