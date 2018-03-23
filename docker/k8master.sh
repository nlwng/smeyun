yum install crudini -y
yum install epel-release
yum install docker
yum install -y kubernetes etcd flannel

master_host="192.168.234.44"


#docker
##/etc/sysconfig/docker
crudini --set  /etc/sysconfig/docker '' ADD_REGISTRY "'--insecure-registry ${master_host}'"

#kubernetes 
##/etc/kubernetes/apiserver
crudini --set  /etc/kubernetes/apiserver '' KUBE_API_ADDRESS '"--insecure-bind-address=0.0.0.0"'
crudini --set  /etc/kubernetes/apiserver '' KUBE_API_PORT '"--port=8080"'
crudini --set  /etc/kubernetes/apiserver '' KUBELET_PORT '"--kubelet-port=10250"'
crudini --set  /etc/kubernetes/apiserver '' KUBE_ETCD_SERVERS '"--etcd-servers=http://'${master_host}':2379"'
crudini --set  /etc/kubernetes/apiserver '' KUBE_SERVICE_ADDRESSES '"--service-cluster-ip-range=10.254.0.0/16"'
crudini --set  /etc/kubernetes/apiserver '' KUBE_ADMISSION_CONTROL '"--admission-control=NamespaceLifecycle,NamespaceExists,LimitRanger,SecurityContextDeny,ResourceQuota"'
crudini --set  /etc/kubernetes/apiserver '' KUBE_API_ARGS '""'

##/etc/kubernetes/config
crudini --set  /etc/kubernetes/config '' KUBE_LOGTOSTDERR '"--logtostderr=true"'
crudini --set  /etc/kubernetes/config '' KUBE_LOG_LEVEL '"--v=0"'
crudini --set  /etc/kubernetes/config '' KUBE_ALLOW_PRIV '"--allow-privileged=false"'
crudini --set  /etc/kubernetes/config '' KUBE_MASTER '"--master=http://master:8080"'

##/etc/kubernetes/kubelet
crudini --set  /etc/kubernetes/kubelet '' KUBELET_ADDRESS '"--address=0.0.0.0"'
crudini --set  /etc/kubernetes/kubelet '' KUBELET_HOSTNAME '"--hostname-override=master"'
crudini --set  /etc/kubernetes/kubelet '' KUBELET_API_SERVER '"--api-servers=http://'${master_host}':8080"'
crudini --set  /etc/kubernetes/kubelet '' KUBELET_POD_INFRA_CONTAINER '"--pod-infra-container-image='${master_host}'/library/pause-amd643:latest"'

#/etc/etcd/etcd.conf
crudini --set  /etc/etcd/etcd.conf '' ETCD_LISTEN_CLIENT_URLS '"http://'${master_host}':2379,http://127.0.0.1:2379"'
crudini --set  /etc/etcd/etcd.conf '' ETCD_ADVERTISE_CLIENT_URLS '"http://'${master_host}':2379,http://127.0.0.1:2379"'


service etcd start
etcdctl mkdir /kube-centos/network
etcdctl mk /kube-centos/network/config "{ \"Network\": \"172.30.0.0/16\", \"SubnetLen\": 24, \"Backend\": { \"Type\": \"vxlan\" } }"

etcdctl ls

#/etc/sysconfig/flanneld
crudini --set  /etc/sysconfig/flanneld FLANNEL_ETCD_ENDPOINTS '"http://master:2379"'
crudini --set  /etc/sysconfig/flanneld FLANNEL_ETCD_KEY '"/kube-centos/network"'
crudini --set  /etc/sysconfig/flanneld FLANNEL_OPTIONS '""'
 


for SERVICES in etcd kube-apiserver kube-controller-manager kube-scheduler flanneld; do
    systemctl restart $SERVICES
    systemctl enable $SERVICES
    systemctl status $SERVICES
done
