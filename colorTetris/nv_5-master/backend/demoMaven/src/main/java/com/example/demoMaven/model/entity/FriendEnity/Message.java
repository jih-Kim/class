package com.example.demoMaven.model.entity.FriendEnity;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import javax.persistence.*;
import java.time.LocalDateTime;

/**
 * Friendlist entity
 * @author Jihoo
 */

@Data
@Entity
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Message {
    /**
     * message Id
     * generate Id number automatically
     */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private long Message_Id;
    /**
     * sender
     */
    private String sender;
    /**
     * receiver
     */
    private String receiver;
    /**
     * local date time
     * create automatically by using CreationTimestemp
     */
    @CreationTimestamp
    private LocalDateTime createDateTime;
    /**
     * message
     */
    private String message;
}