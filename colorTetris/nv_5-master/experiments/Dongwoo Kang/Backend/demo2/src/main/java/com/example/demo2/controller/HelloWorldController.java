package com.example.demo2.controller;

import com.example.demo2.model.ParamObj;
import org.springframework.web.bind.annotation.*;

@RestController
public class HelloWorldController {
   @RequestMapping(method = RequestMethod.GET, path = "/hello") //Localhost:8080/api/getMethod
   public String getRequest(){
       return "Please get A";
   }

    @GetMapping("/getParameter")  //localhost:8080/hello/getParameter?id=abc&password=qwer
    public String getParameter(@RequestParam String id, @RequestParam String password) {
        System.out.println("id : " + id);
        System.out.println("password : " +password);

        return id+password;
    }
    @GetMapping("/getMultiParameter") //localhost:8080/hello/getMultiParameter?account=dongwoo&email=dongwoo@iastate.edu&page=2
    public String getMultiParameter(ParamObj paramObj) {
        System.out.println(paramObj.getAccount());
        System.out.println(paramObj.getEmail());
        System.out.println(paramObj.getPage());

        return "Good Work";
    }
}

