#!/bin/bash

cd /root/openstack-ansible

./scripts/bootstrap-ansible.sh
ansible-playbook /root/ansible-opn/playbook/galera_recovery.yml
time ansible-playbook playbooks/setup-hosts.yml
time ansible-playbook playbooks/setup-infrastructure.yml
time ansible-playbook playbooks/setup-openstack.yml && time /etc/openstack_deploy/tune.sh
