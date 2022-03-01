package com.example.demo7.idList;

import lombok.*;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;

@NoArgsConstructor(access = AccessLevel.PROTECTED)
@Setter
@Getter
@Entity
public class idList {

    @Id
    @GeneratedValue
    private Double id;

    @Column(length = 300, nullable = false)
    private String email;

    @Column(nullable = false)
    private String name;

    @Column
    private String city;

    @Builder
    public idList(String email, String name, String city) {
        this.email = email;
        this.name = name;
        this.city = city;
    }

}
