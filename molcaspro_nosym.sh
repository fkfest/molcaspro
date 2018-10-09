#!/bin/bash
# script to transform MOLCAS orbitals to MOLPRO orbitals without symmetry
# Usage: molcaspro.sh <MOLPRO AO-Overlap> "<Number of basis functions>" <MOLCAS Orbitals> 
####################################################

if command -v matlab >/dev/null 2>&1; then
  MATLAB="matlab -nodesktop -nosplash"
elif command -v octave >/dev/null 2>&1; then 
  OCTAVE="octave"
else
  echo "Matlab or octave are required!"
  exit 1
fi

if [ $# -lt 3 ]; then
  echo 'Usage: molcaspro.sh <MOLPRO AO-Overlap> "<Number of basis functions>" <MOLCAS Orbitals> [<Auxiliary MOLCAS orbitals>]'
  exit
fi

MCPPATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

#orbname
orbname=$(basename -- "$3")
orbname="${orbname%.*}.orbdump"

# clean the MOLCAS orbital file
cat "$3"| sed -e/ORBITAL/\{ -e:1 -en\;b1 -e\} -ed | sed '/OCC/,$d' > molcas.orbs
# prepare the overlap and orbitals
"$MCPPATH/joinorb" "$1" $2 > overlap.molpro
"$MCPPATH/joinorb" molcas.orbs $2 > molcas.orbs.tmp
mv molcas.orbs.tmp molcas.orbs
molcasorbs="'molcas.orbs'"

if [ $# -gt 3 ]; then
  # auxiliary orbitals for generation of the AO overlap
  # clean the MOLCAS orbital file
  cat "$4"| sed -e/ORBITAL/\{ -e:1 -en\;b1 -e\} -ed | sed '/OCC/,$d' > auxmolcas.orbs
  "$MCPPATH/joinorb" auxmolcas.orbs "$NMC" > auxmolcas.orbs.tmp
  mv auxmolcas.orbs.tmp auxmolcas.orbs
  molcasorbs="{'auxmolcas.orbs','molcas.orbs'}"
fi

# generate the orbitals
echo "addpath('$MCPPATH/')
molcaspro($molcasorbs,'$orbname');" > mcp.m

if [ -n "$MATLAB" ]; then
  cat mcp.m | $MATLAB
else
  $OCTAVE mcp.m
fi
rm mcp.m

# split the orbitals
"$MCPPATH/splitorb" $orbname > $orbname.tmp
mv $orbname.tmp $orbname
