#安装并配置控制器节点
source admin-openrc
#创建 swift 用户：
openstack user create --domain default --password-prompt swift
#给 swift 用户添加 admin 角色：
openstack role add --project service --user swift admin
#创建 swift 服务条目：
openstack service create --name swift \
  --description "OpenStack Object Storage" object-store
#创建对象存储服务 API 端点
openstack endpoint create --region RegionOne \
  object-store public http://controller:8080/v1/AUTH_%\(tenant_id\)s
openstack endpoint create --region RegionOne \
  object-store internal http://controller:8080/v1/AUTH_%\(tenant_id\)s
openstack endpoint create --region RegionOne \
  object-store admin http://controller:8080/v1

apt-get install swift swift-proxy python-swiftclient \
  python-keystoneclient python-keystonemiddleware \
  memcached

#创建 /etc/swift 目录。
mkdir -p /etc/swift
#从对象存储的仓库源中获取代理服务的配置文件：
curl -o /etc/swift/proxy-server.conf https://git.openstack.org/cgit/openstack/swift/plain/etc/proxy-server.conf-sample?h=stable/mitaka

#/etc/swift/proxy-server.conf 
crudini --set  /etc/swift/proxy-server.conf DEFAULT bind_port 8080
crudini --set  /etc/swift/proxy-server.conf DEFAULT user swift
crudini --set  /etc/swift/proxy-server.conf DEFAULT swift_dir /etc/swift
crudini --set  /etc/swift/proxy-server.conf pipeline:main pipeline "catch_errors gatekeeper healthcheck proxy-logging cache container_sync bulk ratelimit authtoken keystoneauth container-quotas account-quotas slo dlo versioned_writes proxy-logging proxy-server"

crudini --set  /etc/swift/proxy-server.conf app:proxy-server use egg:swift#proxy
crudini --set  /etc/swift/proxy-server.conf app:proxy-server account_autocreate true

crudini --set  /etc/swift/proxy-server.conf filter:keystoneauth use egg:swift#keystoneauth
crudini --set  /etc/swift/proxy-server.conf filter:keystoneauth operator_roles admin,user
crudini --set  /etc/swift/proxy-server.conf filter:authtoken paste.filter_factory keystonemiddleware.auth_token:filter_factory
crudini --set  /etc/swift/proxy-server.conf filter:authtoken auth_uri http://controller:5000
crudini --set  /etc/swift/proxy-server.conf filter:authtoken auth_url http://controller:35357
crudini --set  /etc/swift/proxy-server.conf filter:authtoken memcached_servers controller:11211
crudini --set  /etc/swift/proxy-server.conf filter:authtoken auth_type password
crudini --set  /etc/swift/proxy-server.conf filter:authtoken project_domain_name default
crudini --set  /etc/swift/proxy-server.conf filter:authtoken user_domain_name default
crudini --set  /etc/swift/proxy-server.conf filter:authtoken project_name service
crudini --set  /etc/swift/proxy-server.conf filter:authtoken username swift
crudini --set  /etc/swift/proxy-server.conf filter:authtoken password pass
crudini --set  /etc/swift/proxy-server.conf filter:authtoken delay_auth_decision true


crudini --set  /etc/swift/proxy-server.conf filter:cache use egg:swift#memcache
crudini --set  /etc/swift/proxy-server.conf filter:cache memcache_servers controller:11211


-------------------------------------------------------------------------------------------
#安装和配置存储节点
apt-get install xfsprogs rsync

mkfs.xfs /dev/sdb
mkfs.xfs /dev/sdc
mkfs.xfs /dev/sdd

#创建挂载点目录结构：
mkdir -p /srv/node/sdb
mkdir -p /srv/node/sdc
mkdir -p /srv/node/sdd

#编辑``/etc/fstab``文件并添加以下内容：
/dev/sdb /srv/node/sdb xfs noatime,nodiratime,nobarrier,logbufs=8 0 2
/dev/sdc /srv/node/sdc xfs noatime,nodiratime,nobarrier,logbufs=8 0 2
/dev/sdd /srv/node/sdd xfs noatime,nodiratime,nobarrier,logbufs=8 0 2

#挂载设备：
mount /srv/node/sdb
mount /srv/node/sdc
mount /srv/node/sdd

