package com.example.demo7.idList;

import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@AllArgsConstructor
@Service
public class ser {

    private idRepository idR;

    public List<idList> finaAll() {
        return idR.findAll();
    }

    public Optional<idList> findOne(double id) {
        return idR.findById(id);
    }

}
