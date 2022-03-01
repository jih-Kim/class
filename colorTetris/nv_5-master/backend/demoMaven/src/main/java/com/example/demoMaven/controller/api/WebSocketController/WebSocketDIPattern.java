package com.example.demoMaven.controller.api.WebSocketController;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.websocket.Session;
import java.io.IOException;
import java.util.Map;

/**
 * the class which implements WebSocketBasic interface for DI design pattern
 * @author Dongwoo
 */
public class WebSocketDIPattern implements WebSocketBasic {

    // for log
    private final Logger logger = LoggerFactory.getLogger(MultiGamesWebSocketServer.class);

    /**
     * When a user enter the session, the method shows log.
     * @param session
     * @param username
     * @param sessionUsernameMap
     * @param usernameSessionMap
     * @throws IOException
     */
    @Override
    public void onOpen(Session session, String username, Map<Session, String> sessionUsernameMap, Map<String, Session> usernameSessionMap) throws IOException {

        logger.info("Entered into Open");

        sessionUsernameMap.put(session, username);
        usernameSessionMap.put(username, session);
    }

    /**
     * When a user get out the session, the method shows log.
     * @param session
     * @param sessionUsernameMap
     * @param usernameSessionMap
     * @throws IOException
     */
    @Override
    public void onClose(Session session, Map<Session, String> sessionUsernameMap, Map<String, Session> usernameSessionMap) throws IOException {
        logger.info("Entered into Close");

        String username = sessionUsernameMap.get(session);
        sessionUsernameMap.remove(session);
        usernameSessionMap.remove(username);
    }

    /**
     * If there are some error, it shows log.
     * @param session
     * @param throwable
     */
    @Override
    public void onError(Session session, Throwable throwable) {
        logger.info("Entered into Error");
    }
}
