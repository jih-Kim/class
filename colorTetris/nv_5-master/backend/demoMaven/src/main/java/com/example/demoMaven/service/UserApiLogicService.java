package com.example.demoMaven.service;


import com.example.demoMaven.model.entity.LeaderboardEnity.SingleLeaderBoard;
import com.example.demoMaven.model.entity.User;
import com.example.demoMaven.repository.LeaderboardRepository.SingleLeaderBoardRepository;
import com.example.demoMaven.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.awt.print.PrinterException;
import java.util.List;

/**
 * Api Logic Service for User
 * @author Jihoo
 * @author Dongwoo
 */

@Service
public class UserApiLogicService {

    /**
     * UserRepository
     */
    @Autowired
    private UserRepository userRepository;

    /**
     * SingleLeaderBoardRepository
     */
    @Autowired
    private SingleLeaderBoardRepository singleLeaderBoardRepository;

    /**
     *     create method for user
     *     @param user
     *     @return User
     */
    public User create(User user) {

        User userdata = new User();
        userdata.setAccount(user.getAccount());
        userdata.setPw(user.getPw());

        SingleLeaderBoard singleLeaderBoard = new SingleLeaderBoard();
        singleLeaderBoard.setAccount(user.getAccount());
        singleLeaderBoard.setScore(0);
        userdata.setSingleLeaderBoard(singleLeaderBoard);

        userRepository.save(userdata);
        return userdata;

    }

    /**
     *     read method for user
     *     @return List<User>
     */
    public List<User> read() {
        return userRepository.findAll();
    }

    /**
     * update pw method
     * @param user
     * @param account
     * @return User
     * @throws PrinterException
     */
    public User updatePw(User user, String account) throws PrinterException {
        User userdata = userRepository.findByAccount(account);
        userdata.setPw(user.getPw());
        userRepository.save(userdata);
        return userdata;
    }

    /**
     *     delete method for user
     *     @param id
     */
    public void delete(Long id) {

        singleLeaderBoardRepository.deleteById(id);
        userRepository.deleteById(id);

    }
    /**
     *     checkAccount method for user
     *     return 0 if account is duplicate or else return 1
     *     @param account
     *     @return boolean
     */
    public boolean checkAccountDuplicate(String account)
    {
        List<User> userData = read();
        for(int i=0;i<userData.size();i++)
        {
            if(userData.get(i).getAccount().equals(account))
                return false;
        }
        return true;
    }


    /**
     *     check password method for user
     *     return 0 if password and account does not match or else return 1
     *     @param account
     *     @param password
     *     @return boolean
     */
    public boolean checkPasswordMatchAccount(String account, String password)
    {
        List<User> userData = read();
        int index=-1;
        for(int i=0;i<userData.size();i++)
        {
            if(userData.get(i).getAccount().equals(account))
                index=i;
        }
        if(index!=-1&&userData.get(index).getPw().equals(password)) {

            return true;
        }
        else
            return false;
    }

}
