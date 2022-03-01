package com.example.demoMaven.MockitoDongwoo;

import com.example.demoMaven.model.entity.LeaderboardEnity.MultiLeaderBoard;
import com.example.demoMaven.model.entity.LeaderboardEnity.SingleLeaderBoard;
import com.example.demoMaven.repository.LeaderboardRepository.MultiLeaderBoardRepository;
import com.example.demoMaven.service.LeaderboardService.MultiLogicService;
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
public class TestMultiLogicService {

    private MockMvc mockMvc;

    @InjectMocks
    private MultiLogicService multiLogicService;

    @Mock
    private MultiLeaderBoardRepository multiLeaderBoardRepository;

    @Before
    public void init() {
        MockitoAnnotations.initMocks(this);
    }

    @Test
    public void createTest() {

        MultiLeaderBoard multiLeaderBoard = new MultiLeaderBoard();
        multiLeaderBoard.setId(1L);
        multiLeaderBoard.setAccount("Test");
        multiLeaderBoard.setScore(234);


        MultiLeaderBoard temp = multiLogicService.createScore(multiLeaderBoard);
        assertEquals((String) "Test", temp.getAccount());
        assertEquals((Integer)234, temp.getScore());
    }

    @Test
    public void readTest() {
        MultiLeaderBoard s1 = new MultiLeaderBoard("test1", "300");

        when(multiLeaderBoardRepository.findByAccount(s1.getAccount())).thenReturn(s1);

        Integer temp = multiLogicService.showScore("test1");

        assertEquals((Integer)300, temp);

    }

    @Test
    public void readAllTest() {
        List<MultiLeaderBoard> list = new ArrayList<MultiLeaderBoard>();
        MultiLeaderBoard multi1 = new MultiLeaderBoard("Test1",  "500");
        MultiLeaderBoard multi2 = new MultiLeaderBoard("Test2",  "345");
        MultiLeaderBoard multi3 = new MultiLeaderBoard("Test3",  "120");

        list.add(multi1);
        list.add(multi2);
        list.add(multi3);

        when(multiLeaderBoardRepository.findAll()).thenReturn(list);

        List<MultiLeaderBoard> mList = multiLogicService.showAllScore();

        assertEquals(3, mList.size());
        verify(multiLeaderBoardRepository, times(1)).findAll();
    }

    @Test
    public void updateTest() {

        MultiLeaderBoard multi1 = new MultiLeaderBoard("Test1",  "500");
        MultiLeaderBoard multi2 = new MultiLeaderBoard("Test2",  "345");
        MultiLeaderBoard multi3 = new MultiLeaderBoard("Test3",  "120");

        MultiLeaderBoard tempUp = new MultiLeaderBoard("Test1",  "55");


        when(multiLeaderBoardRepository.findByAccount(multi1.getAccount())).thenReturn(multi1);
        when(multiLeaderBoardRepository.findByAccount(multi2.getAccount())).thenReturn(multi2);
        when(multiLeaderBoardRepository.findByAccount(multi3.getAccount())).thenReturn(multi3);

        when(multiLeaderBoardRepository.save(tempUp)).thenReturn(tempUp);

        MultiLeaderBoard temp = multiLogicService.updateScore(tempUp, "Test2");

        assertEquals((Integer)55, temp.getScore());
    }
}
