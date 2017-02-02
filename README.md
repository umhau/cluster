Assumptions:
* Ubuntu Server 16.04.1 LTS has been installed
* all computers have been assembled, added to the network and are accessible through ssh
* a root user has been set up and can be ssh'd into seamlessly.
* sshpass has been installed.

To see the details of implementing the above, see:
* https://nixingaround.blogspot.com/2017/01/a-homebrew-beowulf-cluster-part-1.html
* https://nixingaround.blogspot.com/2017/01/a-homemade-beowulf-cluster-part-2.html

==============================================================================================

Both of these scripts are intended to be run from a computer external from the cluster.  For 
the second script, the [USER] is the one configured to run MPI programs.

USAGE: 
    bash create_hosts_file.sh [MACHINE_COUNT] [ROOT PASSWORD] [HOSTNAME_BASE]
    bash test_configuration.sh [USER] [PASSWORD] [MASTER NODE HOSTNAME] [TOTAL CORES]
    
Extra! Extra! Read all about it!
