

# 一、Spring基础

## 1.Spring简介

### 1.1 核心概念

| 序号 | 概念 | 全称                                      | 具体内容                                       |
| ---- | ---- | :---------------------------------------- | ---------------------------------------------- |
| 1    | IoC  | Inversion of Control (控制反转)           | 对象创建和对象关系管理权限，由开发者转为spring |
| 2    | DI   | Dependency Injection(依赖注入)            | 对象的依赖关系的创建过程                       |
| 3    | AOP  | Aspect Oriented Programming(面向切面编程) |                                                |



功能模块组成：

![1560331987419](D:\smeyun\doc\spring\1560331987419.png)

| 模块            | 功能                           | 备注             |
| --------------- | ------------------------------ | ---------------- |
| Core            | IoC，DI 功能实现最基本实现     | 核心模块         |
| Beans           | Bean工厂(创建对象的工厂)       | 核心模块         |
| Context         | IoC容器，上下文                | 核心模块         |
| SpEL            | spring 表达式语言              | 核心模块         |
| JDBC            | JDBC封装                       | 数据访问集成模块 |
| ORM             | 数据集成框架封装，jpa jdo      | 数据访问集成模块 |
| OXM             | 实现对象和xml转换              | 数据访问集成模块 |
| JMS             | 生产消费实现                   | 数据访问集成模块 |
| Transactions    | 事务管理                       | 数据访问集成模块 |
| web             | web监听，初始化ioc容器，上传等 | web模块          |
| webSocket       | webSocket开发                  | web模块          |
| Servlet         | spring MVC                     | web模块          |
| Portlet         | 内容集成 聚合                  | web模块          |
| AOP             | AOP相关                        |                  |
| Aspects         | Aspects面向切面编程            |                  |
| Instrumentation | 设备相关                       |                  |
| Messaging       | 消息相关                       |                  |
| Test            | 测试模块                       |                  |

***spring 包含spring MVC***

### 1.2 相关参数解析

| 名称                                             | 用途                                                         | 备注                                           | 类型               |
| ------------------------------------------------ | ------------------------------------------------------------ | ---------------------------------------------- | ------------------ |
| private                                          | 声明成员变量                                                 |                                                |                    |
| 有参的构造函数                                   | 关联成员变量和无参构造函数的关系                             |                                                |                    |
| public void play()                               | 构造一个方法play，执行具体逻辑                               |                                                |                    |
| @Autowired                                       | 自动满足bean之间的依赖                                       | 自动装配，自动注入注解                         | 定义组件           |
| @Component                                       | 表示这个累需要在应用程序中被创建，被扫描                     | 被spring上下文发现，自动发现注解               | 定义组件           |
| @ComponentScan                                   | 自动发现应用程序中创建的类                                   | 自动扫描Component类                            | 定义配置           |
| @Configuration                                   | 表示当前类是一个配置类                                       | 标注类为配置类                                 | 定义配置           |
| @Test                                            | 表示当前类是一个测试类                                       |                                                |                    |
| @RunWith(SpringJUnit4ClassRunner.class)          | 引入Spring单元测试模块                                       | 声明使用SpringJUnit4ClassRunner.class 测试单元 | spring测试环境     |
| @ContextConfiguration(classes = AppConfig.class) | 加载配置类                                                   |                                                | spring测试环境     |
| @Primary                                         | 首选bean                                                     | 设置实现类的首选                               | 自动装配歧义性     |
| @Qualifier                                       | 给bean做注解                                                 | 调用的时候可以通过注解区分实现类               | 自动装配歧义性     |
| @Resource                                        | @Resource 相当于@Autowired + @Qualifier("userServiceNormal") | java标准                                       | 自动装配歧义性     |
| @Repository                                      | 标注数据dao实现类                                            | 本质和@Component没有区别，只是更加明确         | 分层架构中定义组件 |
| @Service                                         | 标注Service实现类                                            | 本质和@Component没有区别，只是更加明确         | 分层架构中定义组件 |
| @Controller                                      | 标注web、controller实现类                                    | 本质和@Component没有区别，只是更加明确         | 分层架构中定义组件 |
| @Bean                                            |                                                              | 当前配置类为默认配置类，自动调用               |                    |



## 2.Component对象 

2.1 创建maven项目

![1560333429683](D:\smeyun\doc\spring\1560333429683.png)



2.2 创建基础目录

![1560328314221](D:\smeyun\doc\spring\1560328314221.png)



2.3 配置pom.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.xfedu</groupId>
    <artifactId>spring01</artifactId>
    <version>1.0-SNAPSHOT</version>

    <dependencies>
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-context</artifactId>
            <version>4.3.13.RELEASE</version>
        </dependency>

    </dependencies>

</project>
```



2.4 编写纯java版本代码

编写MessagesService

```java
package hello;


