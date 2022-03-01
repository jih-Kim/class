package com.example.sqltest.Controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class Controller {

    @GetMapping("/sqlTest")
    public String test() {
        return "sql test demo";
    }
}
