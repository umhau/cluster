#!/bin/bash
#
# NOTES =======================================================================
#
# USE =========================================================================
# 
#   bash set_up_shared_folder.sh [NEW USERNAME] 
#                                [NEW USER PASSWORD] 
#                                [HOSTNAME_MASTER] 
#                                [TOTAL CORES]
#
# VARIABLES ===================================================================

NEW_USERNAME=$1
USER_PASSWORD=$1
HOSTNAME_MASTER=$2 
TOTAL_CORES=$3      # available, as listed in the machinefile

# LOGIC =======================================================================

# upload c program to master node ---------------------------------------------

sshpass -p "$USER_PASSWORD" scp ./mpi_hello.c $NEW_USERNAME@$HOSTNAME_MASTER:/mirror11/mpi_hello.c 

# compile ---------------------------------------------------------------------

sshpass -p "$USER_PASSWORD" ssh $NEW_USERNAME@$HOSTNAME_MASTER "cd /mirror11 && mpicc mpi_hello.c -o mpi_hello"

# run -------------------------------------------------------------------------

# weird fix: http://stackoverflow.com/a/20105670/7163016
sshpass -p "$USER_PASSWORD" ssh $NEW_USERNAME@$HOSTNAME_MASTER "cd /mirror11/mpi_hello" &>/dev/null

sshpass -p "$USER_PASSWORD" ssh $NEW_USERNAME@$HOSTNAME_MASTER "mpiexec -n $TOTAL_CORES -f /mirror11/machinefile /mirror11/mpi_hello"

