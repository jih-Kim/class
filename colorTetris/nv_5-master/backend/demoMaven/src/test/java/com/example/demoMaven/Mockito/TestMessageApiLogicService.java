package com.example.demoMaven.Mockito;

import com.example.demoMaven.model.entity.FriendEnity.Message;
import com.example.demoMaven.repository.FriendRepository.MessageRepository;
import com.example.demoMaven.service.FriendService.MessageApiLogicService;
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
public class TestMessageApiLogicService {

    private MockMvc mockMvc;

    @InjectMocks
    private MessageApiLogicService messageApiLogicService;
    @Mock
    private MessageRepository messageRepository;

    @Before
    public void init() {
        MockitoAnnotations.initMocks(this);
    }

    @Test
    public void createTest() {
        Message message = new Message();
        message.setSender("sender");
        message.setReceiver("receiver");
        message.setMessage("message");
        message.setMessage_Id(1L);

        Message temp = messageApiLogicService.create(message);
        assertEquals((String)"sender",temp.getSender());
        assertEquals((String)"receiver",temp.getReceiver());
        assertEquals((String)"message",temp.getMessage());
    }

    //Test read
    @Test
    public void readTest() {
        List<Message> messageList = new ArrayList<Message>();
        Message message1 = new Message();
        Message message2 = new Message();
        Message message3 = new Message();
        message1.setMessage("Hello");
        message2.setMessage("How are you?");
        message3.setMessage("I'm fine");
        message1.setSender("test1");
        message2.setSender("test1");
        message3.setSender("test1");
        message1.setReceiver("test2");
        message2.setReceiver("test2");
        message3.setReceiver("test2");

        messageList.add(message1);
        messageList.add(message2);
        messageList.add(message3);

        when(messageRepository.findAll()).thenReturn(messageList);

        List<Message> mList = messageApiLogicService.read("test1","test2");

        assertEquals(3,mList.size());
        verify(messageRepository,times(1)).findAll();
    }

}
