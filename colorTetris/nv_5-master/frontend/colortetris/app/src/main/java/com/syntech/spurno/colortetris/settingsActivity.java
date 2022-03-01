package com.syntech.spurno.colortetris;

import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.RadioButton;
import android.widget.CheckBox;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;
import androidx.constraintlayout.widget.ConstraintLayout;

public class settingsActivity extends AppCompatActivity {

    private static int speed;
    private static boolean allowRequests;
    private static boolean darkMode;

    public static int getSpeed(){
        return speed;
    }

    public static boolean getDarkMode(){
        return darkMode;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_settings);
        final CheckBox darkModeCheck = findViewById(R.id.darkModeCheckBox);
        final RadioButton slowSpeed = findViewById(R.id.slowRadioButton);
        final RadioButton moderateSpeed = findViewById(R.id.moderateRadioButton);
        final RadioButton fastSpeed = findViewById(R.id.fastRadioButton);
        TextView text = findViewById(R.id.textView3);
        Button cancel = findViewById(R.id.cancelButton);
        Button accept = findViewById(R.id.acceptButton);
        ConstraintLayout settingsScreen = findViewById(R.id.settingsScreen);
        try {
            if (darkMode) {
                settingsScreen.setBackgroundResource(R.color.black);
                text.setTextColor(getResources().getColor(R.color.white));
            }
        }
        catch(Exception e){}

        accept.setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View view){
                if(fastSpeed.isChecked())
                    speed = 3;
                else if(moderateSpeed.isChecked())
                    speed = 2;
                else
                    speed = 1;
                if (darkModeCheck.isChecked())
                    darkMode = true;
                else
                    darkMode = false;
                Intent j = new Intent( settingsActivity.this, MainActivity.class);
                startActivity(j);
            }
        });

        cancel.setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View view){
                Intent j = new Intent( settingsActivity.this, MainActivity.class);
                startActivity(j);
            }
        });
    }
}

