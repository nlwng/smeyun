<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [git错误解决](#git错误解决)
	- [tips1:](#tips1)

<!-- /TOC -->


# git错误解决
## tips1:
error: Your local changes to the following files would be overwritten by merge:
如果希望保留生产服务器上所做的改动,仅仅并入新配置项, 处理方法如下:
```
git stash
git pull
git stash pop
```
反过来,如果希望用代码库中的文件完全覆盖本地工作版本. 方法如下:
```
git reset --hard
git pull
```
其中git reset是针对版本,如果想针对文件回退本地修改,使用
```
git checkout HEAD file/to/restore
```
