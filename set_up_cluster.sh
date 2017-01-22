#!/bin/bash
#
# NOTES =======================================================================
#
#   Assumes this script is being run from within its own directory.  
# 
#   Assumes the master node is nunmbered 0, and the rest increment upwards from
#   there.
# 
#   There is an option to leave a core free on the master node for networking
#   and communication purposes.  See the machinefile section below.
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

NEW_USER=$4
NEW_USER_PASSWORD=$5

# LOGIC =======================================================================

# create hosts file -----------------------------------------------------------

bash ./create_hosts_file.sh $MACHINE_COUNT $PASSWORD $HOSTNAME_BASE

# establish shared folder -----------------------------------------------------

bash ./set_up_shared_folder.sh $MACHINE_COUNT $PASSWORD $HOSTNAME_BASE

# establish seamless communication protocol -----------------------------------

bash ./set_up_comm_protocol.sh  $MACHINE_COUNT \
                                $PASSWORD \
                                $HOSTNAME_BASE \
                                $NEW_USER \
                                $NEW_USER_PASSWORD

# install compilers -----------------------------------------------------------

bash ./install_compilers.sh $MACHINE_COUNT $PASSWORD $HOSTNAME_BASE

# set up machinefile ----------------------------------------------------------

bash ./set_up_machinefile.sh $MACHINE_COUNT $PASSWORD $HOSTNAME_BASE -ex_core

TOTAL_CORES=$?

bash ./test_configuration.sh $NEW_USER \
                             $NEW_USER_PASSWORD \
                             "$HOSTNAME_BASE"0 \
                             $TOTAL_CORES

# Process complete ------------------------------------------------------------