public class MessagesService {

    /**
     * 执行打印功能
     * @return返回要打印的字符串
     */
    public String getMessage(){

        return "hello world!";
    }
}

```

编写MessagePrinter

```java
package hello;

public class MessagePrinter {

    /**
     * private 建立MessagePrinter 和 MessagesService 关联关系
     */
    private MessagesService service;

    /**
     * service setter 方法 选择service 按住alt+insert 选择setter
     * 设置service的值
     * @param service
     */
    public void setService(MessagesService service) {
        this.service = service;
    }

    public void  printMessage(){

        System.out.println(this.service.getMessage());
    }
}

```

编写Application

```java
package hello;


/**
 * 创建Application来调用MessagePrinter类
 */
public class Application {

    public static void main(String[] args) {

        System.out.println("application");

        //创建打印机对象
        MessagePrinter printer = new MessagePrinter();
        //创建消息服务对象
        MessagesService service = new MessagesService();
        //设置打印机的service属性
        printer.setService(service);

        //打印消息
        printer.printMessage();

    }
}
```



2.5 编写spring 框架版本代码

编写MessagesService

```java
package hello;

import org.springframework.stereotype.Component;

/**
 * @Component通知spring容器,
 * 应用程序的对象(MessagesService)未来会通过spring容器自动创建出来
 * 不需要程序员通过new关键字来创建
 */
@Component
public class MessagesService {

    /**
     * ctrl+o 创建无参构造的方法(object)
     *
     */
    public MessagesService() {
        super();
        System.out.println("MessageServer....");
    }

    /**
     * 执行打印功能
     * @return返回要打印的字符串
     */
    public String getMessage(){

        return "hello world!";
    }
}

```

编写MessagePrinter

```java
package hello;

import org.springframework.stereotype.Component;

/**
 * @Component通知spring容器,
 * 应用程序的对象(MessagePrinter)未来会通过spring容器自动创建出来
 * 不需要程序员通过new关键字来创建
 */
@Component
public class MessagePrinter {

    /**
     * ctrl+o 创建无参构造的方法(object)
     *
     */
    public MessagePrinter() {
        super();
        System.out.println("MessagePrinter");

    }

    /**
     * private 建立MessagePrinter 和 MessagesService 关联关系
     */
    private MessagesService service;

    /**
     * service setter 方法 选择service 按住alt+insert 选择setter
     * 设置service的值
     * @param service
     */
    public void setService(MessagesService service) {
        this.service = service;
    }

    public void  printMessage(){

        System.out.println(this.service.getMessage());
    }
}

```

编写ApplicationSpring

```java
package hello;


import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.context.annotation.ComponentScan;

/**
 * 创建Application来调用MessagePrinter类
 * @ComponentScan 扫描@Component注解的类
 */
@ComponentScan
public class ApplicationSpring {

    public static void main(String[] args) {



        System.out.println("application");
//
//        //创建打印机对象
//        MessagePrinter printer = new MessagePrinter();
//        //创建消息服务对象
//        MessagesService service = new MessagesService();
//        //设置打印机的service属性
//        printer.setService(service);
//
//        //打印消息
//        printer.printMessage();

        //初始化Spring容器
        ApplicationContext context = new AnnotationConfigApplicationContext(ApplicationSpring.class);

    }
}

```

***优点：通过 * @ComponentScan 扫描@Component注解的类，创建对象的时候就可以不用重新new***



## 3.对象装配注入Bean

### 3.1 Bena装配(注入)的三种方式

#### 3.1.1 隐式的bean发现机制和自动装配(主流)

##### 1 简单案列

```java

package hello;

import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.context.annotation.ComponentScan;

/**
 * 创建Application来调用MessagePrinter类
 * @ComponentScan 扫描@Component注解的类
 */
@ComponentScan
public class ApplicationSpring {

