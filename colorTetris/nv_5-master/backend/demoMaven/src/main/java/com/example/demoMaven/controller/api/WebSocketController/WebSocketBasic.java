package com.example.demoMaven.controller.api.WebSocketController;

import javax.websocket.Session;
import javax.websocket.server.PathParam;
import java.io.IOException;
import java.util.Hashtable;
import java.util.Map;

/**
 * the interface for WebSocket
 * @author Dongwoo
 */
public interface WebSocketBasic {

    Map<Session, String> sessionUsernameMap = new Hashtable<>();
    Map<String, Session> usernameSessionMap = new Hashtable<>();

    /**
     * when a user get into WebSocket Session, this method will use.
     * @param session
     * @param username
     * @param sessionUsernameMap
     * @param usernameSessionMap
     * @throws IOException
     */
    public void onOpen(Session session, @PathParam("username") String username,
                       Map<Session, String> sessionUsernameMap, Map<String, Session> usernameSessionMap) throws IOException;

    /**
     * when a user get out WebSocket Session, this method will use.
     * @param session
     * @param sessionUsernameMap
     * @param usernameSessionMap
     * @throws IOException
     */
    public void onClose(Session session,  Map<Session, String> sessionUsernameMap, Map<String, Session> usernameSessionMap) throws IOException;

    /**
     * if there are some errors, it will use.
     * @param session
     * @param throwable
     */
    public void onError(Session session, Throwable throwable);

}
