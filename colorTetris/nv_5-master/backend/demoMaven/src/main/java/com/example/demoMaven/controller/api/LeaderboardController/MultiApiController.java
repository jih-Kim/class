package com.example.demoMaven.controller.api.LeaderboardController;

import com.example.demoMaven.model.entity.LeaderboardEnity.MultiLeaderBoard;
import com.example.demoMaven.service.LeaderboardService.MultiLogicService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * controller for multi playing game.
 * @author Dongwoo
 */
@Slf4j
@RestController
@RequestMapping("/api/multi")
public class MultiApiController {

    /**
     * Connect with MultiLogicService.
     */
    @Autowired
    private MultiLogicService multiLogicService;

    /**
     * testing the controller
     * @return String
     */
    @RequestMapping(method = RequestMethod.GET, path = "/test")
    private String test() {
        return "The multi is working now";
    }

    /**
     * create score
     * This function is for administrator (If the administrator want to add particular player)
     * @param multiLeaderBoard
     */
    @PostMapping("/create")
    private void createScore(@RequestBody MultiLeaderBoard multiLeaderBoard) {
        multiLogicService.createScore(multiLeaderBoard);
    }


    /**
     * Read all score in multi leader-board.
     * @return List<MultiLeaderBoard>
     */
    @GetMapping("/read")
    private List<MultiLeaderBoard> showAllScore() {
        return multiLogicService.showAllScore();
    }

    /**
     * Read one particular score in leader-board.
     * @param account
     * @return Integer score
     */
    @GetMapping("/readOne/{account}")
    private Integer oneScore(@PathVariable String account) {
        return multiLogicService.showScore(account);
    }

    /**
     * update a particular user's score
     * This function is for administrator (If the administrator want to update particular player)
     * @param multiLeaderBoard
     * @param account
     */
    @PutMapping("/update/{account}")
    private void updateScore(@RequestBody MultiLeaderBoard multiLeaderBoard, @PathVariable String account) {
        multiLogicService.updateScore(multiLeaderBoard, account);
    }

    /**
     * delete one user
     * @param id
     */
    @DeleteMapping("/delete/{id}")
    private void delete(@PathVariable Long id) {
        multiLogicService.delete(id);
    }
}