#创建并编辑``/etc/rsyncd.conf``文件并包含以下内容：
crudini --set /etc/rsyncd.conf '' uid swift
crudini --set /etc/rsyncd.conf '' gid swift
crudini --set /etc/rsyncd.conf '' "log file" /var/log/rsyncd.log
crudini --set /etc/rsyncd.conf '' "pid file" /var/run/rsyncd.pid
crudini --set /etc/rsyncd.conf '' address 192.168.31.138
crudini --set /etc/rsyncd.conf account "max connections" 2
crudini --set /etc/rsyncd.conf account path /srv/node/
crudini --set /etc/rsyncd.conf account "read only" False
crudini --set /etc/rsyncd.conf account "lock file" /var/lock/account.lock
crudini --set /etc/rsyncd.conf container "max connections" 2
crudini --set /etc/rsyncd.conf container path /srv/node/
crudini --set /etc/rsyncd.conf container "read only" False
crudini --set /etc/rsyncd.conf container "lock file" /var/lock/container.lock
crudini --set /etc/rsyncd.conf object "max connections" 2
crudini --set /etc/rsyncd.conf object path /srv/node/
crudini --set /etc/rsyncd.conf object "read only" False
crudini --set /etc/rsyncd.conf object "lock file" /var/lock/object.lock

#编辑 “/etc/default/rsync” 文件和启用 “rsync” 服务：
crudini --set /etc/default/rsync "" RSYNC_ENABLE true

#启动 “rsync” 服务
service rsync start
#从对象存储源仓库中获取accounting, container以及object服务配置文件
apt-get -qy install swift swift-account swift-container swift-object
curl -o /etc/swift/account-server.conf https://git.openstack.org/cgit/openstack/swift/plain/etc/account-server.conf-sample?h=stable/mitaka
curl -o /etc/swift/container-server.conf https://git.openstack.org/cgit/openstack/swift/plain/etc/container-server.conf-sample?h=stable/mitaka
curl -o /etc/swift/object-server.conf https://git.openstack.org/cgit/openstack/swift/plain/etc/object-server.conf-sample?h=stable/mitaka

crudini --set /etc/swift/account-server.conf DEFAULT bind_ip 192.168.31.138
crudini --set /etc/swift/account-server.conf DEFAULT bind_port 6002
crudini --set /etc/swift/account-server.conf DEFAULT user swift 
crudini --set /etc/swift/account-server.conf DEFAULT swift_dir /etc/swift
crudini --set /etc/swift/account-server.conf DEFAULT devices /srv/node
crudini --set /etc/swift/account-server.conf DEFAULT mount_check true

#在``[pipeline:main]``部分，启用合适的模块：
#pipeline = healthcheck recon account-server
crudini --set /etc/swift/account-server.conf pipeline:main pipeline "healthcheck recon account-server"


#在``[filter:recon]``部分，配置recon （meters）缓存目录：
crudini --set /etc/swift/account-server.conf filter:recon use egg:swift#recon
crudini --set /etc/swift/account-server.conf filter:recon recon_cache_path /var/cache/swift

crudini --set /etc/swift/container-server.conf DEFAULT bind_ip 192.168.31.138
crudini --set /etc/swift/container-server.conf DEFAULT bind_port 6001
crudini --set /etc/swift/container-server.conf DEFAULT user swift
crudini --set /etc/swift/container-server.conf DEFAULT swift_dir /etc/swift
crudini --set /etc/swift/container-server.conf DEFAULT devices /srv/node
crudini --set /etc/swift/container-server.conf DEFAULT mount_check true

#在``[pipeline:main]``部分，启用合适的模块：
#[pipeline:main]
#pipeline = healthcheck recon container-server
crudini --set /etc/swift/container-server.conf pipeline:main pipeline "healthcheck recon container-server"

crudini --set /etc/swift/container-server.conf filter:recon use egg:swift#recon
crudini --set /etc/swift/container-server.conf filter:recon recon_cache_path /var/cache/swift

crudini --set /etc/swift/object-server.conf DEFAULT bind_ip 192.168.31.138
crudini --set /etc/swift/object-server.conf DEFAULT bind_port 6000
crudini --set /etc/swift/object-server.conf DEFAULT user swift
crudini --set /etc/swift/object-server.conf DEFAULT swift_dir /etc/swift
crudini --set /etc/swift/object-server.conf DEFAULT devices /srv/node
crudini --set /etc/swift/object-server.conf DEFAULT mount_check true
crudini --set /etc/swift/object-server.conf pipeline:main pipeline "healthcheck recon object-server"

