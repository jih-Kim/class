package com.syntech.spurno.colortetris;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.TextView;

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
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class FriendActivity extends AppCompatActivity {
    static String friends;
    final String TAG = "HELP";
    ListView list;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_friend);
        String url = "http://coms-309-nv-5.cs.iastate.edu:8181";

        //final TextView friendlist = (TextView) findViewById(R.id.friendlist);

        JsonObjectRequest FriendlistRequest = new JsonObjectRequest
                (Request.Method.GET, url+"/api/friend/"+login.getUsername()+"/read", null, new Response.Listener<JSONObject>() {

                    @Override
                    public void onResponse(JSONObject response) {
                        Log.d(TAG, response.toString());
                        //friendlist.setText(response.toString());
                        try {
                            friends = response.getString("friends");
                        }
                        catch(JSONException e){
                            e.printStackTrace();
                        }

                    }
                }, new Response.ErrorListener() {

                    @Override
                    public void onErrorResponse(VolleyError error) {
                        VolleyLog.d(TAG, error.toString());
                    }
                });

        SingletonRequestQueue.getInstance(FriendActivity.this).addToRequestQueue(FriendlistRequest);

        list=(ListView) findViewById(R.id.frienditem);
        List<String> friendList = Arrays.asList(friends);


        ArrayAdapter<String> adapter = new ArrayAdapter<>(getBaseContext(), android.R.layout.simple_list_item_1,friendList);
        list.setAdapter(adapter);



    }
}
