apt-get -y remove --purge openstack-dashboard-ubuntu-theme
-----------------------------
安裝 LBaaSv2
-----------------------------

#LBaaSv2 Controller 節點安裝

apt-get install python-neutron-lbaas haproxy neutron-lbaasv2-agent -y

#/etc/neutron/neutron.conf文件中使用service_provider 属性，来启用HAProxy 插件：
crudini --set /etc/neutron/neutron.conf DEFAULT service_plugins router,neutron_lbaas.services.loadbalancer.plugin.LoadBalancerPluginv2
crudini --set /etc/neutron/neutron.conf service_providers service_provider LOADBALANCERV2:Haproxy:neutron_lbaas.drivers.haproxy.plugin_driver.HaproxyOnHostPluginDriver:default
crudini --set /etc/neutron/lbaas_agent.ini DEFAULT interface_driver linuxbridge

#crudini --set /etc/neutron/services_lbaas.conf service_providers service_provider LOADBALANCERV2:Haproxy:neutron_lbaas.drivers.haproxy.plugin_driver.HaproxyOnHostPluginDriver:default

#Update neutron DB
neutron-db-manage --subproject neutron-lbaas upgrade head
service neutron-server restart
service neutron-lbaasv2-agent restart

for i in {neutron-server,neutron-lbaasv2-agent};do service $i restart;done

apt-get install git
git clone https://git.openstack.org/openstack/neutron-lbaas-dashboard
cd neutron-lbaas-dashboard
git checkout stable/mitaka

python setup.py install
cp neutron_lbaas_dashboard/enabled/_1481_project_ng_loadbalancersv2_panel.py /usr/share/openstack-dashboard/openstack_dashboard/local/enabled/

#初始页面
cd /usr/share/openstack-dashboard
./manage.py collectstatic
./manage.py compress

#LBaaSv2 Network 節點安裝

#apt-get install neutron-lbaasv2-agent -y

#crudini --set /etc/neutron/lbaas_agent.ini DEAULT device_driver neutron_lbaas.drivers.haproxy.namespace_driver.HaproxyNSDriverF
#crudini --set /etc/neutron/lbaas_agent.ini DEFAULT interface_driver neutron.agent.linux.interface.BridgeInterfaceDriver
#crudini --set /etc/neutron/lbaas_agent.ini haproxy user_group haproxy
#crudini --set /etc/neutron/neutron_lbaas.conf service_providers service_provider LOADBALANCERV2:Haproxy:neutron_lbaas.drivers.haproxy.plugin_driver.HaproxyOnHostPluginDriver:default

#crudini --set /etc/neutron/lbaas_agent.ini DEFAULT interface_driver neutron.agent.linux.interface.OVSInterfaceDriver
#crudini --set /etc/neutron/lbaas_agent.ini DEFAULT interface_driver neutron.agent.linux.interface.BridgeInterfaceDriver

#service neutron-lbaasv2-agent restart

#apt-get install git
#git clone https://git.openstack.org/openstack/neutron-lbaas-dashboard
#cd neutron-lbaas-dashboard
#git checkout stable/mitaka

#python setup.py install
#cp neutron_lbaas_dashboard/enabled/_1481_project_ng_loadbalancersv2_panel.py /usr/share/openstack-dashboard/openstack_dashboard/local/enabled/
#
##初始页面
#cd /usr/share/openstack-dashboard
#python manage.py collectstatic
#python manage.py compress

apt-get install neutron-lbaas-dashboard
#最後檢查 Dashboard 的檔案local_settings.py，是否有開啟 UI：
OPENSTACK_NEUTRON_NETWORK = {
    'enable_lb': True,
    ...
}

service apache2 restart

-----------------------------------------------------------
yum install haproxy openstack-neutron-lbaas 

crudini --set /etc/neutron/neutron.conf DEFAULT service_plugins router,neutron_lbaas.services.loadbalancer.plugin.LoadBalancerPluginv2
crudini --set /etc/neutron/neutron.conf service_providers service_provider LOADBALANCERV2:Haproxy:neutron_lbaas.drivers.haproxy.plugin_driver.HaproxyOnHostPluginDriver:default
crudini --set /etc/neutron/lbaas_agent.ini DEFAULT interface_driver linuxbridge
crudini --set /etc/neutron/lbaas_agent.ini DEFAULT device_driver neutron_lbaas.services.loadbalancer.drivers.haproxy.namespace_driver.HaproxyNSDriver

