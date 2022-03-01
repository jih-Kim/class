package com.example.randomblockgenerator;

import androidx.annotation.RequiresApi;
import androidx.appcompat.app.AppCompatActivity;

import android.content.Context;
import android.os.Build;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.GridLayout;
import android.widget.ImageView;
import android.widget.RelativeLayout;

public class MainActivity extends AppCompatActivity {
    gamePiece toMove;
    @RequiresApi(api = Build.VERSION_CODES.JELLY_BEAN)
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        toMove = null;
        setContentView(R.layout.activity_main);
        Button newBlockButton = findViewById(R.id.buttonNewBlock);
        final Context act = this.getApplication();
        final FrameLayout grid = (FrameLayout) findViewById(R.id.gameGrid);
        newBlockButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (toMove != null) {
                   toMove.delete(grid);
                }
                toMove = new gamePiece(act, grid);
            }
        });

    }
}

