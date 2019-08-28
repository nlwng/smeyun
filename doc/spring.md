s100





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

| 名称                                             | 用途                                                         | 备注                                                         | 类型                                              |
| ------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------- |
| private                                          | 声明成员变量                                                 |                                                              |                                                   |
| 有参的构造函数                                   | 关联成员变量和无参构造函数的关系                             |                                                              |                                                   |
| public void play()                               | 构造一个方法play，执行具体逻辑                               |                                                              |                                                   |
| @Autowired                                       | 自动满足bean之间的依赖                                       | 自动装配，自动注入注解                                       | 定义组件                                          |
| @Transactional                                   |                                                              | @Transactional 可以作用于接口、接口方法、类以及类方法上。当作用于类上时，该类的所有 public 方法将都具有该类型的事务属性，同时，我们也可以在方法级别使用该标注来覆盖类级别的定义。                                                但是 Spring 建议不要在接口或者接口方法上使用该注解，因为这只有在使用基于接口的代理时它才会生效。另外， @Transactional 注解应该只被应用到 public 方法上 | 事务管理                                          |
| @Component                                       | 表示这个累需要在应用程序中被创建，被扫描                     | 被spring上下文发现，自动发现注解                             | 定义组件                                          |
| @ComponentScanTransactional                      | 自动发现应用程序中创建的类                                   | 自动扫描Component类                                          | 定义配置                                          |
| @Configuration                                   | 表示当前类是一个配置类                                       | 标注类为配置类                                               | 定义配置                                          |
| @Test                                            | 表示当前类是一个测试类                                       |                                                              |                                                   |
| @RunWith(SpringJUnit4ClassRunner.class)          | 引入Spring单元测试模块                                       | 声明使用SpringJUnit4ClassRunner.class 测试单元               | spring测试环境                                    |
| @ContextConfiguration(classes = AppConfig.class) | 加载配置类                                                   |                                                              | spring测试环境                                    |
| @Primary                                         | 首选bean                                                     | 设置实现类的首选                                             | 自动装配歧义性                                    |
| @Qualifier                                       | 给bean做注解                                                 | 调用的时候可以通过注解区分实现类                             | 自动装配歧义性                                    |
| @Resource                                        | @Resource 相当于@Autowired + @Qualifier("userServiceNormal") | java标准                                                     | 自动装配歧义性                                    |
| @Repository                                      | 标注数据dao实现类                                            | 本质和@Component没有区别，只是更加明确                       | 分层架构中定义组件                                |
| @Service                                         | 标注Service实现类                                            | 本质和@Component没有区别，只是更加明确                       | 分层架构中定义组件                                |
| @Controller                                      | 标注web、controller实现类， **API接口**                      | 本质和@Component没有区别，只是更加明确                       | 分层架构中定义组件                                |
| @Bean                                            |                                                              | 当前配置类为默认配置类，自动调用                             |                                                   |
| @Override                                        | 重写，重载                                                   | 自雷重写父类的方法                                           |                                                   |
| @RequestMapping                                  | 是一个用来处理请求地址映射的注解，可用于类或方法上。用于类上，表示类中的所有响应请求的方法都是以该地址作为父路径。 | 配置url映射                                                  |                                                   |
| @RestController                                  | 是@ResponseBody和@Controller的组合注解                       |                                                              |                                                   |
| Extends-**继承类**                               | 全盘继承                                                     | 在类的声明中，通过关键字extends来创建一个类的子类。          | 对于class而言，Extends用于(单)继承一个类（class） |
| implements-**实现接口**                          | 给这个类附加额外的功能                                       | 实现接口就是在接口中定义了方法，这个方法要你自己去实现，接口可以看作一个标准，比如定义了一个动物的接口，它里面有吃（eat()）这个方法，你就可以实现这个方法implements，这个方法是自己写，可以是吃苹果，吃梨子，香蕉，或者其他的。implements就是具体实现这个接口 | implements用于实现一个接口(interface)             |
| DAO                                              | DAO是传统MVC中Model的关键角色，全称是Data Access Object。DAO直接负责数据库的存取工作，乍一看两者非常类似，但从架构设计上讲两者有着本质的区别： | DAO则没有摆脱数据的影子，仍然停留在数据操作的层面上，DAO则是相对数据库而言 |                                                   |
| Repository                                       | Repository蕴含着真正的OO概念，即一个数据仓库角色，负责所有对象的持久化管理。 | Repository是相对对象而言，                                   | https://segmentfault.com/a/1190000012346333       |

接口：

接口一般是只有方法声明没有定义的。

接口可以比作协议，比如我说一个协议是“杀人”那么这个接口你可以用 砍刀去实现，至于怎么杀砍刀可以去实现，当然你也可以用抢来实现杀人接口，但是你不能用杀人接口去杀人，因为杀人接口只不过是个功能说明，是个协议，具体怎么干，还要看他的实现类。那么一个包里面如果有接口，你可以不实现。这个不影响你使用其他类。







### 1.3 for 循环

- ***this.tracks.for + Enter 可以快速得到for循环***

```java
        for (String track : this.tracks) {
            System.out.println("音乐:" + track);
        }
```



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

#### 3.2.3 用成员变量的方式进行依赖注入

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

### 6.2 构造函数注入场景- 普通方式

UserServiceNormal 

- 通过构造函数关联依赖

```java
public class UserServiceNormal implements UserService {

    private UserDao userDao;

    //无参构造函数
    public UserServiceNormal() {
        super();
    }

    //有参构造函数
    public UserServiceNormal(UserDao userDao) {
        this.userDao = userDao;
    }

    @Override
    public void add() {
        userDao.add();

    }
}
```

UserService

```java
public interface UserService {

    void add();
}
```

UserDao

```java
public interface UserDao {
    void add();
}
```

UserDaoNormal

```java
public class UserDaoNormal implements UserDao {

    @Override
    public void add() {

        System.out.println("添加用户到数据库中。。。。");

    }
}
```

AppConfig

```java
@Configuration
public class AppConfig {

    @Bean
    public UserDao userDaoNormal(){
        System.out.println("创建UserDao对象");

        return new UserDaoNormal();
    }

    @Bean
    public UserService userServiceNormal(){
        System.out.println("创建UserService对象");
        UserDao userDao = userDaoNormal();
        return new UserServiceNormal(userDao);
    }

}
```

UserServiceTest

```java
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = AppConfig.class)
public class UserServiceTest {

    @Autowired
    private UserService userService;

    @Test
    public void testAdd(){

        userService.add();
    }


}
```

### 6.3 构造函数注入场景- 优雅方式

AppConfig

```java
@Configuration
public class AppConfig {

    @Bean
    public UserDao userDaoNormal(){
        System.out.println("创建UserDao对象");

        return new UserDaoNormal();
    }

    @Bean
    public UserService userServiceNormal(UserDao userDao){
        System.out.println("创建UserService对象");
        
        //UserDao userDao = userDaoNormal();
        return new UserServiceNormal(userDao);
    }

}
```

- 实际编程中不会做函数的调用，而是在参数中取获取UserDao

### 6.4 通过setter方法依赖注入

UserServiceNormal

```java
public class UserServiceNormal implements UserService {

    private UserDao userDao;

    //setter方法注入
    public void setUserDao(UserDao userDao) {
        this.userDao = userDao;
    }

    @Override
    public void add() {
        userDao.add();

    }
}
```

AppConfig

```java
@Configuration
public class AppConfig {

    @Bean
    public UserDao userDaoNormal(){
        System.out.println("创建UserDao对象");

        return new UserDaoNormal();
    }

    @Bean
    public UserService userServiceNormal(UserDao userDao){
        System.out.println("创建UserService对象");
        //赋值给一个变量userService
        UserServiceNormal userService = new UserServiceNormal();
        //调用userService的setter方法，将userDao注入
        userService.setUserDao(userDao);
        //返回userService
        return userService;

    }

}
```

