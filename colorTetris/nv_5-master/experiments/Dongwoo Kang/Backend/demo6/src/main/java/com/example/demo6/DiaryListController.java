package com.example.demo6;


import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import java.util.List;


@Controller
@RequestMapping("/")
public class DiaryListController {
    private static final String user = "Dongwoo";

    private DiaryListRepository dlr;

    @Autowired
    public DiaryListController(DiaryListRepository dlr) {
        this.dlr=dlr;
    }

    @RequestMapping(method = RequestMethod.GET)
    public String users(Model model) {
        List<Diary> dl = dlr.findByUser(user);
        if(dl != null) {
            model.addAttribute("diarys",dl);
        }
        return  "diarylist";
    }

    @RequestMapping(method = RequestMethod.POST)
    public String addToList(Diary di) {
        di.setUser(user);
        dlr.save(di);
        return "redirect:/";
    }



}
