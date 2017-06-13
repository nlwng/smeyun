<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [django基础命令](#django基础命令)
- [django admin](#django-admin)
- [数据模型](#数据模型)
- [HttpRequest](#httprequest)
- [视图views,Url参数：](#视图viewsurl参数)
- [django补丁](#django补丁)
- [模型设置](#模型设置)
- [数据库操作](#数据库操作)
- [模版逻辑：](#模版逻辑)
- [CSRF](#csrf)

<!-- /TOC -->

# django基础命令
```python
视图里:
p= [{'week': 1}, {'week': 2}, {'week': 3}] return render_to_response('p.html', {'p': p})

前台p.html显示:
<select name="mychoice"> {% for pp in p %} <option>{{pp.week }}</option> {% endfor %}  
```
pip install dj-database-url gunicorn dj-static

建立 Django 專案  
django-admin startproject mysite

新增 Django app  
python manage.py startapp polls

测试工程中文件  
python manage.py test polls

创建数据库,修改创建迁移文件  
python manage.py makemigrations

更新到数据库  
python manage.py migrate  
python manage.py makemigrations polls  
并在setting.py 中加上polls

创建admin帐号  
python manage.py createsuperuser

启动程序  
python manage.py runserver  
python manage.py runserver 8080  

命令接收迁移文件的名字并返回它们的SQL语句  
python manage.py sqlmigrate polls 0001  

检查模型是否存在问题  
python manage.py check

# django admin

INSTALLED_APPS:
```p
django.contrib.auth
django.contrib.contenttypes
```

默认app
```p
django.contrib.admin —— 管理站点
django.contrib.auth —— 认证系统。
django.contrib.contenttypes —— 用于内容类型的框架。
django.contrib.sessions —— 会话框架。
django.contrib.messages —— 消息框架。
django.contrib.staticfiles —— 管理静态文件的框架。
```
C:\Python27\Lib\site-packages\django\contrib\admin\templates\admin\base_site.html

# 数据模型   
给你的模型添加__str__()方法很重要，不仅会使你自己在使用交互式命令行时看得更加方便，  
而且会在Django自动生成的管理界面中使用对象的这种表示。  
```P
python manage.py shell
django shell:
import django
django.setup()

导入模块
from polls.models import Question, Choice

全局查询
Question.objects.all()
from django.utils import timezone
q = Question(question_text="What's new?", pub_date=timezone.now())
q.save()

如果你找不到Django源文件在你系统上的位置，运行如下命令：
$ python -c "
import sys
sys.path = sys.path[1:]
import django
print(django.__path__)"
```

# HttpRequest
对象表示来自某客户端的一个单独的 HTTP 请求。HttpRequest 对象是 Django 自动创建的
```py
from django.shortcuts import render
request -- HttpRequest 物件
template_name -- 要使用的 template
dictionary -- 包含要新增至 template 的變數

render：產生 HttpResponse 物件。
render(request, template_name, dictionary)
```

# 视图views,Url参数：
1.regex
```s
是“regular expression(正则表达式)”的常用的一个缩写，是一种用来匹配字符串中模式的语法，在这里是URL模式
Django从第一个正则表达式开始，依次将请求的URL与每个正则表达式进行匹配，直到找到匹配的那个为止。
这些正则表达式不会检索URL中GET和POST的参数以及域名。

例如，对于http://www.example.com/myapp/请求，URLconf 将查找myapp/。
对于http://www.example.com/myapp/?page=3请求，URLconf 也将查找myapp/
```
2.view
```s
当Django找到一个匹配的正则表达式时，它就会调用view参数指定的视图函数，
并将HttpRequest对象作为第一个参数，从正则表达式中“捕获”的其他值作为其他参数，
传入到该视图函数中。如果正则表达式使用简单的捕获方式，值将作为位置参数传递；
如果使用命名的捕获方式，值将作为关键字参数传递。
```
3.kwargs
```s
任何关键字参数都可以以字典形式传递给目标视图。
```
4.name
```s
命名你的URL。 这样就可以在Django的其它地方尤其是模板中，
通过名称来明确地引用这个URL。 这个强大的特性可以使你仅仅修改一个文件就可以改变全局的URL模式
```

视图views：
```s
1.常见的习惯是载入一个模板、填充一个context 然后返回一个含有模板渲染结果的HttpResponse对象。
2.快捷方式 render()
3.快捷方式：get_object_or_404()
```

# django补丁
http://python.usyiyi.cn/django/intro/contributing.html

# 模型设置
http://python.usyiyi.cn/django/ref/models/fields.html#common-model-field-options

```s
null    如果为True，Django 将用NULL 来在数据库中存储空值。 默认值是 False.
blank   如果为True，该字段允许不填。默认为False。
choices 由二项元组构成的一个可迭代对象（例如，列表或元组），用来给字段提供选择项。 如果设置了choices,
        默认的表单将是一个选择框而不是标准的文本框，而且这个选择框的选项就是choices 中的选项。
```
```py
class Person(models.Model):
    SHIRT_SIZES = (
        ('S', 'Small'),
        ('M', 'Medium'),
        ('L', 'Large'),
    )
    name = models.CharField(max_length=60)
    shirt_size = models.CharField(max_length=1, choices=SHIRT_SIZES)

default  字段的默认值。可以是一个值或者可调用对象。如果可调用 ，每有新对象被创建它都会被调用
help_text 表单部件额外显示的帮助内容。即使字段不在表单中使用，它对生成文档也很有用。

primary_key 如果为True，那么这个字段就是模型的主键。
            如果你没有指定任何一个字段的primary_key=True，Django 就会自动添加一个IntegerField 字段做为主键，
            所以除非你想覆盖默认的主键行为，否则没必要设置任何一个字段的primary_key=True。详见自增主键字段。

unique  如果该值设置为 True, 这个数据字段的值在整张表中必须是唯一的
```

# 数据库操作
```py
from trips.models import Post

写：
Post.objects.create(title='My Second Trip', content='去散散步吧',  location='台北火車站'

读：
Post.objects.filter(pk__gt=1)
Post.objects.all()

update：
posts = Post.objects.filter(pk__lt=3)
posts.update(location='捷運大安站')

删除：
posts.delete()
```

# 模版逻辑：
```py
for
{% for <element> in <list> %}
{% endfor %}

#if else
{% if post.photo %}
{% else %}
{% endif %}
```

日期数据格式化
```py
{{ post.created_at|date:"Y / m / d" }}
```

連結到特定 view 的 template tag
```py
{% url '<view_name>' %}
{% url '<view_name>' arg1=<var1> arg2=<var2> ...%}
```

设置url自动跳转  
二级页面跳转和按钮进入其他页面   
```py
url(r'^post/(?P<pk>\d+)/$', post_detail, name='post_detail'),
<!-- home.html -->
<h2 class="title">
    <a href="#">{{ post.title }}</a>
</h2>
```
修改为
```python
<h2 class="title">
    <a href="{% url 'post_detail' pk=post.pk %}">{{ post.title }}</a>
</h2>
```

```py
<!-- home.html -->
<a class="read-more" href="#">
    Read More <i class="fa fa-arrow-right"></i>
</a>
````
修改为
```py
<a class="read-more" href="{% url 'post_detail' pk=post.pk %}">
    Read More <i class="fa fa-arrow-right"></i>
</a>
```

```py
{% firstof var1 var2 var3 %}
```
相当于：
```py
{% if var1 %}
    {{ var1 }}
{% elif var2 %}
    {{ var2 }}
{% elif var3 %}
    {{ var3 }}
{% endif %}
```

# CSRF
错误：CSRF verification failed. Request aborted.

在表单里添加{％csrf_token％}
```py
<form action="/books/contact/" method="post">
                {% csrf_token %}      <--------------------------------------新加入的                  
                <p>Subject: <input type="text" name="subject"></p>
                <p>Your e-mail: (optional): <input type="text" name="email"></p>
                <p>Message: <textarea name="message" rows="10" cols="50"></textarea></p>
                <input type="submit" value="Submit">
</form>
```
还需要最后一步在view文件中加入装饰器@csrf_exempt如下：
```py
from django.views.decorators.csrf import csrf_exempt
@csrf_exemptdef
def contact(request):
```
