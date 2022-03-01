package com.example.demoMaven.repository.LeaderboardRepository;

import com.example.demoMaven.model.entity.LeaderboardEnity.MultiLeaderBoard;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
/**
 * interface for multirepository
 */
public interface MultiLeaderBoardRepository extends JpaRepository<MultiLeaderBoard, Long> {

    MultiLeaderBoard findByAccount(String account);
}