### 6.5 通过任意函数注入

UserServiceNormal

```java

public class UserServiceNormal implements UserService {

    private UserDao userDao;

    //任意函数注入
    public void prepare(UserDao userDao){
        this.userDao = userDao;
    }

    @Override
    public void add() {
        userDao.add();

    }
}
```

AppConfig

```java
@Configuration
public class AppConfig {

    @Bean
    public UserDao userDaoNormal(){
        System.out.println("创建UserDao对象");

        return new UserDaoNormal();
    }

    @Bean
    public UserService userServiceNormal(UserDao userDao){
        System.out.println("创建UserService对象");
        UserServiceNormal userService = new UserServiceNormal();
        //任意函数注入
        userService.prepare(userDao);
        return userService;

    }

}
```

### 6.6 XML装配

#### 6.6.1 创建xml配置规范

applicationContext.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd">
    
</beans>
```

#### 6.6.2 xml定义第bean

CompactDisc

```java
public class CompactDisc {

    public CompactDisc() {
        super();
        System.out.println("CompacDisc构造函数。。。。" + this.toString());
    }

    public void play(){
        System.out.println("播放CD音乐。。。。。" + this.toString());

    }
}
```

ApplicationSpring

```java
public class ApplicationSpring {

    public static void main(String[] args) {
        System.out.println("ApplicationSpring is running......");

        ClassPathXmlApplicationContext context =  new ClassPathXmlApplicationContext("applicationContext.xml");
        //初始化cd
        CompactDisc cd = context.getBean(CompactDisc.class);
        //调用play方法
        cd.play();
    }
}
```

applicationContext.xml

- xml 定义bean

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd">

    <bean class="com.cloud.deam.soundsystem.CompactDisc" />
</beans>
```

输出结果

```
ApplicationSpring is running......
CompacDisc构造函数。。。。com.cloud.deam.soundsystem.CompactDisc@2669b199
播放CD音乐。。。。。com.cloud.deam.soundsystem.CompactDisc@2669b199
```



***多个重名bean设置id区分：***

```xml
    <bean id="CompactDisc1" class="com.cloud.deam.soundsystem.CompactDisc" />
    <bean id="CompactDisc2" class="com.cloud.deam.soundsystem.CompactDisc" />
```

```xml
    <bean name="CompactDisc1" class="com.cloud.deam.soundsystem.CompactDisc" />
    <bean name="CompactDisc2" class="com.cloud.deam.soundsystem.CompactDisc" />
```

- name可以通过分号、空格、逗号分隔，设置不同的别名 name="CompactDisc1 CompactDisc12 CompactDisc13  "
- id只能通过传字符进行传递

ApplicationSpring -- 主方法

```java
public class ApplicationSpring {

    public static void main(String[] args) {
        System.out.println("ApplicationSpring is running......");

        ClassPathXmlApplicationContext context =  new ClassPathXmlApplicationContext("applicationContext.xml");
        //CompactDisc cd = context.getBean(CompactDisc.class);

        CompactDisc cd1 = (CompactDisc) context.getBean("compactDisc1");
        CompactDisc cd2 = (CompactDisc) context.getBean("compactDisc2");
        
        cd1.play();      
        cd2.play();
    }
}
```

AppTest -- 测试类

```java
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration("classpath:applicationContext.xml")
public class CompactDiscTest {


    @Autowired
    private CompactDisc CompactDisc1;

    @Autowired
    private CompactDisc CompactDisc2;

    //过滤方式注入
    @Autowired
    @Qualifier("CompactDisc2")
    private CompactDisc cd;


    @Test
    public void testPlay(){
        CompactDisc1.play();
        CompactDisc2.play();
        cd.play();
    }
}
```

#### 6.6.3 xml注入 - 通过构造函数

| 名称                  | 用途                                                         | 备注 |
| --------------------- | ------------------------------------------------------------ | ---- |
| <constructor-arg>元素 | 依赖Bean，有参构造函数依赖注入                               |      |
| c-名称空间            | --c：c函数命令空间 :cd 构造函数的参数名字cd<br/>     public CDPlayer(CompactDisc cd)，-ref:表示的是CompactDisc2名称的引用<br/>	也可以写成c:0-ref="CompactDisc2" c:1-ref="CompactDisc2" 表示第一个 第二个参数 |      |
|                       |                                                              |      |

***<constructor-arg>元构造函数依赖注入***

applicationContext.xml

```xml
    <bean id="cdPlayer1" class="com.cloud.deam.soundsystem.CDPlayer">
        <!--下面写的是依赖Bean -->
        <constructor-arg ref="CompactDisc1"/>        
    </bean>
```

CDPlayerTest

```java
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration("classpath:applicationContext.xml")
public class CDPlayerTest {

    @Autowired
    private CDPlayer cdPlayer;

    @Test
    public void Test01(){

        cdPlayer.play();
    }

}
```

***c-名称空间依赖注入***

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:c="http://www.springframework.org/schema/c"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd">

    <bean id="CompactDisc1" class="com.cloud.deam.soundsystem.CompactDisc" />
    <bean id="CompactDisc2" class="com.cloud.deam.soundsystem.CompactDisc" />
    <bean id="cdPlayer1" class="com.cloud.deam.soundsystem.CDPlayer">
        <constructor-arg ref="CompactDisc1"/>
    </bean>
    
    <!--c：c函数命令空间 :cd 构造函数的参数名字cd
     public CDPlayer(CompactDisc cd)，-ref:表示的是CompactDisc2名称的引用
	也可以写成c:0-ref="CompactDisc2" c:1-ref="CompactDisc2" 表示第一个 第二个参数
     -->
    <bean id="cdPlayer2" class="com.cloud.deam.soundsystem.CDPlayer" c:cd-ref="CompactDisc2"></bean>
</beans>
```

CDPlayerTest

```java
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration("classpath:applicationContext.xml")
public class CDPlayerTest {

    @Autowired
    private CDPlayer cdPlayer1;

    @Autowired
    private CDPlayer cdPlayer2;

    @Test
    public void Test01(){

        cdPlayer1.play();
        cdPlayer2.play();
    }

}
```

#### 6.6.4 注入简单类型 -通过构造函数

- 给CompactDisc1 对象注入title、artist

```xml
    <bean id="CompactDisc1" class="com.cloud.deam.soundsystem.CompactDisc">
        <constructor-arg name="title" value="I Do" />
        <constructor-arg name="artist" value="莫文蔚" />
    </bean>
```

```xml
    <bean id="CompactDisc1" class="com.cloud.deam.soundsystem.CompactDisc">
        <constructor-arg index="title" value="I Do" />
        <constructor-arg index="artist" value="莫文蔚" />
    </bean>
```

***-c方式注入简单类型：***

```xml
    <bean id="CompactDisc2" class="com.cloud.deam.soundsystem.CompactDisc"
          c:title="爱在西元"
          c:artist="周杰伦"
    />
```

CompactDisc

```java
public class CompactDisc {

    private String title;
    private String artist;


    public CompactDisc() {
        super();
        System.out.println("CompacDisc构造函数。。。。" + this.toString());
    }



    public CompactDisc(String title, String artist) {
        this.title = title;
        this.artist = artist;

        System.out.println("CompacDisc构造函数。。。。" + this.toString());
    }

    public void play(){
        System.out.println("播放CD音乐。。。。。" + this.toString() +" " +this.title+ " by " +this.artist);

    }
}
```

#### 6.6.5  注入list类型 -通过构造函数

applicationContext.xml

```xml
    <bean id="CompactDisc1" class="com.cloud.deam.soundsystem.CompactDisc">
        <constructor-arg name="title" value="I Do" />
        <constructor-arg name="artist" value="莫文蔚" />
        <constructor-arg name="tracks">
            <list>
                <value>I Do 1</value>
                <value>I Do 2</value>
                <value>I Do 3</value>
            </list>
        </constructor-arg>
    </bean>
