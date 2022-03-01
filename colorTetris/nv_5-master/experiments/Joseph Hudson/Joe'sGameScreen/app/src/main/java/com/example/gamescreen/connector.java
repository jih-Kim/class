package com.example.gamescreen;

import android.content.Context;
import android.graphics.Color;
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
     * 7 - left
     */
    private int position;
    private int x;
    private int y;
    private ImageView image;

    public connector(int pos, int x, int y, Context act, FrameLayout rel) {
        this.position = pos;
        this.x = x;
        this.y = y;
        this.image = new ImageView(act);
        //rel.addView(image, rel.getWidth() / 10 + 2, rel.getHeight() / 20 + 2);
        updateImage(rel);
    }

    private void updateImage(FrameLayout rel){

        switch (position) {
            case 0:
                image.setImageResource(R.drawable.connector0);
                break;
            case 1:
                image.setImageResource(R.drawable.connector1);
                break;
            case 2:
                image.setImageResource(R.drawable.connector2);
                break;
            case 3:
                image.setImageResource(R.drawable.connector3);
                break;
            case 4:
                image.setImageResource(R.drawable.connector4);
                break;
            case 5:
                image.setImageResource(R.drawable.connector5);
                break;
            case 6:
                image.setImageResource(R.drawable.connector6);
                break;
            case 7:
                image.setImageResource(R.drawable.connector7);
                break;
            default:
                break;
        }
        //TODO find out how to make the white background transparent so I can display the connectors
        image.setX(rel.getX() + 14 + ((x - 6) * rel.getWidth() / 10));
        image.setY(rel.getY() + 12 + ((18 - y) * rel.getHeight() / 20));
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


    public void rotateClockwise(int x, int y, FrameLayout rel) {
        this.x = x;
        this.y = y;
        position += 2;
        if (position > 7)
            position -= 7;
        updateImage(rel);
    }

    public void rotateCounterClockwise(int x, int y, FrameLayout rel) {
        this.x = x;
        this.y = y;
        position -= 2;
        if (position < 0)
            position += 7;
        updateImage(rel);
    }

    public void move(int x, int y, FrameLayout rel){
        this.x = x;
        this.y = y;
        updateImage(rel);
    }

    public void delete(FrameLayout rel) {
        rel.removeView(image);
    }
}
