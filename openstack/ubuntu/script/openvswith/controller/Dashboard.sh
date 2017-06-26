#------------------------------------------------------------------

#安装软件包：
apt-get install openstack-dashboard -y

sed -i s/"OPENSTACK_HOST = \"127.0.0.1\""/"OPENSTACK_HOST = \"controller\""/g /etc/openstack-dashboard/local_settings.py

sed -i s/"A/ '\*'"/"ALLOWED_HOSTS = ['\*',]"/g /etc/openstack-dashboard/local_settings.py

sed -in "129a SESSION_ENGINE = 'django.contrib.sessions.backends.cache'" /etc/openstack-dashboard/local_settings.py

sed -i s/"'LOCATION': '127.0.0.1:11211'"/"'LOCATION': 'controller:11211'"/g /etc/openstack-dashboard/local_settings.py

sed -in "62a OPENSTACK_API_VERSIONS = { \n\"identity\": 3, \n\"volume\": 2, \n\"compute\": 2, \n}" /etc/openstack-dashboard/local_settings.py

sed -i s/"%s:5000\/v2.0"/"%s:5000\/v3"/g /etc/openstack-dashboard/local_settings.py

sed -i s/"_member_"/"user"/g /etc/openstack-dashboard/local_settings.py

OPENSTACK_KEYSTONE_DEFAULT_ROLE = "_member_"

sed -i s/"TIME_ZONE = \"UTC\""/"TIME_ZONE = \"Asia\/Shanghai\""/g /etc/openstack-dashboard/local_settings.py


#配置openstackUI模板
apt-get remove --purge openstack-dashboard-ubuntu-theme -y
/usr/share/openstack-dashboard/manage.py collectstatic
/usr/share/openstack-dashboard/manage.py compress

#重新加载 web 服务器配置：
service apache2 reload
