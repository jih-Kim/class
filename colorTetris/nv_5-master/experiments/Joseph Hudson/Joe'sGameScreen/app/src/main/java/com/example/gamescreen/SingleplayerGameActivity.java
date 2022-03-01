package com.example.gamescreen;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Context;
import android.os.Bundle;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageButton;

public class SingleplayerGameActivity extends AppCompatActivity {

    block[][] gameBoard = new block[20][10];
    gamePiece active = null;
    gamePiece next;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.singleplayergame);

        ImageButton leftButton = findViewById(R.id.ShiftLeftButton);
        ImageButton rightButton = findViewById(R.id.ShiftRightButton);
        ImageButton downButton = findViewById(R.id.ShiftDownButton);
        ImageButton clockwiseButton = findViewById(R.id.ClockwiseRotateButton);
        ImageButton counterClockwiseButton = findViewById(R.id.CounterClockwiseRotateButton);

        final FrameLayout gameFrame = findViewById(R.id.gameFrame);
        final Context act = this.getApplication();

        rightButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(active != null)
                    active.shiftRight(gameBoard, gameFrame);
            }
        });

        leftButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(active != null)
                    active.shiftLeft(gameBoard, gameFrame);
            }
        });


        downButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (active == null) {
                    active = new gamePiece(act, gameFrame);
                }
                else if(active.shiftDown(gameBoard, gameFrame)==0)
                {
                    active.toBoard(gameBoard);
                    active = null;
                }
            }
        });

        clockwiseButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(active != null)
                    active.rotateClockwise(gameBoard, gameFrame);
            }
        });

        counterClockwiseButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(active != null)
                    active.rotateCounterClockwise(gameBoard, gameFrame);
            }
        });
    }
}
