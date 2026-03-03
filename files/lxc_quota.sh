
# ls /sys/fs/cgroup/lxc.payload.container/

# Resources configuration
lxc.cgroup2.memory.max = 2G
lxc.cgroup2.memory.high = 2G
lxc.cgroup2.cpuset.cpus = 0-3
#lxc.cgroup2.io.max="8:0 rbps=67108864 wbps=67108864"

# limit IO to 1Mbit/s
#echo "8:0 wbps=1048576" > /sys/fs/cgroup/<container>/io.max

# /var/lib/lxc/infra1_galera_container-1dab194f/config

# memory.swappiness
# Controls swap priority. Determines whether kernel can claim memory from the control group. 
# Set this value to 0 for high memory consuming processes, such as MySQL, MongoDB, RabbitMQ.

# Using cpu.shares you can set the following CPU limits:

# beam.smp - for RabbitMQ up to 40%.
# nova-api - for Nova 20 - 45%.
# nova-conductor - for Nova up to 20%.
# mysqld - for MySQL up to 10%.
# neutron-server - for Neutron - 10%.
