package com.example.myfirstexperiment;

import android.os.Bundle;
import android.widget.Button;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;

import java.util.HashMap;

//import android.support.v7.app.AppCompatActivity;

public class subActivity extends AppCompatActivity {

        TextView questionTextView;
        Button example1Button;
        Button example2Button;

        HashMap[] problems = {
                new HashMap() {{
                    put("Question", "1+1 = 2");
                    put("example1","O");
                    put("example2","X");
                }},
                new HashMap() {{
                    put("Question", "sun is circling the earth");
                    put("example1","O");
                    put("example2","X");
                }},
                new HashMap() {{
                    put("Question", "spider is insect");
                    put("example1","O");
                    put("example2","X");
                }},
                new HashMap() {{
                    put("Question", "water is H2O");
                    put("example1","O");
                    put("example2","X");
                }},
                new HashMap() {{
                    put("Question", "Snail have teeth");
                    put("example1","O");
                    put("example2","X");
                }},
                new HashMap() {{
                    put("Question", "fish can coughing");
                    put("example1","O");
                    put("example2","X");
                }},
                new HashMap() {{
                    put("Question", "tomato is fruit");
                    put("example1","O");
                    put("example2","X");
                }},
                new HashMap() {{
                    put("Question", "small octopus have three heart");
                    put("example1","O");
                    put("example2","X");
                }},
                new HashMap() {{
                    put("Question", "Romeo is older than Juliet(in Shakespeare's play");
                    put("example1","O");
                    put("example2","X");
                }},
                new HashMap() {{
                    put("Question", "Lion have bone in tongue");
                    put("example1","O");
                    put("example2","X");
                }}
        };

        int problemNumber = 1;
        String question = "";
        String answer = "";
        String example1 = "";
        String example2 = "";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_sub);

//        questionTextView = findViewById(R.id.questionTextView);
//        example1Button = findViewById(R.id.example1Button);
//        example2Button = findViewById(R.id.example2Button);

        question = (String)problems[problemNumber-1].get("question");
        answer = (String)problems[problemNumber-1].get("answer");
        example1 = (String)problems[problemNumber-1].get("example1");
        example2 = (String)problems[problemNumber-1].get("example2");

        questionTextView.setText(question);
        example1Button.setText(example1);
        example2Button.setText(example2);

    }
}
