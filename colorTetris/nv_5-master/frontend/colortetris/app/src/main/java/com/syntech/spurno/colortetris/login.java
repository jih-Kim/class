
package com.syntech.spurno.colortetris;

import androidx.appcompat.app.AppCompatActivity;
import androidx.constraintlayout.widget.ConstraintLayout;

import android.content.Intent;
import android.os.Bundle;
import android.text.Editable;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;

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

/**
 *  this class is the collection of user login and signin interface that communicates with the server
 */

public class login extends AppCompatActivity {


    private String user_name;
    private String pass_word;
    private static String username;
    private static Boolean signedin= true;
    public static final String TAG = "HELP";
    String url = "http://coms-309-nv-5.cs.iastate.edu:8181/api/user";
    //String url = "http://httpbin.org/post";
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);
        Button go = findViewById(R.id.button5);
        Button register = findViewById(R.id.button6);
        ConstraintLayout loginScreen = findViewById(R.id.loginScreen);

        try {
            if (settingsActivity.getDarkMode()) {
                loginScreen.setBackgroundResource(R.color.black);
            }
        }
        catch(Exception e){}


        /**
         * this go button is referred as sign in, it will send a user-typedin username and password and would wait for the server to give back a boolean value
         */
        go.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                final EditText user = findViewById(R.id.username);
                user_name = user.getText().toString();

                username=user_name;//need to be fixed


                final EditText password = findViewById(R.id.password);
                pass_word = user.getText().toString();

                JSONObject user_profile = new JSONObject();
                try{
                    user_profile.put("account",user_name);
                    user_profile.put("pw",pass_word);
                }
                catch(JSONException e){
                }


                JsonObjectRequest signinRequest = new JsonObjectRequest(Request.Method.POST, url+ "/checkPassword", user_profile, new Response.Listener<JSONObject>() {
                    @Override
                    public void onResponse(JSONObject response) {
                        Log.d(TAG, response.toString());
//                        if (response.toString()=="false"){
//                            String ErrorSignin = "something is wrong with the email or password";
//                            Log.d(TAG, ErrorSignin);
//                        }
//                        if (true){
                            username = user_name;
                            signedin = true;
                            Intent i = new Intent( login.this, MainActivity.class);
                            startActivity(i);
                            System.out.println(username+ "/" + user_name);

                       // }
                    }
                }, new Response.ErrorListener() {

                    @Override
                    public void onErrorResponse(VolleyError error) {
                        VolleyLog.v(TAG, error.toString());
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
                SingletonRequestQueue.getInstance(login.this).addToRequestQueue(signinRequest);
            }
        });
        /**
         * this register button is referred as sign up, it will send a user-typedin username and password and would wait for the server to give back a boolean value
         */
    register.setOnClickListener(new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            final EditText user = findViewById(R.id.username);
            user_name = user.getText().toString();

            username=user_name;//need to be fixed


            final EditText password = findViewById(R.id.password);
            pass_word = password.getText().toString();

            JSONObject user_profile = new JSONObject();
            try{
                user_profile.put("account",user_name);
                user_profile.put("pw",pass_word);
            }
            catch(JSONException e){
            }


            JsonObjectRequest signupRequest = new JsonObjectRequest(Request.Method.POST, url + "/create" , user_profile, new Response.Listener<JSONObject>() {
                @Override
                public void onResponse(JSONObject response) {
                    Log.d(TAG, response.toString());
                    if (response.toString()=="false"){
                        String ErrorSignup = "email already taken";
                        Log.d(TAG, ErrorSignup);
                    }
                    if (response.toString()=="true"){
                        username = user_name;
                        signedin = true;
                        Intent i = new Intent( login.this, MainActivity.class);
                        startActivity(i);
                    }
                    Intent i = new Intent( login.this, MainActivity.class);
                    startActivity(i);
                }
            }, new Response.ErrorListener() {

                @Override
                public void onErrorResponse(VolleyError error) {
                    VolleyLog.v(TAG, error.toString());
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
            SingletonRequestQueue.getInstance(login.this).addToRequestQueue(signupRequest);
        }
    });



    }

    public static String getUsername() {
        return username;
    }

    public static Boolean getSignedin() {
        return signedin;
    }
}

