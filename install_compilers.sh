#!/bin/bash
#
# NOTES =======================================================================
#
#   assumes the master node is numbered 0, and the rest increment upwards from
#   there.
#
# USE =========================================================================
# 
#   bash install_compilers.sh [MACHINE_COUNT] [PASSWORD] [HOSTNAME_BASE]
#
# VARIABLES ===================================================================

MACHINE_COUNT=$1-1
USERNAME=root 
PASSWORD=$2 
HOSTNAME_BASE=$3 

# LOGIC =======================================================================

cmd1="apt-get install build-essential -y"
cmd2="apt-get install gfortran -y"
cmd3="apt-get install mpich"

echo -n "COMPILERS AND MPICH INSTALLED ON: "

for ((i=0;i<=MACHINE_COUNT;i++))
do
    HOSTNAME=$HOSTNAME_BASE$i

    sshpass -p "$PASSWORD" ssh "root@$HOSTNAME" "$cmd1 && $cmd2 && $cmd3" 

    echo -n "$HOSTNAME  "

done

