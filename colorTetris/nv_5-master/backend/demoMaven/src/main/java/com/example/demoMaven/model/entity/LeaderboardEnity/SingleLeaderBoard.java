package com.example.demoMaven.model.entity.LeaderboardEnity;

import com.example.demoMaven.model.entity.User;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.persistence.*;

/**
 * SingleLeaderBoard Entity
 */
@Data
@Entity
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SingleLeaderBoard {

    /**
     * Long id for user
     */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long SingleLeaderBoard_id;

    /**
     * Account name
     */
    private String account;

    /**
     * score
     */
    private Integer score;
}