#在``[filter:recon]``部分，配置recon（meters）缓存和lock目录：
crudini --set /etc/swift/object-server.conf filter:recon use egg:swift#recon
crudini --set /etc/swift/object-server.conf filter:recon recon_cache_path /var/cache/swift
crudini --set /etc/swift/object-server.conf filter:recon recon_lock_path /var/lock

#确认挂载点目录结构是否有合适的所有权：
chown -R swift:swift /srv/node

#创建 “recon” 目录和确保它有合适的所有权：
mkdir -p /var/cache/swift
chown -R root:swift /var/cache/swift
chmod -R 775 /var/cache/swift

------------------------------------------------------------------
创建账户ring
------------------------------------------------------------------
#创建，分发并初始化rings
#切换到 ``/etc/swift``目录。
#创建基本 account.builder 文件：
swift-ring-builder account.builder create 10 3 1

#添加每个节点到 ring 中：
swift-ring-builder account.builder \
  add --region 1 --zone 1 --ip 192.168.31.138 --port 6002 \
  --device sdb --weight 100

swift-ring-builder account.builder \
  add --region 1 --zone 1 --ip 192.168.31.138 --port 6002 \
  --device sdc --weight 100

swift-ring-builder account.builder \
  add --region 1 --zone 1 --ip 192.168.31.138 --port 6002 \
  --device sdd --weight 100

#验证 ring 的内容：
swift-ring-builder account.builder
#平衡 ring：
swift-ring-builder account.builder rebalance

------------------------------------------------------------------
#创建容器ring
------------------------------------------------------------------
#切换到 ``/etc/swift``目录。
#创建基本``container.builder``文件：
swift-ring-builder container.builder create 10 3 1

#添加每个节点到 ring 中：
swift-ring-builder container.builder \
  add --region 1 --zone 1 --ip 192.168.31.138 --port 6001 \
  --device sdb --weight 100

swift-ring-builder container.builder \
  add --region 1 --zone 1 --ip 192.168.31.138 --port 6001 \
  --device sdc --weight 100

swift-ring-builder container.builder \
  add --region 1 --zone 1 --ip 192.168.31.138 --port 6001 \
  --device sdd --weight 100

#验证 ring 的内容
swift-ring-builder container.builder

#平衡 ring：
swift-ring-builder container.builder rebalance

------------------------------------------------------------------
#创建对象ring
------------------------------------------------------------------
#切换到 ``/etc/swift``目录。
#创建基本``object.builder``文件：
swift-ring-builder object.builder create 10 3 1

swift-ring-builder object.builder add \
  --region 1 --zone 1 --ip 192.168.31.138 --port 6000 --device sdb --weight 100

swift-ring-builder object.builder add \
  --region 1 --zone 1 --ip 192.168.31.138 --port 6000 --device sdc --weight 100

swift-ring-builder object.builder add \
  --region 1 --zone 1 --ip 192.168.31.138 --port 6000 --device sdd --weight 100

#验证 ring 的内容：
swift-ring-builder object.builder
#平衡 ring：
swift-ring-builder object.builder rebalance

#分发环配置文件
#复制``account.ring.gz``，container.ring.gz``和``object.ring.gz 文件到每个存储节点和其他运行了代理服务的额外节点的
#/etc/swift 目录。包括控制节点

#完成安装
#从对象存储源仓库中获取 /etc/swift/swift.conf 文件：
curl -o /etc/swift/swift.conf \
  https://git.openstack.org/cgit/openstack/swift/plain/etc/swift.conf-sample?h=stable/mitaka

#编辑 /etc/swift/swift.conf 文件并完成以下动作
crudini --set /etc/swift/swift.conf swift-hash swift_hash_path_suffix pass
crudini --set /etc/swift/swift.conf swift-hash swift_hash_path_prefix pass

crudini --set /etc/swift/swift.conf storage-policy:0 name Policy-0
crudini --set /etc/swift/swift.conf storage-policy:0 default yes

#复制``swift.conf`` 文件到每个存储节点和其他允许了代理服务的额外节点的 /etc/swift 目录。
#在所有节点上，确认配置文件目录是否有合适的所有权：
chown -R root:swift /etc/swift

#在控制节点和其他运行了代理服务的节点上，重启对象存储代理服务及其依赖的服务：
service memcached restart
service swift-proxy restart

#在存储节点上启动对象存储服务：
swift-init all start