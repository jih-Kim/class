package com.syntech.spurno.colortetris;

import androidx.appcompat.app.AppCompatActivity;
import androidx.constraintlayout.widget.ConstraintLayout;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.widget.TextView;

import com.android.volley.Request;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.VolleyLog;
import com.android.volley.toolbox.JsonObjectRequest;

import org.json.JSONObject;

/**
 * score class is reading the value of personal_high from the singleplayer class and display it in a text box
 */
public class score extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        String url = "http://coms-309-nv-5.cs.iastate.edu:8181";
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_score);
        final TextView world_high = (TextView) findViewById(R.id.textView2);
        ConstraintLayout scoreScreen = findViewById(R.id.scoreScreen);
        if (login.getSignedin()){
            JsonObjectRequest jsonObjectRequest = new JsonObjectRequest
                    (Request.Method.GET, url + "/api/single/read/" + login.getUsername(), null, new Response.Listener<JSONObject>() {

                        @Override
                        public void onResponse(JSONObject response) {
                            world_high.setText(response.toString());
                        }
                    }, new Response.ErrorListener() {

                        @Override
                        public void onErrorResponse(VolleyError error) {

                        }
                    });

// Access the RequestQueue through your singleton class.
            SingletonRequestQueue.getInstance(score.this).addToRequestQueue(jsonObjectRequest);

        }

        try {
            if (settingsActivity.getDarkMode()) {
                scoreScreen.setBackgroundResource(R.color.black);
                world_high.setTextColor(getResources().getColor(R.color.white));
            }
        }
        catch(Exception e){}

    }
}