```

CompactDisc

```java
public class CompactDisc {

    private String title;
    private String artist;
    
    //声明一个list
    private List<String> tracks;


    public CompactDisc() {
        super();
        System.out.println("CompacDisc构造函数。。。。" + this.toString());
    }



    public CompactDisc(String title, String artist) {
        this.title = title;
        this.artist = artist;

        System.out.println("CompacDisc有参构造函数。。。。" + this.toString());
    }

    //创建包含三个函数的构造函数
    public CompactDisc(String title, String artist, List<String> tracks) {
        this.title = title;
        this.artist = artist;
        this.tracks = tracks;

        System.out.println("CompacDisc有三个参构造函数。。。。" + this.toString());
    }

    public void play(){
        System.out.println("播放CD音乐。。。。。" + this.toString() +" " +this.title+ " by " +this.artist);
        
       //循环打印tracks内容
        for (String track : this.tracks) {
            System.out.println("音乐:" + track);
        }

    }
}
```

***创建一个复杂对象类型***

创建类型 Music 

```java
package com.cloud.deam.soundsystem;

public class Music {

    private String title;
    private Integer duration;

    //创建getter setter 方法
    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public Integer getDuration() {
        return duration;
    }

    public void setDuration(Integer duration) {
        this.duration = duration;
    }

    //创建无参构造方法

    public Music() {
        super();
    }

    //创建有参构造方法
    public Music(String title, Integer duration) {
        this.title = title;
        this.duration = duration;
    }
}

```

CompactDisc

```java
public class CompactDisc {

    private String title;
    private String artist;
    
    //设置List为Music类型
    private List<Music> tracks;


    public CompactDisc() {
        super();
        System.out.println("CompacDisc构造函数。。。。" + this.toString());
    }



    public CompactDisc(String title, String artist) {
        this.title = title;
        this.artist = artist;

        System.out.println("CompacDisc有参构造函数。。。。" + this.toString());
    }

    //设置List为Music类型
    public CompactDisc(String title, String artist, List<Music> tracks) {
        this.title = title;
        this.artist = artist;
        this.tracks = tracks;

        System.out.println("CompacDisc有三个参构造函数。。。。" + this.toString());
    }

    public void play(){
        System.out.println("播放CD音乐。。。。。" + this.toString() +" " +this.title+ " by " +this.artist);

        for (Music track : this.tracks) {
			//通过get方法获取属性
            System.out.println("音乐:" + track.getTitle() + ".时长：" + track.getDuration());

        }

    }
}

```

applicationContext.xml

- 复杂的对象依赖注入

```xml
    <bean id="music1" class="com.cloud.deam.soundsystem.Music">
        <constructor-arg value="I Do 1" />
        <constructor-arg value="270" />
    </bean>

    <bean id="music2" class="com.cloud.deam.soundsystem.Music">
        <constructor-arg value="I Do 2" />
        <constructor-arg value="280" />
    </bean>

    <bean id="music3" class="com.cloud.deam.soundsystem.Music">
        <constructor-arg value="I Do 3" />
        <constructor-arg value="290" />
    </bean>

    <bean id="CompactDisc1" class="com.cloud.deam.soundsystem.CompactDisc">
        <constructor-arg name="title" value="I Do" />
        <constructor-arg name="artist" value="莫文蔚" />
        <constructor-arg name="tracks">
            <list>
                <ref bean="music1" />
                <ref bean="music2" />
                <ref bean="music3" />
            </list>
        </constructor-arg>
    </bean>
```

#### 6.6.6 注入set类型 -通过构造函数

CompactDisc

```java
public class CompactDisc {

    private String title;
    private String artist;
    
    //设置set为Music类型
    private List<Music> tracks;


    public CompactDisc() {
        super();
        System.out.println("CompacDisc构造函数。。。。" + this.toString());
    }



    public CompactDisc(String title, String artist) {
        this.title = title;
        this.artist = artist;

        System.out.println("CompacDisc有参构造函数。。。。" + this.toString());
    }

    //设置set为Music类型
    public CompactDisc(String title, String artist, set<Music> tracks) {
        this.title = title;
        this.artist = artist;
        this.tracks = tracks;

        System.out.println("CompacDisc有三个参构造函数。。。。" + this.toString());
    }

    public void play(){
        System.out.println("播放CD音乐。。。。。" + this.toString() +" " +this.title+ " by " +this.artist);

        for (Music track : this.tracks) {
			//通过get方法获取属性
            System.out.println("音乐:" + track.getTitle() + ".时长：" + track.getDuration());

        }

    }
}

```

applicationContext.xml

```xml
    <bean id="music1" class="com.cloud.deam.soundsystem.Music">
        <constructor-arg value="I Do 1" />
        <constructor-arg value="270" />
    </bean>

    <bean id="music2" class="com.cloud.deam.soundsystem.Music">
        <constructor-arg value="I Do 2" />
        <constructor-arg value="280" />
    </bean>

    <bean id="music3" class="com.cloud.deam.soundsystem.Music">
        <constructor-arg value="I Do 3" />
        <constructor-arg value="290" />
    </bean>


    <bean id="CompactDisc1" class="com.cloud.deam.soundsystem.CompactDisc">
        <constructor-arg name="title" value="I Do" />
        <constructor-arg name="artist" value="莫文蔚" />
        <constructor-arg name="tracks">
            <!-- set 类型设置-->
            <set>
                <ref bean="music1" />
                <ref bean="music2" />
                <ref bean="music3" />
            </set>
        </constructor-arg>
    </bean>
```

- ***set和list区别在装配的时候重复的值在set中会被过滤***
- ***set元素的顺序能够和插入一致。而list是无序的***



#### 6.6.7 注入MAP集合 -通过构造函数

CompactDisc

```java
public class CompactDisc {

    private String title;
    private String artist;
    private Map<String, Music> tracks;


    public CompactDisc() {
        super();
        System.out.println("CompacDisc构造函数。。。。" + this.toString());
    }

    public CompactDisc(String title, String artist) {
        this.title = title;
        this.artist = artist;

        System.out.println("CompacDisc有参构造函数。。。。" + this.toString());
    }

    public CompactDisc(String title, String artist, Map<String,Music> tracks) {
        this.title = title;
        this.artist = artist;
        this.tracks = tracks;

        System.out.println("CompacDisc有三个参构造函数。。。。" + this.toString());
    }

    public void play(){
        System.out.println("播放CD音乐。。。。。" + this.toString() +" " +this.title+ " by " +this.artist);

        for (String key : this.tracks.keySet()) {
            System.out.println("key:" + key );
            Music music = this.tracks.get(key);
            System.out.println("音乐:" + music.getTitle() + ".时长：" + music.getDuration());
        }
    }
}
```

applicationContext.xml

```xml
    <bean id="music1" class="com.cloud.deam.soundsystem.Music">
        <constructor-arg value="I Do 1" />
        <constructor-arg value="270" />
    </bean>

    <bean id="music2" class="com.cloud.deam.soundsystem.Music">
        <constructor-arg value="I Do 2" />
        <constructor-arg value="280" />
    </bean>

    <bean id="music3" class="com.cloud.deam.soundsystem.Music">
        <constructor-arg value="I Do 3" />
        <constructor-arg value="290" />
    </bean>


    <bean id="CompactDisc1" class="com.cloud.deam.soundsystem.CompactDisc">
        <constructor-arg name="title" value="I Do" />
        <constructor-arg name="artist" value="莫文蔚" />
        <constructor-arg name="tracks">
            
            //map类型注入需要使用entry
            <map>
                <entry key="m1" value-ref="music1"/>
                <entry key="m2" value-ref="music2"/>
                <entry key="m3" value-ref="music3"/>
            </map>
        </constructor-arg>
    </bean>
```

#### 6.6.8 注入数组类型 -通过构造函数

CompactDisc

```java
public class CompactDisc {

