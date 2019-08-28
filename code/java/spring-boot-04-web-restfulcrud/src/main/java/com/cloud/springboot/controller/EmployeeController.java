package com.cloud.springboot.controller;

import com.cloud.springboot.entity.Department;
import com.cloud.springboot.entity.Employee;
import com.cloud.springboot.repository.DepartmentRepository;
import com.cloud.springboot.repository.EmployeeRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.Collection;

@Controller
public class EmployeeController {

    @Autowired
    EmployeeRepository employeeRepository;

    /**
     * 把部门的deo拿过来
     */
    @Autowired
    DepartmentRepository departmentRepository;

    @GetMapping("/emps")
    public String list(Model model){

        Collection<Employee> employees = employeeRepository.findAll();
        //放在请求域中;
        model.addAttribute("emps",employees);
        //thymeleaf默认会拼串
        return "emp/list";

    }

    @GetMapping("/emp")
    public String toAddPage(Model model){
        //来到添加页面,查出所有部门在页面显示
        Collection<Department> departments = departmentRepository.findAll();

        /**
         * 给model添加变量,把departmentst添加进来depts
         *
         */
        model.addAttribute("depts",departments);

        return "emp/add";

    }
    //员工添加功能
    //SpringMVC自动将请求参数和入参的属性进行一一绑定
    //要求请求参数的名字和javaBean入参的对象属性名是一样的
    @PostMapping("/emp")
    public String addEmp(Employee employee){
        System.out.println("保存的员工信息："+employee);

        //保存员工
        employeeRepository.save(employee);
        //来到员工列表页面
        //redirect:表示重定向到一个地址
        //forward:表示转发到一个地址
        return "redirect:/emps";

    }
    @GetMapping("/emp/{id}")
    public String toEditPage(@PathVariable("id") Integer id, Model model){
        Employee employee = employeeRepository.findOne(id);
        model.addAttribute("emp",employee);

        //查出部门信息，页面显示所有部门列表
        Collection<Department> departments = departmentRepository.findAll();
        model.addAttribute("depts",departments);

        //回到修改页面
        return "emp/add";
    }

    //员工修改:需要提交员工ID
    @PutMapping("/emp")
    public String updateEmployee(Employee employee){
        System.out.println("修改的员工数据:"+employee);
        employeeRepository.save(employee);
        return "redirect:/emps";
    }


    //删除员工
    @DeleteMapping("/emp/{id}")
    public String deleteEmployee(@PathVariable("id") Integer id){
        employeeRepository.delete(id);
        return "redirect:/emps";

    }
}
