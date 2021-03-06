#!/bin/bash -xe

echo 'Starting neutron'

COMMAND="${@:-start}"


function bootstrap() {
    export PATH=$PATH:/opt/neutron/bin
    source /mnt/openstack/etc/resolvrc
    cp /mnt/neutron/etc/neutron.conf /etc/neutron/
    cp /mnt/neutron/etc/ml2_conf.ini /etc/neutron/
    cp /mnt/neutron/etc/linuxbridge_agent.ini /etc/neutron/

    transport_url=`kubectl get cm rabbitmq-svc-common -o jsonpath='{.data.transport_url}'`
    sed -i "s/@transport_url/$transport_url/g" /etc/neutron/neutron.conf
}


function start() {
    bootstrap
    /opt/neutron/bin/neutron-server \
        --config-file /etc/neutron/neutron.conf \
        --config-file /etc/neutron/ml2_conf.ini
}


function start_linuxbridge_agent() {
    bootstrap
    yum -y install iproute ebtables bridge-utils
    /opt/neutron/bin/neutron-linuxbridge-agent \
        --config-file /etc/neutron/neutron.conf \
        --config-file /etc/neutron/ml2_conf.ini \
        --config-file /etc/neutron/linuxbridge_agent.ini
}


function liveness() {
    echo "liveness"
}


function readiness() {
    echo "readiness"
}


$COMMAND
