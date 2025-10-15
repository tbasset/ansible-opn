#!/bin/bash

# create router for labz..

OS_PROJECT_NAME=test1 openstack router create TEST1-GW
OS_PROJECT_NAME=test1 openstack router add subnet TEST1-GW test1
OS_PROJECT_NAME=test1 openstack router set TEST1-GW --external-gateway c34a1b56-9cba-45f4-b013-74d031184623

OS_PROJECT_NAME=test2 openstack router create TEST2-GW
OS_PROJECT_NAME=test2 openstack router add subnet TEST2-GW test2
OS_PROJECT_NAME=test2 openstack router set TEST2-GW --external-gateway c34a1b56-9cba-45f4-b013-74d031184623

OS_PROJECT_NAME=test3 openstack router create TEST3-GW
OS_PROJECT_NAME=test3 openstack router add subnet TEST3-GW test3
OS_PROJECT_NAME=test3 openstack router set TEST3-GW --external-gateway c34a1b56-9cba-45f4-b013-74d031184623

OS_PROJECT_NAME=test4 openstack router create TEST4-GW
OS_PROJECT_NAME=test4 openstack router add subnet TEST4-GW test4
OS_PROJECT_NAME=test4 openstack router set TEST4-GW --external-gateway c34a1b56-9cba-45f4-b013-74d031184623

OS_PROJECT_NAME=test5 openstack router create TEST5-GW
OS_PROJECT_NAME=test5 openstack router add subnet TEST5-GW test5
OS_PROJECT_NAME=test5 openstack router set TEST5-GW --external-gateway c34a1b56-9cba-45f4-b013-74d031184623

OS_PROJECT_NAME=test6 openstack router create TEST6-GW
OS_PROJECT_NAME=test6 openstack router add subnet TEST6-GW test6
OS_PROJECT_NAME=test6 openstack router set TEST6-GW --external-gateway c34a1b56-9cba-45f4-b013-74d031184623

OS_PROJECT_NAME=test7 openstack router create TEST7-GW
OS_PROJECT_NAME=test7 openstack router add subnet TEST7-GW test7
OS_PROJECT_NAME=test7 openstack router set TEST7-GW --external-gateway c34a1b56-9cba-45f4-b013-74d031184623

OS_PROJECT_NAME=test8 openstack router create TEST8-GW
OS_PROJECT_NAME=test8 openstack router add subnet TEST8-GW test8
OS_PROJECT_NAME=test8 openstack router set TEST8-GW --external-gateway c34a1b56-9cba-45f4-b013-74d031184623
