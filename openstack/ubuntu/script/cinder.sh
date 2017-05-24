apt-get -y install cinder-volume python-mysqldb crudini
crudini --set /etc/cinder/cinder.conf DEFAULT rootwrap_config /etc/cinder/rootwrap.conf
crudini --set /etc/cinder/cinder.conf DEFAULT api_paste_confg  /etc/cinder/api-paste.ini
crudini --set /etc/cinder/cinder.conf DEFAULT volume_name_template volume-%s
crudini --set /etc/cinder/cinder.conf DEFAULT volume_group cinder-volumes
crudini --set /etc/cinder/cinder.conf DEFAULT verbose True
crudini --set /etc/cinder/cinder.conf DEFAULT auth_strategy keystone
crudini --set /etc/cinder/cinder.conf DEFAULT state_path /var/lib/cinder
crudini --set /etc/cinder/cinder.conf DEFAULT lock_path /var/lock/cinder
crudini --set /etc/cinder/cinder.conf DEFAULT volumes_dir /var/lib/cinder/volumes
crudini --set /etc/cinder/cinder.conf DEFAULT rpc_backend rabbit
crudini --set /etc/cinder/cinder.conf DEFAULT my_ip 192.168.1.31
crudini --set /etc/cinder/cinder.conf DEFAULT enabled_backends glusterfs
crudini --set /etc/cinder/cinder.conf DEFAULT glance_api_servers http://controller:9292
crudini --set /etc/cinder/cinder.conf database connection mysql+pymysql://cinder:pass@controller/cinder
crudini --set /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_host controller
crudini --set /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_userid openstack
crudini --set /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_password pass
crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_uri http://controller:5000
crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_url http://controller:35357
crudini --set /etc/cinder/cinder.conf keystone_authtoken memcached_servers controller:11211
crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_type password
crudini --set /etc/cinder/cinder.conf keystone_authtoken project_domain_name default
crudini --set /etc/cinder/cinder.conf keystone_authtoken user_domain_name default
crudini --set /etc/cinder/cinder.conf keystone_authtoken project_name service
crudini --set /etc/cinder/cinder.conf keystone_authtoken username cinder
crudini --set /etc/cinder/cinder.conf keystone_authtoken password pass
crudini --set /etc/cinder/cinder.conf oslo_concurrency lock_path /var/lib/cinder/tmp
crudini --set /etc/cinder/cinder.conf glusterfs volume_driver cinder.volume.drivers.glusterfs.GlusterfsDriver
crudini --set /etc/cinder/cinder.conf glusterfs glusterfs_shares_config /etc/cinder/glusterfs_shares
crudini --set /etc/cinder/cinder.conf glusterfs glusterfs_mount_point_base /mnt

chmod 640 /etc/cinder/cinder.conf
chgrp cinder /etc/cinder/cinder.conf
service  cinder-volume restart
