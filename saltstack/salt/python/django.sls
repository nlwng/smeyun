#!py

def run():
    '''
    Install the django package
    '''
    return {'include': ['python'],
            'django': {'pkg': ['installed']}}

使用 :doc:`pydsl</ref/renderers/all/salt.renderers.pydsl>`渲染器，
上面的例子可以被更加简洁地写为：
#!pydsl
include('python', delayed=True)
state('django').pkg.installed()

文档:doc:pyobjects</ref/renderers/all/salt.renderers.pyobjects>
渲染器提供了一个 `"Pythonic"`_对象，它是建立状态数据的基础方法。上面的例子可以被写为：
#!pyobjects
include('python')
Pkg.installed("django")

#yaml
include:
  - python
django:
  pkg.installed
