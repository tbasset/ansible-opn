#!/bin/bash

# to run on all designate container after each install/upgrade

lastvenv=`cd /openstack/venvs; ls -Art  | tail -n 1`
/openstack/venvs/${lastvenv}/bin/designate-manage pool generate_file --file /tmp/check-pool.yaml
poolid=`grep "id:" /tmp/check-pool.yaml | awk '{print $2}'`
sed -i "s/^default_pool_id = .*/default_pool_id = $poolid/" /etc/designate/designate.conf
systemctl stop designate.slice
systemctl start designate.slice
systemctl start designate-api
systemctl start designate-central
systemctl start designate-mdns
systemctl start designate-producer
systemctl start designate-sink
systemctl start designate-worker
/openstack/venvs/${lastvenv}/bin/designate-manage pool update
#/openstack/venvs/${lastvenv}/bin/designate-manage pool show_config --all
