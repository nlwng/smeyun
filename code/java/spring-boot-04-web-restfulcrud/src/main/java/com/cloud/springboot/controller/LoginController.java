package com.cloud.springboot.controller;

import org.apache.catalina.User;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import javax.servlet.http.HttpSession;
import java.nio.file.spi.FileSystemProvider;
import java.util.Map;

@Controller
public class LoginController {


    @PostMapping(value = "/user/login")
    //@RequestMapping(value = "/user/login",method = RequestMethod.POST )
    public String login(@RequestParam("username") String username,
                        @RequestParam("password") String password,
                        Map<String,Object> map, HttpSession session){

        if (!StringUtils.isEmpty(username) && "123".equals(password)){
            session.setAttribute( "loginUser",username);
            return "redirect:/main.html";
            //return "dashboard";
    }else{
            map.put("msg","用户名密码错误");
        }
        return "login";

    }
}

