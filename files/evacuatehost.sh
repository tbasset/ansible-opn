#!/bin/bash

SRCHOST=$1
VMSTATE=$2

HOSTS=(node1 node2 node3)
INSTANCES=$(openstack server list --all-projects --host ${SRCHOST} --vm-state $VMSTATE -f value -c ID)

incr=0
for INSTANCE in ${INSTANCES};
do
  # counter
  incr=$(($incr+1));

  # dispatch evenly to hosts
  DESTHOST=${HOSTS[0]}
  while [[ $DESTHOST == $SRCHOST ]]; do
    size=${#HOSTS[@]}
    index=$(($RANDOM % $size))
    DESTHOST=${HOSTS[$index]}
  done

  # print
  echo "#$incr $INSTANCE move to $DESTHOST"
  openstack server migrate --live-migration --host $DESTHOST $INSTANCE

done
