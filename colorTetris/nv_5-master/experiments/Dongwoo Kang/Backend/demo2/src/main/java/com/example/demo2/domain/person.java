package com.example.demo2.domain;


import com.fasterxml.jackson.annotation.JsonTypeInfo;
import org.springframework.boot.autoconfigure.domain.EntityScan;

import javax.annotation.Generated;

@EntityScan
public class person {
    private double id;
}
