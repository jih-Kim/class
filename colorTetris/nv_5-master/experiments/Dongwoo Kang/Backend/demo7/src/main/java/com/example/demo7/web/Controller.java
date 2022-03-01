package com.example.demo7.web;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class Controller {

    @GetMapping("/Hello")
    public String hello() {
        return "Last";
    }

}
