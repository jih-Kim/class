package com.syntech.spurno.colortetris;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.RelativeLayout;
import android.widget.TextView;

/**
 * the main page is a collection of navigation button to setting login and single/multi player game mode
 */
public class MainActivity extends AppCompatActivity {
    Button button_single;
    Button button_signin;
    Button button_chat;
    Button button_friends;
    Button settings;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        button_single = (Button) findViewById(R.id.button2);
        settings = findViewById(R.id.settingsButton);
        TextView mainText = findViewById(R.id.textView);
        RelativeLayout mainScreen = findViewById(R.id.mainScreen);

        try {
            if (settingsActivity.getDarkMode()) {
                mainScreen.setBackgroundResource(R.color.black);
                mainText.setTextColor(getResources().getColor(R.color.white));
            }
        }
        catch(Exception e){}


        button_single.setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View view){
                Intent i = new Intent( MainActivity.this, singleplayer.class);
                startActivity(i);
            }
        });


        button_signin = (Button) findViewById(R.id.button4);

        button_signin.setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View view){
                Intent j = new Intent( MainActivity.this, login.class);
                startActivity(j);
            }
        });



        button_chat = (Button) findViewById(R.id.chat);

        button_chat.setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View view){
                Intent j = new Intent( MainActivity.this, chat.class);
                startActivity(j);
            }
        });

        button_friends = (Button) findViewById(R.id.friends);

        button_friends.setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View view){
                Intent j = new Intent( MainActivity.this, FriendActivity.class);
                startActivity(j);
            }
        });






        settings.setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View view){
                Intent k = new Intent( MainActivity.this, settingsActivity.class);
                startActivity(k);
            }
        });

    }
}

