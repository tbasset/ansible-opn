#!/bin/bash

SRCHOST=node1
DESTHOSTS=(node2 node3)

INSTANCES=$(openstack server list --all-projects --host ${SRCHOST} -f value -c ID)

incr=0
for INSTANCE in ${INSTANCES};
do

  incr=$(($incr+1))
  if [ $(($incr%2)) == 0 ]
  then
    DESTHOST=${DESTHOSTS[0]}
  else
    DESTHOST=${DESTHOSTS[1]}
  fi

  echo "$incr $INSTANCE move to $DESTHOST"
  openstack server migrate --live-migration --host $DESTHOST $INSTANCE

done
