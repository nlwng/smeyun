<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [shell模式](#shell模式)
	- [non-interactive + login shell](#non-interactive-login-shell)
	- [interactive + non-login shell](#interactive-non-login-shell)

<!-- /TOC -->


# shell模式
## non-interactive + login shell
第二种模式的shell为non-interactive login shell，即非交互式的登陆shell，这种是不太常见的情况。一种创建此shell的方法为：bash -l script.sh，
前面提到过-l参数是将shell作为一个login shell启动，而执行脚本又使它为non-interactive shell。

## interactive + non-login shell
第三种模式为交互式的非登陆shell，这种模式最常见的情况为在一个已有shell中运行bash，此时会打开一个交互式的shell，而因为不再需要登陆，因此不是login shell。

参考http://blog.csdn.net/whitehack/article/details/51705889
