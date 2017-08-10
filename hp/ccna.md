<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [1.模式](#1模式)
	- [1.1模式切换](#11模式切换)
	- [1.2实验初始化设置](#12实验初始化设置)
	- [1.3接口](#13接口)

<!-- /TOC -->


# 1.模式
```s
Router> //用户模式  
Router# //特权模式（也叫enable 模式）
Router(config-if)# //接口模式
Router(config   //超级模式
Router(config-subif)# //子接口模式
```

## 1.1模式切换
```s
Router> //用户模式  
Router>enable //在用户模式敲入enable 进入特权模式（也叫enable 模式）
Router#disable //在特权模式敲入disable 退出到用户模式
Router>enable //在用户模式敲入enable 进入特权模式  
Router#configure terminal //在特权模式敲入configure terminal 进入到配置模式
Router(config)#interface ethernet 0/0 //在配置模式敲入“interface+接口类型+接口
```

## 1.2实验初始化设置
```s
switch# enable
switch# configure terminal
Switch(config)# no ip domain-lookup #关闭域名解析
Switch(config)# line console 0
Switch(config-line)# exec-timeout 0 0 #设置会话不超时
Switch(config-line)# logging synchronous #路由器发送的控制台屏幕的消息不附加命令行
```
## 1.3接口
```s
line con 0 #console port
line vty 0 4 #ssh telnet
line vty 5 15
```
