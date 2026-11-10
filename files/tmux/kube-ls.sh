#!/bin/bash

host=$(grep $1 /etc/hosts | awk '{print $3}')
#echo $host
ssh $host -t "watch kubectl get pods --all-namespaces"