    public static void main(String[] args) {



        System.out.println("application");
//
//        //创建打印机对象
//        MessagePrinter printer = new MessagePrinter();
//        //创建消息服务对象
//        MessagesService service = new MessagesService();
//        //设置打印机的service属性
//        printer.setService(service);
//
//        //打印消息
//        printer.printMessage();

        //初始化Spring容器
        ApplicationContext context = new AnnotationConfigApplicationContext(ApplicationSpring.class);

        //从容器中获取MessagePrinter对象
        MessagePrinter printer = context.getBean(MessagePrinter.class);
        //从容器中获取MessagesService对象
        MessagesService service = context.getBean(MessagesService.class);

        System.out.println(printer);
        System.out.println(service);

        //设置打印机的service属性,printer和service 建立关联关系
        printer.setService(service);
        //打印消息调用printMessage打印
        printer.printMessage();
    }
}
```

**从Context中获取class**

ApplicationContext context = new AnnotationConfigApplicationContext(ApplicationSpring.class);

** 如何在对象中获取对象**

```java
//从容器中获取MessagePrinter对象,使用context.getBean方法
MessagePrinter printer = context.getBean(MessagePrinter.class);
```

** 如何建立对象的关联关系**

```java
//设置打印机的service属性,printer和service 建立关联关系
printer.setService(service);
```



##### 2. 完整的案列



1.定义CompactDisc类，

- 内置CompactDisc无参构造函数
- paly方法
- 用@Component包装

2.定义CDPlayer

- 内置CDPlayer无参数构造函数
- 声明CompactDisc
- 构建有参构造函数关联CDPlayer和CompactDisc，利用@Autowired进行关联自动管理
- 定义play方法

3.定义执行main函数

- 先通过AnnotationConfigApplicationContext 查出类
- 执行paly方法
- 利用@ComponentScan包装，进行自动组件扫描

4.解耦组件扫描和主类

- 将注解和主类解耦，单独新建配置类AppConfig



CompactDisc

```java
package soundsystem;

import org.springframework.stereotype.Component;

@Component
public class CompactDisc {

    public CompactDisc() {
        super();
        System.out.println("CompactDisc无参构造函数");
    }

    public void play(){

        System.out.println("正在播放音乐......");
    }
}
```

CDPlayer

```java
package soundsystem;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

/**
 * Component 让他能被spring上下文发现
 */

@Component
public class CDPlayer {

    /**
     *private 成员变量
     */
    private CompactDisc cd;

    public CDPlayer() {
        super();
        System.out.println("CDPlayer无参数构造函数");
    }

    /**
     * Ctrl + Insert 选(Constructor)创建有参的构造函数
     * @param
     */

    @Autowired
    public CDPlayer(CompactDisc cd) {
        this.cd = cd;
        System.out.println("CDPlayer有参数构造函数");
    }

    /**
     * 定义一个方法play,执行cd.play()播放工作
     */
    public void play(){
        cd.play();

    }
}
```

App

```java
package soundsystem;

import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.context.annotation.ComponentScan;

@ComponentScan
public class App {

    public static void main(String[] args) {
         ApplicationContext context = new AnnotationConfigApplicationContext(App.class);
        CDPlayer player = context.getBean(CDPlayer.class);

        player.play();
    }
}
```

***将注解和主类解耦，单独新建配置类AppConfig***

AppConfig

- 这里就配置类扫描@ComponentScan 和@Configuration 注解

```java
package soundsystem;


import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;


/**
 * 这就是一个配置类
 */

@Configuration
@ComponentScan
public class AppConfig {
    public AppConfig() {
        super();
        System.out.println("配置类，用于将注解和主类解耦");
    }
}
```

App 

- 这里就将@ComponentScan注解取消了

```java
package soundsystem;


import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;


public class App {

    public static void main(String[] args) {
        ApplicationContext context = new AnnotationConfigApplicationContext(AppConfig.class);
        CDPlayer player = context.getBean(CDPlayer.class);

        player.play();
    }

}
```


#### 3.1.2  在XML进行显示

applicationContext.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd">

    <!--
    bean元素：描述当前的对象由spring容器管理
    id属性：标识对象，未来在应用程序中可以根据ID获取对象
    class：被管理对象的类全名
    -->
    <bean id="service" class="hello.MessagesService"></bean>
    <bean id="printer" class="hello.MessagePrinter">
        <!--
        name：ID标识为service
        ref：指向对象 （bean id="service"）的对象
        property： 用于描述（bean id="service"） 和（bean id="printer"）的关系
        这样service对象成功注入MessagePrinter对象当中
        -->
        <property name="service" ref="service"></property>
    </bean>

</beans>
```

MessagePrinter

```java
package hello;

/**
 * @Component通知spring容器,
 * 应用程序的对象(MessagePrinter)未来会通过spring容器自动创建出来
 * 不需要程序员通过new关键字来创建
 */

public class MessagePrinter {

    /**
     * ctrl+o 创建无参构造的方法(object)
     *
     */
    public MessagePrinter() {
        super();
        System.out.println("MessagePrinter");

    }

    /**
     * private 建立MessagePrinter 和 MessagesService 关联关系
     */
    private MessagesService service;

    /**
     * service setter 方法 选择service 按住alt+insert 选择setter
     * 设置service的值
     * @param service
     */
    public void setService(MessagesService service) {
        this.service = service;
    }

    public void  printMessage(){
        System.out.println(this.service.getMessage());
    }
}

```

MessagesService

```java
package hello;

/**
 * @Component通知spring容器,
 * 应用程序的对象(MessagesService)未来会通过spring容器自动创建出来
 * 不需要程序员通过new关键字来创建
 */

public class MessagesService {

    /**
     * ctrl+o 创建无参构造的方法(object)
     *
     */
    public MessagesService() {
        super();
        System.out.println("MessageServer....");
    }

    /**
     * 执行打印功能
     * @return返回要打印的字符串
     */
    public String getMessage(){

        return "hello world!";
    }
}

```



