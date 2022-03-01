package com.example.demoMaven.Mockito;


import com.example.demoMaven.model.entity.FriendEnity.Friendlist;
import com.example.demoMaven.model.entity.LeaderboardEnity.SingleLeaderBoard;
import com.example.demoMaven.model.entity.User;
import com.example.demoMaven.repository.FriendRepository.FriendListRepository;
import com.example.demoMaven.repository.UserRepository;
import com.example.demoMaven.service.FriendService.FriendListApiLogicService;
import org.junit.Before;
import org.junit.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.web.servlet.MockMvc;

import java.util.ArrayList;
import java.util.List;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class TestFriendListApiLogicService {

    private MockMvc mockMvc;

    @InjectMocks
    private FriendListApiLogicService friendListApiLogicService;
    @Mock
    private FriendListRepository friendListRepository;
    @Mock
    private UserRepository userRepository;

    @Before
    public void init() {
        MockitoAnnotations.initMocks(this);
    }

    @Test
    public void createTest() {
        List<User> user = new ArrayList<User>();
        User user1 = new User();
        User user2 = new User();
        User user3 = new User();

        SingleLeaderBoard single1 = new SingleLeaderBoard();
        single1.setSingleLeaderBoard_id(1L);
        single1.setAccount("test1");
        single1.setScore(100);
        user1.setSingleLeaderBoard(single1);
        user2.setSingleLeaderBoard(single1);
        user3.setSingleLeaderBoard(single1);

        user1.setAccount("test1");
        user2.setAccount("test2");
        user3.setAccount("test3");

        user1.setPw("1234");
        user2.setPw("1234");
        user3.setPw("1234");

        user.add(user1);
        user.add(user2);
        user.add(user3);

        when(userRepository.findAll()).thenReturn(user);


        Friendlist friend = new Friendlist();
//        friend.setUser(user1);
        friend.setFriendname("test2");

        when(friendListRepository.save(friend)).thenReturn(friend);

        Friendlist result = friendListApiLogicService.create(friend,"test1");
        assertEquals((String)"test2",result.getFriendname());
        assertEquals((String)"test1",result.getUser().getAccount());

    }

    //Test read
    //have to do it! not complete
    @Test
    public void readTest() {
        User user1 = new User();
        user1.setAccount("test1");
        user1.setUser_id(1L);

        List<Friendlist> friend = new ArrayList<Friendlist>();
        Friendlist friend1 = new Friendlist();
        Friendlist friend2 = new Friendlist();

        friend1.setFriendname("test2");
        friend1.setUser(user1);
        friend2.setFriendname("test3");
        friend2.setUser(user1);
        friend.add(friend1);
        friend.add(friend2);


        when(friendListRepository.findAll()).thenReturn(friend);

        List<String> result = friendListApiLogicService.read("test1");
        assertEquals(2,result.size());
        verify(friendListRepository, times(1)).findAll();

    }
}