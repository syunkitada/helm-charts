#!/bin/bash -xe

/opt/neutron/bin/neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/ml2_conf.ini upgrade head


source /etc/openstack/adminrc

openstack network show local-net \
  || openstack network create local-net
openstack subnet show local-subnet \
  || openstack subnet create local-subnet --network local-net --subnet-range 192.168.100.0/24
