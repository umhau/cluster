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
#   This only allows for alphanumeric iterators.
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
PASSWORD=$3 

HOSTNAME_BASE=$4 
HOSTNAME_ITERATORS=(a b c d e f g h i j k l m n o p q r s t u v w x y z)

HOSTFILE_CONTENTS="127.0.0.1     localhost\n"

# LOGIC =======================================================================

# preparation -----------------------------------------------------------------

# check if machine count variable provided & verify sanity
if [[ ! $1 =~ ^-?[0-9]+$ ]]
then 
    echo "USAGE: bash create_hosts_file.sh [MACHINE_COUNT] [USERNAME] [PASSWORD] [HOSTNAME_BASE]"
    exit 0
fi

# request confirmation
echo -e "\nPLEASE CONFIRM VARIABLES:\n"
echo -e "USERNAME:    $USERNAME"
echo -e "PASSWORD:    $PASSWORD"
echo -n "MACHINES:    $HOSTNAME_BASE${HOSTNAME_ITERATORS[0]}"
for ((i=1;i<=MACHINE_COUNT;i++))
do
    echo -n " | $HOSTNAME_BASE${HOSTNAME_ITERATORS[i]}"
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
    HOSTNAME=$HOSTNAME_BASE${HOSTNAME_ITERATORS[i]}

    # get the ip of each computer
    IP=$(getent hosts $HOSTNAME | awk '{ print $1 }')

    # add to the hostfile
    HOSTFILE_CONTENTS+="$IP $HOSTNAME\n"

done

echo -e "CONTENTS OF NEW HOSTFILE:\n"
echo -e $HOSTFILE_CONTENTS
echo -n "[ENTER] TO UPLOAD, [CTRL-C] TO CANCEL" 
read

# save hostfile to /tmp folder
echo -e $HOSTFILE_CONTENTS > /tmp/hosts

# upload to each machine in the cluster ---------------------------------------
for ((i=0;i<=MACHINE_COUNT;i++))
do
    HOSTNAME=$HOSTNAME_BASE${HOSTNAME_ITERATORS[i]}

    # make sure there's a backup of the original hosts file
    if ! sshpass -p "$PASSWORD" ssh -q $HOSTNAME [[ -f "/home/$USERNAME/hosts.bak" ]]
    then 
        sshpass -p "$PASSWORD" ssh $USERNAME@$HOSTNAME "cp /etc/hosts /home/$USERNAME/hosts.bak"
        echo -e "HOSTFILE BACKED UP\n"
    fi
    # upload the new hosts file
    sshpass -p "$PASSWORD" ssh $USERNAME@$HOSTNAME "sudo echo $HOSTFILE_CONTENTS > /etc/hosts"
    # sshpass -p "$PASSWORD" scp /tmp/hosts $USERNAME@$HOSTNAME:/etc/hosts

done

rm /tmp/hosts

echo -e "NEW HOSTFILES INSTALLED\n"