#!/bin/sh
#
#
# kobisun.org build custom packages script
# this script will add ports to a tinderbox queue based on selected kobisun model
# ports are read from a text file named pkg.$KOBISUN_MODEL
# 12/2/2010 Istanbul
#

NANOBSD_DIR=/usr/src/tools/tools/nanobsd
TINDERBOX_DIR=/usr/local/tinderbox
PORTS_TO_INSTALL=`cat pgk.$KOBISUN_MODEL`

# Now create a tinderbuild with the ports we listed
# This will create a tinderbuild from the nanobsd shared
# world and port source and add all required ports to 
# build queue. 

cd $TINDERBOX_DIR/scripts

for c in $PORTS_TO_INSTALL
do	
	./tc addBuildPortsQueueEntry -b 8-NanoBSD-$KOBISUN_MODEL -d $c
done

