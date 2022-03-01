package com.example.demoMaven.model.entity.FriendEnity;

import com.example.demoMaven.model.entity.User;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.persistence.*;

/**
 * Friendlist entity
 * @author Jihoo
 */

@Data
@Entity
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Friendlist {
    /**
     * Long id
     * generate Id number automatically
     */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private long Friend_id;

    /**
     * friendname
     */
    private String friendname;

    /**
     * user
     * Many to One relationship
     */
    @ManyToOne
    @JoinColumn(name="user_id")
    private User user;
}