    private String title;
    private String artist;
    //设置Music为数组类型
    private Music[] tracks;


    public CompactDisc() {
        super();
        System.out.println("CompacDisc构造函数。。。。" + this.toString());
    }



    public CompactDisc(String title, String artist) {
        this.title = title;
        this.artist = artist;

        System.out.println("CompacDisc有参构造函数。。。。" + this.toString());
    }

    //设置Music为数组类型
    public CompactDisc(String title, String artist, Music[] tracks) {
        this.title = title;
        this.artist = artist;
        this.tracks = tracks;

        System.out.println("CompacDisc有三个参构造函数。。。。" + this.toString());
    }

    public void play(){
        System.out.println("播放CD音乐。。。。。" + this.toString() +" " +this.title+ " by " +this.artist);

        for (Music track : this.tracks) {
            System.out.println("音乐:" + track.getTitle() + ".时长：" + track.getDuration());

        }

    }
}
```

applicationContext.xml

```xml
    <bean id="music1" class="com.cloud.deam.soundsystem.Music">
        <constructor-arg value="I Do 1" />
        <constructor-arg value="270" />
    </bean>

    <bean id="music2" class="com.cloud.deam.soundsystem.Music">
        <constructor-arg value="I Do 2" />
        <constructor-arg value="280" />
    </bean>

    <bean id="music3" class="com.cloud.deam.soundsystem.Music">
        <constructor-arg value="I Do 3" />
        <constructor-arg value="290" />
    </bean>


    <bean id="CompactDisc1" class="com.cloud.deam.soundsystem.CompactDisc">
        <constructor-arg name="title" value="I Do" />
        <constructor-arg name="artist" value="莫文蔚" />
        <constructor-arg name="tracks">
            <array>
                <ref bean="music1"/>
                <ref bean="music2"/>
                <ref bean="music3"/>
            </array>
        </constructor-arg>
    </bean>
```

#### 6.6.9 属性注入

1.set注入属性注入

applicationContext-properties.xml

- property 注入元素

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd">

    <bean id="music1" class="com.cloud.deam.soundsystem.Music">
        <property name="title" value="告白气球" />
        <property name="duration" value="215" />
    </bean>

    <bean id="music2" class="com.cloud.deam.soundsystem.Music">

       <property name="title"  value="爱情废材" />
       <property name="duration" value="305" />
    </bean>


</beans>
```

Music

- 属性注入只需set方法就可以
- 属性的构造方法，会走无参构造函数

```java
public class Music {

    //声明的是私有的成员变量
    private String title;
    private Integer duration;

    //创建getter setter 方法
    public String getTitle() {
        return title;
    }

    //setTitle是属性
    public void setTitle(String title) {
        this.title = title;
        System.out.println("--在" +this.toString() + "中注入title");
    }

    public Integer getDuration() {
        return duration;
    }

    //setDuration是属性
    public void setDuration(Integer duration) {
        this.duration = duration;
        System.out.println("--在" +this.toString() + "中注入duration");
    }

    //创建无参构造方法

    public Music() {
        super();
        System.out.println("Music的构造函数。。。"+this.toString());
    }

    //创建有参构造方法
    public Music(String title, Integer duration) {
        this.title = title;
        this.duration = duration;

    }
}

```

AppTest

```java
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration("classpath:applicationContext-properties.xml")
public class AppTest {

    @Test
    public void test(){
    }
}
```

测试结果

```java

Music的构造函数。。。com.cloud.deam.soundsystem.Music@255b53dc
--在com.cloud.deam.soundsystem.Music@255b53dc中注入title
--在com.cloud.deam.soundsystem.Music@255b53dc中注入duration
Music的构造函数。。。com.cloud.deam.soundsystem.Music@482cd91f
--在com.cloud.deam.soundsystem.Music@482cd91f中注入title
--在com.cloud.deam.soundsystem.Music@482cd91f中注入duration
```

2.属性注入中注入数组列表

CompactDisc

- 设置get set方法

```java
public class CompactDisc {

    private String title;
    private String artist;
    private Music[] tracks;


    public CompactDisc() {
        super();
        System.out.println("CompacDisc构造函数。。。。" + this.toString());
    }



    public CompactDisc(String title, String artist) {
        this.title = title;
        this.artist = artist;

        System.out.println("CompacDisc有参构造函数。。。。" + this.toString());
    }

    public CompactDisc(String title, String artist, Music[] tracks) {
        this.title = title;
        this.artist = artist;
        this.tracks = tracks;

        System.out.println("CompacDisc有三个参构造函数。。。。" + this.toString());
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
        System.out.println("--在" +this.toString() + "中注入title");
    }

    public String getArtist() {
        return artist;
    }

    public void setArtist(String artist) {
        this.artist = artist;
        System.out.println("--在" +this.toString() + "中注入artist");
    }

    public Music[] getTracks() {
        return tracks;
    }

    public void setTracks(Music[] tracks) {
        this.tracks = tracks;
        System.out.println("--在" +this.toString() + "中注入tracks");
    }

    public void play(){
        System.out.println("播放CD音乐。。。。。" + this.toString() +" " +this.title+ " by " +this.artist);

        for (Music track : this.tracks) {
            System.out.println("音乐:" + track.getTitle() + ".时长：" + track.getDuration());

        }

    }
}

```

applicationContext-properties.xml

- 增加数组注入

```xml
    <bean id="compactDisc1" class="com.cloud.deam.soundsystem.CompactDisc">
        <property name="title" value="周杰伦的床边故事"/>
        <property name="artist" value="周杰伦"/>
        <property name="tracks">
            <array>
                <ref bean="music1"/>
                <ref bean="music2"/>
            </array>
        </property>
    </bean>
```

测试：

- 会自动注入

```
Music的构造函数。。。com.cloud.deam.soundsystem.Music@255b53dc
--在com.cloud.deam.soundsystem.Music@255b53dc中注入title
--在com.cloud.deam.soundsystem.Music@255b53dc中注入duration
Music的构造函数。。。com.cloud.deam.soundsystem.Music@482cd91f
--在com.cloud.deam.soundsystem.Music@482cd91f中注入title
--在com.cloud.deam.soundsystem.Music@482cd91f中注入duration
CompacDisc构造函数。。。。com.cloud.deam.soundsystem.CompactDisc@123f1134
--在com.cloud.deam.soundsystem.CompactDisc@123f1134中注入title
--在com.cloud.deam.soundsystem.CompactDisc@123f1134中注入artist
--在com.cloud.deam.soundsystem.CompactDisc@123f1134中注入tracks
```

3.属性注入中注入对象引

CDPlayer

- 构造set get方法

```java
public class CDPlayer {

    private CompactDisc cd;
    public CDPlayer() {
        super();
        System.out.println("CDPlayer的构造函数" + this.toString());
    }

    public CDPlayer(CompactDisc cd) {
        this.cd = cd;
        System.out.println("CDPlayer的有参构造函数"+ this.toString());
    }

    public CompactDisc getCd() {
        return cd;
    }

    public void setCd(CompactDisc cd) {
        this.cd = cd;
        System.out.println("--在" +this.toString() + "中注入cd");
    }

    public void play(){
        System.out.println("CDPlayer:"+ this.toString());
        cd.play();
    }

}
```

applicationContext-properties.xml

- 利用ref 引用compactDisc1 属性

```xml
    <bean id="CDPlayer1" class="com.cloud.deam.soundsystem.CDPlayer">
        <property name="cd" ref="compactDisc1" />
    </bean>
```

测试：

- 注入CDPlayer
- 引用CDPlayer，play方法

```java
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration("classpath:applicationContext-properties.xml")
public class AppTest {

    @Autowired
    private CDPlayer cdPlayer;

    @Test
    public void test(){
        cdPlayer.play();
    }
}
```

