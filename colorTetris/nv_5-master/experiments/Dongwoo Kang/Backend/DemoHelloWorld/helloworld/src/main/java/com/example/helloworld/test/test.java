package com.example.helloworld.test;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class test {
    @GetMapping(value = "/helloworld")
    public String helloWorld() {
        return "Pleas...help me";
    }
}
