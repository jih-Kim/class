package com.syntech.spurno.colortetris;

import androidx.appcompat.app.AppCompatActivity;
import androidx.constraintlayout.widget.ConstraintLayout;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import com.android.volley.AuthFailureError;
import com.android.volley.NetworkResponse;
import com.android.volley.Request;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.VolleyLog;
import com.android.volley.toolbox.HttpHeaderParser;
import com.android.volley.toolbox.JsonArrayRequest;
import com.android.volley.toolbox.JsonObjectRequest;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.UnsupportedEncodingException;
import java.util.HashMap;
import java.util.Map;
import java.util.Random;

/**
 * singleplayer class is a collection of navigational button to navigates to the leaderboard or the singleplayer game.
 */
public class singleplayer extends AppCompatActivity {
    Button button_generate;
    Button  button_request;
    Button button_high;
    private static int personal_high = 5;
    private static String world_high;
    public static final String TAG = "HELP";
    private TextView output;
    //RequestQueue queue = Volley.newRequestQueue(this);
    String url = "http://coms-309-nv-5.cs.iastate.edu:8181";
   // String url = "https://93d0bdeb-48c6-48cb-88ef-0b62d79b3add.mock.pstmn.io/endtest";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_singleplayer);
        final TextView output = (TextView) findViewById(R.id.text);
        ConstraintLayout singlePlayerScreen = findViewById(R.id.singlePlayerScreen);

        try {
            if (settingsActivity.getDarkMode()) {
                singlePlayerScreen.setBackgroundResource(R.color.black);
                output.setTextColor(getResources().getColor(R.color.white));
            }
        }
        catch(Exception e){}