crudini --set /etc/neutron/neutron_lbaas.conf service_providers service_provider LOADBALANCERV2:Haproxy:neutron_lbaas.drivers.haproxy.plugin_driver.HaproxyOnHostPluginDriver:default

systemctl restart neutron-server
systemctl enable neutron-lbaasv2-agent.service
systemctl restart neutron-lbaasv2-agent.service

systemctl restart httpd.service
-----------------------------------------------------------
neutron lbaas-loadbalancer-create --name test-lb provider
neutron lbaas-loadbalancer-show test-lb

neutron security-group-create lbaas
neutron security-group-rule-create \
  --direction ingress \
  --protocol tcp \
  --port-range-min 80 \
  --port-range-max 80 \
  --remote-ip-prefix 0.0.0.0/0 \
  lbaas
neutron security-group-rule-create \
  --direction ingress \
  --protocol tcp \
  --port-range-min 443 \
  --port-range-max 443 \
  --remote-ip-prefix 0.0.0.0/0 \
  lbaas
neutron security-group-rule-create \
  --direction ingress \
  --protocol icmp \
  lbaas
neutron port-update \
  --security-group lbaas \
  d12e4004-1dba-4bf7-9069-fdbab94d65f6

neutron lbaas-listener-create \
  --name test-lb-http \
  --loadbalancer test-lb \
  --protocol HTTP \
  --protocol-port 80

neutron lbaas-pool-create \
  --name test-lb-pool-http \
  --lb-algorithm ROUND_ROBIN \
  --listener test-lb-http \
  --protocol HTTP
neutron lbaas-member-create \
  --subnet provider \
  --address 192.168.2.12 \
  --protocol-port 80 \
  test-lb-pool-http
neutron lbaas-member-create \
  --subnet provider \
  --address 192.168.2.13 \
  --protocol-port 80 \
  test-lb-pool-http

----------------------------------------------------------------------
#[DEFAULT]
#service_provider = LOADBALANCER:Haproxy:neutron_lbaas.services.loadbalancer.drivers.haproxy.plugin_driver.HaproxyOnHostPluginDriver:default
#service_plugins = lbaas,router  

#/etc/neutron/neutron.conf文件中通过使用 service_plugins属性来启用负载均衡插件：
service_plugins = router,neutron_lbaas.services.loadbalancer.plugin.LoadBalancerPluginv2
service_provider = LOADBALANCERV2:Haproxy:neutron_lbaas.drivers.haproxy.plugin_driver.HaproxyOnHostPluginDriver:default

#在/etc/neutron/lbaas_agent.ini文件中启用HAProxy负载均衡器：
[DEFAULT]
device_driver = neutron_lbaas.services.loadbalancer.drivers.haproxy.namespace_driver.HaproxyNSDriver
interface_driver = neutron.agent.linux.interface.OVSInterfaceDriver 

[haproxy]  
user_group = haproxy 

#在文件/etc/neutron/lbaas_agent.ini中选择所需要的驱动：激活Open vSwitch 负载均衡即服务驱动:
interface_driver = neutron.agent.linux.interface.OVSInterfaceDriver
#或者，激活Linux网桥负载均衡即服务驱动:
interface_driver = neutron.agent.linux.interface.BridgeInterfaceDriver

#在数据库中创建所要求的表：
neutron-db-manage --subproject neutron-lbaas upgrade head

#重启neutron-server 和 neutron-lbaas-agent服务以使设置生效。
#在面板的项目 选项卡下启用负载均衡。
service neutron-lbaas-agent  restart;service neutron-server  restart


neutron-lbaasv2-agent --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/lbaas_agent.ini

在local_settings文件中修改enable_lb 的属性为True (发行版 Fedora, RHEL,和 
CentOS: /etc/openstack-dashboard/local_settings, 
发行版 Ubuntu 和 Debian: /etc/openstack-dashboard/local_settings.py, 
以及发型版 openSUSE 和 SLES: /srv/www/openstack-dashboard/openstack_dashboard/local/local_settings.py):

Select Text

OPENSTACK_NEUTRON_NETWORK = {
    'enable_lb': True,
    ...
}
重启web服务器以使设置生效。此时可以在图形面板中的项目中看到负载均衡器的管理项了。

service apache2 reload

