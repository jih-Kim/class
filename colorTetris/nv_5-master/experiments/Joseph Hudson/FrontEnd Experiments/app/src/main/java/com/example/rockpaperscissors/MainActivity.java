package com.example.rockpaperscissors;

import android.os.Bundle;

import com.google.android.material.bottomnavigation.BottomNavigationView;

import androidx.appcompat.app.AppCompatActivity;
import androidx.navigation.NavController;
import androidx.navigation.Navigation;
import androidx.navigation.ui.AppBarConfiguration;
import androidx.navigation.ui.NavigationUI;

import android.view.View;
import android.widget.Button;

public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        BottomNavigationView navView = findViewById(R.id.nav_view);

        int P1hover = 0;
        int P2hover = 0;
        int P1choice = 0;
        int P2choice = 0;

        Button results = findViewById(R.id.resultsButton);
        Button reset = findViewById(R.id.resetButton);

        Button P1paper = findViewById(R.id.paperP1);
        Button P1rock = findViewById(R.id.rockP1);
        Button P1scissors = findViewById(R.id.scissorsP1);
        Button P1submit = findViewById(R.id.submitP1);

        Button P2paper = findViewById(R.id.paperP2);
        Button P2rock = findViewById(R.id.rockP2);
        Button P2scissors = findViewById(R.id.scissorsP2);
        Button P2submit = findViewById(R.id.submitP2);
        // Passing each menu ID as a set of Ids because each
        // menu should be considered as top level destinations.

        results.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {


            }
        });

        reset.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {


            }
        });

        P1paper.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {


            }
        });

        P1rock.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {


            }
        });

        P1scissors .setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {


            }
        });

        P1submit.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {


            }
        });

        P2paper.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {


            }
        });

        P2rock.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {


            }
        });

        P2scissors.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {


            }
        });

        P2submit.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {


            }
        });



        AppBarConfiguration appBarConfiguration = new AppBarConfiguration.Builder(
                R.id.navigation_results, R.id.navigation_Player1, R.id.navigation_P2)
                .build();
        NavController navController = Navigation.findNavController(this, R.id.nav_host_fragment);
        NavigationUI.setupActionBarWithNavController(this, navController, appBarConfiguration);
        NavigationUI.setupWithNavController(navView, navController);
    }

}
