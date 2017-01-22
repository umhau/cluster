#!/bin/bash
#
# NOTES =======================================================================
#
#   assumes the master node is nunmbered 0, and the rest increment upwards from
#   there.
#
# USE =========================================================================
# 
#   bash set_up_shared_folder.sh [MACHINE_COUNT] [PASSWORD] [HOSTNAME_BASE]
#
# VARIABLES ===================================================================

MACHINE_COUNT=$1-1
USERNAME=root 
PASSWORD=$2 
HOSTNAME_BASE=$3 

# LOGIC =======================================================================

echo ""

# install dependencies --------------------------------------------------------

sshpass -p "$PASSWORD" ssh "root@$HOSTNAME_BASE"0 "apt-get install nfs-server"


for ((i=1;i<=MACHINE_COUNT;i++))
do
    HOSTNAME=$HOSTNAME_BASE$i

    sshpass -p "$PASSWORD" ssh "root@$HOSTNAME" "apt-get install nfs-client"

done

# add /mirror -----------------------------------------------------------------

for ((i=0;i<=MACHINE_COUNT;i++))
do
    HOSTNAME=$HOSTNAME_BASE$i

    sshpass -p "$PASSWORD" ssh "root@$HOSTNAME" "mkdir /mirror"

done

# share mirror to all nodes ---------------------------------------------------

cmd1="echo '/mirror *(rw,sync)' | sudo tee -a /etc/exports"
cmd2="service nfs-kernel-server restart"

sshpass -p "$PASSWORD" ssh "root@$HOSTNAME_BASE"0 "$cmd1; $cmd2"

# mount mirror on each node ---------------------------------------------------

HOSTNAME_MASTER="$HOSTNAME_BASE"0

cmd1="echo '$HOSTNAME_MASTER:/mirror    /mirror    nfs' | tee -a /etc/fstab"
cmd2="mount -a"


for ((i=0;i<=MACHINE_COUNT;i++))
do
    HOSTNAME=$HOSTNAME_BASE$i

    sshpass -p "$PASSWORD" ssh "root@$HOSTNAME" "$cmd1; $cmd2"

done

# announce results ------------------------------------------------------------

echo -e "SHARED FOLDER CREATED ON: $HOSTNAME_MASTER\n"
