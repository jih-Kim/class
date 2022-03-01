package com.example.demoMaven.service.LeaderboardService;

import com.example.demoMaven.model.entity.LeaderboardEnity.SingleLeaderBoard;
import com.example.demoMaven.repository.LeaderboardRepository.SingleLeaderBoardRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * Api Logic Service for SinglePlay
 */
@Service
public class SingleLogicService implements LeaderBoardLogicService {

    /**
     * SingleLeaderBoardRepository
     */
    @Autowired
    private SingleLeaderBoardRepository singleLeaderBoardRepository;

    /**
     * update score
     * @param singleLeaderBoard
     * @param account
     */
    public void updateScore(SingleLeaderBoard singleLeaderBoard, String account) {

        SingleLeaderBoard SLB = singleLeaderBoardRepository.findByAccount(account);


        if(singleLeaderBoard.getScore() > SLB.getScore()) {

            SLB.setScore(singleLeaderBoard.getScore());
            singleLeaderBoardRepository.save(SLB);
            System.out.println("Update Score");

        } else {
            System.out.println("Nothing changed");
        }
    }

    /**
     * read all score
     * @return
     */
    public List<SingleLeaderBoard> showAllScore() {
        return singleLeaderBoardRepository.findAll();
    }

    /**
     * read one score
     * @param account
     * @return
     */
    @Override
    public Integer showScore(String account) {
        return singleLeaderBoardRepository.findByAccount(account).getScore();
    }

    /**
     * delete one score.
     * @param id
     */
    @Override
    public void delete(Long id) {
        singleLeaderBoardRepository.deleteById(id);
    }
}
