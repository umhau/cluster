#!/bin/bash
#
# NOTES =======================================================================
#
#   Assumes the master node is numbered 0, and the rest increment upwards from
#   there.
# 
#   The machinefile is generated in reverse order from the numbering of the 
#   machines, such that the master node (numbered 0) is listed in the last 
#   place.
# 
#   if the -ex_core flag is set, then one core of the master node will be left
#   off the machine file.  This allows the master node to perform interfacing 
#   functions without freezing.
#
# USE =========================================================================
# 
#   bash set_up_machinefile.sh [MACHINE_COUNT] [PWD] [HOSTNAME_BASE] [-ex_core]
#
# VARIABLES ===================================================================

MACHINE_COUNT=$1-1
USERNAME=root 
PASSWORD=$2 
HOSTNAME_BASE=$3 

TOTAL_CORES=0
MACHINEFILE=""

if [[ $4 == *-ex_core* ]]; then EX_CORE=1; else EX_CORE=0; fi

MIRROR="/mirror"        # so I can differentiate during testing

# LOGIC =======================================================================

# compile machinefile information ---------------------------------------------

echo -e "CREATING MACHINEFILE\n"

for ((i=MACHINE_COUNT;i>=1;i--))
do
    HOSTNAME=$HOSTNAME_BASE$i

    CORES=$(sshpass -p "$PASSWORD" ssh "root@$HOSTNAME" "nproc")

    echo "$CORES CORES DETECTED ON $HOSTNAME"

    TOTAL_CORES=$(($TOTAL_CORES + $CORES))

    MACHINEFILE+="$HOSTNAME:$CORES\\n"

done

# get master node separately --------------------------------------------------

MACHINE_COUNT=0
HOSTNAME=$HOSTNAME_BASE$MACHINE_COUNT
CORES=$(sshpass -p "$PASSWORD" ssh "root@$HOSTNAME" "nproc")

echo -n "$CORES CORES DETECTED ON $HOSTNAME"

if [[ $4 == *-ex_core* ]]
then 
    CORES=$(($CORES - 1))
    echo ", $CORES USED"
else
    echo
fi

# save machinefile and display cores ------------------------------------------

TOTAL_CORES=$(($TOTAL_CORES + $CORES))
echo "TOTAL CORES: $TOTAL_CORES"

MACHINEFILE+="$HOSTNAME:$CORES\\n"

echo -e "CONTENTS OF MACHINEFILE:\n"
echo -e $MACHINEFILE

# $HOSTNAME is still the master node 
sshpass -p "$PASSWORD" ssh "root@$HOSTNAME" "printf '$MACHINEFILE' > $MIRROR/machinefile"

echo -e "MACHINEFILE SAVED TO: $MIRROR/machinefile"

