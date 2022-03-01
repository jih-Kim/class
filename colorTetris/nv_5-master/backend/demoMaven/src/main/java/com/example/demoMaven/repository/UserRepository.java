package com.example.demoMaven.repository;


import com.example.demoMaven.model.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

/**
 * interface for userRepository
 * @author Jihoo
 * @author Dongwoo
 */
@Repository
public interface  UserRepository extends JpaRepository<User, Long> {

    User findByAccount(String account);
}
