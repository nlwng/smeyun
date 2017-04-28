在新的mod_python SLS中，mod_python包已经被添加了，
但是更重要的apache 服务还是被通过观察mod_python 包的方式扩展进来。

对比扩展和`required`or watch
extend 语句的工作方式有别于``require``或者``watch``，它只是附加而不是替换必要的组件。


django.sls:
这个例子展示了一个非常基础的Python SLS文件：

这是个简单的例子，第一行是SLS组织行，告诉Salt不要用默认的渲染器，
而是使用``py``渲染器。然后运行定义的功能，运行功能返回值必须是Salt友好的数据结构或从这里了解更多一个Salt:doc:HighState data structure</ref/states/highstate>.
作为一种选择，使用 :doc:`pydsl</ref/renderers/all/salt.renderers.pydsl>`渲染器，上面的例子可以被更加简洁地写为：
