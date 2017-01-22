#!/bin/bash
#
# NOTES =======================================================================
#
#   assumes the master node is numbered 0, and the rest increment upwards from
#   there.
# 
#   assumes that all local IP addresses start with '192.168'.
#
# USE =========================================================================
# 
#   bash set_up_comm_protocol.sh    [MACHINE_COUNT] 
#                                   [PASSWORD] 
#                                   [HOSTNAME_BASE]
#                                   [NEW USER]
#                                   [NEW USER PASSWORD]
#
# VARIABLES ===================================================================

MACHINE_COUNT=$1-1
USERNAME=root 
PASSWORD=$2 
HOSTNAME_BASE=$3 
NEW_USER=$4
NEW_USER_PASSWORD=$5

MIRROR="/mirror"        # so I can differentiate during testing

# LOGIC =======================================================================

# create a new user -----------------------------------------------------------

cmd1="useradd --uid 1010 -m -d $MIRROR/$NEW_USER $NEW_USER"
cmd2="echo $NEW_USER:$NEW_USER_PASSWORD | chpasswd"
cmd3="chown $NEW_USER $MIRROR"

for ((i=0;i<=MACHINE_COUNT;i++))
do
    HOSTNAME=$HOSTNAME_BASE$i

    sshpass -p "$PASSWORD" ssh "root@$HOSTNAME" "$cmd1; $cmd2; $cmd3"

done

# ssh without passwords -------------------------------------------------------

#   After generating the keys as root in the root directory, move the .ssh 
#   folder over to the new user.  This would be bad security practice in 
#   *other* contexts, but all I need is seamless communication.  I don't even
#   have passwords, because it doesn't matter.

cmd1="apt­-get install openssh-server"
cmd2="yes 'y' | ssh-keygen -t rsa"
cmd3="cd .ssh && cat id_rsa.pub >> authorized_keys"
cmd4="mv /root/.ssh $MIRROR/$NEW_USER/" # http://serverfault.com/a/323964
cmd5="chown -R $NEW_USER: $MIRROR/$NEW_USER/.ssh" # http://askubuntu.com/a/6727

# disable host verification - src: http://superuser.com/a/628801
txt="Host 192.168.*.*\n   StrictHostKeyChecking no\n   UserKnownHostsFile=/dev/null"
cmd6="printf '$txt' >> /etc/ssh/ssh_config"

for ((i=0;i<=MACHINE_COUNT;i++))
do
    HOSTNAME=$HOSTNAME_BASE$i

    sshpass -p "$PASSWORD" ssh "root@$HOSTNAME" "$cmd1; $cmd2; $cmd3"

    sshpass -p "$PASSWORD" ssh "root@$HOSTNAME" "$cmd4; $cmd5; $cmd6"

done






