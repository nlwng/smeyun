#install vnc
apt-get install x11vnc

#set passwd
x11vnc -storepasswd

#start server
x11vnc -auth guess -once -loop -noxdamage -repeat -rfbauth /root/.vnc/passwd -rfbport 5900 -shared

#设置开机启动
vim /lib/systemd/system/x11vnc.service
[Unit]
Description=Start x11vnc at startup.
After=multi-user.target

[Service]
Type=simple
ExecStart=/usr/bin/x11vnc -auth guess -once -loop -noxdamage -repeat -rfbauth /root/.vnc/passwd -rfbport 5900 -shared

[Install]
WantedBy=multi-user.target

sudo systemctl daemon-reload
sudo systemctl enable x11vnc.service