package com.example.demoMaven.controller.api.WebSocketController;

import java.io.IOException;
import java.util.Hashtable;
import java.util.Map;

import javax.websocket.OnClose;
import javax.websocket.OnError;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.server.PathParam;
import javax.websocket.server.ServerEndpoint;

import com.example.demoMaven.model.entity.LeaderboardEnity.MultiLeaderBoard;
import com.example.demoMaven.repository.LeaderboardRepository.MultiLeaderBoardRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

/**
 * The class for Multi playing game by using WebSocket.
 * @author Dongwoo
 */
@ServerEndpoint("/multiWebSocket/{username}")
@Component
public class MultiGamesWebSocketServer {

    // Store all socket session and their corresponding username.
    private static Map<Session, String> sessionUsernameMap = new Hashtable<>();
    private static Map<String, Session> usernameSessionMap = new Hashtable<>();

    // show log whenever it need
    private final Logger logger = LoggerFactory.getLogger(MultiGamesWebSocketServer.class);

    // To save the score at leader board in real time
    private static MultiLeaderBoardRepository multiLeaderBoardRepository;

    // the interface for DI design pattern.
    private WebSocketBasic webSocketBasic;

    // For DI design pattern.
    private MultiGamesWebSocketServer() {
        webSocketBasic = new WebSocketDIPattern();
    }

    /**
     * To save the score at leader board in real time
     * Connect with multileaderboard table.
     * @param multiLeaderBoardRepository
     */
    @Autowired
    private void setDataToUser(MultiLeaderBoardRepository multiLeaderBoardRepository) {
        this.multiLeaderBoardRepository = multiLeaderBoardRepository;
    }

    /**
     * Call onOpen method in WebSocket Interface.
     * @param session
     * @param username
     * @throws IOException
     */
    @OnOpen
    public void onOpen(Session session, @PathParam("username") String username) throws IOException
    {
        webSocketBasic.onOpen(session, username, sessionUsernameMap, usernameSessionMap);
    }

    /**
     * send the score to opponent player
     * The format is "@username <score>"
     * @param session
     * @param message
     * @throws IOException
     */
    @OnMessage
    public void onMessage(Session session, String message) throws IOException
    {
        // Handle new messages
        logger.info("Entered into Message: Got Message:"+message);
        String username = sessionUsernameMap.get(session);

        String opponentAccount = message.split(" ")[0].substring(1);
        String scoreData = message.split(" ")[1];

        if (message.startsWith("@")) // Direct message to a user using the format "@username <message>"
        {

            MultiLeaderBoard multiLeaderBoard = multiLeaderBoardRepository.findByAccount(username);

            if(multiLeaderBoard != null) {
                if(multiLeaderBoard.getScore() <= Integer.parseInt(scoreData)) {
                    multiLeaderBoard.setScore(Integer.parseInt(scoreData));
                    multiLeaderBoardRepository.save(multiLeaderBoard);
                }
            } else {
                multiLeaderBoardRepository.save(new MultiLeaderBoard(username, scoreData));
            }
            sendData(opponentAccount, scoreData);
        }
        else //if there is some error.
        {
            sendData(username, "formatting error");
        }
    }

    /**
     * Call onClose method in WebSocket Interface.
     * @param session
     * @throws IOException
     */
    @OnClose
    public void onClose(Session session) throws IOException
    {
        webSocketBasic.onClose(session,sessionUsernameMap, usernameSessionMap);
    }

    /**
     * Call onError method in WebSocket interface.
     * @param session
     * @param throwable
     */
    @OnError
    public void onError(Session session, Throwable throwable)
    {
        webSocketBasic.onError(session, throwable);
    }

    /**
     * this is a help method to send data to the particular user.
     * @param username
     * @param message
     */
    private void sendData(String username, String message)
    {
        try {
            usernameSessionMap.get(username).getBasicRemote().sendText(message);
        } catch (IOException e) {
            logger.info("Exception: " + e.getMessage().toString());
            e.printStackTrace();
        }
    }
}