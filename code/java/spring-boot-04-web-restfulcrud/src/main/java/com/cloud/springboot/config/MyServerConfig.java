package com.cloud.springboot.config;

import com.cloud.springboot.servlet.MyServlet;
import org.springframework.boot.context.embedded.ConfigurableEmbeddedServletContainer;
import org.springframework.boot.context.embedded.EmbeddedServletContainerCustomizer;
import org.springframework.boot.web.servlet.ServletRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class MyServerConfig {

    //注册三大组件
    @Bean
    public ServletRegistrationBean myServlet(){
        ServletRegistrationBean registrationBean = new ServletRegistrationBean(new MyServlet(),"/myservlet");
        return registrationBean;
    }


    /**
     * @Bean 加入容器
     *
     */
    @Bean
    public EmbeddedServletContainerCustomizer embeddedServletContainerCustomizer(){
        return new EmbeddedServletContainerCustomizer() {

            //定制嵌入式的Serviet容器相关的规则
            @Override
            public void customize(ConfigurableEmbeddedServletContainer container) {
                container.setPort(8083);
            }
        };
    }


}