ApplicationSpring

```java
package hello;


import org.springframework.context.ApplicationContext;
import org.springframework.context.support.ClassPathXmlApplicationContext;

/**
 * 创建Application来调用MessagePrinter类
 * @ComponentScan 扫描@Component注解的类
 */

public class ApplicationSpring {

    public static void main(String[] args) {

        System.out.println("application");
		
         //初始化Spring容器
        ApplicationContext context = new ClassPathXmlApplicationContext("applicationContext.xml");

        //从容器中获取MessagePrinter对象
        MessagePrinter printer = context.getBean(MessagePrinter.class);

        //打印消息调用printMessage打印
        printer.printMessage();
    }
}
```

***声明使用xml文件***

ApplicationContext context = new ClassPathXmlApplicationContext("applicationContext.xml");

#### 3.1.3 在java中进行显示

### 3.2 Autowired 使用场景

***用于管理对象之间的关联关系***



#### 3.2.1 简单的依赖注入例子

MessagePrinter

```java
package hello;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

/**
 * @Component通知spring容器,
 * 应用程序的对象(MessagePrinter)未来会通过spring容器自动创建出来
 * 不需要程序员通过new关键字来创建
 */
@Component
public class MessagePrinter {

    /**
     * ctrl+o 创建无参构造的方法(object)
     *
     */
    public MessagePrinter() {
        super();
        System.out.println("MessagePrinter");

    }

    /**
     * private 建立MessagePrinter 和 MessagesService 关联关系
     */
    private MessagesService service;

    /**
     * service setter 方法 选择service 按住alt+insert 选择setter
     * 设置service的值
     * @param service
     * @Autowired 用于spring管理对象之间的关联关系
     */

    @Autowired
    public void setService(MessagesService service) {
        this.service = service;
    }

    public void  printMessage(){

        System.out.println(this.service.getMessage());
    }
}

```

ApplicationSpring

```java
package hello;


import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.context.annotation.ComponentScan;

/**
 * 创建Application来调用MessagePrinter类
 * @ComponentScan 扫描@Component注解的类
 */
@ComponentScan
public class ApplicationSpring {

    public static void main(String[] args) {



        System.out.println("application");
//
//        //创建打印机对象
//        MessagePrinter printer = new MessagePrinter();
//        //创建消息服务对象
//        MessagesService service = new MessagesService();
//        //设置打印机的service属性
//        printer.setService(service);
//
//        //打印消息
//        printer.printMessage();

        //初始化Spring容器
        ApplicationContext context = new AnnotationConfigApplicationContext(ApplicationSpring.class);

        //从容器中获取MessagePrinter对象
        MessagePrinter printer = context.getBean(MessagePrinter.class);
        //从容器中获取MessagesService对象
        //MessagesService service = context.getBean(MessagesService.class);

        //System.out.println(printer);
        //System.out.println(service);

        //设置打印机的service属性,printer和service 建立关联关系
        //printer.setService(service);
        //打印消息调用printMessage打印
        printer.printMessage();
    }
}

```

***注解：使用@Autowired管理对象之间的关联关系，这样就可以自动处理关联关系。***

####  3.2.2 构造函数方法进行依赖注入

- 注入的效率最高

Power 新建power方法

```java
package soundsystem;

import org.springframework.stereotype.Component;

@Component
public class Power {
    public Power() {
        super();

    }

    public void supply(){
        System.out.println("电源供电中。。。。。");
    }
}
```

CDPlayer 增加power注入

```java
package soundsystem;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

/**
 * Component 让他能被spring上下文发现
 */

@Component
public class CDPlayer {

    /**
     *private 成员变量
     */
    private CompactDisc cd;

    private Power power;

    public CDPlayer() {
        super();
        System.out.println("CDPlayer无参数构造函数");
    }

    /**
     * Ctrl + Insert 选(Constructor)创建有参的构造函数
     * @param
     */

//    @Autowired
//    public CDPlayer(CompactDisc cd, Power power) {
//        this.cd = cd;
//    	this.power = power;
//        System.out.println("CDPlayer多参数构造函数");
//    }

    @Autowired
    public CDPlayer(CompactDisc cd, Power power) {
        this.cd = cd;
        this.power = power;
        System.out.println("CDPlayer多参数构造函数。。。。");
    }

    /**
     * 定义一个方法play,执行cd.play() power.supply();播放工作
     */
    public void play(){
        power.supply();
        cd.play();
    }
}
```

CompactDisc 无修改

