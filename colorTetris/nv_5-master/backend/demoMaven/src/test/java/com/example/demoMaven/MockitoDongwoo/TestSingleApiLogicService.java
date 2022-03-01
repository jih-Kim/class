package com.example.demoMaven.MockitoDongwoo;

import com.example.demoMaven.model.entity.LeaderboardEnity.SingleLeaderBoard;
import com.example.demoMaven.repository.LeaderboardRepository.SingleLeaderBoardRepository;
import com.example.demoMaven.service.LeaderboardService.SingleLogicService;
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
public class TestSingleApiLogicService {

    private MockMvc mockMvc;

    @InjectMocks
    private SingleLogicService singleLogicService;

    @Mock
    private SingleLeaderBoardRepository singleLeaderBoardRepository;

    @Before
    public void init() {
        MockitoAnnotations.initMocks(this);
    }

    @Test
    public void updateTest() {
        SingleLeaderBoard s1 = new SingleLeaderBoard((long)1,"test1", 300);
        SingleLeaderBoard s2 = new SingleLeaderBoard((long)1,"test2", 300);
        SingleLeaderBoard s3 = new SingleLeaderBoard((long)1,"test3", 300);

        SingleLeaderBoard updateTemp = new SingleLeaderBoard((long)1,"test2", 899);

        when(singleLeaderBoardRepository.findByAccount(s1.getAccount())).thenReturn(s1);
        when(singleLeaderBoardRepository.findByAccount(s2.getAccount())).thenReturn(s2);
        when(singleLeaderBoardRepository.findByAccount(s3.getAccount())).thenReturn(s3);

        when(singleLeaderBoardRepository.save(updateTemp)).thenReturn(updateTemp);

        //SingleLeaderBoard temp = singleApiLogicService.updateScore(updateTemp, "test2");

        assertEquals((Integer)899, updateTemp.getScore());
    }

    @Test
    public void readTest() {

        SingleLeaderBoard s1 = new SingleLeaderBoard((long)1,"test1", 300);

        when(singleLeaderBoardRepository.findByAccount(s1.getAccount())).thenReturn(s1);

        Integer temp = singleLogicService.showScore("test1");

        assertEquals((Integer)300, temp);
    }

    @Test
    public void readAllTest() {
        List<SingleLeaderBoard> list = new ArrayList<SingleLeaderBoard>();
        SingleLeaderBoard s1 = new SingleLeaderBoard((long)1,"test1", 300);
        SingleLeaderBoard s2 = new SingleLeaderBoard((long)1,"test2", 300);
        SingleLeaderBoard s3 = new SingleLeaderBoard((long)1,"test3", 300);

        list.add(s1);
        list.add(s2);
        list.add(s3);

        when(singleLeaderBoardRepository.findAll()).thenReturn(list);

        List<SingleLeaderBoard> tempList = singleLogicService.showAllScore();

        assertEquals(3, tempList.size());
        verify(singleLeaderBoardRepository, times(1)).findAll();
    }

}
