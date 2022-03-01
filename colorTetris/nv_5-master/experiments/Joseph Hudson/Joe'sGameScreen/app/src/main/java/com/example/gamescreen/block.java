package com.example.gamescreen;

import android.content.Context;
import android.widget.FrameLayout;
import android.widget.ImageView;

public class block {

    private connector conn1;
    private connector conn2;
    private int x;
    private int y;
    private int color; //1 red, 2 blue, 3 yellow
    private ImageView image;


    public block(int x, int y, int color, int posConn1, int posConn2, Context act, FrameLayout rel) {
        this.x = x;
        this.y = y;
        this.color = color;
        conn1 = conn2 = null;
        image = new ImageView(act);

        switch (color) {
            case 1:
                image.setImageResource(R.drawable.redblock);
                break;
            case 2:
                image.setImageResource(R.drawable.blueblock);
                break;
            case 3:
                image.setImageResource(R.drawable.yellowblock);
                break;
            default:
                break;
        }
        rel.addView(image, rel.getWidth()/10+2, rel.getHeight()/20+2);
        updatePos(rel);
        this.conn1 = new connector(posConn1, x, y, act, rel);
        this.conn2 = new connector(posConn2, x, y, act, rel);
    }

    public block(int x, int y, int color, int posConn1, Context act, FrameLayout rel) {
        this.x = x;
        this.y = y;
        this.color = color;
        this.image = new ImageView(act);
        switch (color) {
            case 1:
                image.setImageResource(R.drawable.redblock);
                break;
            case 2:
                image.setImageResource(R.drawable.blueblock);
                break;
            case 3:
                image.setImageResource(R.drawable.yellowblock);
                break;
            default:
                break;
        }
        rel.addView(image, rel.getWidth()/10+2, rel.getHeight()/20+2);
        updatePos(rel);
        this.conn1 = new connector(posConn1, x, y, act, rel);
        this.conn2 = null;
    }

    private void updatePos(FrameLayout rel){
        image.setX(rel.getX()+14+((x-6)*rel.getWidth()/10));
        image.setY(rel.getY()+12+((18-y)*rel.getHeight()/20));
    }

    public connector getConn1() {
        return this.conn1;
    }

    public void delConn1(FrameLayout rel) {
        if (this.conn1 != null) {
            this.conn1.delete(rel);
            this.conn1 = null;
        }
    }

    public connector getConn2() {
        return this.conn2;
    }

    public void delConn2(FrameLayout rel) {
        if (this.conn2 != null) {
            this.conn2.delete(rel);
            this.conn2 = null;
        }
    }

    public int getColor() {
        return this.color;
    }

    public void setColor(int color) {
        if (color <= 4 && color > 0)
            this.color = color;
    }

    public int getX() {
        return this.x;
    }

    public void setX(int x) {
        this.x = x;
    }

    public int getY() {
        return this.y;
    }

    public void setY(int y) {
        this.y = y;
    }

    public void delete(FrameLayout rel) {
        if(conn1 != null)
            conn1.delete(rel);
        if(conn2 != null)
            conn2.delete(rel);
        rel.removeView(image);
    }

    public void shiftLeft(FrameLayout rel){
        this.x--;
        conn1.move(this.x, this.y, rel);
        if(conn2 != null)
            conn2.move(this.x, this.y, rel);
        updatePos(rel);
    }

    public void shiftRight(FrameLayout rel){
        this.x++;
        conn1.move(this.x, this.y, rel);
        if(conn2 != null)
            conn2.move(this.x, this.y, rel);
        updatePos(rel);
    }

    public void shiftDown(FrameLayout rel){
        this.y--;
        conn1.move(this.x, this.y, rel);
        if(conn2 != null)
            conn2.move(this.x, this.y, rel);
        updatePos(rel);
    }

    public void rotateClockwise(int x, int y, FrameLayout rel){
        this.x = x;
        this.y = y;
        conn1.rotateClockwise(this.x, this.y, rel);
        if(conn2 != null)
            conn2.rotateClockwise(this.x, this.y, rel);
        updatePos(rel);
    }

    public void rotateCounterClockwise(int x, int y, FrameLayout rel){
        this.x = x;
        this.y = y;
        conn1.rotateCounterClockwise(this.x, this.y, rel);
        if(conn2 != null)
            conn2.rotateCounterClockwise(this.x, this.y, rel);
        updatePos(rel);
    }

}
