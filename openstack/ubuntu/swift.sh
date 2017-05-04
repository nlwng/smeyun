#��װ�����ÿ������ڵ�
source admin-openrc
#���� swift �û���
openstack user create --domain default --password-prompt swift
#�� swift �û���� admin ��ɫ��
openstack role add --project service --user swift admin
#���� swift ������Ŀ��
openstack service create --name swift \
  --description "OpenStack Object Storage" object-store
#��������洢���� API �˵�
openstack endpoint create --region RegionOne \
  object-store public http://controller:8080/v1/AUTH_%\(tenant_id\)s
openstack endpoint create --region RegionOne \
  object-store internal http://controller:8080/v1/AUTH_%\(tenant_id\)s
openstack endpoint create --region RegionOne \
  object-store admin http://controller:8080/v1

apt-get install swift swift-proxy python-swiftclient \
  python-keystoneclient python-keystonemiddleware \
  memcached

#���� /etc/swift Ŀ¼��
mkdir -p /etc/swift
#�Ӷ���洢�Ĳֿ�Դ�л�ȡ�������������ļ���
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
#��װ�����ô洢�ڵ�
apt-get install xfsprogs rsync

mkfs.xfs /dev/sdb
mkfs.xfs /dev/sdc
mkfs.xfs /dev/sdd

#�������ص�Ŀ¼�ṹ��
mkdir -p /srv/node/sdb
mkdir -p /srv/node/sdc
mkdir -p /srv/node/sdd

#�༭``/etc/fstab``�ļ�������������ݣ�
/dev/sdb /srv/node/sdb xfs noatime,nodiratime,nobarrier,logbufs=8 0 2
/dev/sdc /srv/node/sdc xfs noatime,nodiratime,nobarrier,logbufs=8 0 2
/dev/sdd /srv/node/sdd xfs noatime,nodiratime,nobarrier,logbufs=8 0 2

#�����豸��
mount /srv/node/sdb
mount /srv/node/sdc
mount /srv/node/sdd

#�������༭``/etc/rsyncd.conf``�ļ��������������ݣ�
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

#�༭ ��/etc/default/rsync�� �ļ������� ��rsync�� ����
crudini --set /etc/default/rsync "" RSYNC_ENABLE true

#���� ��rsync�� ����
service rsync start
#�Ӷ���洢Դ�ֿ��л�ȡaccounting, container�Լ�object���������ļ�
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

#��``[pipeline:main]``���֣����ú��ʵ�ģ�飺
#pipeline = healthcheck recon account-server
crudini --set /etc/swift/account-server.conf pipeline:main pipeline "healthcheck recon account-server"


#��``[filter:recon]``���֣�����recon ��meters������Ŀ¼��
crudini --set /etc/swift/account-server.conf filter:recon use egg:swift#recon
crudini --set /etc/swift/account-server.conf filter:recon recon_cache_path /var/cache/swift

crudini --set /etc/swift/container-server.conf DEFAULT bind_ip 192.168.31.138
crudini --set /etc/swift/container-server.conf DEFAULT bind_port 6001
crudini --set /etc/swift/container-server.conf DEFAULT user swift
crudini --set /etc/swift/container-server.conf DEFAULT swift_dir /etc/swift
crudini --set /etc/swift/container-server.conf DEFAULT devices /srv/node
crudini --set /etc/swift/container-server.conf DEFAULT mount_check true

#��``[pipeline:main]``���֣����ú��ʵ�ģ�飺
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

#��``[filter:recon]``���֣�����recon��meters�������lockĿ¼��
crudini --set /etc/swift/object-server.conf filter:recon use egg:swift#recon
crudini --set /etc/swift/object-server.conf filter:recon recon_cache_path /var/cache/swift
crudini --set /etc/swift/object-server.conf filter:recon recon_lock_path /var/lock

#ȷ�Ϲ��ص�Ŀ¼�ṹ�Ƿ��к��ʵ�����Ȩ��
chown -R swift:swift /srv/node

#���� ��recon�� Ŀ¼��ȷ�����к��ʵ�����Ȩ��
mkdir -p /var/cache/swift
chown -R root:swift /var/cache/swift
chmod -R 775 /var/cache/swift

