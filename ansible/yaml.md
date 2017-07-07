<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [简介](#简介)
	- [语法规则](#语法规则)
	- [支持数据结构](#支持数据结构)
- [对象](#对象)
- [数组](#数组)
- [复合结构](#复合结构)
- [纯量](#纯量)
- [字符串](#字符串)
- [引用](#引用)
- [函数和正则表达式的转换](#函数和正则表达式的转换)

<!-- /TOC -->

# 简介
## 语法规则
```code
大小写敏感，使用缩进表示层级关系
缩进时不允许使用Tab键，只允许使用空格。
缩进的空格数目不重要，只要相同层级的元素左侧对齐即可
注释方式为 #
```

## 支持数据结构
```code
对象：键值对的集合，又称为映射（mapping）/ 哈希（hashes） / 字典（dictionary）
数组：一组按次序排列的值，又称为序列（sequence） / 列表（list）
纯量（scalars）：单个的、不可再分的值
```

# 对象
标准对象:  
```
animal: pets  

JavaScript：
{ animal: 'pets' }  
```

特殊写法，将所有键值对写成一个行内对象：  
yaml:
```
hash: { name: Steve, foo: bar }

JavaScript:  
{ hash: { name: 'Steve', foo: 'bar' } }  
```

# 数组
标准数组:
```
- Cat
- Dog
- Goldfish

JavaScript:
mmm[ 'Cat', 'Dog', 'Goldfish' ]
```

数据结构的子成员是一个数组，则可以在该项下面缩进一个空格:
```
-
 - Cat
 - Dog
 - Goldfish

JavaScript:
[ [ 'Cat', 'Dog', 'Goldfish' ] ]
```

数组也可以采用行内表示法
```
animal: [Cat, Dog]

JavaScript:
{ animal: [ 'Cat', 'Dog' ] }
```

# 复合结构
对象和数组可以结合使用，形成复合结构
```
languages:
 - Ruby
 - Perl
 - Python
websites:
 YAML: yaml.org
 Ruby: ruby-lang.org
 Python: python.org
 Perl: use.perl.org

JavaScript:
{ languages: [ 'Ruby', 'Perl', 'Python' ],
  websites:
   { YAML: 'yaml.org',
     Ruby: 'ruby-lang.org',
     Python: 'python.org',
     Perl: 'use.perl.org' } }
```

# 纯量
纯量是最基本的、不可再分的值。以下数据类型都属于 JavaScript 的纯量
```
字符串、布尔值、整数、浮点数、Null、时间、日期
```

数值直接以字面量的形式表示
```
number: 12.30

JavaScript:
{ number: 12.30 }
```

布尔值用true和false表示
```
isSet: true

JavaScript：
{ isSet: true }
```

null用~表示
```
parent: ~

JavaScript:
{ parent: null }
```

时间采用 ISO8601 格式
```
iso8601: 2001-12-14t21:59:43.10-05:00

JavaScript:
{ iso8601: new Date('2001-12-14t21:59:43.10-05:00') }
```

日期采用复合 iso8601 格式的年、月、日表示
```
date: 1976-07-31

JavaScript:
{ date: new Date('1976-07-31') }
```

YAML 允许使用两个感叹号，强制转换数据类型
```
e: !!str 123
f: !!str true

JavaScript:
{ e: '123', f: 'true' }
```

# 字符串
```
str: 这是一行字符串

JavaScript:
{ str: '这是一行字符串' }
```

如果字符串之中包含空格或特殊字符，需要放在引号之中
```
str: '内容： 字符串'

JavaScript:
{ str: '内容: 字符串' }
```

单引号和双引号都可以使用，双引号不会对特殊字符转义
```
s1: '内容\n字符串'
s2: "内容\n字符串"

JavaScript:
{ s1: '内容\\n字符串', s2: '内容\n字符串' }
```

单引号之中如果还有单引号，必须连续使用两个单引号转义
```
str: 'labor''s day'

JavaScript:
{ str: 'labor\'s day' }
```

字符串可以写成多行，从第二行开始，必须有一个单空格缩进。换行符会被转为空格
```
str: 这是一段
  多行
  字符串

JavaScript:
{ str: '这是一段 多行 字符串' }
```

多行字符串可以使用|保留换行符，也可以使用>折叠换行
```
this: |
  Foo
  Bar
that: >
  Foo
  Bar

JavaScript:
{ this: 'Foo\nBar\n', that: 'Foo Bar\n' }
```

+表示保留文字块末尾的换行，-表示删除字符串末尾的换行
```
s1: |
  Foo
s2: |+
  Foo
s3: |-
  Foo

JavaScript:
{ s1: 'Foo\n', s2: 'Foo\n\n\n', s3: 'Foo' }  
```

字符串之中可以插入 HTML 标记
```
message: |
  <p style="color: red">
    段落
  </p>

JavaScript:
{ message: '\n<p style="color: red">\n  段落\n</p>\n' }  
```

# 引用
锚点&和别名*，可以用来引用
```
defaults: &defaults
  adapter:  postgres
  host:     localhost
development:
  database: myapp_development
  <<: *defaults
test:
  database: myapp_test
  <<: *defaults

等同：
  defaults:
    adapter:  postgres
    host:     localhost  
  development:
    database: myapp_development
    adapter:  postgres
    host:     localhost  
  test:
    database: myapp_test
    adapter:  postgres
    host:     localhost
```

&用来建立锚点（defaults），<<表示合并到当前数据，* 用来引用锚点
```
- &showell Steve
- Clark
- Brian
- Oren
- *showell

JavaScript:
[ 'Steve', 'Clark', 'Brian', 'Oren', 'Steve' ]
```

# 函数和正则表达式的转换
这是 JS-YAML 库特有的功能，可以把函数和正则表达式转为字符串
```
example.yml
fn: function () { return 1 }
reg: /test/

解析上面的 yml 文件的代码如下:

var yaml = require('js-yaml');
var fs   = require('fs');
try {
  var doc = yaml.load(
    fs.readFileSync('./example.yml', 'utf8')
  );
  console.log(doc);
} catch (e) {
  console.log(e);
}

从 JavaScript 对象还原到 yaml 文件的代码如下:

var yaml = require('js-yaml');
var fs   = require('fs');
var obj = {
  fn: function () { return 1 },
  reg: /test/
};
try {
  fs.writeFileSync(
    './example.yml',
    yaml.dump(obj),
    'utf8'
  );
} catch (e) {
  console.log(e);
}
```
