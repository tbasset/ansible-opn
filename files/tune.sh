#!/bin/bash

echo "nova cpu_allocation_ratio => 8"
ansible infra1 -m shell -a "sed -i 's/^cpu_allocation_ratio = .*/cpu_allocation_ratio = 8/' /etc/nova/nova.conf"
ansible infra2 -m shell -a "sed -i 's/^cpu_allocation_ratio = .*/cpu_allocation_ratio = 8/' /etc/nova/nova.conf"
ansible infra3 -m shell -a "sed -i 's/^cpu_allocation_ratio = .*/cpu_allocation_ratio = 8/' /etc/nova/nova.conf"

echo "nova libvirt workaround 2024.2 weird live-migrate CPU found incompatible even when identical"
ansible infra1 -m shell -a "grep -qxF '[workarounds]' /etc/nova/nova.conf || echo '[workarounds]' >> /etc/nova/nova.conf"
ansible infra1 -m shell -a "grep -qxF 'skip_cpu_compare_at_startup = true' /etc/nova/nova.conf || echo 'skip_cpu_compare_at_startup = true' >> /etc/nova/nova.conf"
ansible infra1 -m shell -a "grep -qxF 'skip_cpu_compare_on_dest = true' /etc/nova/nova.conf || echo 'skip_cpu_compare_on_dest = true' >> /etc/nova/nova.conf"
ansible infra1 -m shell -a "systemctl restart nova.slice;"

ansible infra2 -m shell -a "grep -qxF '[workarounds]' /etc/nova/nova.conf || echo '[workarounds]' >> /etc/nova/nova.conf"
ansible infra2 -m shell -a "grep -qxF 'skip_cpu_compare_at_startup = true' /etc/nova/nova.conf || echo 'skip_cpu_compare_at_startup = true' >> /etc/nova/nova.conf"
ansible infra2 -m shell -a "grep -qxF 'skip_cpu_compare_on_dest = true' /etc/nova/nova.conf || echo 'skip_cpu_compare_on_dest = true' >> /etc/nova/nova.conf"
ansible infra2 -m shell -a "systemctl restart nova.slice;"

ansible infra3 -m shell -a "grep -qxF '[workarounds]' /etc/nova/nova.conf || echo '[workarounds]' >> /etc/nova/nova.conf"
ansible infra3 -m shell -a "grep -qxF 'skip_cpu_compare_at_startup = true' /etc/nova/nova.conf || echo 'skip_cpu_compare_at_startup = true' >> /etc/nova/nova.conf"
ansible infra3 -m shell -a "grep -qxF 'skip_cpu_compare_on_dest = true' /etc/nova/nova.conf || echo 'skip_cpu_compare_on_dest = true' >> /etc/nova/nova.conf"
ansible infra3 -m shell -a "systemctl restart nova.slice;"

echo "lowering mysql settings to a reasonable homelab standing"
ansible galera_container -m shell -a "sed -i 's/^max_connections = .*/max_connections = 3200/' /etc/mysql/mariadb.cnf"
ansible galera_container -m shell -a "sed -i 's/^innodb-log-file-size.*/innodb-log-file-size = 16M/' /etc/mysql/mariadb.cnf"
ansible galera_container -m shell -a "sed -i 's/^innodb-buffer-pool-size.*/innodb-buffer-pool-size = 128M/' /etc/mysql/mariadb.cnf"
ansible galera_container -f 1 -m shell -a "systemctl restart mariadb"

echo "restart keystone uwsgi after mysql restart"
ansible keystone_container -f 1 -m shell -a "sysctl -w net.core.somaxconn=1024 ; sed -nr '/^listen =/!p;$alisten = 1024' /etc/uwsgi/keystone-wsgi-public.ini ; systemctl restart keystone-wsgi-public.service ;"

echo "lowering procs/threads concurrency settings to a reasonable homelab standing"

echo "infra*_nova_api_container*"
ansible infra*_nova_api_container* -m shell -a "sed -i 's/^workers = 8/workers = 2/' /etc/nova/nova.conf"
ansible infra*_nova_api_container* -m shell -a "systemctl restart nova-conductor.service"
ansible infra*_nova_api_container* -m shell -a "sed -i 's/^processes = 8/processes = 2/' /etc/uwsgi/nova-api-metadata.ini"
ansible infra*_nova_api_container* -m shell -a "systemctl restart nova-api-metadata.service"
ansible infra*_nova_api_container* -m shell -a "sed -i 's/^processes = 8/processes = 2/' /etc/uwsgi/nova-api-os-compute.ini"
ansible infra*_nova_api_container* -m shell -a "systemctl restart nova-api-os-compute.service"

echo "infra*_cinder_api*"
ansible infra*_cinder_api* -m shell -a "sed -i 's/^osapi_volume_workers = 8/osapi_volume_workers = 2/' /etc/cinder/cinder.conf"
ansible infra*_cinder_api* -m shell -a "systemctl restart cinder-scheduler.service"
ansible infra*_cinder_api* -m shell -a "sed -i 's/^processes = 8/processes = 2/' /etc/uwsgi/cinder-api.ini"
ansible infra*_cinder_api* -m shell -a "systemctl restart cinder-api.service"

echo "infra*_placement_container*"
ansible infra*_placement_container* -m shell -a "sed -i 's/^processes = 8/processes = 2/' /etc/uwsgi/placement-api.ini"
ansible infra*_placement_container* -m shell -a "systemctl restart placement-api.service"

echo "infra*_heat_api_container*"
ansible infra*_heat_api_container* -m shell -a "sed -i 's/^num_engine_workers = 8/num_engine_workers = 2/' /etc/heat/heat.conf"
ansible infra*_heat_api_container* -m shell -a "systemctl restart heat-engine.service"
ansible infra*_heat_api_container* -m shell -a "sed -i 's/^processes = 8/processes = 2/' /etc/uwsgi/heat-api-cfn.ini"
ansible infra*_heat_api_container* -m shell -a "systemctl restart heat-api-cfn.service"
ansible infra*_heat_api_container* -m shell -a "sed -i 's/^processes = 8/processes = 2/' /etc/uwsgi/heat-api.ini"
ansible infra*_heat_api_container* -m shell -a "systemctl restart heat-api.service"

echo "infra*_neutron_server*"
ansible infra*_neutron_server* -m shell -a "sed -i 's/^rpc_workers = 8/rpc_workers = 2/' /etc/neutron/neutron.conf"
ansible infra*_neutron_server* -m shell -a "systemctl restart neutron-server.service"

echo "restart cinder-volume.service"
ansible infra1 -m shell -a "systemctl restart cinder-volume.service"
ansible infra2 -m shell -a "systemctl restart cinder-volume.service"
ansible infra3 -m shell -a "systemctl restart cinder-volume.service"
