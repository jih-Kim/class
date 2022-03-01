package com.syntech.spurno.colortetris;

import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageButton;
import android.graphics.Color;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;
import androidx.constraintlayout.widget.ConstraintLayout;

import com.android.volley.AuthFailureError;
import com.android.volley.NetworkResponse;
import com.android.volley.Request;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.VolleyLog;
import com.android.volley.toolbox.HttpHeaderParser;
import com.android.volley.toolbox.JsonObjectRequest;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.UnsupportedEncodingException;
import java.util.HashMap;
import java.util.Map;
import java.util.Timer;

/**
 * The game page that hosts the main produce of the application. Has buttons that moves gamePieces.
 */
public class SingleplayerGameActivity extends AppCompatActivity {

    private static int FAST_SPEED = 400;
    private static int MODERATE_SPEED = 600;
    private static int SLOW_SPEED = 900;

    block[][] gameBoard = new block[20][10];
    boolean[][] visited = new boolean[20][10];
    boolean[][] removable = new boolean[20][10];
    gamePiece active = null;
    Timer timer = new Timer();
    Handler gravityHandler = new Handler();
    Boolean hasLost;
    String url = "http://coms-309-nv-5.cs.iastate.edu:8181";
    int speed;
    int score;
    boolean speedChecked = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        score = 0;
        setContentView(R.layout.gamescreen);

        checkDarkMode();

        ImageButton leftButton = findViewById(R.id.ShiftLeftButton);
        ImageButton rightButton = findViewById(R.id.ShiftRightButton);
        ImageButton downButton = findViewById(R.id.ShiftDownButton);
        ImageButton clockwiseButton = findViewById(R.id.ClockwiseRotateButton);
        ImageButton counterClockwiseButton = findViewById(R.id.CounterClockwiseRotateButton);
        ImageButton menuButton = findViewById(R.id.menuButton);

        timer = new Timer();
        hasLost = false;

        final FrameLayout gameFrame = findViewById(R.id.gameFrame);
        final Context act = this.getApplication();

        final Runnable constGravity = new Runnable() {
            @Override
            public void run() {
                if (hasLost) {
//                    if(login.getSignedin()){
//                        JSONObject score = new JSONObject();
//                        try {
//                            //score.put("userid", null);
//                            //score.put("pw", null);
//                            //score.put("name", null);
//                            score.put("account", login.getUsername());
//                            score.put("score", score);
//                            // score.put("registered_at", null);
//                            // score.put("unregistered_at", null);
//
//                        } catch (JSONException e) {
//                        }
//
//                        JsonObjectRequest jsonObjectRequest = new JsonObjectRequest
//                                (Request.Method.POST,
//                                        url +"/api/single/updateScore/" + login.getUsername()
//                                        //"http://httpbin.org/post"
//                                        , score, new Response.Listener<JSONObject>() {
//
//                                    @Override
//                                    public void onResponse(JSONObject response) {
//                                    }
//                                }, new Response.ErrorListener() {
//
//                                    @Override
//                                    public void onErrorResponse(VolleyError error) {
//
//
//                                        NetworkResponse response = error.networkResponse;
//                                        if (response != null && response.statusCode == 404) {
//                                            try {
//                                                String res = new String(response.data,
//                                                        HttpHeaderParser.parseCharset(response.headers, "utf-8"));
//                                                // Now you can use any deserializer to make sense of data
//                                                JSONObject obj = new JSONObject(res);
//                                                //use this json as you want
//                                            } catch (UnsupportedEncodingException e1) {
//                                                // Couldn't properly decode data to string
//                                                e1.printStackTrace();
//                                            } catch (JSONException e2) {
//                                                // returned data is not JSONObject?
//                                                e2.printStackTrace();
//                                            }
//                                        }
//                                    }
//                                }) {
//                            @Override
//                            public Map<String, String> getHeaders() throws AuthFailureError {
//                                HashMap<String, String> headers = new HashMap<String, String>();
//                                headers.put("Content-Type", "application/json");
//                                return headers;
//                            }
//                        };
//
////                       {
////
//                        SingletonRequestQueue.getInstance(SingleplayerGameActivity.this).addToRequestQueue(jsonObjectRequest);
//                    }
//                    Intent j = new Intent( SingleplayerGameActivity.this, score.class);
//                    startActivity(j);
                } else if (active == null) {
                    active = new gamePiece(act, gameFrame);
                    if (active.hasLost(gameBoard)) {
                        hasLost = true;
                    }
                } else if (active.shiftDown(gameBoard, gameFrame) == 0) {
                    active.toBoard(gameBoard);
                    active.removeConnectors();
                    active = null;
                }
                if (!hasLost) {
                    gravityHandler.postDelayed(this, speed);
                    checkRemoval(gameFrame);
                    updateScore();
                } else
                    gravityHandler.removeCallbacks(this);
            }
        };

        menuButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent i = new Intent(SingleplayerGameActivity.this, singleplayer.class);
                startActivity(i);
            }
        });

        rightButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (!hasLost)
                    if (active != null)
                        active.shiftRight(gameBoard, gameFrame);
            }
        });

        leftButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (!hasLost)
                    if (active != null)
                        active.shiftLeft(gameBoard, gameFrame);
            }
        });

        downButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (!speedChecked)
                    setSpeed();
                gravityHandler.removeCallbacks(constGravity);//Need to reset the timer for the shiftdown
                constGravity.run();//Then restart and cause an instant shift
            }
        });

        clockwiseButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (!hasLost)
                    if (active != null)
                        active.rotateClockwise(gameBoard, gameFrame);
            }
        });

        counterClockwiseButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (!hasLost)
                    if (active != null)
                        active.rotateCounterClockwise(gameBoard, gameFrame);
            }
        });
    }

    /**
     * updates the text view for score to the current score
     */
    public void updateScore() {
        TextView scoreText = findViewById(R.id.scoreText);
        scoreText.setText("Score: " + score);
    }

    /**
     * Checks if blocks are removable, it does this by initializing two boolean arrays
     * (Presets all null blocks to visited.) and then running a DFS on every 'unvisited' block
     * that only checks unvisited same color blocks, if any DFS reaches 5 or more blocks, it shall
     * run another DFS at the same block and set all valid blocks to removable.
     * Also updates score
     * @param gameFrame the gameFrame in which the blocks that are to be removed can remove
     *                  their images from
     */
    public void checkRemoval(FrameLayout gameFrame) {
        for (int x = 0; x < 10; x++) {
            for (int y = 0; y < 20; y++) {
                if (gameBoard[y][x] == null)
                    visited[y][x] = true;
                else
                    visited[y][x] = false;
                removable[y][x] = false;
            }
        }

        int clusterSize;

        for (int x = 0; x < 10; x++) {
            for (int y = 0; y < 20; y++) {
                if (!visited[y][x]) {
                    clusterSize = visit(x, y, gameBoard[y][x].getColor(), 0);
                    if (clusterSize >= 5) {
                        setRemovable(x, y, gameBoard[y][x].getColor());
                        score += (clusterSize * (clusterSize - 4) * 25);
                    }
                }
            }
        }
        blockRemoval(gameFrame);
    }

    /**
     * Sets the visited state of the block to visited, this prevents rechecking the same block
     * which would cause indefinite loops
     * The DFS for checking the quantity of color clusters. checks directly left, up, right, and down
     * will only visit those blocks if they're unvisited and the same color as the search
     * @param x the x coord of the block to be visited
     * @param y the y coord of the block to be visited
     * @param color the color of the search
     * @param connected the counter of how many blocks are connected
     * @return how many blocks it was able to reach from its DFS + its parents connections
     */
    public int visit(int x, int y, int color, int connected) {
        //0 left, 1 up, 2 right, 3 down
        int ret = connected + 1;
        int checkX, checkY;
        visited[y][x] = true;
        for (int i = 0; i < 4; i++) {
            if (i == 0) {
                checkX = x - 1;
                checkY = y;
            } else if (i == 1) {
                checkX = x;
                checkY = y + 1;
            } else if (i == 2) {
                checkX = x + 1;
                checkY = y;
            } else {
                checkX = x;
                checkY = y - 1;
            }
            if (checkX >= 0 && checkX < 10 && checkY >= 0 && checkY < 20) {
                if (!visited[checkY][checkX])
                    if (color == gameBoard[checkY][checkX].getColor()) {
                        ret = visit(checkX, checkY, color, ret);
                    }
            }
        }
        return ret;
    }

    /**
     * Runs a DFS that sets the removable state of the blocks to true, only visits blocks adjacent
     * to it, not removable, and the same color
     * @param x the x coord of the current block
     * @param y the y coord of the current block
     * @param color  the color of blocks met to be set to removable
     */
    public void setRemovable(int x, int y, int color) {
        //0 left, 1 up, 2 right, 3 down
        int checkX, checkY;
        removable[y][x] = true;
        for (int i = 0; i < 4; i++) {
            if (i == 0) {
                checkX = x - 1;
                checkY = y;
            } else if (i == 1) {
                checkX = x;
                checkY = y + 1;
            } else if (i == 2) {
                checkX = x + 1;
                checkY = y;
            } else {
                checkX = x;
                checkY = y - 1;
            }
            if (checkX >= 0 && checkX < 10 && checkY >= 0 && checkY < 20)
                if (gameBoard[checkY][checkX] != null)
                    if (!removable[checkY][checkX])
                        if (color == gameBoard[checkY][checkX].getColor())
                            setRemovable(checkX, checkY, color);
        }
    }

    /**
     * Goes through every value in the removable array and then removes all blocks marked as
     * removable. then checks gravity if blocks need to shift downwards
     * @param gameFrame the FrameLayout to remove the block images from.
     */
    public void blockRemoval(FrameLayout gameFrame) {
        for (int x = 0; x < 10; x++) {
            for (int y = 0; y < 20; y++) {
                if (removable[y][x]) {
                    gameBoard[y][x].delete(gameFrame);
                    gameBoard[y][x] = null;
                }
            }
        }
        gravityCheck(gameFrame);
    }

    /**
     * Runs the recursive gravityCheck method, and if that moves any blocks, checks if any blocks
     * are removable.
     * @param gameFrame the Framelayout to update block images from
     */
    private void gravityCheck(FrameLayout gameFrame) {
        if (gravityCheckRepeatable(gameFrame))
            checkRemoval(gameFrame);
    }

    /**
     * A recursive method. Checks starting at y = 1 (as all blocks at y = 0 are on the ground)
     * if blocks can be shifted down (the block below it is null) and then shifts it down if so.
     * calls the block to then update its image
     * @param gameFrame The FrameLayout to update block image locations
     * @return true if any blocks were moved, false otherwise
     */
    private boolean gravityCheckRepeatable(FrameLayout gameFrame) {
        boolean hasMoved = false;
        for (int x = 0; x < 10; x++) {
            for (int y = 1; y < 20; y++) {
                if (gameBoard[y][x] != null && gameBoard[y - 1][x] == null) {
                    hasMoved = true;
                    gameBoard[y][x].shiftDown(gameFrame);
                    gameBoard[y - 1][x] = gameBoard[y][x];
                    gameBoard[y][x] = null;
                }
            }
        }
        if (hasMoved) {
            gravityCheckRepeatable(gameFrame);
        }
        return hasMoved;
    }

    /**
     * Updates the constant gravity speed based upon settings
     */
    private void setSpeed() {
        speedChecked = true;
        try {
            int speedCheck = settingsActivity.getSpeed();
            if (speedCheck == 3)
                speed = FAST_SPEED;
            else if (speedCheck == 2)
                speed = MODERATE_SPEED;
            else
                speed = SLOW_SPEED;
            return;
        } catch (Exception e) {
            speed = SLOW_SPEED;
        }
    }

    /**
     * Checks if darkmode is enabled in settings, and then change the display if that is the case.
     */
    private void checkDarkMode() {
        ConstraintLayout screen = findViewById(R.id.Screen);
        try {
            if (settingsActivity.getDarkMode())
                screen.setBackgroundResource(R.color.black);
            else
                screen.setBackgroundResource(R.color.white);
        } catch (Exception e) {
            screen.setBackgroundResource(R.color.white);
        }
    }
    private int getscore(){
       return score;
    }
}
