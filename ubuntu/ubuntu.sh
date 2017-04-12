
#monaco-font install
curl -kL https://raw.github.com/cstrap/monaco-font/master/install-font-ubuntu.sh | bash


#sublime 左侧目录与背景同步插件
SyncedSidebarBg 

#安装ubuntu优化
sudo apt-get remove unity-webapps-common  
sudo apt-get remove libreoffice-common 
sudo apt-get remove thunderbird totem rhythmbox empathy brasero simple-scan gnome-mahjongg aisleriot gnome-mines cheese transmission-common gnome-orca webbrowser-app gnome-sudoku  landscape-client-ui-install

sudo apt-get remove thunderbird（邮箱）
 sudo apt-get remove  totem （视频播放器）
 sudo apt-get remove rhythmbox（音乐播放器）
 sudo apt-get remove empathy 
 sudo apt-get remove brasero
 sudo apt-get remove simple-scan
 sudo apt-get remove gnome-mahjongg 
 sudo apt-get remove aisleriot 
 sudo apt-get remove gnome-mines 
 sudo apt-get remove transmission-common 
 sudo apt-get remove gnome-orca 
 sudo apt-get remove webbrowser-app 
 sudo apt-get remove gnome-sudoku 


sudo apt-get remove onboard deja-dup 
sudo apt-get install vim git

#install sublime
sudo add-apt-repository ppa:webupd8team/sublime-text-3    
sudo apt-get update    
sudo apt-get install sublime-text  

#安装经典菜单指示器
sudo add-apt-repository ppa:diesch/testing  
sudo apt-get update  
sudo apt-get install classicmenu-indicator 


#安装系统指示器SysPeek
sudo add-apt-repository ppa:nilarimogard/webupd8    
sudo apt-get update    
sudo apt-get install syspeek 

#nav工具是在终端界面看日志的神器
sudo apt-get install lnav 

#安装unrar
sudo apt-get install unrar 


#关闭自动更新
vi /etc/apt/apt.conf.d/50unattended-upgrades
vi /etc/apt/apt.conf.d/10periodic
vi /etc/apt/apt.conf.d/20auto-upgrades


sudo apt-get install pidgin
sudo apt-get install pidgin-plugin-pack



#输入法出现2个图标
sudo dpkg -l|grep qimpanel
sudo dpkg -P 上面查出来的结果


#安装monaco
curl -kL https://raw.github.com/cstrap/monaco-font/master/install-font-ubuntu.sh | bash

#安装mac皮肤
sudo add-apt-repository ppa:noobslab/macbuntu
sudo apt-get install  macbuntu-os-ithemes-lts-v7
sudo apt-get install  macbuntu-os-icons-lts-v7 
sudo apt-get install macbuntu-os-plank-theme-lts-v7
sudo apt-get install unity-tweak-tool 
unity-tweak-tool 中设皮肤、图标
点击左上角的dash菜单搜索“plank”，并打开

sudo apt-get install gnome-tweak-tool

3、安装 Slingscold（替代Launchpad）

sudo add-apt-repository ppa:noobslab/macbuntu
sudo apt-get update
sudo apt-get install slingscold

4、安装Albert Spotlight (替代 Mac Spotlight)

sudo add-apt-repository ppa:noobslab/macbuntu
sudo apt-get update
sudo apt-get install albert

启动自运行，需要创建以下链接：
sudo ln -s /usr/share/applications/plank.desktop /etc/xdg/autostart/

10、配置 Mac 字体：
安装字体命令：
wget -O mac-fonts.zip http://drive.noobslab.com/data/Mac/macfonts.zip
sudo unzip mac-fonts.zip -d /usr/share/fonts; rm mac-fonts.zip
sudo fc-cache -f -v

使用 Unity-Tweak-Tool, Gnome-Tweak-Tool 或 Ubuntu Tweak 软件更换字体。

11、修改启动界面：
sudo add-apt-repository ppa:noobslab/themes
sudo apt-get update
sudo apt-get install macbuntu-os-bscreen-lts-v7
如果你喜欢 MBuntu 启动界面，你想恢复到 Ubuntu ，使用命令：
sudo apt-get autoremove macbuntu-os-bscreen-lts-v7