```
Music的构造函数。。。com.cloud.deam.soundsystem.Music@1b68b9a4
--在com.cloud.deam.soundsystem.Music@1b68b9a4中注入title
--在com.cloud.deam.soundsystem.Music@1b68b9a4中注入duration
Music的构造函数。。。com.cloud.deam.soundsystem.Music@75c072cb
--在com.cloud.deam.soundsystem.Music@75c072cb中注入title
--在com.cloud.deam.soundsystem.Music@75c072cb中注入duration
CompacDisc构造函数。。。。com.cloud.deam.soundsystem.CompactDisc@1f1c7bf6
--在com.cloud.deam.soundsystem.CompactDisc@1f1c7bf6中注入title
--在com.cloud.deam.soundsystem.CompactDisc@1f1c7bf6中注入artist
--在com.cloud.deam.soundsystem.CompactDisc@1f1c7bf6中注入tracks
CDPlayer的构造函数com.cloud.deam.soundsystem.CDPlayer@20d3d15a
--在com.cloud.deam.soundsystem.CDPlayer@20d3d15a中注入cd
CDPlayer:com.cloud.deam.soundsystem.CDPlayer@20d3d15a
播放CD音乐。。。。。com.cloud.deam.soundsystem.CompactDisc@1f1c7bf6 周杰伦的床边故事 by 周杰伦
音乐:告白气球.时长：215
音乐:爱情废材.时长：305
```

#### 6.6.10 P 名称空间注入

- 集合和数组不支持

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:p="http://www.springframework.org/schema/p"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:util="http://www.springframework.org/schema/util"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd http://www.springframework.org/schema/util http://www.springframework.org/schema/util/spring-util.xsd">

    <bean id="music1" class="com.cloud.deam.soundsystem.Music">
        <property name="title" value="告白气球" />
        <property name="duration" value="215" />
    </bean>

    <bean id="music2" class="com.cloud.deam.soundsystem.Music"
          p:title="爱情废材"
          p:duration="305" />


    <bean id="compactDisc1" class="com.cloud.deam.soundsystem.CompactDisc" p:title="周杰伦的床边故事" p:artist="周杰伦">
        <property name="tracks">
            <array>
                <ref bean="music1"/>
                <ref bean="music2"/>
            </array>
        </property>
    </bean>

    <bean id="CDPlayer1" class="com.cloud.deam.soundsystem.CDPlayer" p:cd-ref="compactDisc1" />

</beans>
```

#### 6.6.11 util名称空间注入

- 处理集合数组注入
- 使用util:list 和ref 进行关联

```xml
    <util:list id="tracklist">
            <ref bean="music1"/>
            <ref bean="music2"/>
    </util:list>

    <bean id="compactDisc1" class="com.cloud.deam.soundsystem.CompactDisc"
          p:title="周杰伦的床边故事"
          p:artist="周杰伦"
          p:tracks-ref="tracklist" >
    </bean>
```

### 6.7 xml装配总结

- id 和name 的区别

  - id ：整个id属性就是bean名字

  - name: 可以使用分号、空格或逗号分隔开，每个部分是一个别名，通过任何别名都可以获取到bean对象

- 通过构造函数依赖注入

  - <constructor-arg> 元素
  - c-名称空间
  - 能注入 list、set、map、数组

- 属性注入，类的set方法

  - <property> 元素
  - p-名称空间
  - util-名称空间，可以和p名称结合处理复杂集合注入

- 三种装配方式总结

  - 自动装配 -推荐
  - java装配 - 其次
  - XML装配 - 最次

## 7 高级装配

### 7.1 bean的单例作用域

1. bean单例作用域
   - 默认情况下spring应用程序的上下文中所有的bean都是单例加载的
   - 无论获取多少次，拿到的都是一个对象

notepad

```java
public class Notepad {

    public Notepad(){
        super();
        System.out.println("Notepad的构造函数。。。"+this.toString());

    }
}
```

applicationContext.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd">

    <bean id="notepad" class="com.cloud.demo.Notepad" />

</beans>
```

测试：

NotepadTest

```java
/**
 * 1.无论我们是否去主动获取bean对象，Spring上下文件，一加载就会创建bean对象
 * 2.无论获取多少次，拿到的都是一个对象
 */

public class NotepadTest {

    @Test
    public void test(){
        ClassPathXmlApplicationContext context = new ClassPathXmlApplicationContext("applicationContext.xml");
        //创建notepad对象，默认获得的是Object对象
        Object notepad1 = (Notepad)context.getBean("notepad");
        Object notepad2 = (Notepad)context.getBean("notepad");
        System.out.println(notepad1 == notepad2);
    }
}
```

NotepadTestAutowired

```java
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration("classpath:applicationContext.xml")
public class NotepadTestAutowired {

    @Autowired
    private Notepad notepad1;

    @Autowired
    private Notepad notepad2;

    /**
     * 1.无论我们是否去主动获取bean对象，Spring上下文件，一加载就会创建bean对象
     * 2.无论获取多少次，拿到的都是一个对象
     */

    @Test
    public void test(){
        System.out.println(notepad1 == tepad2);
    }
}
```
### 7.2 bean的作用域
   - xml单作用域

```xml
<bean id="notepad" class="com.cloud.demo.Notepad" scope="prototype"/>
```

输出：

```
Notepad的构造函数。。。com.cloud.demo.Notepad@1f1c7bf6
Notepad的构造函数。。。com.cloud.demo.Notepad@214b199c
false
```

### 7.3 自动装配中定义bean作用域

Notepad2

```java
@Component
//scope定义bean作用域3种方法
//@Scope("prototype")
//@Scope(scopeName = "prototype")
@Scope(ConfigurableBeanFactory.SCOPE_PROTOTYPE)
public class Notepad2 {

    public Notepad2(){
        super();
        System.out.println("Notepad2的构造函数。。。"+this.toString());

    }
}
```

applicationContext.xml

- <context:component-scan base-package="com.cloud.demo"/>  启用全局扫描

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:context="http://www.springframework.org/schema/context"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd http://www.springframework.org/schema/context http://www.springframework.org/schema/context/spring-context.xsd">

    <context:component-scan base-package="com.cloud.demo"/>
<bean id="notepad" class="com.cloud.demo.Notepad" scope="prototype"/>

</beans>
```

### 7.4 javaconfig 装配中定义bean的作用域

AppConfig

```java
@Configuration
public class AppConfig {

    @Bean
    @Scope(ConfigurableBeanFactory.SCOPE_PROTOTYPE)
    public Notepad3 notepad3(){

        return new Notepad3();
    }
}
```



Notepad3

```JAVA
public class Notepad3 {

    public Notepad3(){
        super();
        System.out.println("Notepad的构造函数。。。"+this.toString());

    }
}
```

Notepad3Test

```java
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = AppConfig.class)
public class Notepad3Test {

    @Autowired
    private Notepad3 notepad1;

    @Autowired
    private Notepad3 notepad2;

    @Test
    public void test(){

        System.out.println(notepad1 == notepad2);

    }
}
```

### 7.5 延迟加载

- 延迟加载默认只能在singleton模式下

xml模式下：

```xml
<bean id="notepad" class="com.cloud.demo.Notepad" scope="singleton" lazy-init="true"/>
```

自动装配：

```java
@Component
@Scope("singleton")
//@Scope(scopeName = "prototype")
//@Scope(ConfigurableBeanFactory.SCOPE_PROTOTYPE)
@Lazy
public class Notepad2 {

    public Notepad2(){
        super();
        System.out.println("Notepad2的构造函数。。。"+this.toString());

    }
}
```

java 类模式下：

```java
@Configuration
public class AppConfig {

    @Bean
    @Scope(ConfigurableBeanFactory.SCOPE_SINGLETON)
    @Lazy
    public Notepad3 notepad3(){

        return new Notepad3();
    }
}
```

### 7.6 对象的初始化和销毁

***xml模式：***

```xml
<bean id="notepad" class="com.cloud.demo.Notepad" scope="singleton" lazy-init="true"
        destroy-method="destory"
        init-method="init"/>

