#!/bin/sh
#
#
# kobisun.org build custom fw package dir script
#
# This script cleans out ports from a tinderbuild.
#

NANOBSD_DIR=/usr/src/tools/tools/nanobsd
TINDERBOX_DIR=/usr/local/tinderbox
PORTS_TO_REMOVE=`cat ports.DELETE`

# Or list them here and disable the upper command
# PORTS_TO_REMOVE='
# '

# Remove ports from tinderbuild

cd $TINDERBOX_DIR/scripts
for c in $PORTS_TO_REMOVE
do	
	./tc rmPort -d $c -b 8-NanoBSD-PBX -f

done

