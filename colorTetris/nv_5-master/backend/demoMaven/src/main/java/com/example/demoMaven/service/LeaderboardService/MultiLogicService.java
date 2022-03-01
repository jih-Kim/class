package com.example.demoMaven.service.LeaderboardService;

import com.example.demoMaven.model.entity.LeaderboardEnity.MultiLeaderBoard;
import com.example.demoMaven.repository.LeaderboardRepository.MultiLeaderBoardRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.PathVariable;

import java.util.List;

/**
 * Api Logic Service for Multiplayer
 */
@Service
public class MultiLogicService implements  LeaderBoardLogicService{

    /**
     * MultiLeaderBoardRepository
     */
    @Autowired
    private MultiLeaderBoardRepository mlf1Repository;

    /**
     * create score.
     * @param multiLeaderBoard
     * @return
     */
    public MultiLeaderBoard createScore(MultiLeaderBoard multiLeaderBoard) {
        MultiLeaderBoard multiLeaderBoardData = new MultiLeaderBoard();
        multiLeaderBoardData.setScore(multiLeaderBoard.getScore());
        multiLeaderBoardData.setAccount(multiLeaderBoard.getAccount());

        mlf1Repository.save(multiLeaderBoardData);
        return multiLeaderBoardData;
    }

    /**
     * update one score.
     * @param multiLeaderBoard
     * @param account
     * @return
     */
    public MultiLeaderBoard updateScore(MultiLeaderBoard multiLeaderBoard, String account) {
        MultiLeaderBoard multiLeaderBoardData = mlf1Repository.findByAccount(account);

        multiLeaderBoardData.setScore(multiLeaderBoard.getScore());
        multiLeaderBoardData.setAccount(multiLeaderBoard.getAccount());

        mlf1Repository.save(multiLeaderBoardData);

        return multiLeaderBoardData;
    }

    /**
     * read all score.
     * @return
     */
    public List<MultiLeaderBoard> showAllScore() {
        return mlf1Repository.findAll();
    }

    /**
     * read one score.
     * @param account
     * @return
     */
    @Override
    public Integer showScore(String account) {
        return mlf1Repository.findByAccount(account).getScore();
    }

    /**
     * delete one score.
     * @param id
     */
    @Override
    public void delete(@PathVariable Long id) {
        mlf1Repository.deleteById((id));
    }
}