</beans>
```

Notepad

```java
public class Notepad {

    public Notepad(){
        super();
        System.out.println("Notepad的构造函数。。。"+this.toString());

    }

    //容器初始化自动调用init方法
    public void init(){
        System.out.println("Notepad的初始化方法");

    }

    //容器初始化自动调用销毁方法
    public void destory(){
        System.out.println("Notepad的销毁方法");
    }

}
```

NotepadTest

```java
public class NotepadTest {


    @Test
    public void test(){
        ClassPathXmlApplicationContext context = new ClassPathXmlApplicationContext("applicationContext.xml");
        //创建notepad对象，默认获得的是Object对象
        Object notepad1 = (Notepad)context.getBean("notepad");
//        Object notepad2 = (Notepad)context.getBean("notepad");
//        System.out.println(notepad1 == notepad2);

        //主动调用销毁方法,close方法自动调用destroy方法
        //context.destroy();
        context.close();


    }
}
```

***自动装配：***

Notepad2

```java
@Component
@Scope("singleton")
//@Scope(scopeName = "prototype")
//@Scope(ConfigurableBeanFactory.SCOPE_PROTOTYPE)
@Lazy
public class Notepad2 {

    public Notepad2(){
        super();
        System.out.println("Notepad2的构造函数。。。"+this.toString());
    }

    //容器初始化自动调用init方法
    @PostConstruct
    public void init(){
        System.out.println("Notepad2的初始化方法");

    }

    //容器初始化自动调用销毁方法
    @PreDestroy
    public void destory(){
        System.out.println("Notepad2的销毁方法");
    }

}
```

Notepad2Test

```java
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration("classpath:applicationContext.xml")
public class Notepad2Test {

    @Autowired
    private Notepad notepad1;

    @Autowired
    private Notepad notepad2;

    /**
     * 1.无论我们是否去主动获取bean对象，Spring上下文件，一加载就会创建bean对象
     * 2.无论获取多少次，拿到的都是一个对象
     */

    @Test
    public void test(){

        System.out.println(notepad1 == notepad2);

    }
}
```

***java类：***

Notepad3

```java
public class Notepad3 {

    public Notepad3(){
        super();
        System.out.println("Notepad3的构造函数。。。"+this.toString());

    }

    //容器初始化自动调用init方法
    @PostConstruct
    public void init(){
        System.out.println("Notepad3的初始化方法");

    }

    //容器初始化自动调用销毁方法
    @PreDestroy
    public void destory(){
        System.out.println("Notepad3的销毁方法");
    }
}
```

Notepad3Test

```java
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = AppConfig.class)
public class Notepad3Test {

    @Autowired
    private Notepad3 notepad1;

    //@Autowired
    //private Notepad3 notepad2;

    /**
     * 1.无论我们是否去主动获取bean对象，Spring上下文件，一加载就会创建bean对象
     * 2.无论获取多少次，拿到的都是一个对象
     */

    @Test
    public void test(){

        //System.out.println(notepad1 == notepad2);

    }
}
```

### 7.7 工厂方法创建bean对象

- 主要是在xml方法中使用，
- 自动装配和java方法不存在解决方案，直接写代码就可以了



```xml
    <!--静态工厂-->
    <context:component-scan base-package="com.cloud.demo"/>
    <bean id="person1" class="com.cloud.demo.PersonFactory" factory-method="createPerson" />

    <!--实例工厂-->
    <bean id="personFactory" class="com.cloud.demo.PersonFactory" />
    <bean id="person2" factory-bean="personFactory" factory-method="createPerson2" />
```

 Person

```java
public class Person {
}
```

PersonFactory

```java
/**
 * 用工厂方法实现
 */

public class PersonFactory {


    public static Person createPerson(){
        System.out.println("静态工厂创建Person....");
        return new Person();
    }

    public Person createPerson2(){

        System.out.println("实例工厂创建Person....");
        return new Person();
    }

}
```

PersonTest

```java
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration("classpath:applicationContext.xml")
public class PersonTest {

    @Autowired
    Person person1;

    @Autowired
    Person person2;

    @Test
    public void test(){
        System.out.println(person1);
        System.out.println(person2);

    }

}
```

### 7.8 装配总结

- 单例 Sinleton: 在整个应用程序中，只创建bean的一个实例

- 原型 Prototype: 每次注入或通过Spring上下文获取的时候，都会创建一个新的bean实例

- 会话 Session 在Web应用中，为每个会话创建一个bean实例

- 请求 request 在应用中，为每个请求创建一个bean实例

- 作用域配置

  - xml配置  scope=“singleton”

  - 自动装配 

    @Component

    @Scope("singleton")

  - javaConfig配置

    @Bean

    @Scope(ConfigurableBeanFactory.SCOPE_SINGLETON)

- 延迟配置

  - xml配置

    lazy-init=“true”

  - 自动装配

    @Component

    @Lazy

  - JavaConfig

    @Bean

    @Lazy

- 初始化方法和销毁方法

  - xml配置

    destory-method=“destory” init-method="init"

  - 自动装配和JavaConfig

    @PostConstruct

    public void init() { system.out.println("Notepad2的初始化方法")；}

    @PerDestroy

    public void destroy() { system.out.println("Notepad2的销毁方法")；}

- 工厂方法

  - 静态工厂

    ```xml
    <bean id="person1" class="com.cloud.demo.PersonFactory" factory-method="createPerson" />
    ```

    

  - 实例工厂

    ```xml
    <bean id="personFactory" class="com.cloud.demo.PersonFactory" />
    <bean id="person2" factory-bean="personFactory" factory-method="createPerson2" />
    ```

## 8、 @Controller/@RestController/@RequestMapping

### 8.1 @Controller 处理http请求

```java
@Controller
//@ResponseBody
public class HelloController {

    @RequestMapping(value="/hello",method= RequestMethod.GET)
    public String sayHello(){
        return "hello";
    }
}
```

如果直接使用@Controller这个注解，当运行该SpringBoot项目后，在浏览器中输入：local:8080/hello,会得到如下错误提示： 

出现这种情况的原因在于：没有使用模版。即@Controller 用来响应页面，@Controller必须配合模版来使用。spring-boot 支持多种模版引擎包括： 
1，FreeMarker 
2，Groovy 
3，Thymeleaf （Spring 官网使用这个） 
4，Velocity 

5，JSP （貌似Spring Boot官方不推荐，STS创建的项目会在src/main/resources 下有个templates 目录，这里就是让我们放模版文件的，然后并没有生成诸如 SpringMVC 中的webapp目录）

本文以Thymeleaf为例介绍使用模版，具体步骤如下：

第一步：在pom.xml文件中添加如下模块依赖：

```html
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-thymeleaf</artifactId>
        </dependency>

```

第二步：修改控制器代码，具体为：

```java
/**
 * Created by wuranghao on 2017/4/7.
 */
@Controller
public class HelloController {

    @RequestMapping(value="/hello",method= RequestMethod.GET)
    public String sayHello(){
        return "hello";
    }
}

```

第三步：在resources目录的templates目录下添加一个hello.html文件，具体工程目录结构如下：

其中，hello.html文件中的内容为：

```html
 <h1>wojiushimogui</h1>
```

这样，再次运行此项目之后，在浏览器中输入：localhost:8080/hello

就可以看到hello.html中所呈现的内容了。

因此，我们就直接使用@RestController注解来处理http请求来，这样简单的多。



### 8.2 @RestController

Spring4之后新加入的注解，原来返回json需要@ResponseBody和@Controller配合。

即@RestController是@ResponseBody和@Controller的组合注解。

```java
@RestController
public class HelloController {

    @RequestMapping(value="/hello",method= RequestMethod.GET)
    public String sayHello(){
        return "hello";
    }
}