```java
package soundsystem;

import org.springframework.stereotype.Component;

@Component
public class CompactDisc {

    public CompactDisc() {
        super();
        System.out.println("CompactDisc无参构造函数");
    }

    public void play(){

        System.out.println("正在播放音乐......");
    }
}
```

AppConfig 无修改

```java
package soundsystem;


import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;


/**
 * 这就是一个配置类
 */

@Configuration
@ComponentScan
public class AppConfig {
    public AppConfig() {
        super();
        System.out.println("配置类，用于将注解和主类解耦");
    }
}
```

AppTest 无修改

```java
package soundsystem;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = AppConfig.class)
public class AppTest {

    @Autowired
    private CDPlayer player;

    @Test
    public void testPlay(){

        player.play();
    }

}
```

#### 3.2.3 用在成员变量上的方式进行依赖注入

- 这个方式就是spring通过反射机制做的依赖注入
- 注入效率低，但是简洁

```java
package soundsystem;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

/**
 * Component 让他能被spring上下文发现
 */

@Component
public class CDPlayer {

    /**
     *private 成员变量
     */
    @Autowired
    private CompactDisc cd;

    @Autowired
    private Power power;

    public CDPlayer() {
        super();
        System.out.println("CDPlayer无参数构造函数");

    }

    /**
     * Ctrl + Insert 选(Constructor)创建有参的构造函数
     * @param
     */

//    @Autowired
//    public CDPlayer(CompactDisc cd) {
//        this.cd = cd;
//        System.out.println("CDPlayer有参数构造函数");
//    }

//    @Autowired
//    public CDPlayer(CompactDisc cd, Power power) {
//        this.cd = cd;
//        this.power = power;
//        System.out.println("CDPlayer多参数构造函数。。。。");
//    }

    /**
     * 定义一个方法play,执行cd.play()播放工作
     */
    public void play(){
        power.supply();
        cd.play();
    }
}
```



#### 3.2.3 利用setter方法进行依赖注入

- Alt+Insert 选setter进行setter对对象方法进行装配

```java
package soundsystem;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

/**
 * Component 让他能被spring上下文发现
 */

@Component
public class CDPlayer {

    /**
     *private 成员变量
     */
    //@Autowired
    private CompactDisc cd;

    //@Autowired
    private Power power;

    @Autowired
    public void setCd(CompactDisc cd) {
        this.cd = cd;
        System.out.println("调用setCd。。。。");
    }

    @Autowired
    public void setPower(Power power) {
        this.power = power;
        System.out.println("调用setPower。。。");
    }

    public CDPlayer() {
        super();
        System.out.println("CDPlayer无参数构造函数");

    }

    /**
     * Ctrl + Insert 选(Constructor)创建有参的构造函数
     * @param
     */

//    @Autowired
//    public CDPlayer(CompactDisc cd) {
//        this.cd = cd;
//        System.out.println("CDPlayer有参数构造函数");
//    }

//    @Autowired
//    public CDPlayer(CompactDisc cd, Power power) {
//        this.cd = cd;
//        this.power = power;
//        System.out.println("CDPlayer多参数构造函数。。。。");
//    }

    /**
     * 定义一个方法play,执行cd.play()播放工作
     */
    public void play(){
        power.supply();
        cd.play();

    }

}

```

#### 3.2.4 用在任意方法上

```java
package soundsystem;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

/**
 * Component 让他能被spring上下文发现
 */

@Component
public class CDPlayer {

    /**
     *private 成员变量
     */
    //@Autowired
    private CompactDisc cd;

    //@Autowired
    private Power power;

//    @Autowired
//    public void setCd(CompactDisc cd) {
//        this.cd = cd;
//        System.out.println("调用setCd。。。。");
//    }
//
//    @Autowired
//    public void setPower(Power power) {
//        this.power = power;
//        System.out.println("调用setPower。。。");
//    }
    @Autowired
    public void prepare(CompactDisc cd ,Power power){
        this.cd = cd;
        this.power = power;
        System.out.println("调用prepare。。。");

    }

    public CDPlayer() {
        super();
        System.out.println("CDPlayer无参数构造函数");

    }

    /**
     * Ctrl + Insert 选(Constructor)创建有参的构造函数
     * @param
     */

//    @Autowired
//    public CDPlayer(CompactDisc cd) {
//        this.cd = cd;
//        System.out.println("CDPlayer有参数构造函数");
//    }

//    @Autowired
//    public CDPlayer(CompactDisc cd, Power power) {
//        this.cd = cd;
//        this.power = power;
//        System.out.println("CDPlayer多参数构造函数。。。。");
//    }

    /**
     * 定义一个方法play,执行cd.play()播放工作
     */
    public void play(){
        power.supply();
        cd.play();

    }

}

```



## 4.接口开发 interface

### 4.1 简单的接口实现，单一实现类环境

- 创建com.cloud.demo.service 包

