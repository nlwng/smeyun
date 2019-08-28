package com.cloud.springboot.controller;


import com.cloud.springboot.exception.UserNotExistException;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.ExceptionHandler;

import javax.servlet.http.HttpServletRequest;

import java.util.HashMap;
import java.util.Map;

@Controller
public class MyExceptionHandler {

//    @ResponseBody
//    @ExceptionHandler(UserNotExistException.class)
//    public Map<String,Object>  handleException(Exception e){
//
//         Map<String,Object> map = new HashMap<>();
//
//         map.put("code","user.notexist");
//         map.put("message",e.getMessage());
//         return map;

    @ExceptionHandler(UserNotExistException.class)
    public String handleException(Exception e, HttpServletRequest request){
        Map<String,Object> map = new HashMap<>();
        //传入我们自己的错误状态码  4xx 5xx，否则就不会进入定制错误页面的解析流程
        /**
         * Integer statusCode = (Integer) request
         .getAttribute("javax.servlet.error.status_code");
         */
        request.setAttribute("javax.servlet.error.status_code",500);
        map.put("code","user.notexist");
        map.put("message",e.getMessage());

        request.setAttribute("ext",map);
        //转发到/error
        return "forward:/error";

    }

}
