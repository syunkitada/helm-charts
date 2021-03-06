#!/bin/bash -xe

source /mnt/openstack/etc/adminrc

(\
    helm get openstack-nova && \
    helm upgrade openstack-nova {{ .Values.chart_prefix }}/nova \
        --namespace {{ .Release.Namespace }} -f /mnt/openstack/etc/values.yaml \
) || (\
    helm install -n openstack-nova {{ .Values.chart_prefix }}/nova \
        --namespace {{ .Release.Namespace }} -f /mnt/openstack/etc/values.yaml \
)

kubectl get cm nova-etc -o jsonpath='{.data.nova\.conf}' > /etc/nova/nova.conf
transport_url=`kubectl get cm rabbitmq-svc-common -o jsonpath='{.data.transport_url}'`
sed -i "s/@transport_url/$transport_url/g" /etc/nova/nova.conf

/opt/nova/bin/nova-manage api_db sync

/opt/nova/bin/nova-manage cell_v2 list_cells | grep cell0 || /opt/nova/bin/nova-manage cell_v2 map_cell0
/opt/nova/bin/nova-manage cell_v2 list_cells | grep cell1 || /opt/nova/bin/nova-manage cell_v2 create_cell --name=cell1 --verbose
/opt/nova/bin/nova-manage db sync


openstack flavor show 1v-512M-4G \
  || openstack flavor create --vcpus 1 --ram 512 --disk 4 --public 1v-512M-4G
