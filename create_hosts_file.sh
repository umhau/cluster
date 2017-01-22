#!/bin/bash
#
# NOTES =======================================================================
#
#   See step 1 here: https://help.ubuntu.com/community/MpichCluster
#
#   Since I can't get static IPs to work, I can run this file to create a new 
#   hostfile on each machine dynamically.  
#
#   This cannot be run from a computer within the cluster.  
# 
#   Iterators must start at 0 and increase in single unit steps.  
# 
#   The username must be root, and the root user must be enabled on each 
#   machine.  This is the only way to programmatically modify the 
#   root-protected hosts file.
#
# USE =========================================================================
# 
#   bash create_hosts_file.sh [MACHINE_COUNT] [PASSWORD] [HOSTNAME_BASE]
#
# VARIABLES ===================================================================

MACHINE_COUNT=$1-1

USERNAME=root 
PASSWORD=$2 

HOSTNAME_BASE=$3 

HOSTFILE_CONTENTS="127.0.0.1     localhost\n"

# LOGIC =======================================================================

# preparation -----------------------------------------------------------------

# check if machine count variable provided & verify sanity
if [[ ! $1 =~ ^-?[0-9]+$ ]]
then 
    echo "USAGE: bash create_hosts_file.sh [MACHINE_COUNT] [PASSWORD] [HOSTNAME_BASE]"
    exit 0
fi

# request confirmation
echo -e "\nPLEASE CONFIRM VARIABLES:\n"
echo -e "USERNAME:    $USERNAME"
echo -e "PASSWORD:    $PASSWORD"
echo -n "MACHINES:    $HOSTNAME_BASE"0
for ((i=1;i<=MACHINE_COUNT;i++))
do
    echo -n " | $HOSTNAME_BASE"$i
done 
echo -e "\n\n[ENTER] TO CONTINUE, [CTRL-C] TO CANCEL" 
read

# check if sshpass is installed
if ! hash sshpass 2>/dev/null; then 
    sudo apt-get install sshpass
fi

# create the hostfile, one machine at a time ----------------------------------
for ((i=0;i<=MACHINE_COUNT;i++))
do
    HOSTNAME=$HOSTNAME_BASE$i

    # get the ip of each computer
    IP=$(getent hosts $HOSTNAME | awk '{ print $1 }')

    # add to the hostfile
    HOSTFILE_CONTENTS+="$IP $HOSTNAME\\n"

done

echo -e "CONTENTS OF NEW HOSTFILE:\n"
echo -e $HOSTFILE_CONTENTS
echo -n "[ENTER] TO UPLOAD, [CTRL-C] TO CANCEL" 
read

echo -n "INSTALL PROCESS COMPLETE ON: "

# upload to each machine in the cluster ---------------------------------------
for ((i=0;i<=MACHINE_COUNT;i++))
do
    HOSTNAME=$HOSTNAME_BASE$i

    # make sure there's a backup of the original hosts file
    if ! sshpass -p "$PASSWORD" ssh -q $HOSTNAME [[ -f "/root/hosts.bak" ]]
    then 
        sshpass -p "$PASSWORD" ssh $USERNAME@$HOSTNAME "cp /etc/hosts /root/hosts.bak"
    fi
    # upload the new hosts file
    sshpass -p "$PASSWORD" ssh $USERNAME@$HOSTNAME "sudo printf '$HOSTFILE_CONTENTS' > /etc/hosts"
    echo -n "$HOSTNAME  "

done

echo -e "\n\nNEW HOSTFILES INSTALLED\n"