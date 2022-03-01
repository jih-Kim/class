package com.experiment.myapplication;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;

public class MainActivity extends AppCompatActivity {
Button button_go;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        button_go = (Button) findViewById(R.id.buttonGo);

        button_go.setOnClickListener(new View.OnClickListener(){
            @Override
                    public void onClick(View view){
    Intent i = new Intent( MainActivity.this, SecondActivity.class);
    startActivity(i);
            }
        });
    }
}

