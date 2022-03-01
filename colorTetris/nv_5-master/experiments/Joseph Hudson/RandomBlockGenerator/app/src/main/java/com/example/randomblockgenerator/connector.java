package com.example.randomblockgenerator;

import android.content.Context;
import android.widget.FrameLayout;
import android.widget.ImageView;

public class connector {

    /**
     * 0 - top left
     * 1 - top
     * 2 - top right
     * 3 - right
     * 4 - bottom right
     * 5 - bottom
     * 6 - bottom left
     * 7 - left*/
    private int position;
    private int x;
    private int y;
    private ImageView image;

    public connector(int pos, int x, int y, Context act, FrameLayout rel) {
        this.position = pos;
        this.x = x;
        this.y = y;
        this.image = new ImageView(act);
        switch(pos){
            case 0:
                image.setImageResource(R.drawable.conncetor);
                break;
            case 1:
                image.setImageResource(R.drawable.conncetor);
                break;
            case 2:
                image.setImageResource(R.drawable.conncetor);
                break;
            case 3:
                image.setImageResource(R.drawable.conncetor);
                break;
            case 4:
                image.setImageResource(R.drawable.conncetor);
                break;
            case 5:
                image.setImageResource(R.drawable.conncetor);
                break;
            case 6:
                image.setImageResource(R.drawable.conncetor);
                break;
            case 7:
                image.setImageResource(R.drawable.conncetor);
                break;
        }
    }

    public int getPosition() {
        return this.position;
    }

    public void setPosition(int pos) {
        this.position = pos;
    }

    public int getX() {
        return this.x;
    }

    public void setX(int x) {
        this.x = x;
    }

    public float getY() {
        return this.y;
    }

    public void setY(int y) {
        this.y = y;
    }


    public void clockWiseRotate() {
        position += 2;
        if (position > 7)
            position -= 7;
    }

    public void counterclockWiseRotate() {
        position -= 2;
        if (position < 0)
            position += 7;
    }

    public void delete(FrameLayout rel) {
        rel.removeView(image);
    }
}
