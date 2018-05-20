#!/bin/bash
# script to transform MOLCAS orbitals to MOLPRO orbitals
# Usage: molcaspro.sh <MOLPRO AO-Overlap> "<Symmetry line (11A1  +   4B1  +   7B2  +   2A2)>" <MOLCAS Orbitals> "<Symmetries (a1  b1  a2  b2)>"
####################################################

if command -v matlab >/dev/null 2>&1; then
  MATLAB="matlab -nodesktop -nosplash"
elif command -v octave >/dev/null 2>&1; then 
  OCTAVE="octave"
else
  echo "Matlab or octave are required!"
  exit 1
fi

if [ $# -lt 4 ]; then
  echo 'Usage: molcaspro.sh <MOLPRO AO-Overlap> "<Symmetry line (11A1  +   4B1  +   7B2  +   2A2)>" <MOLCAS Orbitals> "<Symmetries (a1  b1  a2  b2)>"'
  exit
fi

MCPPATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
#get MOLCAS dimensions:
NMC=""
SYMMC=$(echo $4|tr /a-z/ /A-Z/)
SYMMP=$(echo $2|tr /a-z/ /A-Z/)
for SYM in $SYMMC; do
  NUM="${SYMMP%$SYM *}"
  if [ "$NUM" == "$SYMMP" ] ;then
    NUM="${SYMMP%$SYM}"
  fi
  if [ "$NUM" == "$SYMMP" ] ;then
    echo "Symmetry $SYM is not found in $SYMMP",$NUM
    exit
  else
#    echo "Found $SYM: $NUM"
    NSYM=${NUM##*+}
    NMC="$NMC $NSYM"
  fi
done

#orbname
orbname=$(basename -- "$3")
orbname="${orbname%.*}.orbdump"

# clean the MOLCAS orbital file
cat "$3"| sed -e/ORBITAL/\{ -e:1 -en\;b1 -e\} -ed | sed '/OCC/,$d' > molcas.orbs
# prepare the overlap and orbitals
"$MCPPATH/joinorb" "$1" "$2" > overlap.molpro
"$MCPPATH/joinorb" molcas.orbs "$NMC" > molcas.orbs.tmp
mv molcas.orbs.tmp molcas.orbs

# generate the orbitals
echo "addpath('$MCPPATH/')
[dims,symord]=dimsym('$2','$4');
molcaspro('molcas.orbs','$orbname',dims,symord);" > mcp.m

if [ -n "$MATLAB" ]; then
  cat mcp.m | $MATLAB
else
  $OCTAVE mcp.m
fi
rm mcp.m

# split the orbitals
"$MCPPATH/splitorb" $orbname > $orbname.tmp
mv $orbname.tmp $orbname
