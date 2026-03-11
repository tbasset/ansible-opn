#!/bin/bash

#add this to lxc configs (after openstack-ansible setup_host runs)
# cpu.max is like a cpu shares, mostly
# memory.high is soft limit (memory pressure)
# memory.max is hard limit (oom) todo: cpumax=$((cpuhigh*125/100))

echo "Setting limits for nova_api"
cpumax=20000
memmax=1024M
container=$(lxc-ls -1 --filter=nova[-_]api)
config="/var/lib/lxc/${container}/config"
grep -q "lxc.cgroup2.cpu.max" ${config} || echo "lxc.cgroup2.cpu.max = ${cpumax}" >> ${config}
grep -q "lxc.cgroup2.memory.max" ${config} || echo "lxc.cgroup2.memory.max = ${memmax}" >> ${config}
grep -q "lxc.cgroup2.memory.high" ${config} || echo "lxc.cgroup2.memory.high = ${memmax}" >> ${config}
lxc-stop ${container}
lxc-start ${container}

echo "Setting limits for zookeeper"
cpumax=20000
memmax=768M
container=$(lxc-ls -1 --filter=zookeeper)
config="/var/lib/lxc/${container}/config"
grep -q "lxc.cgroup2.cpu.max" ${config} || echo "lxc.cgroup2.cpu.max = ${cpumax}" >> ${config}
grep -q "lxc.cgroup2.memory.max" ${config} || echo "lxc.cgroup2.memory.max = ${memmax}" >> ${config}
grep -q "lxc.cgroup2.memory.high" ${config} || echo "lxc.cgroup2.memory.high = ${memmax}" >> ${config}
lxc-stop ${container}
lxc-start ${container}

echo "Setting limits for horizon"
cpumax=max
memmax=1536M
container=$(lxc-ls -1 --filter=horizon)
config="/var/lib/lxc/${container}/config"
grep -q "lxc.cgroup2.cpu.max" ${config} || echo "lxc.cgroup2.cpu.max = ${cpumax}" >> ${config}
grep -q "lxc.cgroup2.memory.max" ${config} || echo "lxc.cgroup2.memory.max = ${memmax}" >> ${config}
grep -q "lxc.cgroup2.memory.high" ${config} || echo "lxc.cgroup2.memory.high = ${memmax}" >> ${config} 
lxc-stop ${container}
lxc-start ${container}

echo "Setting limits for designate"
cpumax=20000
memmax=768M
container=$(lxc-ls -1 --filter=designate)
config="/var/lib/lxc/${container}/config"
grep -q "lxc.cgroup2.cpu.max" ${config} || echo "lxc.cgroup2.cpu.max = ${cpumax}" >> ${config}
grep -q "lxc.cgroup2.memory.max" ${config} || echo "lxc.cgroup2.memory.max = ${memmax}" >> ${config}
grep -q "lxc.cgroup2.memory.high" ${config} || echo "lxc.cgroup2.memory.high = ${memmax}" >> ${config}
lxc-stop ${container}
lxc-start ${container}

echo "Setting limits for keystone"
cpumax=20000
memmax=768M
container=$(lxc-ls -1 --filter=keystone)
config="/var/lib/lxc/${container}/config"
grep -q "lxc.cgroup2.cpu.max" ${config} || echo "lxc.cgroup2.cpu.max = ${cpumax}" >> ${config}
grep -q "lxc.cgroup2.memory.max" ${config} || echo "lxc.cgroup2.memory.max = ${memmax}" >> ${config}
grep -q "lxc.cgroup2.memory.high" ${config} || echo "lxc.cgroup2.memory.high = ${memmax}" >> ${config}
lxc-stop ${container}
lxc-start ${container}

echo "Setting limits for glance"
cpumax=20000
memmax=512M
container=$(lxc-ls -1 --filter=glance)
config="/var/lib/lxc/${container}/config"
grep -q "lxc.cgroup2.cpu.max" ${config} || echo "lxc.cgroup2.cpu.max = ${cpumax}" >> ${config}
grep -q "lxc.cgroup2.memory.max" ${config} || echo "lxc.cgroup2.memory.max = ${memmax}" >> ${config}
grep -q "lxc.cgroup2.memory.high" ${config} || echo "lxc.cgroup2.memory.high = ${memmax}" >> ${config}
lxc-stop ${container}
lxc-start ${container}

