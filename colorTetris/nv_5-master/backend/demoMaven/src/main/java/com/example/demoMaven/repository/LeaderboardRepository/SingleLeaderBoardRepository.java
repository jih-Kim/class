package com.example.demoMaven.repository.LeaderboardRepository;

import com.example.demoMaven.model.entity.LeaderboardEnity.SingleLeaderBoard;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
/**
 * interface for singleRepository
 */
public interface SingleLeaderBoardRepository extends JpaRepository<SingleLeaderBoard, Long> {

    SingleLeaderBoard findByAccount(String account);

}