------------------------------------------------------------------
�����˻�ring
------------------------------------------------------------------
#�������ַ�����ʼ��rings
#�л��� ``/etc/swift``Ŀ¼��
#�������� account.builder �ļ���
swift-ring-builder account.builder create 10 3 1

#���ÿ���ڵ㵽 ring �У�
swift-ring-builder account.builder \
  add --region 1 --zone 1 --ip 192.168.31.138 --port 6002 \
  --device sdb --weight 100

swift-ring-builder account.builder \
  add --region 1 --zone 1 --ip 192.168.31.138 --port 6002 \
  --device sdc --weight 100

swift-ring-builder account.builder \
  add --region 1 --zone 1 --ip 192.168.31.138 --port 6002 \
  --device sdd --weight 100

#��֤ ring �����ݣ�
swift-ring-builder account.builder
#ƽ�� ring��
swift-ring-builder account.builder rebalance

------------------------------------------------------------------
#��������ring
------------------------------------------------------------------
#�л��� ``/etc/swift``Ŀ¼��
#��������``container.builder``�ļ���
swift-ring-builder container.builder create 10 3 1

#���ÿ���ڵ㵽 ring �У�
swift-ring-builder container.builder \
  add --region 1 --zone 1 --ip 192.168.31.138 --port 6001 \
  --device sdb --weight 100

swift-ring-builder container.builder \
  add --region 1 --zone 1 --ip 192.168.31.138 --port 6001 \
  --device sdc --weight 100

swift-ring-builder container.builder \
  add --region 1 --zone 1 --ip 192.168.31.138 --port 6001 \
  --device sdd --weight 100

#��֤ ring ������
swift-ring-builder container.builder

#ƽ�� ring��
swift-ring-builder container.builder rebalance

------------------------------------------------------------------
#��������ring
------------------------------------------------------------------
#�л��� ``/etc/swift``Ŀ¼��
#��������``object.builder``�ļ���
swift-ring-builder object.builder create 10 3 1

swift-ring-builder object.builder add \
  --region 1 --zone 1 --ip 192.168.31.138 --port 6000 --device sdb --weight 100

swift-ring-builder object.builder add \
  --region 1 --zone 1 --ip 192.168.31.138 --port 6000 --device sdc --weight 100

swift-ring-builder object.builder add \
  --region 1 --zone 1 --ip 192.168.31.138 --port 6000 --device sdd --weight 100

#��֤ ring �����ݣ�
swift-ring-builder object.builder
#ƽ�� ring��
swift-ring-builder object.builder rebalance

#�ַ��������ļ�
#����``account.ring.gz``��container.ring.gz``��``object.ring.gz �ļ���ÿ���洢�ڵ�����������˴������Ķ���ڵ��
#/etc/swift Ŀ¼���������ƽڵ�

#��ɰ�װ
#�Ӷ���洢Դ�ֿ��л�ȡ /etc/swift/swift.conf �ļ���
curl -o /etc/swift/swift.conf \
  https://git.openstack.org/cgit/openstack/swift/plain/etc/swift.conf-sample?h=stable/mitaka

#�༭ /etc/swift/swift.conf �ļ���������¶���
crudini --set /etc/swift/swift.conf swift-hash swift_hash_path_suffix pass
crudini --set /etc/swift/swift.conf swift-hash swift_hash_path_prefix pass

crudini --set /etc/swift/swift.conf storage-policy:0 name Policy-0
crudini --set /etc/swift/swift.conf storage-policy:0 default yes

#����``swift.conf`` �ļ���ÿ���洢�ڵ�����������˴������Ķ���ڵ�� /etc/swift Ŀ¼��
#�����нڵ��ϣ�ȷ�������ļ�Ŀ¼�Ƿ��к��ʵ�����Ȩ��
chown -R root:swift /etc/swift

#�ڿ��ƽڵ�����������˴������Ľڵ��ϣ���������洢��������������ķ���
service memcached restart
service swift-proxy restart

#�ڴ洢�ڵ�����������洢����
swift-init all start