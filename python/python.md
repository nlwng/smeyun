<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [文件处理](#文件处理)
	- [读写文件](#读写文件)
	- [读一行内容:](#读一行内容)
	- [readlines()的读取为列表](#readlines的读取为列表)
	- [writelines()这个方法](#writelines这个方法)
- [字符串处理](#字符串处理)
	- [去空格及特殊符号](#去空格及特殊符号)
	- [复制字符串](#复制字符串)
	- [连接字符串](#连接字符串)
	- [查找字符](#查找字符)
	- [比较字符串](#比较字符串)
	- [扫描字符串是否包含指定的字符](#扫描字符串是否包含指定的字符)
	- [字符串长度](#字符串长度)
	- [将字符串中的大小写转换](#将字符串中的大小写转换)
	- [追加指定长度的字符串](#追加指定长度的字符串)
	- [字符串指定长度比较](#字符串指定长度比较)
	- [复制指定长度的字符](#复制指定长度的字符)
	- [将字符串前n个字符替换为指定的字符](#将字符串前n个字符替换为指定的字符)
	- [扫描字符串](#扫描字符串)
	- [翻转字符串](#翻转字符串)
	- [查找字符串](#查找字符串)
	- [分割字符串](#分割字符串)
	- [连接字符串](#连接字符串)
	- [只显示字母与数字](#只显示字母与数字)
	- [截取字符串](#截取字符串)

<!-- /TOC -->
# 文件处理
## 读写文件
```python
f = open('blogCblog.txt')
fr = f.read()
print fr
```
## 读一行内容:
```python
f = open('blogCblog.txt')  #首先先创建一个文件对象
fr = f.readline()  #用readline()方法读取文件的一行内容
print fr  #打印所读取到的内容
```
## readlines()的读取为列表
```python
f = open('blogCblog.txt')  #首先先创建一个文件对象
fr = f.readlines()  #用readlines()方法读取文件
print fr  #打印所读取到的内容

 #打印结果：['blogCblog\n', 'blog1Cblog\n', 'blog2Cblog']
```
## writelines()这个方法
```python
f = open('blogCblog.txt', 'w')  #首先先创建一个文件对象，打开方式为w
f.writelines('123456')  #用readlines()方法写入文件
f.close()
```

# 字符串处理
## 去空格及特殊符号
```python
s.strip().lstrip().rstrip(',')
```
## 复制字符串
```python
 strcpy(sStr1,sStr2)
sStr1 = 'strcpy'
sStr2 = sStr1
sStr1 = 'strcpy2'
print sStr2
```
## 连接字符串

```c
strcat(sStr1,sStr2)
sStr1 = 'strcat'
sStr2 = 'append'
sStr1 += sStr2
print sStr1
```

## 查找字符
```python
strchr(sStr1,sStr2)
 < 0 为未找到
sStr1 = 'strchr'
sStr2 = 's'
nPos = sStr1.index(sStr2)
print nPos
```
## 比较字符串
```python
strcmp(sStr1,sStr2)
sStr1 = 'strchr'
sStr2 = 'strch'
print cmp(sStr1,sStr2)
```
## 扫描字符串是否包含指定的字符
```python
strspn(sStr1,sStr2)
sStr1 = '12345678'
sStr2 = '456'
 sStr1 and chars both in sStr1 and sStr2
print len(sStr1 and sStr2)
```
## 字符串长度
```python
strlen(sStr1)
sStr1 = 'strlen'
print len(sStr1)
```
## 将字符串中的大小写转换
```python
strlwr(sStr1)
sStr1 = 'JCstrlwr'
sStr1 = sStr1.upper()
 sStr1 = sStr1.lower()
print sStr1
```
## 追加指定长度的字符串
```python
strncat(sStr1,sStr2,n)
sStr1 = '12345'
sStr2 = 'abcdef'
n = 3
sStr1 += sStr2[0:n]
print sStr1
```
## 字符串指定长度比较
```python
strncmp(sStr1,sStr2,n)
sStr1 = '12345'
sStr2 = '123bc'
n = 3
print cmp(sStr1[0:n],sStr2[0:n])
```
## 复制指定长度的字符
```python
strncpy(sStr1,sStr2,n)
sStr1 = ''
sStr2 = '12345'
n = 3
sStr1 = sStr2[0:n]
print sStr1
```
## 将字符串前n个字符替换为指定的字符
```python
strnset(sStr1,ch,n)
sStr1 = '12345'
ch = 'r'
n = 3
sStr1 = n * ch + sStr1[3:]
print sStr1
```
## 扫描字符串
```python
strpbrk(sStr1,sStr2)
sStr1 = 'cekjgdklab'
sStr2 = 'gka'
nPos = -1
for c in sStr1:
    if c in sStr2:
        nPos = sStr1.index(c)
        break
print nPos
```
## 翻转字符串
```python
strrev(sStr1)
sStr1 = 'abcdefg'
sStr1 = sStr1[::-1]
print sStr1
```

## 查找字符串
```python
strstr(sStr1,sStr2)
sStr1 = 'abcdefg'
sStr2 = 'cde'
print sStr1.find(sStr2)
```
## 分割字符串
```python
strtok(sStr1,sStr2)
sStr1 = 'ab,cde,fgh,ijk'
sStr2 = ','
sStr1 = sStr1[sStr1.find(sStr2) + 1:]
print sStr1
或者
s = 'ab,cde,fgh,ijk'
print(s.split(','))
```
##  连接字符串

```python
delimiter = ','
mylist = ['Brazil', 'Russia', 'India', 'China']
print delimiter.join(mylist)
PHP 中 addslashes 的实现

def addslashes(s):
    d = {'"':'\\"', "'":"\\'", "\0":"\\\0", "\\":"\\\\"}
    return ''.join(d.get(c, c) for c in s)

s = "John 'Johny' Doe (a.k.a. \"Super Joe\")\\\0"
print s
print addslashes(s)
```

## 只显示字母与数字

```python
def OnlyCharNum(s,oth=''):
    s2 = s.lower();
    fomart = 'abcdefghijklmnopqrstuvwxyz0123456789'
    for c in s2:
        if not c in fomart:
            s = s.replace(c,'');
    return s;

print(OnlyStr("a000 aa-b"))
```
## 截取字符串
```python
str = '0123456789'
print str[0:3] #截取第一位到第三位的字符
print str[:] #截取字符串的全部字符
print str[6:] #截取第七个字符到结尾
print str[:-3] #截取从头开始到倒数第三个字符之前
print str[2] #截取第三个字符
print str[-1] #截取倒数第一个字符
print str[::-1] #创造一个与原字符串顺序相反的字符串
print str[-3:-1] #截取倒数第三位与倒数第一位之前的字符
print str[-3:] #截取倒数第三位到结尾
print str[:-5:-3] #逆序截取，具体啥意思没搞明白？```
