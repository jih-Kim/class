package com.example.demoMaven.controller.api.LeaderboardController;


import com.example.demoMaven.model.entity.LeaderboardEnity.SingleLeaderBoard;
import com.example.demoMaven.service.LeaderboardService.SingleLogicService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.awt.print.PrinterException;
import java.util.List;

/**
 * Controller for single play game
 * @author Dongwoo
 */
@Slf4j
@RestController
@RequestMapping("/api/single")
public class SingleApiController {

    /**
     * SingleApiLogicService
     */
    @Autowired
    private SingleLogicService singleLogicService;

    /**
     * update a particular user's score
     * @param singleLeaderBoard
     * @param account
     * @return "succeed" message.
     */
    @PutMapping("/updateScore/{account}")
    private String updateScore(@RequestBody SingleLeaderBoard singleLeaderBoard, @PathVariable String account) {
        singleLogicService.updateScore(singleLeaderBoard, account);
        return "succeed";
    }

    /**
     * read one user score.
     * @param account
     * @return Integer score
     * @throws PrinterException
     */
    @GetMapping("/read/{account}")
    private Integer read(@PathVariable String account) throws PrinterException {
        return singleLogicService.showScore(account);
    }

    /**
     * read all user score.
     * @return List<SingleLeaderBoard>
     */
    @GetMapping("/readAll")
    private List<SingleLeaderBoard> readAll() {
        return singleLogicService.showAllScore();
    }

    /**
     * delete one user
     * @param id
     */
    @DeleteMapping("/delete/{id}")
    private void delete(@PathVariable Long id) {
        singleLogicService.delete(id);
    }
}
