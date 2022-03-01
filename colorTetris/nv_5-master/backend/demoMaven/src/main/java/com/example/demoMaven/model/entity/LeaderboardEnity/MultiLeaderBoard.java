package com.example.demoMaven.model.entity.LeaderboardEnity;

import com.sun.istack.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.persistence.*;
import javax.persistence.criteria.CriteriaBuilder;
import java.util.Date;

/**
 * Multileaderboard entity
 */
@Data
@Entity
@AllArgsConstructor
@Builder
public class MultiLeaderBoard {

    /**
     * Long id for user
     */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * Account name
     */
    private String account;

    /**
     * score
     */
    private Integer score;

    /**
     * The sent data log
     */
    @NotNull
    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "sent")
    private Date sent = new Date();

    /**
     * constructor without variable.
     */
    public MultiLeaderBoard() {

    };

    /**
     * constructor
     * @param account
     * @param score
     */
    public MultiLeaderBoard(String account, String score) {
        this.account = account;
        this.score = Integer.parseInt(score);
    }

}
