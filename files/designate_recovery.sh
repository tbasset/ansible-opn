#!/bin/bash

designatehost=$1

pool=$(ssh ${designatehost} "/openstack/venvs/\$(cd /openstack/venvs; ls -Art  | tail -n 1)/bin/designate-manage pool show_config --all | grep 'id:'" | awk '{ print $2 }')
echo $pool
ssh ${designatehost} "sed -i 's/default_pool_id = .*/default_pool_id = $pool/' /etc/designate/designate.conf"
ssh ${designatehost} "systemctl stop designate.slice ; systemctl start designate-api.service designate-central.service designate-mdns.service designate-producer.service designate-sink.service designate-worker.service"
ssh ${designatehost} "/openstack/venvs/\$(cd /openstack/venvs; ls -Art  | tail -n 1)/bin/designate-manage pool update"