```

与下面的代码作用一样

```java
@Controller
@ResponseBody
public class HelloController {

    @RequestMapping(value="/hello",method= RequestMethod.GET)
    public String sayHello(){
        return "hello";
    }
}

```

### 8.3 @RequestMapping 配置url映射

@RequestMapping此注解即可以作用在控制器的某个方法上，也可以作用在此控制器类上。

当控制器在类级别上添加@RequestMapping注解时，这个注解会应用到控制器的所有处理器方法上。处理器方法上的@RequestMapping注解会对类级别上的@RequestMapping的声明进行补充。



例子一：@RequestMapping仅作用在处理器方法上

```java
@RestController
public class HelloController {

    @RequestMapping(value="/hello",method= RequestMethod.GET)
    public String sayHello(){
        return "hello";
    }
}

```

以上代码sayHello所响应的url=localhost:8080/hello。



例子二：@RequestMapping仅作用在类级别上

```java
/**
 * Created by wuranghao on 2017/4/7.
 */
@Controller
@RequestMapping("/hello")
public class HelloController {

    @RequestMapping(method= RequestMethod.GET)
    public String sayHello(){
        return "hello";
    }
}

```

以上代码sayHello所响应的url=localhost:8080/hello,效果与例子一一样，没有改变任何功能。



例子三：@RequestMapping作用在类级别和处理器方法上

```java
/**
 * Created by wuranghao on 2017/4/7.
 */
@RestController
@RequestMapping("/hello")
public class HelloController {

    @RequestMapping(value="/sayHello",method= RequestMethod.GET)
    public String sayHello(){
        return "hello";
    }
    @RequestMapping(value="/sayHi",method= RequestMethod.GET)
    public String sayHi(){
        return "hi";
    }
}

```

这样，以上代码中的sayHello所响应的url=localhost:8080/hello/sayHello。

sayHi所响应的url=localhost:8080/hello/sayHi。

从这两个方法所响应的url可以回过头来看这两句话：当控制器在类级别上添加@RequestMapping注解时，这个注解会应用到控制器的所有处理器方法上。处理器方法上的@RequestMapping注解会对类级别上的@RequestMapping的声明进行补充。

最后说一点的是@RequestMapping中的method参数有很多中选择，一般使用get/post.



## 9.Hibernate，JPA 对象关系映射之关联关系映射策略

### **1.单向OneToOne：**

![1564457569725](D:\smeyun\doc\spring\1564457569725.png)

单向一对一关系的拥有端

```java
@Entity 
public class Person implements Serializable { 
   private static final long serialVersionUID = 1L; 
   @Id 
   @GeneratedValue(strategy = GenerationType.AUTO) 
   private Long id; 
   private String name; 
   private int age; 
   @OneToOne 
private Address address; 
 
// 　 Getters & Setters 
}
```

单向一对一关系的反端

```java
@Entity 
public class Address implements Serializable { 
   private static final long serialVersionUID = 1L; 
   @Id 
   @GeneratedValue(strategy = GenerationType.AUTO) 
   private Long id; 
   private String street; 
   private String city; 
private String country; 
// Gettes& Setters 
}
```



###  2.双向OneToOne

![1564457592744](D:\smeyun\doc\spring\1564457592744.png)

**双向一对一关系中的接受端**

```java
@Entity 
public class Address implements Serializable { 
   private static final long serialVersionUID = 1L; 
   @Id 
   @GeneratedValue(strategy = GenerationType.AUTO) 
   private Long id; 
   private String street; 
   private String city; 
private String country; 
@OneToOne(mappedBy = "address") 
private Person person; 
// Gettes& Setters 
 
}
```

### **3.单向OneToMany**

![1564457610750](D:\smeyun\doc\spring\1564457610750.png)

单向一对多关系的发出端

```java
public class Person implements Serializable { 
   private static final long serialVersionUID = 1L; 
   @Id 
   @GeneratedValue(strategy = GenerationType.AUTO) 
   private Long id; 
   private String name; 
   private int age; 
   @OneToMany 
   private List<CellPhone> cellPhones; 
   // Getters and Setters 
}
```

单向一对多关系的接收端

```java
@Entity 
public class CellPhone implements Serializable { 
   private static final long serialVersionUID = 1L; 
   @Id 
   @GeneratedValue(strategy = GenerationType.AUTO) 
   private Long id; 
   private String manufacture; 
   private String color; 
   private Long  phoneNo; 
   // Getters and Setters 
}
```



### **4.单向ManyToMany**

![1564457732926](D:\smeyun\doc\spring\1564457732926.png)

单向多对多关系的发出端

```java
@Entity 
public class Teacher implements Serializable { 
   
   private static final long serialVersionUID = 1L; 
   @Id 
   @GeneratedValue(strategy = GenerationType.AUTO) 
   private Long id; 
   private String name; 
   private Boolean gender; 
   private int age; 
   private int height; 
   @ManyToMany 
private List<Student> students; 
// Getters  and  Setters 
}
```

单向多对多关系的反端

```java
@Entity 
public class Student implements Serializable { 
   private static final long serialVersionUID = 1L; 
   @Id 
   @GeneratedValue(strategy = GenerationType.AUTO) 
   private Long id; 
   private String name; 
   private Boolean gender; 
   private int age; 
   private int height; 
  //Getters  and  Setters 
}
```



### **5.双向ManyToMany**

![1564457832444](D:\smeyun\doc\spring\1564457832444.png)

双向多对多关系的拥有端

```java
@Entity 
public class Teacher implements Serializable { 
   
   private static final long serialVersionUID = 1L; 
   @Id 
   @GeneratedValue(strategy = GenerationType.AUTO) 
   private Long id; 
   private String name; 
   private Boolean gender; 
   private int age; 
   private int height; 
   @ManyToMany 
private List<Student> students; 
// Getters  and  Setters 
}
```

双向多对多关系的反端

```java
@Entity 
public class Student implements Serializable { 
   private static final long serialVersionUID = 1L; 
   @Id 
   @GeneratedValue(strategy = GenerationType.AUTO) 
   private Long id; 
   private String name; 
   private Boolean gender; 
   private int age; 
   private int height; 
   @ManyToMany(mappedBy = "students") 
   private List<Teacher> teachers; 
   //Getters  and  Setters 
}
```



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
     * ALT + Insert 选(Constructor)创建有参的构造函数
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

### 1.8 IDEA 使用

1.鼠标控制文字大小，类提示

![1562567470130](D:\smeyun\doc\spring\1562567470130.png)

2.自动导包

![1562567660434](D:\smeyun\doc\spring\1562567660434.png)



3.显示行号和方法的分割符

![1562567997320](D:\smeyun\doc\spring\1562567997320.png)

4。多行显示类名

![1562568226678](D:\smeyun\doc\spring\1562568226678.png)



5.自动编译build

![1562568450406](D:\smeyun\doc\spring\1562568450406.png)



| 快捷键      | 功能             |      |
| ----------- | ---------------- | ---- |
| shift+enter | 切换到代码下一行 |      |
| ctrl+d      | 复制一行         |      |
| ctrl+y      | 删除一行         |      |







## 2.开发工具Eclipse



# 五、spring boot开发实战

Spring框架核心：

- 解耦依赖 DI（依赖注入），系统模块化 AOP 

| 注解        | 用途                         |        |
| ----------- | ---------------------------- | ------ |
| @Component  | 标注一个普通的spring bean 类 | 注入类 |
| @Controller | 标注一个控制器组件类         |        |
| @Service    | 标注一个业务逻辑组件类       |        |
| @Repository | 标注一个DAO组件类            |        |
|             |                              |        |



##  1 SpringBoot+MyBatis+Thymeleaf 注册登录

Controller，作为接受页面数据的工具

Dao是操作数据库的工具

Domin是放的实体类

Service主要是操作数据检查合法性,通过Service来发出指令



注册（登录与其相同）：

- 前端页面（templates）把用户的注册信息传递给Controller
- Conteoller把注册信息交给Service去处理
- Service里面和Dao层一起处理业务逻辑（结合数据库判断数据合法性）
- Service把处理结果返回给Controller
- Controller在把结果传递给前端页面，这是用户就能看见注册结果了
   C->V->M->V->C 的流程不多说了。

![1564542677567](D:\smeyun\doc\spring\1564542677567.png)



1.1 view

前端展示页面，基于thymeleaf模版：index.html  

```html
<!--index.html-->
<!--模板源码应该很好理解，不理解的话去看看教程就OK-->
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8">
    <title>首页</title>
