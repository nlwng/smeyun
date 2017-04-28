
<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [1 ubuntu系统初次安装](#1-ubuntu系统初次安装)
	- [1.1 字体安装](#11-字体安装)
	- [1.2 sublime相关插件安装](#12-sublime相关插件安装)
	- [1.3 ubuntu优化](#13-ubuntu优化)
	- [1.4 安装经典菜单指示器](#14-安装经典菜单指示器)
	- [1.5 安装系统指示器SysPeek](#15-安装系统指示器syspeek)
	- [1.6 nav工具是在终端界面看日志的神器](#16-nav工具是在终端界面看日志的神器)
	- [1.7 安装unrar](#17-安装unrar)
	- [1.8 关闭自动更新](#18-关闭自动更新)
	- [1.9 输入法出现2个图标](#19-输入法出现2个图标)
	- [1.10 安装mac皮肤](#110-安装mac皮肤)
- [1.11 系统备份](#111-系统备份)
- [1.12 来源不信任](#112-来源不信任)
- [错误处理](#错误处理)

<!-- /TOC -->


# 1 ubuntu系统初次安装
## 1.1 字体安装
```
monaco-font install
curl -kL https://raw.github.com/cstrap/monaco-font/master/install-font-ubuntu.sh | bash
```
## 1.2 sublime相关插件安装
sudo add-apt-repository ppa:webupd8team/sublime-text-3    
sudo apt-get update    
sudo apt-get install sublime-text  
sublime 左侧目录与背景同步插件 SyncedSidebarBg

## 1.3 ubuntu优化

sudo apt-get remove unity-webapps-common  
sudo apt-get remove libreoffice-common  
sudo apt-get remove thunderbird totem rhythmbox empathy brasero simple-scan   gnome-mahjongg aisleriot gnome-mines cheese transmission-common gnome-orca   webbrowser-app gnome-sudoku  landscape-client-ui-install

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

## 1.4 安装经典菜单指示器
sudo add-apt-repository ppa:diesch/testing  
sudo apt-get update  
sudo apt-get install classicmenu-indicator  


## 1.5 安装系统指示器SysPeek
sudo add-apt-repository ppa:nilarimogard/webupd8    
sudo apt-get update    
sudo apt-get install syspeek

## 1.6 nav工具是在终端界面看日志的神器
sudo apt-get install lnav  

## 1.7 安装unrar
sudo apt-get install unrar  


## 1.8 关闭自动更新
vi /etc/apt/apt.conf.d/50unattended-upgrades  
vi /etc/apt/apt.conf.d/10periodic  
vi /etc/apt/apt.conf.d/20auto-upgrades  
sudo apt-get install pidgin  
sudo apt-get install pidgin-plugin-pack  


## 1.9 输入法出现2个图标
sudo dpkg -l|grep qimpanel  
sudo dpkg -P 上面查出来的结果  


## 1.10 安装mac皮肤
sudo add-apt-repository ppa:noobslab/macbuntu  
sudo apt-get install  macbuntu-os-ithemes-lts-v7  
sudo apt-get install  macbuntu-os-icons-lts-v7  
sudo apt-get install macbuntu-os-plank-theme-lts-v7  
sudo apt-get install unity-tweak-tool  
unity-tweak-tool 中设皮肤、图标  
点击左上角的dash菜单搜索“plank”，并打开  
sudo apt-get install gnome-tweak-tool  

安装 Slingscold（替代Launchpad）   
sudo add-apt-repository ppa:noobslab/macbuntu  
sudo apt-get update  
sudo apt-get install slingscold  

安装Albert Spotlight (替代 Mac Spotlight)  
sudo add-apt-repository ppa:noobslab/macbuntu  
sudo apt-get update  
sudo apt-get install albert  

启动自运行，需要创建以下链接:  
sudo ln -s /usr/share/applications/plank.desktop /etc/xdg/autostart/  

配置 Mac 字体:  
安装字体命令:  
wget -O mac-fonts.zip http://drive.noobslab.com/data/Mac/macfonts.zip  
sudo unzip mac-fonts.zip -d /usr/share/fonts; rm mac-fonts.zip  
sudo fc-cache -f -v  
使用 Unity-Tweak-Tool, Gnome-Tweak-Tool 或 Ubuntu Tweak 软件更换字体.  

修改启动界面:  
sudo add-apt-repository ppa:noobslab/themes  
sudo apt-get update  
sudo apt-get install macbuntu-os-bscreen-lts-v7   
如果你喜欢 MBuntu 启动界面，你想恢复到 Ubuntu ，使用命令:  
sudo apt-get autoremove macbuntu-os-bscreen-lts-v7  

# 1.11 系统备份
sudo add-apt-repository ppa:nemh/systemback  
sudo apt-get update  
sudo apt-get install systemback  

# 1.12 来源不信任  
apt-get install ubuntu-cloud-keyring  
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 16126D3A3E5C1192  
gpg -a --export 16126D3A3E5C1192 | sudo apt-key add -  

# 错误处理
W: Failed to fetch    http://mirrors.sohu.com/ubuntu/dists/precise/universe/i18n/Index  No Hash entry in Release file     /var/lib/apt/lists/partial/mirrors.sohu.com_ubuntu_dists_precise_universe_i18n_Index   
将/var/lib/apt/lists/partial/下的所有文件删除