- 创建UserService 接口

  ```java
  package com.cloud.demo.service;
  
  
  /**
   * 这里是接口类
   */
  public interface UserService {
  
      void add();
  }
  ```

- 创建接口实现方法(实现类)，创建包com.cloud.demo.service.com.cloud.demo.service.impl，创建实现类UserServiceNormal

  ```java
  package com.cloud.demo.service.com.cloud.demo.service.impl;
  
  
  import com.cloud.demo.service.UserService;
  import org.springframework.stereotype.Component;
  
  /**
   * UserServiceNormal 实现UserService 的方法
   * 这里为实现类,@Component不写在接口，写在实现类上
   */
  
  @Component
  public class UserServiceNormal implements UserService {
  
      public void add() {
          System.out.println("添加用户");
  
      }
  }
  
  ```

- 创建配置类AppConfig

  ```java
  package com.cloud.demo.service;
  
  import org.springframework.context.annotation.ComponentScan;
  import org.springframework.context.annotation.Configuration;
  
  @Configuration
  @ComponentScan
  public class AppConfig {
  
  }
  
  ```

  

- 创建单元测试，新建包com.cloud.demo.service，userService的接口UserServiceTest

  ```java
  package com.cloud.demo.service;
  
  
  import org.junit.Test;
  import org.junit.runner.RunWith;
  import org.springframework.beans.factory.annotation.Autowired;
  import org.springframework.test.context.ContextConfiguration;
  import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
  
  /**
   * 1.要测试的是userService的接口
   * 2.private UserService userService; 接口注入@Autowired
   * 3.userService.add() 调用add()方法
   */
  @RunWith(SpringJUnit4ClassRunner.class)
  @ContextConfiguration(classes = AppConfig.class)
  public class UserServiceTest {
  
      //单一实现类环境下
      @Autowired
      private UserService userService;
  
      @Test
      public void testAdd(){
          userService.add();
      }
  
  }
  ```

  ***@Component不写在接口，写在实现类上***

  ***调用userService，需要声明接口 private UserService userService;***

### 4.2 多实现类环境

#### 4.2.1 设置首选Bean

- 配置@Primary，这样系统默认就会使用UserServiceNormal实现类，但是有局限性
- 只能定义一个@Primary

```java
@Component
@Primary
public class UserServiceNormal implements UserService {

    public void add() {
        System.out.println("增加用户");
    }

    public void del() {
        System.out.println("删除用户");
    }
}
```

#### 4.2.2 使用限定符@Qualifier

UserServiceFestival

```java
@Component
@Qualifier("Festival")
public class UserServiceFestival implements UserService {

    @Override
    public void add() {
        System.out.println("注册用户并发送优惠券");
    }

    @Override
    public void del() {

    }
}
```

UserServiceNormal

```java
@Component
@Qualifier("Normal")
public class UserServiceNormal implements UserService {

    public void add() {
        System.out.println("增加用户");
    }

    public void del() {
        System.out.println("删除用户");
    }
}

```

UserServiceTest

```java
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = AppConfig.class)
public class UserServiceTest {

    @Autowired
    //这里通过@Qualifier 调用Festival 实现类
    @Qualifier("Festival")
    private UserService userService;

    @Test
    public void testAdd(){
        userService.add();
        userService.del();
    }
}
```

#### 4.2.3 通过设置ID和限定符实现

- 将参数配置在@Component中实现@Qualifier

UserServiceFestival

```java
@Component("fastival")
public class UserServiceFestival implements UserService {

    @Override
    public void add() {
        System.out.println("注册用户并发送优惠券");
    }

    @Override
    public void del() {

    }
}
```

UserServiceNormal

```java
@Component("normal")
public class UserServiceNormal implements UserService {

    public void add() {
        System.out.println("增加用户");
    }

    public void del() {
        System.out.println("删除用户");
    }
}
```

UserServiceTest

```java
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = AppConfig.class)
public class UserServiceTest {

    @Autowired
    @Qualifier("fastival")
    private UserService userService;

    @Test
    public void testAdd(){
        userService.add();
        userService.del();
    }
}
```

#### 4.2.4 使用系统默认ID和限定符

- spring中默认会给实现类分配一个ID ,为类名首写字母小写

UserServiceTest

```java
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = AppConfig.class)
public class UserServiceTest {

    @Autowired
    @Qualifier("userServiceNormal")
    private UserService userService;

    @Test
    public void testAdd(){
        userService.add();
        userService.del();
    }
}
```

#### 4.2.5 使用@Resource

- @Resource 相当于@Autowired + @Qualifier("userServiceNormal")
- @Resource是jdk标准类，非spring标准类

```java
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = AppConfig.class)
public class UserServiceTest {

    //@Autowired
    //@Qualifier("userServiceNormal")
    @Resource(name="userServiceNormal")
    private UserService userService;


    @Test
    public void testAdd(){
        userService.add();
        userService.del();
    }

}
```

