This set of scripts picks up after:
* Ubuntu Server 16.04.1 LTS has been installed
* all computers have been assembled, added to the network and are accessible through ssh
* a root user has been set up and can be ssh'd into seamlessly.

To see the details of implementing the above, see:
* https://nixingaround.blogspot.com/2017/01/a-homebrew-beowulf-cluster-part-1.html
* https://nixingaround.blogspot.com/2017/01/a-homemade-beowulf-cluster-part-2.html

==============================================================================================

USAGE: 
    bash create_hosts_file.sh [MACHINE_COUNT] [ROOT PASSWORD] [HOSTNAME_BASE]
    bash set_up_machinefile.sh [MACHINE_COUNT] [PWD] [HOSTNAME_BASE] [-ex_core]
    
Note the option '-ex_core' serves to leave an extra core free on the master node.  Helps
prevent freezing.
