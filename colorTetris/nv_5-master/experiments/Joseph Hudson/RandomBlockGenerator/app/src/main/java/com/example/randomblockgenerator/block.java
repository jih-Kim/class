package com.example.randomblockgenerator;

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
        //this.conn1 = new connector(posConn1, x, y, act);
        //this.conn2 = new connector(posConn2, x, y, act);
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
        rel.addView(image, rel.getWidth()/5+4, rel.getHeight()/5+4);
        image.setY(rel.getY()+(rel.getHeight()/5)+12-(y-1)*(rel.getHeight()/5));
        image.setX(rel.getX()-5*rel.getWidth()/5+50+(x-1)*(rel.getWidth()/5));
    }

    public block(int x, int y, int color, int posConn1, Context act, FrameLayout rel) {
        this.x = x;
        this.y = y;
        this.color = color;
        //this.conn1 = new connector(posConn1, x, y, act);
        this.conn2 = this.conn1 = null;
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
        rel.addView(image, rel.getWidth()/5+4, rel.getHeight()/5+4);
        image.setY(rel.getY()+(rel.getHeight()/5)+12-(y-1)*(rel.getHeight()/5));
        image.setX(rel.getX()-5*rel.getWidth()/5+50+(x-1)*(rel.getWidth()/5));
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

    public float getY() {
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
        //TODO interact with gameboard and remove the block's connector(s) and other block(s) connector(s)
    }
}
