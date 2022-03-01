package com.example.demoMaven.service.FriendService;

import com.example.demoMaven.model.entity.FriendEnity.Message;
import com.example.demoMaven.repository.FriendRepository.MessageRepository;
import com.example.demoMaven.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

/**
 * message Api Logic Service
 * @author Jihoo
 */
@Service
public class MessageApiLogicService {
    /**
     * Message Repository
     */
    @Autowired
    private MessageRepository messageRepository;
    /**
     * User Repository
     */
    @Autowired
    private UserRepository userRepository;

    /**
     * create method for message
     * @param request
     * @return Message
     */
    public Message create(Message request) {
        Message messageData = new Message();
        messageData.setReceiver(request.getReceiver());
        messageData.setSender(request.getSender());
        messageData.setMessage(request.getMessage());
        messageRepository.save(messageData);
        System.out.println("Succeed!");
        return messageData;
    }

    /**
     * read method for message
     * @param sender
     * @param receiver
     * @return ArrayList<Message>
     */
    public ArrayList<Message> read(String sender, String receiver) {
        Message message = new Message();
        List<Message> all = messageRepository.findAll();
        ArrayList<Message> result = new ArrayList<Message>();
        for(int i=0;i<all.size();i++)
        {
            if(all.get(i).getReceiver().equals(receiver)&&all.get(i).getSender().equals(sender))
                result.add(all.get(i));
        }
        System.out.println("Succeed!");
        return result;
    }

    /**
     * delete method for message
     * @param sender
     * @param receiver
     * @param message
     */
    public void delete(String sender, String receiver, String message){
        List<Message> all = messageRepository.findAll();
        Long deleteId = 0L;
        for(int i=0;i<all.size();i++)
        {
            if(all.get(i).getSender().equals(sender)&&all.get(i).getReceiver().equals(receiver)&&all.get(i).getMessage().equals(message))
                deleteId = all.get(i).getMessage_Id();
        }
        messageRepository.deleteById(deleteId);
    }
}
