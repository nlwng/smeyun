# shell笔记

## xargs

```
xargs -i -t cp -r ./{} $1

-i 表示将ls的内容一个个交给xargs处理，后面的{}代替传递的内容
-t 表示执行名前把命令打印出来
cp -r ./{} $1 就是文件拷贝
```



## 文件名修改

假如文件名是：time_filename.txt 改成filename_time.txt。例如20111111_me.txt改成me_201111111.txt要如何修改?

```shell
#! /bin/sh
for eachfile in `ls -B`
do
 filename=${eachfile%.txt}
 filehead=`echo $filename | awk -F _ '{print $1 }'`
 filelast=`echo $filename | awk -F _ '{print $2 }'`
 mv $filename.txt ${filelast}_$filehead.txt
done
```

说明：

默认你要处理的文件都在一个文件夹里,后缀都是txt: 
第2行就是列出所有的文件，然后对每个文件进行4-7行的处理；
第4行就是获取文件名，不包括后缀txt；
然后就是将文件名以下划线分割为filehead 和filelast两部分；
最后就是把源文件重命名为filelast_filehead.txt。

```shell
补充：

shell中的${}，##和%%的使用

假设我们定义了一个变量为：
file=/dir1/dir2/dir3/my.file.txt

可以用${ }分别替换得到不同的值：

1. 截断功能
${file#*/}：删掉第一个 / 及其左边的字符串：dir1/dir2/dir3/my.file.txt
${file##*/}：删掉最后一个 /  及其左边的字符串：my.file.txt
${file#*.}：删掉第一个 .  及其左边的字符串：file.txt
${file##*.}：删掉最后一个 .  及其左边的字符串：txt
${file%/*}：删掉最后一个  /  及其右边的字符串：/dir1/dir2/dir3
${file%%/*}：删掉第一个 /  及其右边的字符串：(空值)
${file%.*}：删掉最后一个  .  及其右边的字符串：/dir1/dir2/dir3/my.file
${file%%.*}：删掉第一个  .   及其右边的字符串：/dir1/dir2/dir3/my

记忆的方法为：
#是去掉左边（键盘上#在 $ 的左边），##最后一个；
%是去掉右边（键盘上% 在$ 的右边），%%第一个。

2. 字符串提取

单一符号是最小匹配；两个符号是最大匹配
${file:0:5}：提取最左边的 5 个字节：/dir1
${file:5:5}：提取第 5 个字节右边的连续5个字节：/dir2

3. 字符串替换

也可以对变量值里的字符串作替换：
${file/dir/path}：将第一个dir 替换为path：/path1/dir2/dir3/my.file.txt
${file//dir/path}：将全部dir 替换为 path：/path1/path2/path3/my.file.txt

4. 针对不同的变量状态赋值(没设定、空值、非空值)：
${file-my.file.txt}: 若$file没有设定，则使用my.file.txt作返回值。(空值及非空值时不作处理)
${file:-my.file.txt}:若$file没有设定或为空值，则使用my.file.txt作返回值。(非空值时不作处理)
${file+my.file.txt}: 若$file设为空值或非空值，均使用my.file.txt作返回值。(没设定时不作处理)
${file:+my.file.txt}:若$file为非空值，则使用my.file.txt作返回值。(没设定及空值时不作处理)
${file=my.file.txt}: 若$file没设定，则使用my.file.txt作返回值，同时将$file 赋值为 my.file.txt。(空值及非空值时不作处理)
${file:=my.file.txt}:若$file没设定或为空值，则使用my.file.txt作返回值，同时将 $file 赋值为 my.file.txt。(非空值时不作处理)
${file?my.file.txt}: 若$file没设定，则将my.file.txt输出至 STDERR。(空值及非空值时不作处理)
${file:?my.file.txt}:若$file没设定或为空值，则将my.file.txt输出至STDERR。(非空值时不作处理)

${#var} 可计算出变量值的长度：
${#file} 可得到 27，因为/dir1/dir2/dir3/my.file.txt 是27个字节。

注意: 
":+"的情况是不包含空值的.
":-", ":="等只要有号就是包含空值(null)。


5. 变量的长度
${#file}


6. 数组运算
A=(a b c def)
${A[@]} 或 ${A[*]} 可得到 a b c def (全部组数)
${A[0]} 可得到 a (第一个组数)，${A[1]} 则为第二个组数...
${#A[@]} 或 ${#A[*]} 可得到 4 (全部组数数量)
${#A[0]} 可得到 1 (即第一个组数(a)的长度)，${#A[3]} 可得到 3 (第四个组数(def)的长度)
```