## 5.配置类 ComponentScan组件扫描

### 5.1 直接声明

直接声明单个目录

```java
@Configuration
@ComponentScan("com.cloud.demo")
```



直接声明多个目录

```java
@Configuration
@ComponentScan(basePackages = {"com.cloud.demo.web","com.cloud.demo.service","com.cloud.demo.dao"})
```

- 有风险重构不会自动修改



直接声明接口类

```java
@Configuration
@ComponentScan(basePackageClasses = {UserController.class, UserService.class, UserDao.class})
```

### 5.2 XML声明

***applicationContext.xml 相当于@Configuration***

applicationContext.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd">

    <context:component-scan base-package="com.cloud.demo" />    
</beans>
```

***测试用列中修改UserControllerTest***

@ContextConfiguration("classpath:applicationContext.xml") 指定xml位置

```java

@RunWith(SpringJUnit4ClassRunner.class)
//@ContextConfiguration(classes = AppConfig.class)
@ContextConfiguration("classpath:applicationContext.xml")
public class UserControllerTest {

    @Autowired
    private UserController userController;

    @Test
    public void testAdd(){
        userController.add();

    }
}
```

## 6 配置Java Configuration

### 6.1 如何配置@bean对象在java Config

接口：UserDao

```java

public interface UserDao {
    void add();
}

```

接口实现类：UserDaoNormal

```java
public class UserDaoNormal implements UserDao {

    @Override
    public void add() {

        System.out.println("添加用户到数据库中。。。。");

    }
}

```

配置类：AppConfig

- @Configuration 声明为配置类
- @Bean标识spring默认启动会自动加载改配置

```java
@Configuration
public class AppConfig {

    @Bean
    public UserDao UserDaoNormal(){
        System.out.println("创建UserDao对象");

        return new UserDaoNormal();
    }

}
```

测试类：UserDaoTest

```java
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = AppConfig.class)
public class UserDaoTest {

    @Autowired
    private UserDao userDao;

    @Test
    public void testAdd(){

        userDao.add();
    }

}
```



### 6.2 Java Config中依赖注入





# 二、Spring插件

## 1.日志模块

### 1.1 log4j日志系统

1.1.1 配置pom.xml

```xml
<dependencies>
    <dependency>
        <groupId>org.springframework</groupId>
        <artifactId>spring-core</artifactId>
        <version>4.3.13.RELEASE</version>
    </dependency>
    <dependency>
        <groupId>log4j</groupId>
        <artifactId>log4j</artifactId>
        <version>1.2.17</version>
    </dependency>
</dependencies>

```

1.1.2 配置log4j.properties  

```xml
log4j.rootCategory=INFO, stdout

log4j.appender.stdout=org.apache.log4j.ConsoleAppender
log4j.appender.stdout.layout=org.apache.log4j.PatternLayout
log4j.appender.stdout.layout.ConversionPattern=%d{ABSOLUTE} %5p %t %c{2}:%L - %m%n

log4j.category.org.springframework.beans.factory=DEBUG
```



## 2.单元测试

### 2.1  junit4 单元测试

2.1.1 配置pom.xml

```java
        <dependency>
            <groupId>junit</groupId>
            <artifactId>junit</artifactId>
            <version>4.12</version>
        </dependency>
```

2.1.2 配置测试单元代码

- 在工程目录test中新建和代码工程一样的目录如：soundsystem
- 创建AppTest类,将主类的代码拷贝过来，用@Test标注，主类如果不用可以删除。

```java
package soundsystem;

import org.junit.Test;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

public class AppTest {

    @Test
    public void testPlay(){

        ApplicationContext context = new AnnotationConfigApplicationContext(AppConfig.class);
        CDPlayer player = context.getBean(CDPlayer.class);
        player.play();
    }
}
```



### 2.2 spring-test 单元测试

2.2.1 配置pom.xml

```java
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-context</artifactId>
            <version>4.3.13.RELEASE</version>
        </dependency>
```

2.2.2 编写适合spring-test的测试类

- 在spring-test中可以直接用注解导入类@ContextConfiguration(classes = AppConfig.class)  等同于ApplicationContext context = new AnnotationConfigApplicationContext(AppConfig.class);
- 需要@Autowired 将CDPlayer注入进来

```java
 	@Autowired
    private CDPlayer player;
```

- @RunWith(SpringJUnit4ClassRunner.class)声明使用SpringJUnit4ClassRunner.class 测试单元



```java
package soundsystem;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = AppConfig.class)
public class AppTest {

    @Autowired
    private CDPlayer player;

