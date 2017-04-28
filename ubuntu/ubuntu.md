
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
	- [1.13 vim调优](#113-vim调优)
	- [1.14 安装vnc](#114-安装vnc)
	- [1.15 安装zsh](#115-安装zsh)
	- [1.16 python相关](#116-python相关)
	- [1.17 优化terminator](#117-优化terminator)
- [1.18 python相关](#118-python相关)
- [2 github环境配置](#2-github环境配置)
	- [2.1 git 免密码提交](#21-git-免密码提交)
	- [2.2 git自动提交脚本](#22-git自动提交脚本)
- [config 为配置文件将文件拷贝到用户目录](#config-为配置文件将文件拷贝到用户目录)
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

## 1.11 系统备份
sudo add-apt-repository ppa:nemh/systemback  
sudo apt-get update  
sudo apt-get install systemback  

## 1.12 来源不信任  
apt-get install ubuntu-cloud-keyring  
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 16126D3A3E5C1192  
gpg -a --export 16126D3A3E5C1192 | sudo apt-key add -  

## 1.13 vim调优
install vundle 在.vimrc中跟踪和管理插件  
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

## 1.14 安装vnc
install vnc  
apt-get install x11vnc  

set passwd  
x11vnc -storepasswd  

start server  
x11vnc -auth guess -once -loop -noxdamage -repeat -rfbauth /root/.vnc/passwd -rfbport 5900 -shared

设置开机启动  
vim /lib/systemd/system/x11vnc.service  
```shell
[Unit]  
Description=Start x11vnc at startup.   
After=multi-user.  

[Service]  
Type=simple   
ExecStart=/usr/bin/x11vnc -auth guess -once -loop -noxdamage -repeat -rfbauth /root/.vnc/passwd -rfbport 5900 -shared

[Install]  
WantedBy=multi-user.target  
```
sudo systemctl daemon-reload  
sudo systemctl enable x11vnc.service  

## 1.15 安装zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"  
主题  
ZSH_THEME="wedisagree"   
http://ohmyz.sh/


## 1.16 python相关
安装mysql依赖  
环境ubuntu desktop 16.04  
sudo apt-get install python-pip   
sudo apt-get install libmysqlclient-dev   
sudo apt-get install python-dev  
sudo pip install mysql-python   

## 1.17 优化terminator
修改配置文件  
```
[global_config]
  enabled_plugins = CustomCommandsMenu, TestPlugin, ActivityWatch, TerminalShot, MavenPluginURLHandler
[keybindings]
[layouts]
  [[default]]
    [[[child1]]]
      parent = window0
      profile = default
      type = Terminal
    [[[window0]]]
      parent = ""
      type = Window
[plugins]
[profiles]
  [[default]]
    background_darkness = 0.86
    background_image = None
    background_type = image
    copy_on_selection = True
    cursor_color = "#eee8d5"
    font = Monospace 12
    foreground_color = "#00ff00"
    scroll_on_output = False
    scrollback_lines = 50000
    use_system_font = False
  [[New Profile]]
    background_image = None
```
# 1.18 python相关
环境ubuntu desktop 16.04  
sudo apt-get install python-pip  
sudo apt-get install libmysqlclient-dev   
sudo apt-get install python-dev  
sudo pip install mysql-python  

# 2 github环境配置
## 2.1 git 免密码提交
cd ~  
touch .git-credentials  
vim .git-credentials  
https://{username}:{password}@github.com

git config --global credential.helper store  
vim ~/.gitconfig 会发现多了一项   
[credential]
helper = store

```conf
[user]
	name = {username}@gmail.com
	email = {username}@gmail.com
[credential]
	helper = store
```

## 2.2 git自动提交脚本
```shell
#config 为配置文件将文件拷贝到用户目录
times=`date "+%Y%m%d_%H:%M:%S"`
cd ./mytest
git add .
git commit -am"commit file $times"
git push origin master
cd ../
```





# 错误处理
W: Failed to fetch    http://mirrors.sohu.com/ubuntu/dists/precise/universe/i18n/Index  No Hash entry in Release file     /var/lib/apt/lists/partial/mirrors.sohu.com_ubuntu_dists_precise_universe_i18n_Index   
将/var/lib/apt/lists/partial/下的所有文件删除
