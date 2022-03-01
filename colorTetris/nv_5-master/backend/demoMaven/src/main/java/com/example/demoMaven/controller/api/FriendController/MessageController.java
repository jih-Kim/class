package com.example.demoMaven.controller.api.FriendController;


import com.example.demoMaven.model.entity.FriendEnity.Message;
import com.example.demoMaven.service.FriendService.MessageApiLogicService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;

/**
 * Controller for Message
 * @author Jihoo
 */
@Slf4j
@RestController
@RequestMapping("/api/message")
public class MessageController {

    /**
     * MessageApilogicService
     */
    @Autowired
    private MessageApiLogicService messageApiLogicService;

    /**
     * create method for message
     * @param request
     */
    @PostMapping("/create")
    public void create(@RequestBody Message request) {
        messageApiLogicService.create(request);
    }

    /**
     * read method for message
     * @param sender
     * @param receiver
     * @return ArrayList<Message>
     */
    @GetMapping("/{sender}/{receiver}/read")
    public ArrayList<Message> read(@PathVariable String sender, @PathVariable String receiver) {
        return messageApiLogicService.read(sender, receiver);
    }

    /**
     * delete method for message
     * @param sender
     * @param receiver
     * @param message
     */
    @DeleteMapping("/{sender}/{receiver}/{message}/delete")
    public void delete(@PathVariable String sender, @PathVariable String receiver, @PathVariable String message) {
        messageApiLogicService.delete(sender, receiver, message);
    }
}