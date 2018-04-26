#!/bin/bash
# script to transform MOLCAS orbitals to MOLPRO orbitals without symmetry
# Usage: molcaspro.sh <MOLPRO AO-Overlap> "<Number of basis functions>" <MOLCAS Orbitals> 
####################################################
if [ $# -lt 4 ]; then
  echo 'Usage: molcaspro.sh <MOLPRO AO-Overlap> "<Number of basis functions>" <MOLCAS Orbitals>'
  exit
fi

MCPPATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# clean the MOLCAS orbital file
cat "$3"| sed -e/ORBITAL/\{ -e:1 -en\;b1 -e\} -ed | sed '/OCC/,$d' > molcas.orbs
# prepare the overlap and orbitals
"$MCPPATH/joinorb" "$1" $2 > overlap.molpro
"$MCPPATH/joinorb" molcas.orbs $2 > molcas.orbs.tmp
mv molcas.orbs.tmp molcas.orbs

# generate the orbitals
echo "addpath('$MCPPATH/')
molcaspro('molcas.orbs','molpro.orbdump');" | matlab -nodesktop -nosplash

# split the orbitals
"$MCPPATH/splitorb" molpro.orbdump > molpro.orbdump.tmp
mv molpro.orbdump.tmp molpro.orbdump
