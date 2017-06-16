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
	- [1.10 安装mac皮肤和dock](#110-安装mac皮肤和dock)
	- [1.11 系统备份](#111-系统备份)
	- [1.12 来源不信任](#112-来源不信任)
	- [1.13 vim调优](#113-vim调优)
	- [1.14 安装vnc](#114-安装vnc)
	- [1.15 安装zsh](#115-安装zsh)
	- [1.16 python相关](#116-python相关)
	- [1.17 优化terminator](#117-优化terminator)
	- [1.18 python相关](#118-python相关)
	- [1.19 屏幕边缘鼠标粘滞](#119-屏幕边缘鼠标粘滞)
	- [1.20 安装compiz](#120-安装compiz)
	- [1.21 禁止guest账号登录](#121-禁止guest账号登录)
	- [1.22 vmware](#122-vmware)
	- [1.23 安装mail](#123-安装mail)
	- [1.24 设置boot grub 时间](#124-设置boot-grub-时间)
	- [1.25 安装qq](#125-安装qq)
- [2 github环境配置](#2-github环境配置)
	- [2.1 git 免密码提交](#21-git-免密码提交)
	- [2.2 git自动提交脚本](#22-git自动提交脚本)
- [swap空间设置](#swap空间设置)
- [ubuntu错误集合](#ubuntu错误集合)

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
```s
sudo apt-get -y remove unity-webapps-common
sudo apt-get -y remove libreoffice-common
sudo apt-get -y remove thunderbird totem rhythmbox empathy brasero simple-scan gnome-mahjongg aisleriot gnome-mines cheese transmission-common gnome-orca   webbrowser-app gnome-sudoku  landscape-client-ui-install
sudo apt-get -y remove thunderbird totem rhythmbox empathy brasero simple-scan aisleriot gnome-mines transmission-common gnome-orca webbrowser-app gnome-sudoku  onboard deja-dup
sudo apt-get -y install vim git
```
美化工具
sudo apt-get install unity-tweak-tool

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


## 1.10 安装mac皮肤和dock
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

docky:
sudo add-apt-repository ppa:docky-core/ppa
sudo apt-get update
sudo apt-get install docky

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

vim /etc/vim/vimrc
```
set nocompatible " 关闭 vi 兼容模式
syntax on " 自动语法高亮
colorscheme molokai " 设定配色方案
set number " 显示行号
set cursorline " 突出显示当前行
set ruler " 打开状态栏标尺
set shiftwidth=4 " 设定 << 和 >> 命令移动时的宽度为 4
set softtabstop=4 " 使得按退格键时可以一次删掉 4 个空格
set tabstop=4 " 设定 tab 长度为 4
set nobackup " 覆盖文件时不备份
set autochdir " 自动切换当前目录为当前文件所在的目录
filetype plugin indent on " 开启插件
set backupcopy=yes " 设置备份时的行为为覆盖
set ignorecase smartcase " 搜索时忽略大小写，但在有一个或以上大写字母时仍保持对大小写敏感
set nowrapscan " 禁止在搜索到文件两端时重新搜索
set incsearch " 输入搜索内容时就显示搜索结果
set hlsearch " 搜索时高亮显示被找到的文本
set noerrorbells " 关闭错误信息响铃
set novisualbell " 关闭使用可视响铃代替呼叫
set t_vb= " 置空错误铃声的终端代码
set showmatch " 插入括号时，短暂地跳转到匹配的对应括号
set matchtime=2 " 短暂跳转到匹配括号的时间
set magic " 设置魔术
set hidden " 允许在有未保存的修改时切换缓冲区，此时的修改由 vim 负责保存
set guioptions-=T " 隐藏工具栏
set guioptions-=m " 隐藏菜单栏
set smartindent " 开启新行时使用智能自动缩进
set backspace=indent,eol,start
" 不设定在插入状态无法用退格键和 Delete 键删除回车符
set cmdheight=1 " 设定命令行的行数为 1
set laststatus=2 " 显示状态栏 (默认值为 1, 无法显示状态栏)
set statusline=\ %<%F[%1*%M%*%n%R%H]%=\ %y\ %0(%{&fileformat}\ %{&encoding}\ %c:%l/%L%)\
" 设置在状态行显示的信息
set foldenable " 开始折叠
set foldmethod=syntax " 设置语法折叠
set foldcolumn=0 " 设置折叠区域的宽度
setlocal foldlevel=1 " 设置折叠层数为
set foldclose=all " 设置为自动关闭折叠
nnoremap <space> @=((foldclosed(line('.')) < 0) ? 'zc' : 'zo')<CR>
" 用空格键来开关折叠
```

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
sudo apt-get -y install terminator
```s
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
		show_titlebar = False
  [[New Profile]]
    background_image = None
```


## 1.18 python相关
环境ubuntu desktop 16.04
sudo apt-get install python-pip
sudo apt-get install libmysqlclient-dev
sudo apt-get install python-dev
sudo pip install mysql-python

## 1.19 屏幕边缘鼠标粘滞
Displays --> sticky edges关闭

## 1.20 安装compiz
sudo apt-get install compiz-plugins
sudo apt-get install compizconfig-settings-manager

打开compiz自行配置
destop --> expo
					desktop cube
					rotate cube
					viewport switcher

effects --> anmations
					cube reflection and deformation
					fading windows
					motion blur
					firepaint
					trailfocus
					wizard
快捷键
ctrl+alt+拖动
Shift Switcher

## 1.21 禁止guest账号登录
禁止guest:
sudo sh -c 'printf "[SeatDefaults]\nallow-guest=false\n" >/usr/share/lightdm/lightdm.conf.d/50-no-guest.conf'

开启guest:
sudo rm -f /usr/share/lightdm/lightdm.conf.d/50-no-guest.conf

## 1.22 vmware
1.搭建openstack环境时候无法设置vmware8 为混杂模式,注意每次开机会被重置成root用户.
```s
sudo chgrp neildev /dev/vmnet*
sudo chmod a+rw /dev/vmnet*
vmware &

重置网络:
sudo modprobe vmmon
sudo modprobe vmci
sudo vmware-networks --stop
sudo vmware-networks --start
```

## 1.23 安装mail
```s
sudo add-apt-repository ppa:geary-team/releases
sudo apt-get update

sudo apt-get -y install geary
```

## 1.24 设置boot grub 时间
```s
sudo vim /etc/default/grub
注释掉：GRUB_HIDDEN_TIMEOUT
修改：GRUB_HIDDEN_TIMEOUT= 3

sudo update-grub
```
## 1.25 安装qq
1 安装wine[在系统初始阶段]
```s
sudo  dpkg  --add-architecture i386
wget -nc https://dl.winehq.org/wine-builds/Release.key
sudo apt-key add Release.key
sudo apt-add-repository https://dl.winehq.org/wine-builds/ubuntu/

sudo apt-get update
sudo apt-get -y install --install-recommends winehq-stable
```
2.将目录初始化为32位：
```s
export WINEARCH=win32
rm -r ~/.wine
WINEARCH=win32 WINEPREFIX=~/.wine winecfg

命令行运行： winecfg
在winecfg函数栏目，新增库函数：
*ntoskrnl.exe，*riched20，*txplatform.exe *riched32

设置下列函数为disable：
*ntoskrnl.exe disable
*txplatform.exe disable

安装vc支持：
sudo apt-get -y install winetricks
winetricks mfc42
```

3.安装qq
```s
安装：[建议安装tim]
wine TIM1.1.5.exe
启动：
wine .wine/drive_c/Program\ Files/Tencent/TIM/Bin/TIM.exe

中文字体设置：
字体下载：
http://pan.baidu.com/s/1qYnZvjA
cp simsun.ttc /home/neildev/.wine/drive_c/windows/Fonts/
ln -sf /home/neildev/.wine/drive_c/windows/Fonts/simsun.ttc simfang.ttc
```

4.以下步骤可以不执行：
```s
修改 ~/.wine/system.reg
将其中的：
"LogPixels"=dword:00000060
改为：
"LogPixels"=dword:00000070

"MS Shell Dlg"="Tahoma"
"MS Shell Dlg 2″="Tahoma"
改为：
"MS Shell Dlg"="SimSun"
"MS Shell Dlg 2″="SimSun"

修改 ~/.wine/drive_c/windows/win.ini,增加：
[Desktop]
menufontsize=13
messagefontsize=13
statusfontsize=13
IconTitleSize=13

zh.reg [regedit zh.reg]:
REGEDIT4
[HKEY_LOCAL_MACHINE\Software\Microsoft\Windows
NT\CurrentVersion\FontSubstitutes]
"Arial"="simsun"
"Arial CE,238"="simsun"
"Arial CYR,204"="simsun"
"Arial Greek,161"="simsun"
"Arial TUR,162"="simsun"
"Courier New"="simsun"
"Courier New CE,238"="simsun"
"Courier New CYR,204"="simsun"
"Courier New Greek,161"="simsun"
"Courier New TUR,162"="simsun"
"FixedSys"="simsun"
"Helv"="simsun"
"Helvetica"="simsun"
"MS Sans Serif"="simsun"
"MS Shell Dlg"="simsun"
"MS Shell Dlg 2"="simsun"
"System"="simsun"
"Tahoma"="simsun"
"Times"="simsun"
"Times New Roman CE,238"="simsun"
"Times New Roman CYR,204"="simsun"
"Times New Roman Greek,161"="simsun"
"Times New Roman TUR,162"="simsun"
"Tms Rmn"="simsun"
```
5.通过winetricks 安装
```
mkdir -p temp;git clone https://github.com/hillwoodroc/winetricks-zh.git
sudo ln -sf /home/neildev/temp/winetricks-zh/winetricks-zh /usr/bin/
```
# 2 github环境配置
sudo apt-get install git

## 2.1 git 免密码提交
```s
git config --global credential.helper store

vim ~/.gitconfig 会发现多了一项
[credential]
helper = store
```
git config --global user.email "nlwng49@gmail.com"  
git config --global user.name "nlwng49@gmail.com"  

```s
[user]
	name = {username}@gmail.com
	email = {username}@gmail.com
[credential]
	helper = store
```

## 2.2 git自动提交脚本
config 为配置文件将文件拷贝到用户目录
```s
times=`date "+%Y%m%d_%H:%M:%S"`
cd ./mytest
git add .
git commit -am"commit file $times"
git push origin master
cd ../
```

# swap空间设置
```s
dd if=/dev/zero of=/mnt/swapadd bs=10240 count=524288
mkswap /mnt/swapadd
swapon /mnt/swapadd
echo "/mnt/swapadd swap swap defaults 0 0" >> /etc/fstab
```

# ubuntu错误集合
1.apt更新报错
W: Failed to fetch    http://mirrors.sohu.com/ubuntu/dists/precise/universe/i18n/Index  No Hash entry in Release file     /var/lib/apt/lists/partial/mirrors.sohu.com_ubuntu_dists_precise_universe_i18n_Index
将/var/lib/apt/lists/partial/下的所有文件删除

2.ubuntu16 每次休眠之后进入窗口两侧都有一块白色的区域
在英伟达 375 和 378 版本的驱动上会有这个白边的问题， 在最新的 381 版本上已经修复

最好的办法就是更新驱动为 381 或者降驱动版本降为 340.
升级为 381方法是命令行终端下（Ctrl-Shift-T呼出）输入如下命令， 然后重启电脑
sudo add-apt-repository ppa:graphics-drivers/ppa

sudo apt update
sudo apt purge nvidia*
sudo apt install nvidia-381

临时的解决办法就是在命令行终端下（Ctrl-Shift-T呼出）输入如下命令：
compiz --replace