        Button playButton = findViewById(R.id.playGameButton);
        playButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                JsonObjectRequest jsonObjectRequest = new JsonObjectRequest
                        (Request.Method.GET, url + "/api/single/score/" + login.getUsername(), null, new Response.Listener<JSONObject>() {

                            @Override
                            public void onResponse(JSONObject response) {
                                Log.d(TAG, response.toString());
                                output.setText(response.toString());
                                try {
                                    personal_high = response.getInt("score");
                                } catch (JSONException e) {
                                    e.printStackTrace();
                                }


                            }
                        }, new Response.ErrorListener() {

                            @Override
                            public void onErrorResponse(VolleyError error) {
                                VolleyLog.d(TAG, error.toString());
                            }
                        });
                SingletonRequestQueue.getInstance(singleplayer.this).addToRequestQueue(jsonObjectRequest);
                Intent game = new Intent(singleplayer.this, SingleplayerGameActivity.class);
                startActivity(game);
            }
        });

        button_request =(Button) findViewById(R.id.leader);
        button_request.setOnClickListener(new View.OnClickListener() {//request for world leaderboard
            @Override
            public void onClick(View view) {
                JsonArrayRequest jsonArrayRequest = new JsonArrayRequest
                        (Request.Method.GET, url+"/api/single/readAll", null, new Response.Listener<JSONArray>() {

                            @Override
                            public void onResponse(JSONArray response) {
                                String[] account = new String[99];
                                int[] score = new int[99];
                                try{
                                    for (int i=0;i<response.length();i++){
                                        JSONObject user = response.getJSONObject(i);
                                        account[i] = user.getString("account");
                                        score[i] = user.getInt("score");
                                    }
                                } catch (Exception e) {
                                    e.printStackTrace();
                                }
                                int n = response.length();
                                for (int i = 0; i < n-1; i++) {
                                    for (int j = 0; j < n - i - 1; j++) {
                                        if (score[j] < score[j + 1]) {
                                            int temp = score[j];
                                            String tempstring = account[j];
                                            score[j] = score[j + 1];
                                            account[j] = account[j + 1];
                                            score[j + 1] = temp;
                                            account[j + 1] = tempstring;
                                        }
                                    }
                                }
                                output.setText("");
                                for (int i=0;i<response.length() && i<5 ;i++){
                                    output.append(i+1 + ":" + account[i] + "  "+ score[i] +"\n" );
                                }
                            }
                        }, new Response.ErrorListener() {

                            @Override
                            public void onErrorResponse(VolleyError error) {
                                VolleyLog.d(TAG, error.toString());
                            }
                        });

// Access the RequestQueue through your singleton class.
                SingletonRequestQueue.getInstance(singleplayer.this).addToRequestQueue(jsonArrayRequest);
//                Intent leaderboard = new Intent( singleplayer.this, Leaderboard.class);
//                startActivity(leaderboard);
            }
        });



        button_high =(Button) findViewById(R.id.score);
        button_high.setOnClickListener(new View.OnClickListener() {//request for personal high
            @Override
            public void onClick(View view) {
                Intent score = new Intent(singleplayer.this, score.class);
                startActivity(score);
            }
        });

        button_generate = (Button) findViewById(R.id.gen);
        button_generate.setOnClickListener(new View.OnClickListener() {//send personal score
            @Override
            public void onClick(View view) {
                Random rand = new Random();
                int newscore = rand.nextInt(1000);
//                if(personal_high <= newscore){
//                    personal_high = newscore;
//                }
                System.out.print(newscore);
               // output.setText(//String.valueOf(personal_high) +
                        //login.getUsername());
                if(login.getSignedin()){
                JSONObject score = new JSONObject();
                try {
                    //score.put("userid", null);
                    //score.put("pw", null);
                    //score.put("name", null);
                     score.put("score", newscore);
                    // score.put("registered_at", null);
                    // score.put("unregistered_at", null);

                } catch (JSONException e) {
                }

                JsonObjectRequest jsonObjectRequest = new JsonObjectRequest
                        (Request.Method.PUT,
                                url +"/api/single/updateScore/" + login.getUsername()
                               //"http://httpbin.org/post"
                                , score, new Response.Listener<JSONObject>() {

                            @Override
                            public void onResponse(JSONObject response) {
                                output.setText("111");
                                Log.d(TAG, response.toString());
                                output.setText(response.toString());
                            }
                        }, new Response.ErrorListener() {

                             @Override
                            public void onErrorResponse(VolleyError error) {
                                VolleyLog.v(TAG, error.toString());
                                output.setText(error.toString());
                                NetworkResponse response = error.networkResponse;
                                if (response != null && response.statusCode == 404) {
                                    try {
                                        String res = new String(response.data,
                                                HttpHeaderParser.parseCharset(response.headers, "utf-8"));
                                        // Now you can use any deserializer to make sense of data
                                        JSONObject obj = new JSONObject(res);
                                        //use this json as you want
                                    } catch (UnsupportedEncodingException e1) {
                                        // Couldn't properly decode data to string
                                        e1.printStackTrace();
                                    } catch (JSONException e2) {
                                        // returned data is not JSONObject?
                                        e2.printStackTrace();
                                    }
                                }
                            }
                        }) {
                    @Override
                    public Map<String, String> getHeaders() throws AuthFailureError {
                        HashMap<String, String> headers = new HashMap<String, String>();
                        headers.put("Content-Type", "application/json");
                        return headers;
                    }
                };

//                       {
//                    @Override
//                    protected Map<String, String> getParams() {
//                        Map<String, String> params = new HashMap<String, String>();
//                        params.put("userid", null);
//                        params.put("pw", null);
//                        params.put("name", null);
//                        params.put("email", "Yourdata");
//                        params.put("registered_at", null);
//                        params.put("unregistered_at", null);
//                        return params;
//                    }
//                }

//
//                    @Override
//                    public Map<String, String> getHeaders() throws AuthFailureError {
//                        Map<String, String> params = new HashMap<String, String>();
//                        params.put("Content-Type", "application/x-www-form-urlencoded");
//                        return params;
//                    }
//                };

// Access the RequestQueue through your singleton class.
                SingletonRequestQueue.getInstance(singleplayer.this).addToRequestQueue(jsonObjectRequest);
            }
            }
        });



    }
    public static String getWorld_high(){
        return world_high;
    }
    public static int getPersonal_high(){
        return personal_high;
    }

}

