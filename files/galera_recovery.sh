#!/bin/bash

sed -i '/safe_to_bootstrap: 0/safe_to_bootstrap: 1/' /var/lib/mysql/grastate.dat
systemctl set-environment _WSREP_NEW_CLUSTER='--wsrep-new-cluster'
systemctl stop mariadb
systemctl start mariadb
systemctl set-environment _WSREP_NEW_CLUSTER=''