</head>
<body>
<!--这里result会报错，不要担心这是idea的bug，不影响你的项目->
<h1> <span th:text="${result}"></span></h1>
<h1>欢迎 ： <span  th:text="${session.user}?${session.user.getUsername()}:'（您未登录）'" ></span> </h1>
<a th:href="@{/register}">点击注册</a>
<a th:href="@{/login}" th:if="${session.user==null}">点击登录</a>
<a th:href="@{/loginOut}" th:unless="${session.user==null}">退出登陆</a>
</body>
</html>
```

login.html

```java
<!--login.html-->

<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8">
    <title>登陆</title>
</head>
<body>
<h1>欢迎登陆</h1>
 <!--这个地方user也会报错，不用担心-->
<!--注意下面name，和id都写上就OK-->
<form th:action="@{/login}" th:object="${user}" method="post">
    <label for="username">username:</label>
    <input type="text" name="username"  id="username" />
    <label for="password">password:</label>
    <input type="text" name="password" id="password" />
    <input type="submit" value="submit">
</form>
</body>
</html>
```

register.html

```java
<!--register.html-->

<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8">
    <title>欢迎注册</title>
</head>
<body>
<h1>欢迎注册</h1>
<form th:action="@{/register}" th:object="${user}" method="post">
    <label for="username">username:</label>
    <input type="text" id="username" name="username"/>
    <label for="password">password:</label>
    <input type="text" id="password" name="password"/>
    <input type="submit" value="submit">
</form>
</body>
</html>
```

TIp:页面的重点放在input的一些属性上，我们输入的值最终会被映射到user（domin）里面



1.2 后端

1.2.1 入口main

添加mapper扫描的包路径，为数据库连接做准备

```java
@SpringBootApplication
//Mapper扫描（这里的值就是dao目录的值，按照我刚贴的目录结构来做就行）
@MapperScan("com.example.demo.dao")
public class DemoApplication {

    public static void main(String[] args) {
        SpringApplication.run(DemoApplication.class, args);
    }
}
```

1.2.2 API接口 controller：

实现的功能主要有三个，注册登录注销，那么我们的Controller如下

```java
package com.example.demo.controller;
@Controller
@EnableAutoConfiguration
public class IndexController {
    //自动注入userService，用来处理业务
    @Autowired
    private UserService userService;
     /**
      * 域名访问重定向
      * 作用：输入域名后重定向到index（首页）
      * */
    @RequestMapping("")
    public String index(HttpServletResponse response) {
        //重定向到 /index
        return response.encodeRedirectURL("/index");
    }
    /**
     * 首页API
     * 作用：显示首页
     * */
    @RequestMapping("/index")
    public String home(Model model) {
        //对应到templates文件夹下面的index
        return "index";
    }
    /**
     * 注册API
     * @method：post
     * @param user（从View层传回来的user对象）
     * @return 重定向
     * */
    @RequestMapping(value = "/register", method = RequestMethod.POST)
    public String registerPost(Model model,
                               //这里和模板中的th:object="${user}"对应起来
                               @ModelAttribute(value = "user") User user,
                               HttpServletResponse response) {
        //我们可以用Sout这种最原始打印方式来检查数据的传输
        System.out.println("Controller信息:"+user.getUsername());
        System.out.println("Controller密码:"+user.getPassword());
        //使用userService处理业务
        String result = userService.register(user);
        //将结果放入model中，在模板中可以取到model中的值
        //这里就是交互的一个重要地方，我们可以在模板中通过这些属性值访问到数据
        model.addAttribute("result", result);
        //开始重定向，携带数据过去了。
        return response.encodeRedirectURL("/index");
    }
    /**
     * 登录API
     * @method：post
     * @param user（从View层传回来的user对象）
     * @return 重定向
     * */
    @RequestMapping(value = "/login", method = RequestMethod.POST)
    public String loginPost(Model model,
                            @ModelAttribute(value = "user") User user,
                            HttpServletResponse response,
                            HttpSession session) {
        String result = userService.login(user);
        if (result.equals("登陆成功")) {
           //session是作为用户登录信息保存的存在
            session.setAttribute("user",user);
        }
        model.addAttribute("result", result);
        return response.encodeRedirectURL("/index");
    }
    /**
     * 注销API
     * @method：get
     * @return 首页
     * */
    @RequestMapping(value = "/loginOut", method = RequestMethod.GET)
    public String loginOut(HttpSession session) {
        //从session中删除user属性，用户退出登录
        session.removeAttribute("user");
        return "index";
    }
}
```

Tip:不会使用单元测试或调试的话可以用System.out.print这种最原始的方法来检查数据哦

1.2.3 sevice

其实就是与dao联系起来做数据合法性检验的。

```java
@Service
public class UserService {
    //自动注入一个userDao
    @Autowired
    private UserDao userDao;

    //用户注册逻辑
    public String  register(User user) {
        System.out.println(user.getUsername());
        User x = userDao.getOneUser(user.getUsername());
        //判断用户是否存在
        if (x == null) {
            userDao.setOneUser(user);
            return "注册成功";
        }
        else {
            return x.getUsername()+"已被使用";
        }
    }
    //用户登陆逻辑
    public String login(User user) {
        //通过用户名获取用户
        User dbUser = userDao.getOneUser(user.getUsername());

        //若获取失败
        if (dbUser == null) {
            return "该用户不存在";
        }
        //获取成功后，将获取用户的密码和传入密码对比
        else if (!dbUser.getPassword().equals(user.getPassword())){
            return "密码错误";
        }
        else {
            //若密码也相同则登陆成功
            //让传入用户的属性和数据库保持一致
            user.setId(dbUser.getId());
            return "登陆成功";
        }
    }
}
```

Tip：这里也是可以使用sout来测试数据



1.2.4 Dao

Dao目录下面放的各种dao文件是我们的数据库操作接口（抽象数据类），例如我们的UserDao内容如下，两个操作，增加用户，查询用户。
所以在以后的项目中，如果需求大的话，我们可以编写更多功能。

```java
package com.example.demo.dao;

//这个注解代表这是一个mybatis的操作数据库的类
@Repository
public interface UserDao {
    // 根据username获得一个User类
    @Select("select * from user where username=#{name}")
    User getOneUser(String name);


    //插入一个User
    @Insert("insert into user (username,password) values(#{username},#{password})")
    boolean setOneUser(User user);

}
```

Tip:注意字段对应 比如#{name}最后会被String name 的name所替换



1.2.5 实体类

domin目录下面放实体类，我们第一步先把实体类做出来，为整体的流程做协调，根据我们的数据库设计字段，来设计实体类

```java
package com.example.demo.domin;
public class User {
    private int id;
    private String username;
    private String password;
    public int getId() {
        return id;
    }
    public void setId(int id) {
        this.id = id;
    }
    public String getUsername() {
        return username;
    }
    public void setUsername(String username) {
        this.username = username;
    }
    public String getPassword() {
        return password;
    }
    public void setPassword(String password) {
        this.password = password;
    }
}
```







# 六、相关参考文档

spring 4.3.13 framework：

<https://docs.spring.io/spring/docs/4.3.13.RELEASE/spring-framework-reference/htmlsingle/>

