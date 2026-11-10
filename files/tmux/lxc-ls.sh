#!/bin/bash

ssh $1 -t "watch lxc-ls -f -F NAME,STATE,IPV4"
#ssh $1 -t "watch kubectl get pods --all-namespaces"