echo "Setting limits for cinder-api"
cpumax=20000
memmax=1024M
container=$(lxc-ls -1 --filter=cinder[-_]api)
config="/var/lib/lxc/${container}/config"
grep -q "lxc.cgroup2.cpu.max" ${config} || echo "lxc.cgroup2.cpu.max = ${cpumax}" >> ${config}
grep -q "lxc.cgroup2.memory.max" ${config} || echo "lxc.cgroup2.memory.max = ${memmax}" >> ${config}
grep -q "lxc.cgroup2.memory.high" ${config} || echo "lxc.cgroup2.memory.high = ${memmax}" >> ${config}
lxc-stop ${container}
lxc-start ${container}

echo "Setting limits for neutron-server"
cpumax=20000
memmax=4096M
container=$(lxc-ls -1 --filter=neutron[-_]server)
config="/var/lib/lxc/${container}/config"
grep -q "lxc.cgroup2.cpu.max" ${config} || echo "lxc.cgroup2.cpu.max = ${cpumax}" >> ${config}
grep -q "lxc.cgroup2.memory.max" ${config} || echo "lxc.cgroup2.memory.max = ${memmax}" >> ${config}
grep -q "lxc.cgroup2.memory.high" ${config} || echo "lxc.cgroup2.memory.high = ${memmax}" >> ${config}
lxc-stop ${container}
lxc-start ${container}

echo "Setting limits for galera"
cpumax=20000
memmax=1536M
container=$(lxc-ls -1 --filter=galera)
config="/var/lib/lxc/${container}/config"
grep -q "lxc.cgroup2.cpu.max" ${config} || echo "lxc.cgroup2.cpu.max = ${cpumax}" >> ${config}
grep -q "lxc.cgroup2.memory.max" ${config} || echo "lxc.cgroup2.memory.max = ${memmax}" >> ${config}
grep -q "lxc.cgroup2.memory.high" ${config} || echo "lxc.cgroup2.memory.high = ${memmax}" >> ${config}
lxc-stop ${container}
lxc-start ${container}

echo "Setting limits for heat-api"
cpumax=20000
memmax=768M
container=$(lxc-ls -1 --filter=heat[-_]api)
config="/var/lib/lxc/${container}/config"
grep -q "lxc.cgroup2.cpu.max" ${config} || echo "lxc.cgroup2.cpu.max = ${cpumax}" >> ${config}
grep -q "lxc.cgroup2.memory.max" ${config} || echo "lxc.cgroup2.memory.max = ${memmax}" >> ${config}
grep -q "lxc.cgroup2.memory.high" ${config} || echo "lxc.cgroup2.memory.high = ${memmax}" >> ${config}
lxc-stop ${container}
lxc-start ${container}

echo "Setting limits for utility"
cpumax=20000
memmax=256M
container=$(lxc-ls -1 --filter=utility)
config="/var/lib/lxc/${container}/config"
grep -q "lxc.cgroup2.cpu.max" ${config} || echo "lxc.cgroup2.cpu.max = ${cpumax}" >> ${config}
grep -q "lxc.cgroup2.memory.max" ${config} || echo "lxc.cgroup2.memory.max = ${memmax}" >> ${config}
grep -q "lxc.cgroup2.memory.high" ${config} || echo "lxc.cgroup2.memory.high = ${memmax}" >> ${config}
lxc-stop ${container}
lxc-start ${container}

echo "Setting limits for placement"
cpumax=20000
memmax=512M
container=$(lxc-ls -1 --filter=placement)
config="/var/lib/lxc/${container}/config"
grep -q "lxc.cgroup2.cpu.max" ${config} || echo "lxc.cgroup2.cpu.max = ${cpumax}" >> ${config}
grep -q "lxc.cgroup2.memory.max" ${config} || echo "lxc.cgroup2.memory.max = ${memmax}" >> ${config}
grep -q "lxc.cgroup2.memory.high" ${config} || echo "lxc.cgroup2.memory.high = ${memmax}" >> ${config}
lxc-stop ${container}
lxc-start ${container}

