package com.example.demoMaven.repository.FriendRepository;


import com.example.demoMaven.model.entity.FriendEnity.Friendlist;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * interface for frinedlistrepository
 * @author Jihoo
 */
public interface FriendListRepository extends JpaRepository<Friendlist,Long> {
}
