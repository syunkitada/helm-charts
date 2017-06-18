# openstack-helm

## Require

### mysql
https://github.com/kubernetes/charts/tree/master/stable/mariadb
```
helm install stable/mariadb --name openstack-db --set persistence.enabled=false,mariadbRootPassword=rootpass

# How to access db
$ kubectl run torpid-bat-mariadb-client --rm --tty -i --image bitnami/mariadb --command -- bash
# mysql -h openstack-db-mariadb
```

### rabbitmq
https://github.com/kubernetes/charts/tree/master/stable/rabbitmq
```
helm install stable/rabbitmq --name openstack-rpc --set persistence.enabled=false,rabbitmqUsername=openstack,rabbitmqPassword=openstackpass

echo URL : http://127.0.0.1:15672
kubectl port-forward $POD_NAME 15672:15672

```

### memcached
https://github.com/kubernetes/charts/tree/master/stable/memcached
```
helm install stable/memcached --name openstack-cache --set replicaCount=1,memcached.maxItemMemory=512
```


## Deploy openstack
``` deploy openstack-common
helm install --name ingress ingress
helm install --name openstack openstack
helm install --name keystone keystone
helm install --name glance glance
helm install --name neutron neutron
helm install --name nova nova
helm install --name horizon horizon
```


# Design

* 各ノードを役割に応じて抽象化しラベルを振る
  * controller, compute, net-node, block-storage, object-storage, database
* controller
  * ステートレスなコンピュート群
  * ingress, service, deploymentリソースによりAPIを構成するノード群
  * 重要でないデータを保存するmemcached, rabbitmqもここにデプロイする
  * chartごとにcontrollerプロセスを用意し、charのステータスを監視し正常性をコントロールする
* compute, net-node, block-storage, object-storage, database
  * ステートフルなノード軍
  * hostnet: true
  * 場合によりcontrackを無効にし、kubeのネットワークにも乗せない
  * daemonsetによってcontrollerプロセスを配備し、controllerコンテナないから親ホストの/(ルート)を/hostにマウントする
  * /host/opt/配下にvirtualenv、/host/etc/に設定ファイル、/lib/systemd/system/にサービスファイルをコピーする
  * /hostにchrootし、systemdでサービスを起動する
    * このため、サービスプロセスはkube管轄外となる
  * controllerプロセスでステータスを監視し正常性をコントロールする
