package com.example.demoMaven.repository.FriendRepository;

import com.example.demoMaven.model.entity.FriendEnity.Message;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * interface for message
 * @author Jihoo
 */
public interface MessageRepository extends JpaRepository<Message,Long> {
}
