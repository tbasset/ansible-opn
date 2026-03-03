#!/bin/bash

ansible galera_container            -m shell -a "systemctl restart mariadb"
ansible infra*_nova_api_container*  -m shell -a "systemctl restart nova-api-os-compute.service"
ansible infra*_cinder_api*          -m shell -a "systemctl restart cinder-api.service"
ansible infra*_placement_container* -m shell -a "systemctl restart placement-api.service"
ansible infra*_heat_api_container*  -m shell -a "systemctl restart heat-engine.service"
ansible infra*_heat_api_container*  -m shell -a "systemctl restart heat-api-cfn.service"
ansible infra*_heat_api_container*  -m shell  -a "systemctl restart heat-api.service"
ansible infra*_neutron_server*      -m shell -a "systemctl restart neutron-server.service"

ansible infra1 -m shell -a "systemctl restart cinder-volume.service"
ansible infra2 -m shell -a "systemctl restart cinder-volume.service"
ansible infra3 -m shell -a "systemctl restart cinder-volume.service"
ansible compute1 -m shell -a "systemctl restart cinder-volume.service"
ansible compute2 -m shell -a "systemctl restart cinder-volume.service"

