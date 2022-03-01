package com.example.demoMaven.service.FriendService;

import com.example.demoMaven.model.entity.FriendEnity.Friendlist;
import com.example.demoMaven.model.entity.User;
import com.example.demoMaven.repository.FriendRepository.FriendListRepository;
import com.example.demoMaven.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
/**
 * Api Logic Service for Friendlist
 * @author Jihoo
 */

@Service
public class FriendListApiLogicService {
    /**
     * FriendListRepository
     */
    @Autowired
    private FriendListRepository FriendListRepository;
    /**
     * UserRepository
     */
    @Autowired
    private UserRepository userRepository;


    /**
     * create method for friendlist
     * @param request
     * @param account
     * @return Friendlist
     */
    public Friendlist create(Friendlist request,String account) {
        List<User> dataUser = userRepository.findAll();
        for(int i=0;i<dataUser.size();i++)
        {
            if(dataUser.get(i).getAccount().equals(account))
            {
                request.setUser(dataUser.get(i));
            }
        }
        Friendlist result =  FriendListRepository.save(request);
        System.out.println("Succeed!");
        return result;
    }

    /**
     *    read method for friendlist
     *     @param account
     *     @return ArryList<String>
     */
    public ArrayList<String> read(String account)
    {
        List<Friendlist> all = FriendListRepository.findAll();
        ArrayList<String> result = new ArrayList<String>();
        for(int i=0;i<all.size();i++)
        {
            if(all.get(i).getUser().getAccount().equals(account))
            {
                result.add(all.get(i).getFriendname());
            }
        }
        System.out.println("Succeed!");
        return result;
    }

    /**
     * delete method for friendlist
     * @param account
     * @param friendname
     */
    public void delete(String account, String friendname)
    {
        List<User> dataUser = userRepository.findAll();
        Long Longindex = 0L;
        for(int i=0;i<dataUser.size();i++)
        {
            if(dataUser.get(i).getAccount().equals(account))
                Longindex =dataUser.get(i).getUser_id();
        }
        List<Friendlist> all = FriendListRepository.findAll();
        Long deleteId = 0L;
        for(int i=0;i<all.size();i++)
        {
            if(all.get(i).getUser().getUser_id().equals(Longindex)&&all.get(i).getFriendname().equals(friendname))
                deleteId = all.get(i).getFriend_id();
        }
        FriendListRepository.deleteById(deleteId);
    }
}
