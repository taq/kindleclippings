#!/bin/bash
#
# kindleclippings.sh - Search for Kindle clippings
# 
# Homepage: http://github.com/taq/kindleclippings.git
# Author: Eustaquio 'TaQ' Rangel <eustaquiorangel@gmail.com>
# Version: 0.0.1
#
# This script search for clippings on a Kindle formatted clippings
# file (the default name is My Clippings.txt), filtering on the 
# document name. For example, for all clippings on the Time Magazine,
# we can use:
# 
# ./kindleclippings.sh My\ Clippings.txt Time
# 
# and the script will return all the clippings related to Time, 
# separated with the default Kindle clippings delimiter (some 
# equal signs chars).
#

function next() {
   num=$1
   for del in $delimiters; do
      if [ $del -gt $num ]; then
         echo $del
         return
      fi
   done
}

function version() {
   grep "^# Version:" "$0" | cut -f2 -d:
}

function header() {
   echo Kindle Clippings search - version $(version) 
   echo Searching for \'$2\' clippings on $3 lines of \'$1\' ...
   echo
}

file=$1
clipping=$2
total=$(wc -l "$1" | cut -f1 -d' ')
header "$file" $clipping $total

lines=$(grep -n "^$clipping" "$file" | cut -f1 -d:)
delimiter="=========="
delimiters=$(grep -n "^$delimiter" "$file" | cut -f1 -d:)

for n in $lines; do
   nline=$(next $n)
   dif=$(expr $nline - $n)
   pos=$(expr $total - $n - 2)
   qt=$(expr $nline - $n - 3)
   tail -n $pos "$file" | head -n $qt
   echo $delimiter
done