echo "Setting limits for rabbit-mq"
cpumax=20000
memmax=4096M
container=$(lxc-ls -1 --filter=rabbit[-_]mq)
config="/var/lib/lxc/${container}/config"
grep -q "lxc.cgroup2.cpu.max" ${config} || echo "lxc.cgroup2.cpu.max = ${cpumax}" >> ${config}
grep -q "lxc.cgroup2.memory.max" ${config} || echo "lxc.cgroup2.memory.max = ${memmax}" >> ${config}
grep -q "lxc.cgroup2.memory.high" ${config} || echo "lxc.cgroup2.memory.high = ${memmax}" >> ${config}
lxc-stop ${container}
lxc-start ${container}

echo "Setting limits for memcached"
cpumax=20000
memmax=512M
container=$(lxc-ls -1 --filter=memcached)
config="/var/lib/lxc/${container}/config"
grep -q "lxc.cgroup2.cpu.max" ${config} || echo "lxc.cgroup2.cpu.max = ${cpumax}" >> ${config}
grep -q "lxc.cgroup2.memory.max" ${config} || echo "lxc.cgroup2.memory.max = ${memmax}" >> ${config}
grep -q "lxc.cgroup2.memory.high" ${config} || echo "lxc.cgroup2.memory.high = ${memmax}" >> ${config}
lxc-stop ${container}
lxc-start ${container}

echo "Setting limits for repo"
cpumax=20000
memmax=1024M
container=$(lxc-ls -1 --filter=repo)
config="/var/lib/lxc/${container}/config"
grep -q "lxc.cgroup2.cpu.max" ${config} || echo "lxc.cgroup2.cpu.max = ${cpumax}" >> ${config}
grep -q "lxc.cgroup2.memory.max" ${config} || echo "lxc.cgroup2.memory.max = ${memmax}" >> ${config}
grep -q "lxc.cgroup2.memory.high" ${config} || echo "lxc.cgroup2.memory.high = ${memmax}" >> ${config}
lxc-stop ${container}
lxc-start ${container}

echo "Setting limits for neutron-ovn-northd"
cpumax=20000
memmax=512M
container=$(lxc-ls -1 --filter=neutron[-_]ovn[-_]northd)
config="/var/lib/lxc/${container}/config"
grep -q "lxc.cgroup2.cpu.max" ${config} || echo "lxc.cgroup2.cpu.max = ${cpumax}" >> ${config}
grep -q "lxc.cgroup2.memory.max" ${config} || echo "lxc.cgroup2.memory.max = ${memmax}" >> ${config}
grep -q "lxc.cgroup2.memory.high" ${config} || echo "lxc.cgroup2.memory.high = ${memmax}" >> ${config}
lxc-stop ${container}
lxc-start ${container}



# dsh -M -g infra1 -- "ps -eo size,command --sort -size | awk '{ hr=\$1/1024 ; sum +=hr} END {print sum}'"
# infra1-nova-api-container-6182b2dd: 856.727             1024
# infra1-zookeeper-container-b3ed3535: 526.523            768
# infra1-horizon-container-46f8154b: 1469.01              1536
# infra1-designate-container-c18f09fa: 610.062            768
# infra1-keystone-container-2db7ead5: 773.527             768
# infra1-glance-container-f5ef6fb0: 444.695               512
# infra1-cinder-api-container-59df5016: 868.094           1024
# infra1-neutron-server-container-f997f082: 4718.55       3072
# infra1-galera-container-1dab194f: 1310.59               1536
# infra1-heat-api-container-7b082dfb: 714.297             768  
# infra1_utility_container-10944ca2: 207.508              256
# infra1-placement-container-bae2b625: 292                512
# infra1-rabbit-mq-container-5c2cef75: 692.531            768
# infra1-memcached-container-0093b903: 380.27             512
# infra1-repo-container-c68f697d: 902.824                 1024
# infra1-neutron-ovn-northd-container-bd21fd88: 318.742   512
#                                                 total ~ 15360