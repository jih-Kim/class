package com.example.randomblockgenerator;

import android.content.Context;
import android.widget.FrameLayout;
import android.widget.RelativeLayout;

import java.util.Random;

public class gamePiece {
    private block b1;//Central Block, has 2 connectors
    private block b2;
    private block b3;
    private Context act;
    private RelativeLayout relativeLayout;

    public gamePiece(Context act, FrameLayout rel){
        this.act = act;
        Random r = new Random();
        int pieceType = r.nextInt(6);//produces a random number from 0 to 5
        int color1, color2, color3;
        color1 = r.nextInt(3)+1;//produces a number 1 to 3
        color2 = r.nextInt(3)+1;//produces a number 1 to 3
        color3 = r.nextInt(3)+1;//produces a number 1 to 3
        switch(pieceType){
            case 0:
                b1 = new block(3 ,3, color1, 7, 3, act, rel);
                b2 = new block(2 ,3, color2, 3, act, rel);
                b3 = new block(4 ,3, color3, 7, act, rel);
                break;
            case 1:
                b1 = new block(3 ,3, color1, 1, 3, act, rel);
                b2 = new block(3 ,4, color2, 5, act, rel);
                b3 = new block(4 ,3, color3, 7, act, rel);
                break;
            case 2:
                b1 = new block(3 ,3, color1, 0, 4, act, rel);
                b2 = new block(2 ,4, color2, 4, act, rel);
                b3 = new block(4 ,2, color3, 0, act, rel);
                break;
            case 3:
                b1 = new block(3 ,3, color1, 0, 3, act, rel);
                b2 = new block(2 ,4, color2, 4, act, rel);
                b3 = new block(4 ,3, color3, 7, act, rel);
                break;
            case 4:
                b1 = new block(3 ,3, color1, 0, 2, act, rel);
                b2 = new block(2 ,4, color2, 4, act, rel);
                b3 = new block(4 ,4, color3, 6, act, rel);
                break;
            case 5:
                b1 = new block(3 ,3, color1, 6, 3, act, rel);
                b2 = new block(2 ,2, color2, 2, act, rel);
                b3 = new block(4 ,3, color3, 7, act, rel);
                break;
            default: break;
        }
    }

    public void delete(FrameLayout rel){
        b1.delete(rel);
        b2.delete(rel);
        b3.delete(rel);
    }
}
