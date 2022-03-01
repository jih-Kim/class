package com.example.demo.hello;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class helloworld
{
    @GetMapping("/test")
    public String helloworld()
    {
        return "Hello World!";
    }
}
