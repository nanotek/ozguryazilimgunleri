#!/bin/sh
#
#
# kobisun.org prune files
#
# This script cleans out leftover files before
# image building process.
#

NANOBSD_DIR=/usr/src/tools/tools/nanobsd
FILES_TO_PRUNE=`cat pkg.PRUNE`

# Or list them here and disable the upper command
# PORTS_TO_REMOVE='
# '

# Prune files

for c in $FILES_TO_PRUNE
do	
	rm -fv $c 

done

