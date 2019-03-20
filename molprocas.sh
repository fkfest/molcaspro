#!/bin/bash
# script to transform MOLPRO orbitals to MOLCAS orbitals
# Usage: molprocas.sh <MOLPRO Orbitals> "<Symmetry line (11A1  +   4B1  +   7B2  +   2A2)>" <MOLCAS Orbitals for Overlap> "<Symmetries (a1  b1  a2  b2)>"
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
  echo 'Usage: molprocas.sh <MOLPRO Orbitals> "<Symmetry line (11A1  +   4B1  +   7B2  +   2A2)>" <MOLCAS Orbitals for Overlap> "<Symmetries (a1  b1  a2  b2)>"'
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
orbname=$(basename -- "$1")
orbname="${orbname%.*}.MPOrb"
#orbname="$(echo "$orbname" | tr '[:upper:]' '[:lower:]')"

# clean the MOLCAS orbital file for Overlap
cat "$3"| sed -e/ORBITAL/\{ -e:1 -en\;b1 -e\} -ed | sed '/OCC/,$d' > molcas4S.orbs
# prepare the MOLPRO orbitals
"$MCPPATH/joinorb" "$1" "$2" > orbs.molpro
"$MCPPATH/joinorb" molcas4S.orbs "$NMC" > molcas.orbs.tmp
mv molcas.orbs.tmp molcas4S.orbs
molcasorbs="'molcas4S.orbs'"
molproorbs="'orbs.molpro'"

# generate the orbitals
echo "addpath('$MCPPATH/')
[dims,symord]=dimsym('$2','$4');
molprocas($molproorbs,$molcasorbs,'$orbname',dims,symord);" > mpc.m

if [ -n "$MATLAB" ]; then
  cat mpc.m | $MATLAB
else
  $OCTAVE mpc.m
fi
rm mpc.m

if [ -f "$orbname" ]; then
  # split the orbitals
  "$MCPPATH/writeorbMC" "$orbname" > "$orbname.tmp"
  mv "$orbname.tmp" "$orbname"
fi
