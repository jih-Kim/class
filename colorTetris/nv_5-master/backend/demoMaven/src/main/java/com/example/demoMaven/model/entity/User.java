package com.example.demoMaven.model.entity;

import com.example.demoMaven.model.entity.LeaderboardEnity.SingleLeaderBoard;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.persistence.*;

/**
 * User Entity
 * @author Jihoo
 * @author Dongwoo
 */
@Data
@Entity
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User {

    /**
     * Long id number for user
     */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long user_id;

    /**
     * Account name
     */
    private String account;

    /**
     * password
     */
    private String pw;

    /**
     * SingleLeaderBoard.
     * One to One relationship
     */
    @OneToOne(cascade = CascadeType.ALL)
    @JoinColumn(name = "SingleLeaderBoard_id")
    private SingleLeaderBoard singleLeaderBoard;
}
