pythonpython-eggs异常解决方法:
: UserWarning: /home/server/.python-eggs is writable by group/others and vulnerable to attack when used with get_resource_filename. Consider a more secure location (set with .set_extraction_path or the PYTHON_EGG_CACHE environment variable).
warnings.warn(msg, UserWarning)
解决办法

进入 /home/server/
chmod g-wx,o-wx .python-eggs/
就是给个权限~