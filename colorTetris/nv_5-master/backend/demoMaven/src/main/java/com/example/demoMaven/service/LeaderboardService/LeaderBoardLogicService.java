package com.example.demoMaven.service.LeaderboardService;

import org.springframework.web.bind.annotation.PathVariable;

/**
 * the interface for leader board
 */
public interface LeaderBoardLogicService {

    /**
     * show one score.
     * @param account
     * @return
     */
    public Integer showScore(String account);

    /**
     * delete one user.
     * @param id
     */
    public void delete(@PathVariable Long id);
}