    @Test
    public void testPlay(){

        player.play();
    }

}
```

# 三、相关架构解析

## 1.web程序的基本架构

![1560417075359](D:\smeyun\doc\spring\1560417075359.png)

| 层级              | 解析             | 备注 |
| ----------------- | ---------------- | ---- |
| web层(controller) | 控制层           |      |
| 业务层(service)   | 处理复杂业务逻辑 |      |
| 数据访问层(dao)   | 持久层           |      |

***实现一个简单的web架构：***

![1560419066083](D:\smeyun\doc\spring\1560419066083.png)



***数据持久层：***

UserDao

```java
package com.cloud.demo.dao;

public interface UserDao {
    void add();

}
```

UserDaoNormal

```java
package com.cloud.demo.dao.impl;

import com.cloud.demo.dao.UserDao;
import org.springframework.stereotype.Component;
import org.springframework.stereotype.Repository;

//@Component
@Repository
public class UserDaoNormal implements UserDao {

    @Override
    public void add() {
        System.out.println("添加用户到数据库中。。。。");

    }
}
```

***服务层：Service***

UserService

```java
package com.cloud.demo.service;

/**
 * 这里是接口类
 */
public interface UserService {

    void add();
    void del();
}
```

UserServiceNormal

```java
package com.cloud.demo.service.impl;


import com.cloud.demo.dao.UserDao;
import com.cloud.demo.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

/**
 * UserServiceNormal 实现UserService 的方法
 * 这里为实现类,@Component不写在接口，写在实现类上
 */

//@Component
@Service
public class UserServiceNormal implements UserService {

    @Autowired
    private UserDao userDao;

    @Override
    public void add() {
        userDao.add();
        System.out.println("增加用户");
    }

    public void del() {
        System.out.println("删除用户");
    }
}
```

***Web层，Controller***

```java
package com.cloud.demo.web;

import com.cloud.demo.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Controller;

//@Component
@Controller
public class UserController {

    @Autowired
    @Qualifier("userServiceNormal")
    private UserService userService;

    public void add(){

        userService.add();
    }
}
```



***测试模块：***

***测试UserService***

UserServiceTest

```java
package com.cloud.demo.service;


import com.cloud.demo.AppConfig;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import javax.annotation.Resource;

/**
 * 1.要测试的是userService的接口
 * 2.private UserService userService; 接口注入@Autowired
 * 3.userService.add() 调用add()方法
 */
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = AppConfig.class)
public class UserServiceTest {

    //@Autowired
    //@Qualifier("userServiceNormal")
    @Resource(name="userServiceNormal")
    private UserService userService;


    @Test
    public void testAdd(){
        userService.add();
        userService.del();
    }

}
```

***测试UserController***

UserControllerTest

```java
package com.cloud.demo.web;

import com.cloud.demo.AppConfig;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = AppConfig.class)
public class UserControllerTest {

    @Autowired
    private UserController userController;

    @Test
    public void testAdd(){
        userController.add();

    }

}
```









# 四、Spring 相关快捷键和技巧记录

## 1. 开发工具Intellij IDEA

### 1.1 查看pom.xml依赖关系

![1560390568723](D:\smeyun\doc\spring\1560390568723.png)

![1560390598106](D:\smeyun\doc\spring\1560390598106.png)

### 1.2 快速添加方法 [Alt+Insert]

1. service setter 方法 选择service 按住alt+insert 选择setter

```java
    public void setCd(CompactDisc cd) {
        this.cd = cd;
    }
```



### 1.3 快速设置构造函数 [Ctrl+O]

1. ctrl+o 创建无参构造的方法(选择 object)

```java
    public CompactDisc() {
        super();
        System.out.println("CompactDisc无参构造函数");
    }
```



2. 设置有参的构造函数 Ctrl + Insert 选(Constructor) 

```java
    /**
     * Ctrl + Insert 选(Constructor)创建有参的构造函数
     * @param cd
     */
    public CDPlayer(CompactDisc cd) {
        this.cd = cd;
    }
```



### 1.4 快速补全类依赖 [Alt+Enter]

1. Alt+Enter

### 1.5 Spring Configuration Check警告屏蔽

![1560392387762](D:\smeyun\doc\spring\1560392387762.png)



### 1.6 快速输入编码

```
输入 sout 回车 --> System.out.println(); 自动生成println函数
输入 psvm 回车 --> public static void main(String[] args) 自动生成main函数
输入 context.getBean(App.class).var 回车 --> CDPlayer player = context.getBean(CDPlayer.class);  自动创建局部变量
```

### 1.7 快速实现抽象类

要实现抽象类AuthorizingRealm中的方法。

鼠标定位到AuthorizingRealm类后面，快捷键：**Alt+Enter**；



## 2.开发工具Eclipse





# 五、相关参考文档

spring 4.3.13 framework：

<https://docs.spring.io/spring/docs/4.3.13.RELEASE/spring-framework-reference/htmlsingle/>

