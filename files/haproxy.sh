#!/bin/bash

cat /etc/openstack_deploy/haproxy_errors.cfg >> /etc/ansible/roles/haproxy_server/templates/haproxy.cfg.j2

ssh node1 -- mkdir -p /etc/haproxy/errors-custom
rsync -av /etc/openstack_deploy/haproxy-custom-errors/* node1:/etc/haproxy/errors-custom/
rsync -av /etc/openstack_deploy/haproxy_errors.cfg node1:/etc/haproxy/
ssh node2 -- mkdir -p /etc/haproxy/errors-custom
rsync -av /etc/openstack_deploy/haproxy-custom-errors/* node2:/etc/haproxy/errors-custom/
rsync -av /etc/openstack_deploy/haproxy_errors.cfg node2:/etc/haproxy/
ssh node2 -- mkdir -p /etc/haproxy/errors-custom
rsync -av /etc/openstack_deploy/haproxy-custom-errors/* node3:/etc/haproxy/errors-custom/
rsync -av /etc/openstack_deploy/haproxy_errors.cfg node3:/etc/haproxy/

#ansible -i inventory/dynamic_inventory.py haproxy_hosts -m shell -a "cat /etc/haproxy/haproxy_errors.cfg >> /etc/haproxy/haproxy.cfg"
#ansible -i inventory/dynamic_inventory.py haproxy_hosts -m shell -a "systemctl reload haproxy"
